import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bytore/core/services/api_service.dart';
import 'package:bytore/features/product/models/product_model.dart';
import 'package:bytore/core/controllers/app_controller.dart';

class ProductManagementController extends GetxController {
  final ApiService _apiService = ApiService();
  final AppController _appController = Get.find<AppController>();

  final RxList<Product> products = <Product>[].obs;
  final RxBool isLoading = false.obs;
  final Rxn<Product> selectedProduct = Rxn<Product>();
  final RxString filterStatus = "الكل".obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    isLoading.value = true;
    try {
      final token = _appController.token.value;
      final result = await _apiService.fetchManagementProducts(token: token.isEmpty ? null : token);
      products.assignAll(result);
    } catch (e) {
      debugPrint("Error fetching management products: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchProductDetail(int id) async {
    isLoading.value = true;
    try {
      final token = _appController.token.value;
      final result = await _apiService.fetchManagementProductDetail(id, token: token.isEmpty ? null : token);
      selectedProduct.value = result;
    } catch (e) {
      debugPrint("Error fetching management product detail: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateStatus(int id, String status) async {
    isLoading.value = true;
    try {
      final token = _appController.token.value;
      final success = await _apiService.updateProductStatus(id, status, token: token.isEmpty ? null : token);
      
      if (success) {
        Get.snackbar(
          "تم بنجاح",
          "تم تغيير حالة المنتج إلى $status",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        // Refresh detail and list
        await fetchProductDetail(id);
        await fetchProducts();
      } else {
        Get.snackbar(
          "خطأ",
          "فشل تحديث حالة المنتج",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
       debugPrint("Error updating status: $e");
       Get.snackbar("خطأ", "حدث خطأ غير متوقع");
    } finally {
      isLoading.value = false;
    }
  }

  List<Product> get filteredProducts {
    if (filterStatus.value == "الكل") return products;
    return products.where((p) => p.status.toLowerCase() == filterStatus.value.toLowerCase()).toList();
  }

  void changeFilter(String? status) {
    if (status != null) {
      filterStatus.value = status;
    }
  }
}
