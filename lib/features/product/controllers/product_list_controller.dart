import 'package:get/get.dart';
import 'package:bytore/features/product/models/product_model.dart';
import 'package:bytore/core/services/api_service.dart';
import 'package:bytore/features/stores/models/advertisement_model.dart';
import 'package:flutter/foundation.dart';

class ProductListController extends GetxController {
  final ApiService _apiService = ApiService();

  final RxString categorySlug = "all".obs;
  final RxString categoryTitle = "المنتجات".obs;
  final RxString subCategorySlug = "all".obs;
  final RxInt? storeId = RxInt(0).obs.value == 0 ? null : 0.obs; // Workaround for optional RxInt
  final RxnInt rxStoreId = RxnInt();
  
  final RxList<Product> products = <Product>[].obs;
  final RxList<AdvertisementModel> advertisements = <AdvertisementModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSearching = false.obs;
  final RxString searchText = "".obs;

  ProductListController({String? initialSlug, String? initialTitle, int? initialStoreId}) {
    if (initialSlug != null) categorySlug.value = initialSlug;
    if (initialTitle != null) categoryTitle.value = initialTitle;
    if (initialStoreId != null) rxStoreId.value = initialStoreId;
  }

  @override
  void onInit() {
    super.onInit();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    await Future.wait([
      fetchProducts(),
      if (rxStoreId.value != null) fetchStoreAds(),
    ]);
  }

  Future<void> fetchProducts() async {
    isLoading.value = true;
    try {
      final result = await _apiService.fetchProducts(
        categorySlug: categorySlug.value,
        storeId: rxStoreId.value,
        search: searchText.value.isEmpty ? null : searchText.value,
      );
      products.assignAll(result);
    } catch (e) {
      debugPrint("Error fetching products: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchStoreAds() async {
    if (rxStoreId.value == null) return;
    try {
      final ads = await _apiService.fetchStoreAdvertisements(rxStoreId.value!);
      advertisements.assignAll(ads);
    } catch (e) {
      debugPrint("Error fetching store ads: $e");
    }
  }

  void updateCategory(String slug, String title) {
    categorySlug.value = slug;
    categoryTitle.value = title;
    subCategorySlug.value = "all";
    searchText.value = ""; // Reset search when changing category
    fetchProducts();
  }

  void updateSubCategory(String slug) {
    subCategorySlug.value = slug;
  }

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      searchText.value = "";
      fetchProducts(); // Refresh list when clearing search
    }
  }

  void updateSearch(String value) {
    searchText.value = value;
  }

  void performSearch() {
    fetchProducts();
  }

  List<Product> get filteredProducts {
    if (searchText.value.isEmpty) return products;
    return products.where((p) => 
      p.name.toLowerCase().contains(searchText.value.toLowerCase()) ||
      p.description.toLowerCase().contains(searchText.value.toLowerCase())
    ).toList();
  }
}
