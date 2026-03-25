import 'package:get/get.dart';
import 'package:bytore/core/services/api_service.dart';
import 'package:bytore/core/routes/app_routes.dart';

class CategoriesController extends GetxController {
  final ApiService _apiService = ApiService();
  
  var selectedCategoryIndex = 0.obs;
  var isLoading = true.obs;
  var apiCategories = <dynamic>[].obs;

  // متغيرات البحث التفاعلي
  var isSearchActive = false.obs;
  var searchText = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  void fetchCategories() async {
    isLoading.value = true;
    final List<dynamic> data = await _apiService.getCategories();
    
    // إضافة قسم "الكل" في البداية مع بيانات الـ API
    if (data.isNotEmpty) {
      apiCategories.assignAll([
        {
          'id': 'all',
          'name': 'الكل',
          'slug': 'all',
          'image': 'https://images.unsplash.com/photo-1498049794561-7780e7231661?q=80&w=1000',
          'subcategories': []
        },
        ...data
      ]);
    } else {
      apiCategories.assignAll([]);
    }
    isLoading.value = false;
  }

  // الحصول على القسم الحالي المختار
  Map<String, dynamic> get currentCategory {
    if (apiCategories.isEmpty) return {};
    if (selectedCategoryIndex.value >= apiCategories.length) return {};
    return apiCategories[selectedCategoryIndex.value] as Map<String, dynamic>;
  }

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
    final cat = currentCategory;
    final List subs = cat['subcategories'] as List? ?? [];
    if (searchText.isEmpty) return subs;
    return subs.where((sub) =>
        (sub['name'] ?? "").toString().toLowerCase().contains(searchText.value.toLowerCase())
    ).toList();
  }

  void navigateToProducts(String title, String slug) {
    // استخدام id: 2 لضمان البقاء داخل الـ Nested Navigator الخاص بالأقسام (وبالتالي ظهور الشريط السفلي)
    Get.toNamed(AppRoutes.PRODUCT_LIST, arguments: {'categoryTitle': title, 'apiCategorySlug': slug}, id: 2);
  }
}