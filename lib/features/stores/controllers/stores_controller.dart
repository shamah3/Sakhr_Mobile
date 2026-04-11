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
      
      // 1. جلب المتاجر الحقيقية
      final List<StoreModel>? stores = await _apiService.fetchStores();
      
      List<AdvertisementModel> allAds = [];

      // إذا نجح الاتصال بالمخدم (حتى لو القائمة فارغة)
      if (stores != null) {
        allStores.assignAll(stores);
        filteredStores.assignAll(stores);

        if (stores.isNotEmpty) {
          // جلب إعلانات من أول 3 متاجر
          int fetchCount = stores.length > 3 ? 3 : stores.length;
          for (int i = 0; i < fetchCount; i++) {
            final ads = await _apiService.fetchStoreAdvertisements(stores[i].id);
            if (ads.isNotEmpty) allAds.addAll(ads);
          }
        } else {
          debugPrint("⚠️ STORES LIST IS EMPTY, TRYING DEFAULT STORE ID (1) FOR ADS");
          final ads = await _apiService.fetchStoreAdvertisements(1);
          if (ads.isNotEmpty) allAds.addAll(ads);
        }
        
        // جلب الإعلانات العامة للإدارة أيضاً لزيادة المحتوى
        final generalAds = await _apiService.fetchAdvertisements();
        if (generalAds.isNotEmpty) {
           allAds.addAll(generalAds);
        }

        advertisements.assignAll(allAds);
        debugPrint("✅ LOAD COMPLETED: ${stores.length} stores, ${allAds.length} ads fetched");
      } else {
        hasError.value = true;
      }
    } catch (e) {
      debugPrint("🔥 Error loading stores or ads: $e");
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
