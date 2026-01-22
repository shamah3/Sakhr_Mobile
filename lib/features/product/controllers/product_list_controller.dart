import 'package:get/get.dart';
import 'package:bytore/features/product/models/product_model.dart';
import 'package:bytore/core/services/api_service.dart';

class ProductListController extends GetxController {
  final ApiService _apiService = ApiService();

  final RxString categorySlug = "all".obs;
  final RxString categoryTitle = "المنتجات".obs;
  final RxString subCategorySlug = "all".obs;
  
  final RxList<Product> products = <Product>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSearching = false.obs;
  final RxString searchText = "".obs;

  ProductListController({String? initialSlug, String? initialTitle}) {
    if (initialSlug != null) categorySlug.value = initialSlug;
    if (initialTitle != null) categoryTitle.value = initialTitle;
  }

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    isLoading.value = true;
    try {
      final result = await _apiService.fetchProducts(categorySlug: categorySlug.value);
      products.assignAll(result);
    } catch (e) {
      Get.snackbar("خطأ", "فشل تحميل المنتجات");
    } finally {
      isLoading.value = false;
    }
  }

  void updateCategory(String slug, String title) {
    categorySlug.value = slug;
    categoryTitle.value = title;
    subCategorySlug.value = "all";
    fetchProducts();
  }

  void updateSubCategory(String slug) {
    subCategorySlug.value = slug;
    // For now, we just update slugs, but real filtering would happen here or in fetch
  }

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) searchText.value = "";
  }

  void updateSearch(String value) {
    searchText.value = value;
  }

  List<Product> get filteredProducts {
    if (searchText.value.isEmpty) return products;
    return products.where((p) => 
      p.name.toLowerCase().contains(searchText.value.toLowerCase()) ||
      p.description.toLowerCase().contains(searchText.value.toLowerCase())
    ).toList();
  }
}
