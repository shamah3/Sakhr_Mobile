import 'package:get/get.dart';
import 'package:bytore/data/category_data.dart';
import 'package:bytore/features/product/views/product_list_view.dart';

class CategoriesController extends GetxController {
  var selectedCategoryIndex = 0.obs;

  // متغيرات البحث التفاعلي
  var isSearchActive = false.obs;
  var searchText = "".obs;

  // الحصول على القسم الحالي المختار
  Map<String, dynamic> get currentCategory => CategoryData.categories[selectedCategoryIndex.value];

  void selectCategory(int index) {
    selectedCategoryIndex.value = index;
    searchText.value = ""; // تصفير البحث عند الانتقال لقسم جديد
  }

  // تفعيل/إلغاء شريط البحث
  void toggleSearch() {
    isSearchActive.value = !isSearchActive.value;
    if (!isSearchActive.value) searchText.value = "";
  }

  // فلترة الأقسام الفرعية بناءً على نص البحث
  List getFilteredSubCategories() {
    final List subs = currentCategory['subcategories'] as List? ?? [];
    if (searchText.isEmpty) return subs;
    return subs.where((sub) =>
        sub['name'].toString().toLowerCase().contains(searchText.value.toLowerCase())
    ).toList();
  }

  void navigateToProducts(String title, String slug) {
    Get.to(() => ProductListView(categoryTitle: title, apiCategorySlug: slug));
  }
}