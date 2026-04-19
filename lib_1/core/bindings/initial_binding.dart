import 'package:get/get.dart';
import 'package:bytore/core/controllers/app_controller.dart';
import 'package:bytore/core/controllers/cart_controller.dart';
import 'package:bytore/features/home/controllers/home_controller.dart';
import 'package:bytore/features/home/controllers/categories_controller.dart';
import 'package:bytore/features/authentication/controllers/auth_controller.dart';
import 'package:bytore/features/checkout/controllers/checkout_controller.dart';
import 'package:bytore/features/home/controllers/main_controller.dart';

import 'package:bytore/features/profile/controllers/purchase_reports_controller.dart';
import 'package:bytore/features/profile/controllers/activities_controller.dart';
import 'package:bytore/features/profile/controllers/returned_products_controller.dart';
import 'package:bytore/features/profile/controllers/reviews_controller.dart';
import 'package:bytore/features/chat/controllers/chat_controller.dart';
import 'package:bytore/features/profile/controllers/edit_profile_controller.dart';
import 'package:bytore/features/chat/controllers/chatbot_controller.dart';
import 'package:bytore/features/notifications/controllers/notification_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Core Controllers (Essential on start)
    Get.put(AppController(), permanent: true);
    Get.put(CartController(), permanent: true);
    Get.put(MainController(), permanent: true);

    // Business Logic (Lazy loading when needed)
    Get.lazyPut(() => HomeController(), fenix: true);
    Get.lazyPut(() => CategoriesController(), fenix: true);
    Get.lazyPut(() => AuthController(), fenix: true);
    Get.lazyPut(() => CheckoutController(), fenix: true);
    
    
    // Profile features (Now permanent for lifecycle tracking)
    Get.put(NotificationController(), permanent: true);
    Get.put(PurchaseReportsController(), permanent: true);
    Get.put(ActivitiesController(), permanent: true);
    Get.put(ReturnedProductsController(), permanent: true);
    Get.put(ReviewsController(), permanent: true);
    
    Get.lazyPut(() => ChatController(), fenix: true);
    Get.lazyPut(() => EditProfileController(), fenix: true);
    Get.lazyPut(() => ChatbotController(), fenix: true);
  }
}
