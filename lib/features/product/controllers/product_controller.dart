import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bytore/features/product/models/product_model.dart';
import 'package:bytore/core/services/api_service.dart';
import 'package:bytore/features/profile/models/review_model.dart';
import 'package:bytore/core/controllers/app_controller.dart';

class ProductController extends GetxController {
  final Rx<Product> product;
  final ApiService _apiService = ApiService();
  var isRefreshing = false.obs;
  var isFetchingReviews = false.obs;
  var reviews = <ReviewModel>[].obs;
  
  ProductController({required Product product}) : product = product.obs;

  var quantity = 1.obs;
  var currentImageIndex = 0.obs;
  final PageController pageController = PageController();
  
  var selectedColor = Rxn<Map<String, dynamic>>();
  var selectedSize = Rxn<Map<String, dynamic>>();
  var displayImageUrl = "".obs;
  var overriddenPrice = Rxn<double>();

  @override
  void onInit() {
    super.onInit();
    _initializeStates();
    refreshProduct();
    fetchReviews();
  }

  void _initializeStates() {
    displayImageUrl.value = product.value.imageUrl;
    
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
      reviews.assignAll(fetched);
    } catch (e) {
      debugPrint("Error fetching reviews: $e");
    } finally {
      isFetchingReviews.value = false;
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
