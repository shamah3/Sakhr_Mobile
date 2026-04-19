import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bytore/features/product/models/product_model.dart';
import 'package:bytore/core/services/api_service.dart';
import 'package:bytore/features/profile/models/review_model.dart';
import 'package:bytore/core/controllers/app_controller.dart';
import 'package:bytore/features/profile/controllers/activities_controller.dart';
import 'package:bytore/features/home/controllers/home_controller.dart';

class ProductController extends GetxController {
  final Rx<Product> product;
  final ApiService _apiService = ApiService();
  var isRefreshing = false.obs;
  var isFetchingReviews = false.obs;
  var reviews = <ReviewModel>[].obs;
  var similarProducts = <Product>[].obs; // 🔥 منتجات مشابهة
  
  ProductController({required Product product}) : product = product.obs;

  var quantity = 1.obs;
  var currentImageIndex = 0.obs;
  final PageController pageController = PageController();
  
  var selectedColor = Rxn<Map<String, dynamic>>();
  var selectedSize = Rxn<Map<String, dynamic>>();
  var displayImageUrl = "".obs;
  var overriddenPrice = Rxn<double>();
  var show3DModel = false.obs;

  void toggle3DModel() {
    show3DModel.value = !show3DModel.value;
  }

  @override
  void onInit() {
    super.onInit();
    _initializeStates();
    refreshProduct();
    fetchReviews();
    _fetchSimilarProducts();

    // سجل النشاط: مشاهدة المنتج
    try {
      if (Get.isRegistered<ActivitiesController>()) {
        Get.find<ActivitiesController>().logActivity(
          title: "مشاهدة منتج: ${product.value.name}",
          type: "view"
        );
      }
    } catch (e) {
      debugPrint("Activity Log Error: $e");
    }
  }

  void _initializeStates() {
    displayImageUrl.value = product.value.imageUrl;
    show3DModel.value = product.value.threeDModel != null && product.value.threeDModel!.isNotEmpty;
    
    if (product.value.colors.isNotEmpty) {
      selectedColor.value = product.value.colors[0];
      displayImageUrl.value = selectedColor.value!['image'] ?? product.value.imageUrl;
      overriddenPrice.value = double.tryParse(selectedColor.value!['price']?.toString() ?? "");
    }
    
    if (product.value.sizes.isNotEmpty) {
      selectedSize.value = product.value.sizes[0];
      if (overriddenPrice.value == null) {
        overriddenPrice.value = double.tryParse(selectedSize.value!['price']?.toString() ?? "");
      }
    }
  }

  Future<void> refreshProduct() async {
    isRefreshing.value = true;
    try {
      final appController = Get.find<AppController>();
      final token = appController.token.value;
      
      final updatedProduct = await _apiService.fetchProductDetail(
        product.value.id,
        token: token.isEmpty ? null : token,
      );
      if (updatedProduct != null) {
        product.value = updatedProduct;
        _initializeStates();
      }
    } catch (e) {
      debugPrint("Error refreshing product info: $e");
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<void> fetchReviews() async {
    try {
      isFetchingReviews.value = true;
      final fetched = await _apiService.fetchProductReviews(product.value.id);
      
      // ✅ إضافة 3 تعليقات نموذجية للمعاينة (Social Proof)
      final List<ReviewModel> samples = [
        ReviewModel(
          id: -1, 
          productName: product.value.name, 
          userName: "أحمد الهادي", 
          date: "منذ يومين", 
          rating: 5, 
          comment: "منتج ممتاز جداً وجودة التصنيع خيالية، أنصح به بشدة."
        ),
        ReviewModel(
          id: -2, 
          productName: product.value.name, 
          userName: "سارة المنصور", 
          date: "منذ أسبوع", 
          rating: 4, 
          comment: "التوصيل كان سريع جداً والمنتج مطابق للوصف تماماً. تجربة شراء ممتازة."
        ),
        ReviewModel(
          id: -3, 
          productName: product.value.name, 
          userName: "محمد علي", 
          date: "الشهر الماضي", 
          rating: 5, 
          comment: "أفضل قيمة مقابل سعر حصلت عليها من فترة طويلة. شكراً لكم!"
        ),
      ];

      reviews.assignAll([...samples, ...fetched]);
    } catch (e) {
      debugPrint("Error fetching reviews: $e");
    } finally {
      isFetchingReviews.value = false;
    }
  }
  
  void _fetchSimilarProducts() {
    try {
      if (Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();
        final current = product.value;
        
        // استبعاد المنتج الحالي من قائمة المرشحين
        final allCandidates = homeController.allProducts.where((p) => p.id != current.id).toList();
        
        List<Product> recommendations = [];
        
        // تحديد نطاق السعر المشابه (±20%)
        final double minPrice = current.price * 0.8;
        final double maxPrice = current.price * 1.2;

        // 1. المستوى الأول: نفس القسم + نفس المتجر + سعر مشابه
        final tier1 = allCandidates.where((p) => 
          p.category == current.category && 
          p.storeId == current.storeId && 
          p.price >= minPrice && p.price <= maxPrice
        ).toList();
        recommendations.addAll(tier1);

        // 2. المستوى الثاني: نفس القسم + من متاجر أخرى + سعر مشابه
        if (recommendations.length < 5) {
          final tier2 = allCandidates.where((p) => 
            !recommendations.any((r) => r.id == p.id) &&
            p.category == current.category && 
            p.price >= minPrice && p.price <= maxPrice
          ).toList();
          recommendations.addAll(tier2);
        }

        // 3. المستوى الثالث: نفس القسم بشكل عام (دون النظر للمتجر أو السعر)
        if (recommendations.length < 5) {
          final tier3 = allCandidates.where((p) => 
            !recommendations.any((r) => r.id == p.id) &&
            p.category == current.category
          ).toList();
          recommendations.addAll(tier3);
        }

        // 4. المستوى الرابع: منتجات إما من نفس الماركة أو "تخص" المنتج (كلمات مفتاحية مشتركة)
        if (recommendations.length < 5) {
          final tier4 = allCandidates.where((p) => 
            !recommendations.any((r) => r.id == p.id) &&
            (p.brandName == current.brandName || 
             _isRelatedByKeywords(p.name, current.name))
          ).toList();
          recommendations.addAll(tier4);
        }
        
        // نأخذ 5 منتجات فقط كما طلب المستخدم
        similarProducts.assignAll(recommendations.take(5).toList());
      }
    } catch (e) {
      debugPrint("Error fetching similar products: $e");
    }
  }

  /// دالة مساعدة للتحقق من وجود كلمات مفتاحية مشتركة بين الاسمين
  bool _isRelatedByKeywords(String name1, String name2) {
    final words1 = name1.toLowerCase().split(' ').where((w) => w.length > 3).toSet();
    final words2 = name2.toLowerCase().split(' ').where((w) => w.length > 3).toSet();
    return words1.intersection(words2).isNotEmpty;
  }

  Future<bool> postReview(int rating, String comment) async {
    try {
      final appController = Get.find<AppController>();
      final token = appController.token.value;
      
      if (token.isEmpty) {
        Get.snackbar("تنبيه", "يجب تسجيل الدخول أولاً لإضافة تقييم", 
            backgroundColor: Colors.orange, colorText: Colors.white);
        return false;
      }

      final success = await _apiService.postProductReview(
        productId: product.value.id,
        userId: appController.user.value?.id ?? 0,
        rating: rating,
        comment: comment,
        token: token,
      );

      if (success) {
        fetchReviews(); // تحديث القائمة بعد الإضافة
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Error posting review: $e");
      return false;
    }
  }

  double get currentPrice {
    if (overriddenPrice.value != null) return overriddenPrice.value!;
    return product.value.price;
  }

  List<String> get productImages {
    final p = product.value;
    List<String> imgs = p.images.isNotEmpty ? List<String>.from(p.images) : [p.imageUrl];
    if (displayImageUrl.value.isNotEmpty && !imgs.contains(displayImageUrl.value)) {
      imgs.insert(0, displayImageUrl.value);
    }
    return imgs;
  }

  void updateColor(Map<String, dynamic> color) {
    selectedColor.value = color;
    displayImageUrl.value = color['image'] ?? product.value.imageUrl;
    overriddenPrice.value = double.tryParse(color['price']?.toString() ?? "");
    currentImageIndex.value = 0;
    if (pageController.hasClients) {
      pageController.jumpToPage(0);
    }
  }

  void updateSize(Map<String, dynamic> size) {
    selectedSize.value = size;
    overriddenPrice.value = double.tryParse(size['price']?.toString() ?? "");
  }

  void incrementQuantity() => quantity.value++;
  void decrementQuantity() {
    if (quantity.value > 1) quantity.value--;
  }

  TextDirection getDirection(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text) ? TextDirection.rtl : TextDirection.ltr;
  }
}
