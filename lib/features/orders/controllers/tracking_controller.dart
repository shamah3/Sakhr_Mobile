import 'dart:async';
import 'package:bytore/core/controllers/app_controller.dart';
import 'package:bytore/core/services/api_service.dart';
import 'package:bytore/features/orders/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TrackingController extends GetxController {
  final ApiService _apiService = ApiService();
  final AppController _appController = Get.find<AppController>();

  var order = Rxn<OrderModel>();
  var isLoading = false.obs;
  Timer? _simulationTimer;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null) {
      if (args is OrderModel) {
        order.value = args;
        loadOrderDetails(args.id, showLoading: false).then((_) => _startStatusSimulation());
      } else if (args is int) {
        loadOrderDetails(args, showLoading: true).then((_) => _startStatusSimulation());
      }
    }
  }

  Future<void> loadOrderDetails(int id, {bool showLoading = true}) async {
    try {
      if (showLoading) isLoading.value = true;
      final token = _appController.token.value;
      if (token.isEmpty) return;

      final data = await _apiService.fetchOrderDetail(id, token);
      if (data != null) {
        order.value = data;
      }
    } catch (e) {
      debugPrint("Error loading order tracking: $e");
    } finally {
      if (showLoading) isLoading.value = false;
    }
  }

  void _startStatusSimulation() {
    if (order.value == null) return;
    
    // توقف إذا كان الطلب ملغي أو مستلم بالفعل
    if (order.value!.status == OrderStatus.delivered) return;

    final statusSequence = [
      OrderStatus.pending,
      OrderStatus.confirmed,
      OrderStatus.processing,
      OrderStatus.outForDelivery,
      OrderStatus.delivered,
    ];

    // تحديد أين نحن الآن في المصفوفة
    int currentIndex = statusSequence.indexOf(order.value!.status);
    if (currentIndex == -1) currentIndex = 0;

    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (currentIndex < statusSequence.length - 1) {
        currentIndex++;
        final nextStatus = statusSequence[currentIndex];

        // تحديث كائن الطلب برمجياً لتحفيز واجهة GetX الاستجابة
        final currentOrder = order.value!;
        order.value = OrderModel(
          id: currentOrder.id,
          dateTime: currentOrder.dateTime,
          status: nextStatus,
          totalPrice: currentOrder.totalPrice,
          itemCount: currentOrder.itemCount,
          shippingAddress: currentOrder.shippingAddress,
          itemsNames: currentOrder.itemsNames,
          productIds: currentOrder.productIds,
        );

        addNotification(
          title: "تحديث الطلب #${currentOrder.id}",
          body: "حالة طلبك الآن هي: ${order.value!.statusText}",
          color: order.value!.statusColor,
        );

        if (nextStatus == OrderStatus.delivered) {
          timer.cancel();
        }
      } else {
        timer.cancel();
      }
    });
  }

  void addNotification({required String title, required String body, Color? color, String category = 'الكل'}) {
    _appController.addNotification(title: title, body: body, color: color, category: category);
  }

  @override
  void onClose() {
    _simulationTimer?.cancel();
    super.onClose();
  }
}
