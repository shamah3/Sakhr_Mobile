import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bytore/core/services/api_service.dart';
import 'package:bytore/data/local_products.dart'; // 🔥 استيراد المنتجات المحلية
import 'package:bytore/features/home/models/coupon_model.dart';
import 'package:bytore/features/product/models/product_model.dart';
import 'package:bytore/core/controllers/app_controller.dart';
import 'package:bytore/features/stores/models/advertisement_model.dart';
import 'package:bytore/features/profile/controllers/activities_controller.dart';

class HomeController extends GetxController {
  final ApiService _apiService = ApiService();
  
  var allProducts = <Product>[].obs;
  var local3DProductsList = <Product>[].obs; // 🔥 قائمة خاصة بالمنتجات المحلية ثلاثية الأبعاد
  var topSellingProducts = <Product>[].obs; // 🔥 منتجات الأكثر مبيعاً
  var filteredProducts = <Product>[].obs;
  var advertisements = <AdvertisementModel>[].obs;
  var coupons = <CouponModel>[].obs;
  var discountedProducts = <Product>[].obs; // 🔥 المنتجات التي عليها خصم
  var isLoading = true.obs;
  var isCouponsLoading = true.obs; // 🔥 حالة تحميل مستقلة للخصومات
  var carouselIndex = 0.obs;
  var statusMessage = "جاري التحقق من الاتصال...".obs;
  var connectionStatus = 0.obs; // 0: checking, 1: online, 2: offline
  
  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
    fetchTopSellingProducts(); // 🔥 جلب الأكثر مبيعاً
    fetchAds();
    fetchCoupons();

    // سجل النشاط: زيارة الصفحة الرئيسية
    try {
      if (Get.isRegistered<ActivitiesController>()) {
        Get.find<ActivitiesController>().logActivity(
          title: "زيارة الصفحة الرئيسية",
          type: "visit"
        );
      }
    } catch (e) {
      debugPrint("Activity Log Error: $e");
    }
  }

  Future<void> fetchCoupons() async {
    try {
      isCouponsLoading.value = true;
      final fetchedCoupons = await _apiService.fetchCoupons();
      
      if (fetchedCoupons.isNotEmpty) {
        coupons.assignAll(fetchedCoupons);
        debugPrint("🏠 HOME: Loaded ${fetchedCoupons.length} Admin Coupons");
      } else {
        debugPrint("🏠 HOME: No coupons found in admin/discounts API.");
        coupons.clear();
      }
    } catch (e) {
      debugPrint("🏠 HOME COUPONS ERROR: $e");
    } finally {
      isCouponsLoading.value = false;
    }
  }

  Future<void> fetchAds() async {
    try {
      final ads = await _apiService.fetchAdvertisements();
      if (ads.isNotEmpty) {
        advertisements.assignAll(ads);
      } else {
        debugPrint("🏠 HOME: No ads found in API. Using 1 default banner.");
        advertisements.assignAll([
          AdvertisementModel(
            id: 0,
            storeId: 0,
            title: "مرحباً بكم في سيليكون",
            description: "اكتشف أفضل العروض الإلكترونية",
            image: "https://img.freepik.com/free-vector/gradient-sale-background_23-2148934477.jpg",
          )
        ]);
      }
    } catch (e) {
      debugPrint("🏠 HOME ADS ERROR: $e");
    }
  }

  Future<void> fetchTopSellingProducts() async {
    try {
      final products = await _apiService.fetchTopSellingProducts();
      if (products.isNotEmpty) {
        topSellingProducts.assignAll(products);
        debugPrint("🏠 HOME: Loaded ${products.length} Top Selling Products");
      }
    } catch (e) {
      debugPrint("🏠 HOME TOP SELLING ERROR: $e");
    }
  }

  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      statusMessage.value = "جاري الاتصال بـ ${ApiService.baseUrl}...";
      
      final appController = Get.find<AppController>();
      final token = appController.token.value;
      
      List<Product> products;
      try {
        products = await _apiService.fetchProducts(token: token.isEmpty ? null : token);
      } catch (e) {
        // Fallback for Emulator if first IP fails
        if (e.toString().contains("SocketException") || e.toString().contains("timeout")) {
           statusMessage.value = "فشل 192.. جاري تجربة عنوان المحاكي 10.0.2.2...";
           // Manual override for this request
           const emulatorIp = "10.0.2.2:8000";
           final emulatorUrl = "http://$emulatorIp/api/v1/products";
           final response = await http.get(Uri.parse(emulatorUrl)).timeout(const Duration(seconds: 10));
           if (response.statusCode == 200) {
              final decoded = jsonDecode(response.body);
              final rawList = decoded is Map ? (decoded['data'] ?? []) : [];
              products = (rawList as List).map((p) => Product.fromJson(p)).toList();
              statusMessage.value = "تم الاتصال بنجاح عبر عنوان المحاكي!";
           } else {
             throw "خطأ في كلا العنوانين. 192 (فشل) و 10.0 (كود ${response.statusCode})";
           }
        } else {
          rethrow;
        }
      }
      
      if (products.isNotEmpty) {
        allProducts.assignAll(products);
        
        // 🔥 دمج المنتجات المحلية مع منتجات السيرفر لجعلها قابلة للبحث
        allProducts.addAll(local3DProducts);
        local3DProductsList.assignAll(local3DProducts); // حفظ نسخة منفصلة للعرض الخاص
        
        connectionStatus.value = 1; // Online
        statusMessage.value = "متصل بنجاح: ${allProducts.length} منتج";
        _updateDiscountedProducts();
        applyFilters();
      } else {
        // 🔥 حتى لو السيرفر فارغ، نظهر المنتجات المحلية
        allProducts.assignAll(local3DProducts);
        local3DProductsList.assignAll(local3DProducts);
        
        connectionStatus.value = 1; // Online (Local only)
        statusMessage.value = "متصل (محلي فقط): ${allProducts.length} منتج";
        _updateDiscountedProducts();
        applyFilters();
      }
    } catch (e) {
      connectionStatus.value = 2; // Offline
      statusMessage.value = "⚠️ فشل فني: $e";
      debugPrint("🏠 HOME ERROR: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      fetchProducts();
      return;
    }
    
    try {
      isLoading.value = true;
      final products = await _apiService.fetchProducts(search: query);
      allProducts.assignAll(products); 
      applyFilters();
    } catch (e) {
      debugPrint("Search error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilters() {
    final appController = Get.find<AppController>();
    final query = searchController.text.toLowerCase();
    
    var results = allProducts.where((p) {
      // Search match
      final matchesSearch = query.isEmpty || 
          p.name.toLowerCase().contains(query) || 
          p.description.toLowerCase().contains(query) ||
          p.brandName.toLowerCase().contains(query) ||
          p.storeName.toLowerCase().contains(query);
          
      // Price match
      final matchesPrice = p.price >= appController.priceRange.value.start && 
                           p.price <= appController.priceRange.value.end;
                           
      // Category match
      final matchesCategory = appController.activeCategory.value == "الكل" || 
                              p.category == appController.activeCategory.value;
                              
      // Brand match
      final matchesBrand = appController.selectedBrand.value == "الكل" || 
                           p.brandName == appController.selectedBrand.value;
                           
      // Availability match
      bool matchesAvailability = true;
      if (appController.selectedAvailability.value != "الكل") {
        if (appController.selectedAvailability.value == "متوفر") {
          matchesAvailability = p.stock > 0 && p.status != "On Shipment";
        } else if (appController.selectedAvailability.value == "غير متوفر") {
          matchesAvailability = p.stock == 0 || p.status == "Out of Stock";
        } else if (appController.selectedAvailability.value == "قيد الشحن") {
          matchesAvailability = p.status == "On Shipment";
        }
      }
      
      // Warranty match
      final matchesWarranty = appController.warrantyText.value == "الكل" || 
                              appController.warrantyText.value.isEmpty ||
                              p.warranty == appController.warrantyText.value;

      // Region match
      final matchesRegion = appController.selectedRegion.value == "الكل" || 
                            p.region == appController.selectedRegion.value;
      
      return matchesSearch && matchesPrice && matchesCategory && matchesBrand && matchesAvailability && matchesWarranty && matchesRegion;
    }).toList();
    
    filteredProducts.assignAll(results);
  }

  void _updateDiscountedProducts() {
    discountedProducts.assignAll(
      allProducts.where((p) => p.oldPrice > p.price).toList()
    );
  }

  void updateCarouselIndex(int index) {
    carouselIndex.value = index;
  }

  bool isFilterActive() {
    final appController = Get.find<AppController>();
    return searchController.text.isNotEmpty || 
           appController.activeCategory.value != "الكل" ||
           appController.selectedBrand.value != "الكل" ||
           appController.selectedAvailability.value != "الكل";
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
