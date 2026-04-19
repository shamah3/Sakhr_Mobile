import 'package:get/get.dart';
import '../controllers/product_list_controller.dart';

class ProductListBinding extends Bindings {
  @override
  void dependencies() {
    // ProductListController often needs tags, but we can provide a default one or 
    // leave it to manual put if needed. However, for named routes, it's better to 
    // use a binding if possible.
    Get.lazyPut(() => ProductListController());
  }
}
