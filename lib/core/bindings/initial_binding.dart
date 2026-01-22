import 'package:get/get.dart';
import 'package:bytore/core/controllers/app_controller.dart';
import 'package:bytore/core/controllers/cart_controller.dart';
import 'package:bytore/features/home/controllers/home_controller.dart';
import 'package:bytore/features/home/controllers/categories_controller.dart';
import 'package:bytore/features/authentication/controllers/auth_controller.dart';
import 'package:bytore/features/checkout/controllers/checkout_controller.dart';
import 'package:bytore/features/home/controllers/main_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AppController(), permanent: true);
    Get.put(CartController(), permanent: true);
    Get.put(HomeController(), permanent: true);
    Get.lazyPut(() => CategoriesController());
    Get.lazyPut(() => AuthController());
    Get.lazyPut(() => CheckoutController());
    Get.put(MainController(), permanent: true);
  }
}
