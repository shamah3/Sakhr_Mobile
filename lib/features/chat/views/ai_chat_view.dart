import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart' as intl;
import 'package:bytore/core/constants/constants.dart';
import 'package:get/get.dart';
import 'dart:ui';

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

  // API Key - In production this should be in an environment variable or secure storage
  static const apiKey = "AIzaSyAS_tVOD5wOeiG5tOd4qvD5LcIWuGgeQnE";

  final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

  final List<Message> _messages = [
    Message(
      isUser: false, 
      message: "مرحباً بك! أنا مساعدك الذكي في متجر صخر. كيف يمكنني مساعدتك اليوم؟", 
      date: DateTime.now()
    ),
  ];
  bool isLoading = false;

  static const assistantInstruction =
      "أنت مساعد ذكي يدعى 'صخر AI' داخل تطبيق متجر 'صخر' الإلكتروني. "
      "مهمتك هي مساعدة المستخدمين في الاستفسار عن المنتجات الإلكترونية والتقنية، الأسعار، العروض، وطرق الشحن والدفع. "
      "أسلوبك يجب أن يكون مهنياً، ودوداً، ومختصراً. "
      "أجب باللغة العربية حصراً. لا تذكر أي معلومات خارج نطاق المتجر.";

  Future<void> sendMessage() async {
    if (_userMessage.text.trim().isEmpty) return;

    final userMessageText = _userMessage.text.trim();
    _userMessage.clear();
    
    setState(() {
      _messages.add(Message(
          isUser: true, message: userMessageText, date: DateTime.now()));
      isLoading = true;
    });

    _scrollToBottom();

    try {
      final chatMessages = _messages.map((m) {
        return m.isUser ? Content.text(m.message) : Content.model([TextPart(m.message)]);
      }).toList();

      // Add instruction as system prompt if needed, but for now append to last message or use session
      final content = [Content.text("$assistantInstruction\n\nالمستخدم: $userMessageText")];
      
      final response = await model.generateContent(content).timeout(const Duration(seconds: 15));

      if (mounted) {
        setState(() {
          _messages.add(Message(
              isUser: false, 
              message: response.text ?? "عذراً، لم أستطع معالجة الطلب حالياً.", 
              date: DateTime.now()));
          isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        String fallbackResponse = _getFallbackResponse(userMessageText);
        setState(() {
          _messages.add(Message(
              isUser: false, 
              message: fallbackResponse, 
              date: DateTime.now()));
          isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  String _getFallbackResponse(String input) {
    final lowerInput = input.toLowerCase();
    if (lowerInput.contains('لابتوب') || lowerInput.contains('كمبيوتر') || lowerInput.contains('mac')) {
      return 'لدينا مجموعة رائعة من اللابتوبات الحديثة، أبرزها لابتوبات Apple وأجهزة المحترفين. يمكنك تفقد قسم التخفيضات!';
    } else if (lowerInput.contains('سعر') || lowerInput.contains('رخيص') || lowerInput.contains('تخفيض') || lowerInput.contains('خصم')) {
      return 'نطمح دائماً لتقديم أفضل الأسعار مع خصومات دورية. تفضل بزيارة قسم "الخصومات" عبر الصفحة الرئيسية للإطلاع على عروضنا.';
    } else if (lowerInput.contains('توصيل') || lowerInput.contains('شحن')) {
      return 'نوفر خدمة توصيل سريعة لكافة المناطق. سيتم عرض تفاصيل التوصيل أثناء إتمام عملية الشراء.';
    } else if (lowerInput.contains('مرحبا') || lowerInput.contains('هلا') || lowerInput.contains('السلام')) {
      return 'أهلاً بك في متجر صخر! كيف يمكنني مساعدتك للوصول لمنتجك التقني المفضل؟';
    } else {
      return 'عذراً لا أملك إجابة دقيقة على ذلك. هل تبحث عن "$input"؟ يمكنك استخدام أيقونة البحث أعلى الصفحة للوصول السريع، أو إعطائي تفاصيل أكثر.';
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
                child: ListView.builder(
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