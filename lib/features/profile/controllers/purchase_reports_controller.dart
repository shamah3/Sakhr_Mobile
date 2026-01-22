import 'package:get/get.dart';

enum TimeFilter { weekly, monthly, yearly }

class PurchaseReportsController extends GetxController {
  // الفلتر المختار حالياً (Reactive)
  var selectedFilter = TimeFilter.monthly.obs;

  // إحصائيات وهمية تتغير بناءً على الفلتر
  var totalSpending = "725,000 ريال".obs;
  var ordersCount = "8 طلبات".obs;

  // دالة لتغيير الفلتر وتحديث البيانات
  void changeFilter(TimeFilter filter) {
    selectedFilter.value = filter;

    // هنا يمكنك إضافة منطق لجلب بيانات مختلفة من السيرفر بناءً على الوقت
    if (filter == TimeFilter.weekly) {
      totalSpending.value = "120,000 ريال";
      ordersCount.value = "3 طلبات";
    } else if (filter == TimeFilter.monthly) {
      totalSpending.value = "725,000 ريال";
      ordersCount.value = "8 طلبات";
    } else {
      totalSpending.value = "4,200,000 ريال";
      ordersCount.value = "45 طلب";
    }
  }
}
