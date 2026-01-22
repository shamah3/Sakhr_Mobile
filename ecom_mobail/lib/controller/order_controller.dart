import 'package:get/get.dart';

// تعريف حالات الطلب كما في كودك
enum OrderStatus { current, completed, canceled }

class OrderModel {
  final String id;
  final String date;
  final int itemCount;
  final String total;
  final OrderStatus status;

  OrderModel({
    required this.id,
    required this.date,
    required this.itemCount,
    required this.total,
    required this.status,
  });
}

class OrdersController extends GetxController {
  // قائمة الطلبات (Reactive)
  var allOrders = <OrderModel>[
    OrderModel(id: '#12345', date: '25-12-2025', itemCount: 3, total: '150,000', status: OrderStatus.current),
    OrderModel(id: '#12333', date: '22-12-2025', itemCount: 1, total: '85,000', status: OrderStatus.completed),
    OrderModel(id: '#12322', date: '20-12-2025', itemCount: 2, total: '45,000', status: OrderStatus.canceled),
  ].obs;

  // دوال للحصول على القوائم المفلترة
  List<OrderModel> get currentOrders => allOrders.where((o) => o.status == OrderStatus.current).toList();
  List<OrderModel> get completedOrders => allOrders.where((o) => o.status == OrderStatus.completed).toList();
  List<OrderModel> get canceledOrders => allOrders.where((o) => o.status == OrderStatus.canceled).toList();
}