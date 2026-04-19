import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bytore/features/profile/models/returned_product_model.dart';
import 'package:bytore/features/profile/controllers/purchase_reports_controller.dart';
import 'package:bytore/features/profile/controllers/activities_controller.dart';
import 'package:bytore/features/orders/models/order_model.dart';
import 'package:bytore/core/services/api_service.dart';
import 'package:bytore/core/controllers/app_controller.dart';

class ReturnedProductsController extends GetxController {
  final ApiService _apiService = ApiService();
  final AppController _appController = Get.find<AppController>();

  // ألوان ثابتة للحالات
  static const Color statusGreen = Color(0xFF2ECC71);
  static const Color statusRed = Color(0xFFE74C3C);
  static const Color secondaryOrange = Color(0xFFFFA931);

  // قائمة المنتجات المسترجعة (Reactive)
  var returnedProducts = <ReturnedProductModel>[].obs;
  var isLoading = false.obs;

  // دالة لفتح نافذة اختيار منتج للاسترجاع
  void addNewReturnRequest() {
    final purchaseController = Get.find<PurchaseReportsController>();
    if (purchaseController.orders.isEmpty) {
      Get.snackbar(
        'تنبيه',
        'لا توجد طلبات سابقة لتقديم طلب استرجاع.',
        backgroundColor: secondaryOrange,
        colorText: Colors.white,
      );
      return;
    }

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(maxHeight: Get.height * 0.7),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            const Text(
              "اختر منتجاً للاسترجاع",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: ListView(
                children: purchaseController.orders.expand((order) {
                  return order.itemsNames.asMap().entries.map((entry) {
                    final index = entry.key;
                    final itemName = entry.value;
                    final productId = order.productIds.length > index
                        ? order.productIds[index]
                        : 0;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.inventory_2_outlined,
                          color: Colors.blue,
                        ),
                        title: Text(
                          itemName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text("طلب: ${order.id}"),
                        trailing: const Icon(Icons.keyboard_arrow_left),
                        onTap: () {
                          Get.back();
                          _submitReturnRequest(order, itemName, productId);
                        },
                      ),
                    );
                  });
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReturnRequest(
    OrderModel order,
    String itemName,
    int productId,
  ) async {
    try {
      isLoading.value = true;
      final token = _appController.token.value;
      final user = await _appController.ensureUserLoaded();
      if (token.isEmpty || user == null || user.id <= 0) {
        Get.snackbar(
          'انتهت الجلسة',
          'يرجى تسجيل الدخول مرة أخرى قبل تقديم طلب الإرجاع.',
          backgroundColor: secondaryOrange,
          colorText: Colors.white,
        );
        return;
      }

      await _apiService.postReturnRequest({
        "order_id": order.id,
        "product_id": productId,
        "reason": "Requested via Mobile App",
      }, token);

      // إضافة محلياً للعرض الفوري
      returnedProducts.insert(
        0,
        ReturnedProductModel(
          name: itemName,
          orderId: order.id.toString(),
          price:
              "${(order.totalPrice / (order.itemsNames.isEmpty ? 1 : order.itemsNames.length)).toStringAsFixed(0)} ريال",
          status: 'تحت المراجعة',
          statusColor: secondaryOrange,
          icon: Icons.access_time,
        ),
      );

      // تسجيل النشاط
      Get.find<ActivitiesController>().logActivity(
        title: "تم تقديم طلب استرجاع: $itemName",
        type: 'return',
      );

      Get.snackbar(
        'تم بنجاح',
        'تم رفع طلب استرجاع للمنتج $itemName',
        backgroundColor: statusGreen,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint("Error submitting return: $e");
      Get.snackbar(
        'خطأ',
        e.toString().replaceFirst('Exception: ', ''),
        backgroundColor: statusRed,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
