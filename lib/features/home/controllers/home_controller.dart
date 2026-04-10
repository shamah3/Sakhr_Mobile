import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bytore/core/services/api_service.dart';
import 'package:bytore/features/product/models/product_model.dart';
import 'package:bytore/core/controllers/app_controller.dart';

class HomeController extends GetxController {
  final ApiService _apiService = ApiService();
  
  var allProducts = <Product>[].obs;
  var filteredProducts = <Product>[].obs;
  var advertisements = <dynamic>[].obs;
  var discountedProducts = <Product>[].obs;
  var isLoading = true.obs;
  var carouselIndex = 0.obs;
  
  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
    fetchAds();
  }

  Future<void> fetchAds() async {
    try {
      final ads = await _apiService.fetchAdvertisements();
      if (ads.isNotEmpty) {
        advertisements.assignAll(ads.map((e) => e.toJson()).toList());
        
        // Notify about new offers
        final appController = Get.find<AppController>();
        appController.addNotification(
          title: "عروض مذهلة بانتظارك!",
          body: "اكتشف أحدث العروض والخصومات الحصرية اليوم في متجر صخر.",
          category: "العروض",
          color: Colors.orange,
        );
      } else {
        // Fallback Ads (Activation)
        _addFallbackAds();
      }
    } catch (e) {
      debugPrint("Error fetching ads: $e");
      _addFallbackAds();
    }
  }

  void _addFallbackAds() {
    advertisements.assignAll([
      {
        'title': 'عروض الصيف',
        'subtitle': 'خصومات تصل إلى 50% على جميع الإلكترونيات',
        'image_url': 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?q=80&w=1780&auto=format&fit=crop',
      },
      {
        'title': 'الأطقم المكتبية',
        'subtitle': 'جدد مكتبك مع أحدث الطابعات والملحقات',
        'image_url': 'https://images.unsplash.com/photo-1491933382434-50028639c527?q=80&w=1964&auto=format&fit=crop',
      },
    ]);
  }

  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      final products = await _apiService.fetchProducts();
      allProducts.assignAll(products);
      _updateDiscountedProducts();
      applyFilters();
    } catch (e) {
      Get.snackbar("خطأ", "فشل تحميل المنتجات");
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
      allProducts.assignAll(products); // Temporarily replace allProducts with search results
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
      // Search match (Name, Description, Brand, Category)
      final matchesSearch = query.isEmpty || 
          p.name.toLowerCase().contains(query) || 
          p.description.toLowerCase().contains(query) ||
          p.brandName.toLowerCase().contains(query) ||
          p.storeName.toLowerCase().contains(query);
          
      // Price match
      final matchesPrice = p.price >= appController.priceRange.value.start && 
                           p.price <= appController.priceRange.value.end;
                           
      // Category match (Strict)
      final matchesCategory = appController.activeCategory.value == "الكل" || 
                              p.category == appController.activeCategory.value;
                              
      // Brand match (Strict)
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
      
      // Warranty match (Contains)
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
