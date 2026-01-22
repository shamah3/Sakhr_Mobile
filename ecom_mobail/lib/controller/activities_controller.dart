import 'package:get/get.dart';

// نموذج لبيانات النشاط (Model)
class ActivityModel {
  final String title;
  final String time;
  final String date; // اليوم أو أمس أو تاريخ محدد
  final String type; // لتحديد الأيقونة واللون

  ActivityModel({required this.title, required this.time, required this.date, required this.type});
}

class ActivitiesController extends GetxController {
  // قائمة الأنشطة (Observable)
  var activities = <ActivityModel>[].obs;
  // حالة التحميل
  var isLoading = true.obs;

  @override
  void onInit() {
    fetchActivities(); // جلب البيانات فور تشغيل الصفحة
    super.onInit();
  }

  void fetchActivities() async {
    try {
      isLoading(true);
      // هنا نقوم بعمل الـ API Call (محاكاة حالياً)
      await Future.delayed(const Duration(seconds: 2));

      var serverData = [
        ActivityModel(title: 'تم شراء آيفون 15 برو', time: '10:30 ص', date: 'اليوم', type: 'buy'),
        ActivityModel(title: 'إضافة "سماعة سوني" للمفضلة', time: '09:15 ص', date: 'اليوم', type: 'fav'),
        ActivityModel(title: 'تسجيل دخول من جهاز جديد', time: '08:00 ص', date: 'اليوم', type: 'security'),
        ActivityModel(title: 'تغيير كلمة المرور', time: '04:20 م', date: 'أمس', type: 'lock'),
      ];

      activities.assignAll(serverData);
    } finally {
      isLoading(false);
    }
  }
}