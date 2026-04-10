import 'package:get/get.dart';
import 'package:bytore/core/services/api_service.dart';
import 'package:bytore/features/stores/models/store_model.dart';
import 'package:bytore/features/stores/models/advertisement_model.dart';
import 'package:flutter/foundation.dart';

class StoresController extends GetxController {
  final ApiService _apiService = ApiService();

  var allStores = <StoreModel>[].obs;
  var filteredStores = <StoreModel>[].obs;
  var advertisements = <AdvertisementModel>[].obs;
  var isLoading = false.obs;
  var hasError = false.obs;
  var searchText = "".obs;

  @override
  void onInit() {
    super.onInit();
    loadStores();
  }

  Future<void> loadStores() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      
      // إرجاع متجر افتراضي للاستخدام المحلي
      final mockStores = [
        StoreModel(id: 1, name: "متجر صخر المميز", category: "عام", rating: 5.0),
        StoreModel(id: 2, name: "عالم التقنية", category: "إلكترونيات", rating: 4.8),
      ];
      final List<AdvertisementModel> mockAds = [];

      allStores.assignAll(mockStores);
      filteredStores.assignAll(mockStores);
      advertisements.assignAll(mockAds);
    } catch (e) {
      debugPrint("🔥 Error loading mock stores: $e");
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  void filterStores(String query) {
    searchText.value = query;
    if (query.isEmpty) {
      filteredStores.assignAll(allStores);
    } else {
      filteredStores.assignAll(allStores.where((store) =>
        store.name.toLowerCase().contains(query.toLowerCase()) ||
        (store.category.toLowerCase().contains(query.toLowerCase()))
      ).toList());
    }
  }

  // --- Protected Methods ---

  Future<bool> createNewStore(Map<String, dynamic> data, String token) async {
    final success = await _apiService.createStore(data, token);
    if (success) await loadStores();
    return success;
  }

  Future<bool> updateExistingStore(int id, Map<String, dynamic> data, String token) async {
    final success = await _apiService.updateStore(id, data, token);
    if (success) await loadStores();
    return success;
  }

  Future<bool> deleteExistingStore(int id, String token) async {
    final success = await _apiService.deleteStore(id, token);
    if (success) await loadStores();
    return success;
  }
}
