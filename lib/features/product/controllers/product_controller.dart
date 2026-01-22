import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bytore/features/product/models/product_model.dart';

class ProductController extends GetxController {
  final Product product;
  
  ProductController({required this.product});

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
    displayImageUrl.value = product.imageUrl;
    
    if (product.colors != null && product.colors!.isNotEmpty) {
      selectedColor.value = product.colors![0];
      displayImageUrl.value = selectedColor.value!['image'];
      overriddenPrice.value = selectedColor.value!['price'];
    }
    
    if (product.sizes != null && product.sizes!.isNotEmpty) {
      selectedSize.value = product.sizes![0];
      overriddenPrice.value = selectedSize.value!['price'];
    }
  }

  double get currentPrice => overriddenPrice.value ?? product.price;

  List<String> get productImages {
    List<String> imgs = product.images.isNotEmpty ? List<String>.from(product.images) : [product.imageUrl];
    if (displayImageUrl.value.isNotEmpty) {
      imgs.remove(displayImageUrl.value);
      imgs.insert(0, displayImageUrl.value);
    }
    return imgs;
  }

  void updateColor(Map<String, dynamic> color) {
    selectedColor.value = color;
    displayImageUrl.value = color['image'];
    overriddenPrice.value = color['price'];
    currentImageIndex.value = 0;
    if (pageController.hasClients) {
      pageController.jumpToPage(0);
    }
  }

  void updateSize(Map<String, dynamic> size) {
    selectedSize.value = size;
    overriddenPrice.value = size['price'];
  }

  void incrementQuantity() => quantity.value++;
  void decrementQuantity() {
    if (quantity.value > 1) quantity.value--;
  }

  TextDirection getDirection(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text) ? TextDirection.rtl : TextDirection.ltr;
  }
}
