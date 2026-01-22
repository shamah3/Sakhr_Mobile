import 'package:get/get.dart';
import 'package:bytore/features/profile/models/activity_model.dart';

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
