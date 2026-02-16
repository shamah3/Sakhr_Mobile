import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bytore/features/profile/models/returned_product_model.dart';
import 'package:bytore/features/profile/controllers/purchase_reports_controller.dart';
import 'package:bytore/features/profile/models/order_model.dart';

class ReturnedProductsController extends GetxController {
  // ألوان ثابتة للحالات
  static const Color statusGreen = Color(0xFF2ECC71);
  static const Color statusRed = Color(0xFFE74C3C);
  static const Color secondaryOrange = Color(0xFFFFA931);

  // قائمة المنتجات المسترجعة (Reactive)
  var returnedProducts = <ReturnedProductModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    // نبدأ بقائمة فارغة، وتعتمد على طلبات المستخدم
  }

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
                  return order.itemsNames.map((itemName) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        leading: const Icon(Icons.inventory_2_outlined, color: Colors.blue),
                        title: Text(itemName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("طلب: ${order.id}"),
                        trailing: const Icon(Icons.keyboard_arrow_left),
                        onTap: () {
                          Get.back();
                          _submitReturnRequest(order, itemName);
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

  void _submitReturnRequest(OrderModel order, String itemName) {
    // محاكاة إضافة طلب استرجاع لمنتج محدد
    returnedProducts.insert(0, ReturnedProductModel(
      name: itemName,
      orderId: order.id,
      price: "${(order.total / order.itemsNames.length).toStringAsFixed(0)} ريال", // تقسيم افتراضي للسعر
      status: 'تحت المراجعة',
      statusColor: secondaryOrange,
      icon: Icons.access_time,
    ));
    
    Get.snackbar(
      'تم بنجاح',
      'تم رفع طلب استرجاع للمنتج $itemName',
      backgroundColor: statusGreen,
      colorText: Colors.white,
    );
  }
}
