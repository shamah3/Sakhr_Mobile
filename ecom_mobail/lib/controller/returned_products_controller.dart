import 'package:flutter/material.dart';
import 'package:get/get.dart';

// نموذج بيانات المنتج المسترجع
class ReturnedProductModel {
  final String name;
  final String orderId;
  final String price;
  final String status;
  final Color statusColor;
  final IconData icon;

  ReturnedProductModel({
    required this.name,
    required this.orderId,
    required this.price,
    required this.status,
    required this.statusColor,
    required this.icon,
  });
}

class ReturnedProductsController extends GetxController {
  // ألوان ثابتة للحالات
  static const Color statusGreen = Color(0xFF2ECC71);
  static const Color statusRed = Color(0xFFE74C3C);
  static const Color secondaryOrange = Color(0xFFFFA931);

  // قائمة المنتجات المسترجعة (Observable)
  var returnedProducts = <ReturnedProductModel>[
    ReturnedProductModel(
      name: 'آيفون 15 برو ماكس',
      orderId: 'رقم الطلب: #MC-9021',
      price: '450,000 ريال',
      status: 'تم قبول الاسترجاع',
      statusColor: statusGreen,
      icon: Icons.check_circle_outline,
    ),
    ReturnedProductModel(
      name: 'سماعة سوني WH-1000XM5',
      orderId: 'رقم الطلب: #MC-8843',
      price: '120,000 ريال',
      status: 'تحت المراجعة',
      statusColor: secondaryOrange,
      icon: Icons.access_time,
    ),
    ReturnedProductModel(
      name: 'شاحن سريع 65 واط',
      orderId: 'رقم الطلب: #MC-7712',
      price: '15,000 ريال',
      status: 'مرفوض (خارج الضمان)',
      statusColor: statusRed,
      icon: Icons.cancel_outlined,
    ),
  ].obs;

  void addNewReturnRequest() {
    // هنا يتم وضع المنطق لفتح صفحة إنشاء طلب جديد
    Get.snackbar(
      'طلب جديد',
      'سيتم فتح نموذج طلب استرجاع جديد',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF015C92),
      colorText: Colors.white,
    );
  }
}