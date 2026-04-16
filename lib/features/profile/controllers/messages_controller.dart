import 'package:bytore/core/services/api_service.dart';
import 'package:bytore/features/stores/models/store_model.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class MessagesController extends GetxController {
  final ApiService _apiService = ApiService();
  
  var stores = <StoreModel>[].obs;
  var isLoading = true.obs;
  var searchQuery = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchStores();
  }

  Future<void> fetchStores() async {
    try {
      isLoading.value = true;
      final fetched = await _apiService.fetchStores();
      stores.assignAll(fetched);
    } catch (e) {
      debugPrint("Error fetching stores for messages: $e");
    } finally {
      isLoading.value = false;
    }
  }

  List<StoreModel> get filteredStores {
    if (searchQuery.value.isEmpty) return stores;
    return stores.where((s) => s.name.toLowerCase().contains(searchQuery.value.toLowerCase())).toList();
  }
}
