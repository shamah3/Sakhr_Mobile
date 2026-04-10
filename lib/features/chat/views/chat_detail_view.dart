import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bytore/core/constants/constants.dart';

import 'package:bytore/features/chat/controllers/chat_controller.dart';

class ChatDetailView extends StatefulWidget {
  const ChatDetailView({super.key});

  @override
  State<ChatDetailView> createState() => _ChatDetailViewState();
}

class _ChatDetailViewState extends State<ChatDetailView> {
  final TextEditingController _messageController = TextEditingController();
  final String senderName = Get.arguments?['senderName'] ?? "المتجر";
  final int storeId = Get.arguments?['storeId'] ?? 1;
  late final ChatController chatController;

  @override
  void initState() {
    super.initState();
    chatController = Get.find<ChatController>();
    // When opening the chat, mark all messages as read
    // Post frame callback to avoid Obx state changes during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      chatController.markAsRead(storeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        toolbarHeight: 70, // Slightly taller for a modern look
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: kPrimaryColor.withOpacity(0.1),
                  child: Text(senderName[0],
                      style: const TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold, fontSize: 18)),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(senderName, style: const TextStyle(color: kTextColor, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                const Text("متصل الآن", style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: kTextColor, size: 20),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: kTextColor, size: 22),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              final messages = chatController.getMessagesForStore(storeId);
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  return Directionality(
                    textDirection: TextDirection.rtl,
                    child: _buildChatBubble(msg['text'], msg['isMe'], msg['time']),
                  );
                },
              );
            }),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isMe, String time) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        constraints: BoxConstraints(maxWidth: Get.width * 0.78),
        decoration: BoxDecoration(
          color: isMe ? kPrimaryColor : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: isMe ? kPrimaryColor.withOpacity(0.15) : Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              text,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: isMe ? Colors.white : kTextColor.withOpacity(0.9),
                fontSize: 15,
                height: 1.4,
                fontWeight: isMe ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: TextStyle(color: isMe ? Colors.white.withOpacity(0.6) : Colors.grey.shade400, fontSize: 10),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.done_all_rounded, size: 12, color: Colors.white.withOpacity(0.6)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.only(
          left: 15, right: 15, top: 15,
          bottom: Get.context != null ? MediaQuery.of(Get.context!).padding.bottom + 15 : 15
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kBgColor,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: const Icon(Icons.add_rounded, color: kTextColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: kBgColor,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: TextField(
                controller: _messageController,
                style: const TextStyle(fontSize: 14),
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  hintText: "اكتب رسالتك هنا...",
                  hintTextDirection: TextDirection.rtl,
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: () {
              if (_messageController.text.trim().isNotEmpty) {
                chatController.sendMessage(storeId, senderName, _messageController.text.trim());
                _messageController.clear();
              }
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: kPrimaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: kPrimaryColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
