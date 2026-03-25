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
      advertisements.assignAll(ads);
    } catch (e) {
      debugPrint("Error fetching ads: $e");
    }
  }

  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      final products = await _apiService.fetchProducts();
      allProducts.assignAll(products);
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
