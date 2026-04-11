import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bytore/core/services/api_service.dart';
import 'package:bytore/features/home/models/coupon_model.dart';
import 'package:bytore/features/product/models/product_model.dart';
import 'package:bytore/core/controllers/app_controller.dart';
import 'package:bytore/features/stores/models/advertisement_model.dart';

class HomeController extends GetxController {
  final ApiService _apiService = ApiService();
  
  var allProducts = <Product>[].obs;
  var topSellingProducts = <Product>[].obs; // 🔥 منتجات الأكثر مبيعاً
  var filteredProducts = <Product>[].obs;
  var advertisements = <AdvertisementModel>[].obs;
  var coupons = <CouponModel>[].obs;
  var discountedProducts = <Product>[].obs; // 🔥 المنتجات التي عليها خصم
  var isLoading = true.obs;
  var isCouponsLoading = true.obs; // 🔥 حالة تحميل مستقلة للخصومات
  var carouselIndex = 0.obs;
  
  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
    fetchTopSellingProducts(); // 🔥 جلب الأكثر مبيعاً
    fetchAds();
    fetchCoupons();
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
      final appController = Get.find<AppController>();
      final token = appController.token.value;
      
      final products = await _apiService.fetchProducts(token: token.isEmpty ? null : token);
      allProducts.assignAll(products);
      
      _updateDiscountedProducts();
      applyFilters();
    } catch (e) {
      debugPrint("🏠 HOME ERROR: $e");
      String errorMsg = "فشل تحميل المنتجات. ";
      if (e.toString().contains("SocketException")) {
        errorMsg += "تأكد من اتصالك بالسيرفر (192.168.8.196)";
      } else if (e.toString().contains("FormatException")) {
        errorMsg += "خطأ في معالجة البيانات من السيرفر";
      } else {
        errorMsg += "يرجى المحاولة لاحقاً";
      }
      Get.snackbar("خطأ في البيانات", errorMsg, 
          snackPosition: SnackPosition.BOTTOM, 
          backgroundColor: Colors.red.withOpacity(0.8), 
          colorText: Colors.white);
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
      final matchesWarranty = appController.warrantyText.value.isEmpty ||
                              p.warranty.contains(appController.warrantyText.value);
      
      return matchesSearch && matchesPrice && matchesCategory && matchesBrand && matchesAvailability && matchesWarranty;
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
