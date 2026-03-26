import 'package:bytore/core/controllers/app_controller.dart';
import 'package:bytore/core/services/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:bytore/features/orders/models/order_model.dart';

enum TimeFilter { weekly, monthly, yearly }

class PurchaseReportsController extends GetxController {
  final ApiService _apiService = ApiService();
  final AppController _appController = Get.find<AppController>();

  var selectedFilter = TimeFilter.monthly.obs;
  var orders = <OrderModel>[].obs;
  var filteredOrders = <OrderModel>[].obs;
  var isLoading = false.obs;

  var totalSpending = "0 ريال".obs;
  var ordersCount = "0 طلبات".obs;
  
  @override
  void onInit() {
    super.onInit();
    loadOrders();
    ever(orders, (_) => changeFilter(selectedFilter.value));
  }
  
  Future<void> loadOrders() async {
    try {
      isLoading.value = true;
      final token = _appController.token.value;
      if (token.isEmpty) return;

      final fetched = await _apiService.fetchOrders(token);
      orders.assignAll(fetched);
    } catch (e) {
      debugPrint("Error loading orders: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void addOrder(OrderModel order) {
    orders.insert(0, order);
  }

  void changeFilter(TimeFilter filter) {
    selectedFilter.value = filter;
    
    final now = DateTime.now();
    filteredOrders.clear();
    
    for (var order in orders) {
      bool include = false;
      if (filter == TimeFilter.weekly) {
        if (now.difference(order.dateTime).inDays <= 7) include = true;
      } else if (filter == TimeFilter.monthly) {
        if (now.difference(order.dateTime).inDays <= 30) include = true;
      } else {
        if (now.difference(order.dateTime).inDays <= 365) include = true;
      }
      
      if (include) filteredOrders.add(order);
    }
    
    double sum = 0;
    for (var o in filteredOrders) sum += o.totalPrice;
    
    totalSpending.value = "${sum.toStringAsFixed(0)} ريال";
    ordersCount.value = "${filteredOrders.length} طلبات";
  }
}
