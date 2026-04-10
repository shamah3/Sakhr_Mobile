import 'package:get/get.dart';
import 'package:bytore/features/product/management/product_management_controller.dart';

class ProductManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductManagementController>(
      () => ProductManagementController(),
    );
  }
}
