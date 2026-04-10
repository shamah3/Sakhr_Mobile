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

  @override
  void onInit() {
    super.onInit();
    final orderId = Get.arguments;
    if (orderId != null && orderId is int) {
      loadOrderDetails(orderId);
    }
  }

  Future<void> loadOrderDetails(int id) async {
    try {
      isLoading.value = true;
      final token = _appController.token.value;
      if (token.isEmpty) return;

      final data = await _apiService.fetchOrderDetail(id, token);
      order.value = data;
    } catch (e) {
      debugPrint("Error loading order tracking: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void addNotification({required String title, required String body, Color? color, String category = 'الكل'}) {
    _appController.addNotification(title: title, body: body, color: color, category: category);
  }
}
