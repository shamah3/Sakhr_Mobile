import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PolicyController extends GetxController {
  // يمكن مستقبلاً جلب هذه النصوص من API لتحديث السياسة بدون تحديث التطبيق
  final String supportMessage = "تواصل مع فريق الدعم الفني لمساعدتك في إتمام العملية بكل سهولة.";

  void startReturnProcess() {
    // منطق بدء طلب الاسترجاع
    Get.snackbar(
      'طلب استرجاع',
      'سيتم توجيهك لنظام تقديم الطلبات الآن',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF015C92),
      colorText: Colors.white,
    );
  }
}
