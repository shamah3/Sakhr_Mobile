import 'package:get/get.dart';
import 'package:bytore/features/profile/models/order_model.dart';

enum TimeFilter { weekly, monthly, yearly }


class PurchaseReportsController extends GetxController {
  // الفلتر المختار حالياً (Reactive)
  var selectedFilter = TimeFilter.monthly.obs;
  
  // قائمة الطلبات الحقيقية
  var orders = <OrderModel>[].obs;
  
  // القائمة المفلترة للعرض
  var filteredOrders = <OrderModel>[].obs;

  // إحصائيات تتغير بناءً على الفلتر
  var totalSpending = "0 ريال".obs;
  var ordersCount = "0 طلبات".obs;
  
  @override
  void onInit() {
    super.onInit();
    // Initialize with some dummy data if needed or empty
    changeFilter(selectedFilter.value);
    
    // Listen to changes in orders
    ever(orders, (_) => changeFilter(selectedFilter.value));
  }
  
  void addOrder(OrderModel order) {
    orders.insert(0, order);
    changeFilter(selectedFilter.value);
  }

  // دالة لتغيير الفلتر وتحديث البيانات
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
    
    // Calculate stats
    double sum = 0;
    for (var o in filteredOrders) sum += o.total;
    
    // Format currency (assuming YER for now or use AppController)
    // Using simple formatting for now
    totalSpending.value = "${sum.toStringAsFixed(0)} ريال";
    ordersCount.value = "${filteredOrders.length} طلبات";
  }
}
