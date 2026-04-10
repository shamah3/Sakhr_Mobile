import 'package:get/get.dart';
import 'package:bytore/features/product/models/product_model.dart';
import 'package:bytore/core/services/api_service.dart';

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
  }

  Future<void> fetchSearchResults() async {
    try {
      isLoading.value = true;
      final results = await _apiService.fetchProducts();
      products.value = results;
      _applyLocalFiltering();
    } catch (e) {
      Get.snackbar("خطأ", "فشل تحميل نتائج البحث");
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
    searchQuery.value = query;
    _applyLocalFiltering();
  }
}
