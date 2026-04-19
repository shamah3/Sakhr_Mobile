import 'package:bytore/core/controllers/app_controller.dart';
import 'package:bytore/core/services/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class ChatController extends GetxController {
  final ApiService _apiService = ApiService();
  final AppController _appController = Get.find<AppController>();

  // featuredStores defines the quick access stores at the top
  final List<Map<String, dynamic>> featuredStores = [
    {'id': 101, 'name': 'كنان'},
    {'id': 102, 'name': 'سيلكون'},
    {'id': 103, 'name': 'متجر صخر'},
  ];

  // storeMessages maps a storeId to a list of messages
  var storeMessages = <int, List<Map<String, dynamic>>>{}.obs;
  var isLoading = false.obs;
  var selectedStoreId = 0.obs; 

  @override
  void onInit() {
    super.onInit();
    // Add some sample data for testing
    _addSampleData();
  }

  void _addSampleData() {
    // Convert sample data to use IDs (101=كنان/headphone, 102=سيلكون/mac, 103=متجر صخر)
    storeMessages[103] = [
      {
        'text': 'مرحباً بك في متجر صخر، كيف يمكننا مساعدتك؟',
        'isMe': false,
        'time': '10:00 ص',
        'isUnread': true,
      },
    ].obs;
    
    storeMessages[101] = [
      {
        'text': 'طلبك قيد المعالجة وسيتم شحنه قريباً.',
        'isMe': false,
        'time': '9:30 ص',
        'isUnread': false,
      },
    ].obs;
  }

  List<Map<String, dynamic>> getMessagesForStore(int storeId) {
    return storeMessages[storeId] ?? [];
  }

  void sendMessage(int storeId, String storeName, String text) {
    if (text.trim().isEmpty) return;
    
    if (!storeMessages.containsKey(storeId)) {
      storeMessages[storeId] = <Map<String, dynamic>>[].obs;
    }
    
    storeMessages[storeId]!.add({
      'text': text,
      'isMe': true,
      'time': _formatTime(DateTime.now()),
      'isUnread': false,
    });
    
    storeMessages.refresh();

    // Sync with platform using the real storeId now
    _syncMessageWithPlatform(storeId, text);
  }

  Future<void> _syncMessageWithPlatform(int storeId, String text) async {
    final token = _appController.token.value;
    if (token.isEmpty) return;

    try {
      final success = await _apiService.sendChatMessage(storeId, text, token);
        if (!success) {
          debugPrint("Failed to sync message for Store ID: $storeId with platform");
        }
    } catch (e) {
      debugPrint("Error syncing message: $e");
    }
  }

  void markAsRead(int storeId) {
    if (storeMessages.containsKey(storeId)) {
      for (var msg in storeMessages[storeId]!) {
        msg['isUnread'] = false;
      }
      storeMessages.refresh();
    }
  }

  String _formatTime(DateTime dateTime) {
    return "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
  }
}
