import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:bytore/core/constants/constants.dart';
import 'package:get/get.dart';
import 'dart:ui';

import 'package:bytore/core/services/api_service.dart';
import 'package:bytore/core/controllers/app_controller.dart';

class AiChatView extends StatefulWidget {
  const AiChatView({super.key});

  @override
  State<AiChatView> createState() => _AiChatViewState();
}

class _AiChatViewState extends State<AiChatView> {
  final TextEditingController _userMessage = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // --- حالة الذاكرة المحلية للشات بوت ---
  String? _detectedSpecialty;

  final ApiService _apiService = ApiService();

  final List<Message> _messages = [];
  bool isLoading = false;
  bool isInitializing = true;

  static const assistantInstruction =
      "أنت 'صخر AI'، مستشار تقني خبير ومتخصص في عتاد الحاسوب لمتجر 'صخر'.\n"
      "يجب أن تلتزم بالقواعد التالية بدقة فائقة:\n"
      "1. العقلانية والخبرة: عند السؤال عن تخصص معين (مثل الجرافيكس)، قدم مواصفات حقيقية ومحتلرفة (مثلاً: RAM لا تقل عن 16GB، معالج i7 أو Ryzen 7 فما فوق، كرت شاشة RTX بذاكرة VRAM كافية).\n"
      "2. السياق والذاكرة: يجب أن تربط إجاباتك ببعضها. إذا سألك المستخدم عن كرت شاشة بعد أن ذكر تخصص الجرافيكس، أجب بناءً على متطلبات الجرافيكس. إذا سألك عن السعر، أعطِ تقديراً يتناسب مع المواصفات التي اقترحتها في الرسائل السابقة.\n"
      "3. التفاعل التدريجي: اطلب تخصص المستخدم أولاً إذا لم يكن معروفاً، ثم قدم النصيحة.\n"
      "4. القيود: أجب بالعربية فقط، كن ودوداً وعملياً، لا تخرج عن نطاق التقنية، ولا تقدم معلومات وهمية.\n"
      "5. الأسعار: قدم نطاقات سعرية واقعية (مثلاً بالدولار أو ما يعادلها) للمواصفات المقترحة.";

  @override
  void initState() {
    super.initState();
    _setupChat();
  }

  Future<void> _setupChat() async {
    // جلب السجل من السيرفر لضمان الاستمرارية العرضية فقط
    try {
      final token = Get.find<AppController>().token.value;
      if (token.isNotEmpty) {
        final rawHistory = await _apiService.fetchChatHistory(token);
        for (var item in rawHistory) {
          final userMsg = item['message'] ?? "";
          final botMsg = item['response'] ?? "";
          final dateStr = item['created_at'] ?? DateTime.now().toIso8601String();
          
          _messages.add(Message(isUser: true, message: userMsg, date: DateTime.parse(dateStr)));
          _messages.add(Message(isUser: false, message: botMsg, date: DateTime.parse(dateStr)));
          
          // محاولة استنتاج التخصص من التاريخ القديم
          if (userMsg.toLowerCase().contains('جرافكس') || userMsg.toLowerCase().contains('graphics')) {
            _detectedSpecialty = "graphics";
          }
        }
      }
    } catch (e) {
      debugPrint("Error loading chat history: $e");
    }

    if (_messages.isEmpty) {
      _messages.add(Message(
          isUser: false,
          message: "مرحباً بك مجدداً في صخر AI! أنا مساعدك التقني المحلي. كيف يمكنني مساعدتك في اختيار عتادك التقني اليوم؟",
          date: DateTime.now()));
    }

    if (mounted) {
      setState(() => isInitializing = false);
      _scrollToBottom();
    }
  }

  Future<void> sendMessage() async {
    if (_userMessage.text.trim().isEmpty) return;

    final userMessageText = _userMessage.text.trim();
    _userMessage.clear();

    setState(() {
      _messages.add(Message(isUser: true, message: userMessageText, date: DateTime.now()));
      isLoading = true;
    });

    _scrollToBottom();

    // جلب الرد من السيرفر (البحث الذكي)
    final token = Get.find<AppController>().token.value;
    String? botResponse = await _apiService.smartSearch(
      userMessageText,
      token: token.isNotEmpty ? token : null,
    );

    // Fallback if API fails
    botResponse ??= "عذراً، لم أتمكن من الحصول على إجابة حالياً. يرجى المحاولة مرة أخرى.";

    if (mounted) {
      setState(() {
        _messages.add(Message(isUser: false, message: botResponse!, date: DateTime.now()));
        isLoading = false;
      });
      _scrollToBottom();
    }

    // حفظ الرد في السيرفر للسجل (اختياري، لأن المحرك قد يقوم بذلك تلقائياً، لكننا نحافظ عليه للتوافق)
    if (token.isNotEmpty) {
      _apiService.sendChatbotResponse({
        if (Get.find<AppController>().user.value?.id != null)
          'user_id': Get.find<AppController>().user.value?.id,
        'message': userMessageText,
        'response': botResponse,
      }, token: token);
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.8),
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: kTextColor, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: kPrimaryColor, size: 20),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "مساعد صخر AI",
                  style: TextStyle(color: kTextColor, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  "متصل الآن",
                  style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Background subtle gradient
          Positioned.fill(
            child: Container(color: Colors.white),
          ),
          
          Column(
            children: [
              Expanded(
                child: isInitializing
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: kPrimaryColor),
                            SizedBox(height: 15),
                            Text("جاري تحميل المحادثات السابقة...",
                                style: TextStyle(color: kTextLightColor, fontSize: 13)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(20, 120, 20, 20),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          return ChatBubble(message: _messages[index]);
                        },
                      ),
              ),
              if (isLoading)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 40,
                        child: LinearProgressIndicator(
                          backgroundColor: kPrimaryColor.withOpacity(0.1),
                          color: kPrimaryColor,
                          minHeight: 2,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text("صخر يكتب...", style: TextStyle(fontSize: 10, color: kPrimaryColor, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),

              _buildInputArea(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: kBgColor,
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextFormField(
                controller: _userMessage,
                focusNode: _focusNode,
                maxLines: 4,
                minLines: 1,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: "اكتب استفسارك هنا...",
                  hintStyle: TextStyle(color: kTextLightColor.withOpacity(0.6), fontSize: 13),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: sendMessage,
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kPrimaryColor, Color(0xFF0277BD)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: kPrimaryColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final Message message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: kPrimaryColor, size: 14),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: isUser ? kPrimaryColor : const Color(0xFFF1F4F7),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: isUser ? const Radius.circular(20) : Radius.zero,
                  bottomRight: isUser ? Radius.zero : const Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    message.message,
                    style: TextStyle(
                      color: isUser ? Colors.white : kTextColor,
                      fontSize: 14,
                      height: 1.5,
                      fontWeight: isUser ? FontWeight.bold : FontWeight.normal,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    intl.DateFormat('hh:mm a').format(message.date),
                    style: TextStyle(
                      fontSize: 9,
                      color: isUser ? Colors.white70 : kTextLightColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 10),
            Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_rounded, color: kPrimaryColor, size: 14),
            ),
          ],
        ],
      ),
    );
  }
}

class Message {
  final bool isUser;
  final String message;
  final DateTime date;

  Message({required this.isUser, required this.message, required this.date});
}