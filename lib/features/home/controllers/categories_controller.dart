import 'package:flutter/foundation.dart';
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
          'image_url': 'https://plus.unsplash.com/premium_photo-1679079456083-9f288e224e96?q=80&w=2070&auto=format&fit=crop', // صورة احترافية للأجهزة الإلكترونية
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

    // 1. معالجة الصور
    cat['image_url'] = _fixImageUrl(cat['image_url'] ?? cat['image']);
    cat['icon_url'] = _fixImageUrl(cat['icon_url'] ?? cat['icon_path']);

    // 2. توحيد مفتاح الأبناء (children / subcategories / sub_categories)
    List<dynamic> rawChildren = cat['children'] ?? 
                                cat['sub_categories'] ?? 
                                cat['subcategories'] ?? 
                                cat['sub_sections'] ?? 
                                cat['child_categories'] ?? 
                                [];
    cat['children'] = rawChildren.map((child) => _processCategory(child)).toList();

    // 3. معالجة الماركات والتحقق من علامة is_brand
    cat['is_brand'] = cat['is_brand'] == 1 || cat['is_brand'] == true || cat['is_brand'] == "1";

    List<dynamic> rawBrands = cat['brands'] ?? [];
    // إذا كان أحد الأبناء يمثل ماركة، نضيفه لقائمة الماركات أيضاً للسهولة
    for (var child in rawChildren) {
      if (child is Map && (child['is_brand'] == 1 || child['is_brand'] == true || child['is_brand'] == "1")) {
        rawBrands.add(child);
      }
    }

    cat['brands'] = rawBrands.map((brand) {
      if (brand is Map) {
         Map<String, dynamic> b = Map<String, dynamic>.from(brand);
         b['brand_logo_url'] = _fixImageUrl(b['brand_logo_url'] ?? b['logo_url'] ?? b['image_url'] ?? b['image']);
         return b;
      }
      return brand;
    }).toList();

    return cat;
  }

  String _fixImageUrl(dynamic url) {
    if (url == null || url.toString().isEmpty) return "";
    String fixedUrl = url.toString().trim();
    
    // استبدال localhost بالعنوان الصحيح
    fixedUrl = fixedUrl.replaceAll("http://localhost:8000", ApiService.serverUrl)
                        .replaceAll("http://127.0.0.1:8000", ApiService.serverUrl)
                        .replaceAll("localhost:8000", ApiService.serverUrl)
                        .replaceAll("127.0.0.1:8000", ApiService.serverUrl)
                        .replaceAll("localhost", ApiService.baseIp)
                        .replaceAll("127.0.0.1", ApiService.baseIp);

    if (!fixedUrl.startsWith("http")) {
      String cleanPath = fixedUrl.startsWith('/') ? fixedUrl.substring(1) : fixedUrl;
      
      if (cleanPath.startsWith("upload/") || cleanPath.startsWith("storage/")) {
        fixedUrl = "${ApiService.serverUrl}/$cleanPath";
      } else {
        fixedUrl = "${ApiService.storageUrl}/$cleanPath";
      }
    }
    return fixedUrl;
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
        
        // ماركات القسم الرئيسي مباشرة
        final List mainBrands = mainCat['brands'] as List? ?? [];
        for (var b in mainBrands) {
          String name = b['name']?.toString() ?? "";
          if (!seenBrands.contains(name)) {
            brands.add(b);
            seenBrands.add(name);
          }
        }

        // ماركات الأقسام الفرعية
        final List children = mainCat['children'] as List? ?? [];
        for (var sub in children) {
          final List subBrands = sub['brands'] as List? ?? [];
          for (var b in subBrands) {
            String name = b['name']?.toString() ?? "";
            if (!seenBrands.contains(name)) {
              brands.add(b);
              seenBrands.add(name);
            }
          }
        }
      }
    } else {
       // logic for single category brands can be added here or kept in view
       // For consistency with current view implementation, we'll keep it simple
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