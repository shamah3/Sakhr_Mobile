import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bytore/core/services/api_service.dart';
import 'package:bytore/core/routes/app_routes.dart';
import 'package:bytore/features/product/models/product_model.dart';

class CategoriesController extends GetxController {
  final ApiService _apiService = ApiService();
  
  var selectedCategoryIndex = 0.obs;
  var isLoading = true.obs;
  var isProductsLoading = false.obs;
  var apiCategories = <dynamic>[].obs;
  var products = <Product>[].obs;

  // Filter State
  var priceRange = const RangeValues(0, 500000).obs; // Adjusted max for easier interaction
  var selectedBrands = <int>{}.obs; // Back to int for API compatibility
  var showOnlyInStock = false.obs;
  var sortBy = "الأحدث".obs; // الأحدث، السعر: من الأقل، السعر: من الأعلى

  // متغيرات البحث التفاعلي
  var isSearchActive = false.obs;
  var searchText = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories().then((_) => fetchFilteredProducts());
  }

  Future<void> fetchCategories() async {
    isLoading.value = true;
    try {
      final List<dynamic> data = await _apiService.getCategories();
      
      debugPrint("📦 CONTROLLER DATA RECEIVED: ${data.length} items");

      // وظيفة لمعالجة الروابط بشكل متكرر
      List<dynamic> processedData = data.map((cat) => _processCategory(cat)).toList();

      // إنشاء قائمة أساسية تحتوي على "الكل" لضمان عدم بقاء الشاشة فارغة
      final List<dynamic> fullList = [
        {
          'id': 'all',
          'name': 'الكل',
          'slug': 'all',
          'image_url': 'https://images.unsplash.com/photo-1542491509-1e0d4474776f?q=80&w=2070&auto=format&fit=crop', // صورة احترافية تشمل تصنيفات متعددة
          'children': [],
          'brands': []
        }
      ];

      if (processedData.isNotEmpty) {
        debugPrint("🟢 SUCCESS: DATA MERGED WITH API RESULTS");
        fullList.addAll(processedData);
        apiCategories.assignAll(fullList);
      } else {
        debugPrint("⚠️ WARNING: API RETURNED EMPTY DATA, ONLY SHOWING 'ALL'");
        apiCategories.assignAll(fullList);
      }
    } catch (e) {
      debugPrint("🔥 CONTROLLER FETCH ERROR: $e");
      // حتى في حالة الخطأ، أظهر "الكل" لنعلم أن الكود يعمل
      apiCategories.assignAll([
        {
          'id': 'all',
          'name': 'الكل',
          'slug': 'all',
          'image_url': 'https://plus.unsplash.com/premium_photo-1679079456083-9f288e224e96?q=80&w=2070&auto=format&fit=crop',
          'children': [],
          'brands': []
        }
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  // معالجة بيانات القسم (تعديل الروابط وتوحيد المفاتيح)
  Map<String, dynamic> _processCategory(dynamic catJson) {
    if (catJson is! Map) return {};
    Map<String, dynamic> cat = Map<String, dynamic>.from(catJson);

    // 1. معالجة الصور باستخدام المحرك الموحد في ApiService
    cat['image_url'] = ApiService.fixImageUrl(
      cat['image_url'] ?? 
      cat['image'] ?? 
      cat['category_image'] ?? 
      cat['path'] ?? 
      cat['original_url']
    );
    cat['icon_url'] = ApiService.fixImageUrl(
      cat['icon_url'] ?? 
      cat['icon_path'] ?? 
      cat['icon'] ?? 
      cat['logo'] ?? 
      cat['logo_url']
    );

    // 2. توحيد مفتاح الأبناء
    List<dynamic> rawChildren = cat['children'] ?? 
                                cat['sub_categories'] ?? 
                                cat['subcategories'] ?? 
                                cat['sub_sections'] ?? 
                                cat['child_categories'] ?? 
                                [];
    cat['children'] = rawChildren.map((child) => _processCategory(child)).toList();

    // 3. معالجة الماركات
    cat['is_brand'] = cat['is_brand'] == 1 || cat['is_brand'] == true || cat['is_brand'] == "1";

    List<dynamic> rawBrands = cat['brands'] ?? [];
    for (var child in rawChildren) {
      if (child is Map && (child['is_brand'] == 1 || child['is_brand'] == true || child['is_brand'] == "1")) {
        rawBrands.add(child);
      }
    }

    cat['brands'] = rawBrands.map((brand) {
      if (brand is Map) {
         Map<String, dynamic> b = Map<String, dynamic>.from(brand);
         b['brand_logo_url'] = ApiService.fixImageUrl(b['brand_logo_url'] ?? b['logo_url'] ?? b['image_url'] ?? b['image']);
         return b;
      }
      return brand;
    }).toList();

    return cat;
  }

  // الحصول على القسم الحالي المختار
  Map<String, dynamic> get currentCategory {
    if (apiCategories.isEmpty) return {};
    if (selectedCategoryIndex.value >= apiCategories.length) return {};
    return apiCategories[selectedCategoryIndex.value] as Map<String, dynamic>;
  }

  void selectCategory(int index) {
    if (selectedCategoryIndex.value == index) return;
    
    selectedCategoryIndex.value = index;
    searchText.value = "";
    selectedBrands.clear();
    
    // Reset local filters when switching major categories
    priceRange.value = const RangeValues(0, 500000);
    showOnlyInStock.value = false;
    
    fetchFilteredProducts();
  }

  // Filter Actions
  void updatePriceRange(RangeValues range) {
    priceRange.value = range;
    fetchFilteredProducts();
  }

  void toggleBrand(int brandId) {
    if (selectedBrands.contains(brandId)) {
      selectedBrands.remove(brandId);
    } else {
      selectedBrands.clear(); 
      selectedBrands.add(brandId);
    }
    fetchFilteredProducts();
  }

  void toggleStockFilter(bool value) {
    showOnlyInStock.value = value;
    fetchFilteredProducts();
  }

  void updateSort(String value) {
    sortBy.value = value;
    fetchFilteredProducts();
  }

  Future<void> fetchFilteredProducts() async {
    isProductsLoading.value = true;
    try {
      final category = currentCategory;
      String? slug = category['slug'] == 'all' ? null : category['slug'];

      final allProducts = await _apiService.fetchProducts(
        categorySlug: slug,
        categoryId: category['id'] is int ? category['id'] : null,
        brandId: selectedBrands.isNotEmpty ? selectedBrands.first : null,
        search: searchText.value.isEmpty ? null : searchText.value,
      );

      // تطبيق الفلترة المحلية (السعر، الماركة، التوفر)
      var filtered = allProducts.where((p) {
        bool matchesPrice = p.price >= priceRange.value.start && p.price <= priceRange.value.end;
        
        // Match brand name by looking up the name of the selected brand ID
        bool matchesBrand = true;
        if (selectedBrands.isNotEmpty) {
           final selectedId = selectedBrands.first;
           final allBrands = getAggregatedBrands();
           final brandMap = allBrands.firstWhere(
             (b) => int.tryParse(b['id']?.toString() ?? "") == selectedId,
             orElse: () => null
           );
           if (brandMap != null) {
             String name = brandMap['name']?.toString() ?? "";
             matchesBrand = p.brandName.toLowerCase() == name.toLowerCase();
           }
        }

        bool matchesStock = !showOnlyInStock.value || p.stock > 0;
        return matchesPrice && matchesBrand && matchesStock;
      }).toList();

      // تطبيق الترتيب
      if (sortBy.value == "السعر: من الأقل") {
        filtered.sort((a, b) => a.price.compareTo(b.price));
      } else if (sortBy.value == "السعر: من الأعلى") {
        filtered.sort((a, b) => b.price.compareTo(a.price));
      }

      products.assignAll(filtered);
    } catch (e) {
      debugPrint("🔥 Error fetching filtered products: $e");
    } finally {
      isProductsLoading.value = false;
    }
  }

  // تفعيل/إلغاء شريط البحث
  void toggleSearch() {
    isSearchActive.value = !isSearchActive.value;
    if (!isSearchActive.value) {
      searchText.value = "";
      fetchFilteredProducts();
    }
  }

  void onSearchChanged(String value) {
    searchText.value = value;
    fetchFilteredProducts();
  }

  // فلترة الأقسام الفرعية بناءً على نص البحث (وتجاهل الماركات)
  List getFilteredSubCategories() {
    final cat = currentCategory;
    List allSubs = [];
    
    if (cat['id'] == 'all') {
      // تجميع كافة الأقسام الفرعية من جميع الأقسام الرئيسية (بدون الماركات)
      Set<String> seenNames = {};
      for (var mainCat in apiCategories) {
        if (mainCat['id'] == 'all') continue;
        final List children = mainCat['children'] as List? ?? [];
        for (var sub in children) {
          if (sub['is_brand'] != true) {
            String name = sub['name']?.toString() ?? "";
            if (!seenNames.contains(name)) {
              allSubs.add(sub);
              seenNames.add(name);
            }
          }
        }
      }
    } else {
      allSubs = cat['children'] as List? ?? [];
    }
    
    // فلترة الأقسام التي ليست ماركات (للحالات الفردية)
    final List subs = allSubs.where((s) => s['is_brand'] != true).toList();

    if (searchText.isEmpty) return subs;
    return subs.where((sub) =>
        (sub['name'] ?? "").toString().toLowerCase().contains(searchText.value.toLowerCase())
    ).toList();
  }

  // تجميع كافة الماركات من الأقسام المفلترة أو من الكل
  List getAggregatedBrands() {
    final cat = currentCategory;
    List brands = [];
    Set<String> seenBrands = {};

    if (cat['id'] == 'all') {
      // تجميع الماركات من كل مكان
      for (var mainCat in apiCategories) {
        if (mainCat['id'] == 'all') continue;
        
        final List mainBrands = mainCat['brands'] as List? ?? [];
        for (var b in mainBrands) {
          String name = (b['name'] ?? "").toString();
          if (!seenBrands.contains(name)) {
            brands.add(b);
            seenBrands.add(name);
          }
        }
      }
    } else {
      // ماركات القسم الحالي المختار فقط
      final List currentBrands = cat['brands'] as List? ?? [];
      for (var b in currentBrands) {
        brands.add(b);
      }
    }
    
    if (searchText.isEmpty) return brands;
    return brands.where((b) =>
        (b['name'] ?? "").toString().toLowerCase().contains(searchText.value.toLowerCase())
    ).toList();
  }

  void navigateToProducts(String title, String slug) {
    // استخدام id: 2 لضمان البقاء داخل الـ Nested Navigator الخاص بالأقسام (وبالتالي ظهور الشريط السفلي)
    Get.toNamed(AppRoutes.PRODUCT_LIST, arguments: {'categoryTitle': title, 'apiCategorySlug': slug}, id: 2);
  }
}