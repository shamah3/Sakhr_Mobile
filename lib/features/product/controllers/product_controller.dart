import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bytore/features/product/models/product_model.dart';
import 'package:bytore/core/services/api_service.dart';

class ProductController extends GetxController {
  final Rx<Product> product;
  final ApiService _apiService = ApiService();
  var isRefreshing = false.obs;
  
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
  }

  void _initializeStates() {
    displayImageUrl.value = product.value.imageUrl;
    
    if (product.value.colors.isNotEmpty) {
      selectedColor.value = product.value.colors[0];
      displayImageUrl.value = selectedColor.value!['image'];
      overriddenPrice.value = double.tryParse(selectedColor.value!['price']?.toString() ?? "");
    }
    
    if (product.value.sizes.isNotEmpty) {
      selectedSize.value = product.value.sizes[0];
      overriddenPrice.value = double.tryParse(selectedSize.value!['price']?.toString() ?? "");
    }
  }

  Future<void> refreshProduct() async {
    isRefreshing.value = true;
    try {
      final updatedProduct = await _apiService.fetchProductDetail(product.value.id);
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

  double get currentPrice {
    if (overriddenPrice.value != null) return overriddenPrice.value!;
    return product.value.price;
  }

  List<String> get productImages {
    final p = product.value;
    List<String> imgs = p.images.isNotEmpty ? List<String>.from(p.images) : [p.imageUrl];
    if (displayImageUrl.value.isNotEmpty) {
      imgs.remove(displayImageUrl.value);
      imgs.insert(0, displayImageUrl.value);
    }
    return imgs;
  }

  void updateColor(Map<String, dynamic> color) {
    selectedColor.value = color;
    displayImageUrl.value = color['image'];
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
