
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:chat_bubbles/chat_bubbles.dart';

class AiChatPage extends StatefulWidget {
const AiChatPage({super.key});

@override
State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
final TextEditingController _controller = TextEditingController();
final ScrollController _scrollController = ScrollController();

final Color _primaryColor = const Color(0xFF015C92);
final Color _secondaryColor = const Color(0xFFFFA931);

bool _isAiTyping = false;
Timer? _aiResponseTimer;

final List<Map<String, dynamic>> _messages = [
{
'isUser': false,
'text': 'مرحباً بك في Mahsoob! كيف يمكنني مساعدتك اليوم؟',
},
];

void _sendMessage() {
if (_controller.text.trim().isEmpty) return;

final String text = _controller.text.trim();

setState(() {
_messages.add({'isUser': true, 'text': text});
_isAiTyping = true;
});

_controller.clear();
_scrollToBottom();

_aiResponseTimer?.cancel();
_aiResponseTimer = Timer(const Duration(seconds: 3), () {
if (!_isAiTyping) return;

setState(() {
_isAiTyping = false;
_messages.add({
'isUser': false,
'text': 'وجدنا لك أفضل الخيارات بناءً على طلبك!',
});
});

_scrollToBottom();
});
}

void _stopAiResponse() {
setState(() {
_isAiTyping = false;
});
_aiResponseTimer?.cancel();
}

void _scrollToBottom() {
if (_scrollController.hasClients) {
Timer(const Duration(milliseconds: 100), () {
_scrollController.animateTo(
_scrollController.position.maxScrollExtent,
duration: const Duration(milliseconds: 300),
curve: Curves.easeOut,
);
});
}
}

@override
void dispose() {
_controller.dispose();
_scrollController.dispose();
_aiResponseTimer?.cancel();
super.dispose();
}

@override
Widget build(BuildContext context) {
return Directionality(
textDirection: TextDirection.rtl,
child: Scaffold(
backgroundColor: Colors.grey[100],
appBar: _buildChatAppBar(),
body: Column(
children: [
Expanded(
child: ListView.builder(
controller: _scrollController,
padding: const EdgeInsets.all(10),
itemCount: _messages.length + (_isAiTyping ? 1 : 0),
itemBuilder: (context, index) {
if (index == _messages.length && _isAiTyping) {
return  BubbleSpecialThree(
text: '',
color:Colors.white,
isSender: false,
tail: false,
);
}

final message = _messages[index];
return _buildMessageBubble(
text: message['text'],
isUser: message['isUser'],
);
},
),
),
_buildMessageInputField(),
],
),
),
);
}

AppBar _buildChatAppBar() {
return AppBar(
backgroundColor: Colors.white,
elevation: 1,
automaticallyImplyLeading: false,
actions: [
IconButton(
icon: const Icon(Icons.arrow_forward, color: Color(0xFF015C92)),
onPressed: () => Navigator.of(context).pop(),
),
],
title: Row(
children: [
CircleAvatar(
backgroundColor: _primaryColor,
child: const Icon(
Icons.support_agent,
color: Colors.white,
size: 22,
),
),
const SizedBox(width: 10),


Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text(
'المساعد الذكي',
style: TextStyle(
color: Colors.black,
fontSize: 18,
fontWeight: FontWeight.bold,
),
),
Text(
'متصل الآن',
style: TextStyle(
color: _secondaryColor,
fontSize: 11,
fontWeight: FontWeight.w600,
),
),
],
),
],
),
);
}

Widget _buildMessageBubble({
required String text,
required bool isUser,
}) {
return BubbleSpecialThree(
text: text,
color: isUser ? _primaryColor : const Color(0xFFE8E8EE),
textStyle: TextStyle(
color: isUser ? Colors.white : Colors.black87,
fontSize: 16,
),
isSender: !isUser,
tail: true,
);
}

Widget _buildMessageInputField() {
return Container(
padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
decoration: BoxDecoration(
color: Colors.white,
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.05),
blurRadius: 10,
),
],
),
child: Row(
children: [
Expanded(
child: TextField(
controller: _controller,
textCapitalization: TextCapitalization.sentences,
decoration: InputDecoration(
hintText: 'اكتب رسالتك هنا...',
filled: true,
fillColor: Colors.grey[100],
contentPadding: const EdgeInsets.symmetric(
vertical: 10,
horizontal: 15,
),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(30),
borderSide: BorderSide.none,
),
),
onSubmitted: (_) => _sendMessage(),
),
),
const SizedBox(width: 8),
InkWell(
onTap: _isAiTyping ? _stopAiResponse : _sendMessage,
child: CircleAvatar(
radius: 18,
backgroundColor:
_isAiTyping ? Color(0xFFFFA931) : _primaryColor,
child: Icon(
_isAiTyping ? Icons.stop : Icons.send,
color: Colors.white,
size: 18,
),
),
),
],
),
);
}
}