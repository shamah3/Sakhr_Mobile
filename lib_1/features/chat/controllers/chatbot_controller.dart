import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:bytore/core/services/api_service.dart';
import 'package:bytore/core/controllers/app_controller.dart';
import 'package:bytore/features/chat/models/chatbot_rule_model.dart';
import 'package:intl/intl.dart';

class ChatMessage {
  final String text;
  final bool isMe;
  final String time;

  ChatMessage({required this.text, required this.isMe, required this.time});
}

class ChatbotController extends GetxController {
  final ApiService _apiService = ApiService();
  final AppController _appController = Get.find<AppController>();

  var rules = <ChatbotRuleModel>[].obs;
  var messages = <ChatMessage>[].obs;
  var isLoadingRules = false.obs;
  var isTyping = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Add default welcome message
    messages.add(ChatMessage(
      text: 'مرحباً بك! أنا مساعدك الذكي في صخر. كيف يمكنني مساعدتك اليوم؟',
      isMe: false,
      time: _getCurrentTime(),
    ));
    fetchRules();
  }

  Future<void> fetchRules() async {
    isLoadingRules.value = true;
    try {
      final list = await _apiService.fetchChatbotRules();
      rules.value = list.map((e) => ChatbotRuleModel.fromJson(Map<String, dynamic>.from(e))).toList();
      debugPrint("✅ Chatbot Rules Loaded: ${rules.length}");
    } catch (e) {
      debugPrint("❌ Failed to load Chatbot Rules: $e");
    } finally {
      isLoadingRules.value = false;
    }
  }

  Future<void> sendMessage(String userMsg) async {
    if (userMsg.trim().isEmpty) return;

    messages.add(ChatMessage(
      text: userMsg,
      isMe: true,
      time: _getCurrentTime(),
    ));

    isTyping.value = true;

    try {
      final token = _appController.token.value;
      String? botResponse = await _apiService.smartSearch(
        userMsg,
        token: token.isNotEmpty ? token : null,
      );

      // Fallback if API fails
      botResponse ??= "عذراً، لم أتمكن من الحصول على إجابة حالياً.";

      messages.add(ChatMessage(
        text: botResponse,
        isMe: false,
        time: _getCurrentTime(),
      ));

      // Send log to server (optional but maintaining logic)
      _saveResponseToServer(userMsg, botResponse);
    } catch (e) {
      debugPrint("❌ Chatbot sendMessage error: $e");
      messages.add(ChatMessage(
        text: "حدث خطأ أثناء الاتصال بالمساعد الذكي.",
        isMe: false,
        time: _getCurrentTime(),
      ));
    } finally {
      isTyping.value = false;
    }
  }

  Future<void> _saveResponseToServer(String userMesssage, String botResponse) async {
    try {
      final token = _appController.token.value;
      final userId = _appController.user.value?.id;
      
      await _apiService.sendChatbotResponse({
        if (userId != null && userId != 0) 'user_id': userId,
        'message': userMesssage,
        'response': botResponse,
      }, token: token);
      
      debugPrint("✅ Chatbot response logged to server successfully");
    } catch (e) {
      debugPrint("❌ Failed to log chatbot response: $e");
    }
  }

  String _getCurrentTime() {
    return DateFormat('hh:mm a').format(DateTime.now()).replaceAll('AM', 'ص').replaceAll('PM', 'م');
  }
}
