import 'package:bytore/core/controllers/app_controller.dart';
import 'package:bytore/core/services/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:bytore/features/profile/models/wallet_model.dart';

class WalletController extends GetxController {
  final ApiService _apiService = ApiService();
  final AppController _appController = Get.find<AppController>();

  var wallet = Rxn<WalletModel>();
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadWallet();
  }

  Future<void> loadWallet() async {
    try {
      isLoading.value = true;
      final token = _appController.token.value;
      if (token.isEmpty) return;

      final data = await _apiService.fetchWallet(token);
      wallet.value = data;
    } catch (e) {
      debugPrint("Error loading wallet: $e");
    } finally {
      isLoading.value = false;
    }
  }

  double get currentBalance => wallet.value?.balance ?? 0.0;
  List<WalletTransaction> get transactions => wallet.value?.transactions ?? [];
}
