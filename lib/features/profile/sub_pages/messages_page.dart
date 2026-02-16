import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bytore/core/constants/constants.dart';
import 'package:bytore/core/routes/app_routes.dart';
import 'package:bytore/core/components/custom_app_bar.dart';


class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      appBar: const CustomAppBar(title: "الرسائل"),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildMessageTile(
            "فريق دعم بايتور",
            "أهلاً بك في بايتور! نحن هنا لمساعدتك في أي استفسار.",
            "10:30 ص",
            true,
          ),
          _buildMessageTile(
            "عالم التقنية",
            "تم تأكيد طلبك رقم #12345 بنجاح.",
            "أمس",
            false,
          ),
          _buildMessageTile(
            "آفاق الكمبيوتر",
            "هل ما زلت مهتماً بجهاز MacBook Pro؟",
            "منذ يومين",
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageTile(String sender, String text, String time, bool isUnread) {
    return InkWell(
      onTap: () => Get.toNamed(AppRoutes.CHAT_DETAIL, arguments: {'senderName': sender}),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: kPrimaryColor.withOpacity(0.1),
            child: Text(sender[0], style: const TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(sender, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(time, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ],
            ),
          ),
          if (isUnread)
            Container(
              margin: const EdgeInsets.only(right: 10),
              width: 10,
              height: 10,
              decoration: const BoxDecoration(color: kSecondaryColor, shape: BoxShape.circle),
            ),
        ],
      ),
    ),
  );
}
}
