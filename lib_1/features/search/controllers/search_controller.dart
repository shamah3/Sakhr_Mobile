import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bytore/features/product/models/product_model.dart';
import 'package:bytore/core/services/api_service.dart';
import 'package:bytore/data/local_products.dart';
import 'package:bytore/features/profile/controllers/activities_controller.dart';

class SearchController extends GetxController {
  final String initialQuery;
  SearchController({required this.initialQuery});

  final ApiService _apiService = ApiService();
  
  var searchQuery = "".obs;
  var isLoading = true.obs;
  var products = <Product>[].obs;
  var filteredProducts = <Product>[].obs;
  
  var selectedFilter = 'الكل'.obs;
  final List<String> filters = ['الكل', 'لابتوبات', 'شاشات', 'معالجات', 'ملحقات'];

  @override
  void onInit() {
    super.onInit();
    searchQuery.value = initialQuery;
    fetchSearchResults();
    
    // سجل النشاط: البحث الأول
    if (initialQuery.isNotEmpty) {
      _logSearchActivity(initialQuery);
    }
  }

  void _logSearchActivity(String query) {
     try {
      if (Get.isRegistered<ActivitiesController>()) {
        Get.find<ActivitiesController>().logActivity(
          title: "البحث عن: $query",
          type: "search"
        );
      }
    } catch (e) {
      debugPrint("Activity Log Error: $e");
    }
  }

  Future<void> fetchSearchResults() async {
    try {
      isLoading.value = true;
      final results = await _apiService.fetchProducts();
      
      // 🔥 دمج المنتجات المحلية مع نتائج البحث القادمة من السيرفر
      products.assignAll(results);
      products.addAll(local3DProducts);
      
      _applyLocalFiltering();
    } catch (e) {
      // حتى لو فشل السيرفر، نظهر المنتجات المحلية
      products.assignAll(local3DProducts);
      _applyLocalFiltering();
      debugPrint("Search error (showing local only): $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _applyLocalFiltering() {
    // Basic mock filtering logic based on title/category
    if (selectedFilter.value == 'الكل') {
      filteredProducts.value = products.where((p) => 
        p.name.toLowerCase().contains(searchQuery.value.toLowerCase())
      ).toList();
    } else {
       // Mock category filtering since API might not support it directly in this call
       filteredProducts.value = products.where((p) => 
        p.name.toLowerCase().contains(searchQuery.value.toLowerCase()) &&
        p.name.toLowerCase().contains(selectedFilter.value.toLowerCase())
      ).toList();
    }
  }

  void updateFilter(String filter) {
    selectedFilter.value = filter;
    _applyLocalFiltering();
  }

  void updateSearchQuery(String query) {
    if (query == searchQuery.value) return;
    searchQuery.value = query;
    _applyLocalFiltering();
    
    // سجل النشاط عند توقف المستخدم عن الكتابة (تبسيطاً حالياً عند الاستدعاء)
    if (query.length > 2) {
      _logSearchActivity(query);
    }
  }
}
