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
    final args = Get.arguments;
    if (args != null) {
      if (args is OrderModel) {
        order.value = args;
        loadOrderDetails(args.id, showLoading: false);
      } else if (args is int) {
        loadOrderDetails(args, showLoading: true);
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

  void addNotification({required String title, required String body, Color? color, String category = 'الكل'}) {
    _appController.addNotification(title: title, body: body, color: color, category: category);
  }
}
