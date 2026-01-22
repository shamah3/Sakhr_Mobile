import 'package:get/get.dart';
import 'package:flutter/material.dart';

class FavoritesController extends GetxController {
  // قائمة المنتجات المفضلة (Reactive)
  var favoriteProducts = <Map<String, dynamic>>[
    {
      'id': '1',
      'name': 'لابتوب احترافي للألعاب مخصص للمصممين',
      'price': '450,000',
      'image': 'https://images.unsplash.com/photo-1541807084-5c52b6b3adef?w=500&q=80',
    },
    {
      'id': '2',
      'name': 'كاميرا تصوير احترافية بدقة 4K',
      'price': '220,000',
      'image': 'https://images.unsplash.com/photo-1510127034890-ba27088e25dc?w=500&q=80',
    },
    {
      'id': '3',
      'name': 'سماعات رأس لاسلكية عازلة للضوضاء',
      'price': '55,000',
      'image': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500&q=80',
    },
  ].obs;

  void removeFromFavorites(String productId) {
    favoriteProducts.removeWhere((p) => p['id'] == productId);
    Get.snackbar(
      'المفضلة',
      'تم إزالة المنتج من قائمتك',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFDC3545),
      colorText: Colors.white,
      margin: const EdgeInsets.all(15),
    );
  }

  void addToCart(String productId) {
    Get.snackbar(
      'السلة',
      'تم إضافة المنتج إلى سلة التسوق',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF015C92),
      colorText: Colors.white,
    );
  }
}