 import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class MessagesPage extends StatefulWidget {
const MessagesPage({super.key});

@override
State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
// ألوان هوية صخر
static const Color kSakhrBlue = Color(0xFF015C92);
static const Color kSakhrGold = Color(0xFFFFA931);
static const Color kBgColor = Color(0xFFF8FAFC);

// متغير للتحكم في المتجر المختار (null يعني لم يتم اختيار متجر بعد)
String? selectedStore;
final TextEditingController _msgController = TextEditingController();

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: kBgColor,
appBar: _buildAppBar(),
body: AnimatedSwitcher(
duration: const Duration(milliseconds: 400),
child: selectedStore == null
? _buildStoreGrid() // عرض المربعات أولاً
    : _buildChatDetail(), // عرض المحادثة عند الاختيار
),
);
}

// --- 1. الهيدر (AppBar) ---
PreferredSizeWidget _buildAppBar() {
return AppBar(
backgroundColor: kSakhrBlue,
elevation: 0,
centerTitle: true,
title: Text(
selectedStore ?? "مركز الرسائل",
style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
),
leading: selectedStore != null
? IconButton(
icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
onPressed: () => setState(() => selectedStore = null),
)
    : null,
);
}

// --- 2. واجهة اختيار المتاجر (المربعات) ---
Widget _buildStoreGrid() {
final List<Map<String, dynamic>> stores = [
{"name": "سيلكون", "icon": Icons.developer_board_rounded, "color": const Color(0xFFE3F2FD)},
{"name": "كنان", "icon": Icons.storefront_rounded, "color": const Color(0xFFFFF3E0)},
];

return Padding(
padding: const EdgeInsets.all(25.0),
child: Column(
crossAxisAlignment: CrossAxisAlignment.end,
children: [
Text("تواصل مع المتاجر", style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: kSakhrBlue)),
const SizedBox(height: 5),
Text("اختر المتجر الذي تود مراسلته بخصوص طلبك", style: GoogleFonts.cairo(fontSize: 13, color: Colors.grey)),
const SizedBox(height: 30),
Row(
mainAxisAlignment: MainAxisAlignment.center,
children: stores.map((store) => _buildStoreSquare(store)).toList(),
),
],
),
);
}

Widget _buildStoreSquare(Map<String, dynamic> store) {
return GestureDetector(
onTap: () => setState(() => selectedStore = store['name']),
child: Container(
width: 130,
height: 140,
margin: const EdgeInsets.symmetric(horizontal: 10),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(20),
border: Border.all(color: Colors.grey.shade100),
boxShadow: [
BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8)),
],
),
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Container(
padding: const EdgeInsets.all(15),
decoration: BoxDecoration(color: store['color'], shape: BoxShape.circle),
child: Icon(store['icon'], color: kSakhrBlue, size: 30),
),
const SizedBox(height: 15),
Text(store['name'], style: GoogleFonts.cairo(fontWeight: FontWeight.w900, fontSize: 15, color: kSakhrBlue)),
],
),
),
);
}
// --- 3. واجهة المحادثة التفصيلية ---
Widget _buildChatDetail() {
return Column(
children: [
Expanded(
child: Container(
margin: const EdgeInsets.only(top: 10),
decoration: const BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
),
child: ListView(
padding: const EdgeInsets.all(20),
children: [
_buildBubble("مرحباً بك! كيف يمكن لمتجر $selectedStore خدمتك اليوم؟", false),
_buildBubble("أريد الاستفسار عن ضمان أجهزة الماك بوك", true),
],
),
),
),
_buildInputArea(),
],
);
}

Widget _buildBubble(String text, bool isMe) {
return Align(
alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
child: Container(
margin: const EdgeInsets.only(bottom: 15),
padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
decoration: BoxDecoration(
color: isMe ? kSakhrBlue : const Color(0xFFF1F5F9),
borderRadius: BorderRadius.only(
topLeft: const Radius.circular(15),
topRight: const Radius.circular(15),
bottomLeft: Radius.circular(isMe ? 15 : 0),
bottomRight: Radius.circular(isMe ? 0 : 15),
),
),
child: Text(text, style: GoogleFonts.cairo(color: isMe ? Colors.white : Colors.black87, fontSize: 13)),
),
);
}

Widget _buildInputArea() {
return Container(
padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
decoration: BoxDecoration(
color: Colors.white,
boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))],
),
child: SafeArea(
child: Row(
children: [
Expanded(
child: Container(
padding: const EdgeInsets.symmetric(horizontal: 20),
decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(30)),
child: TextField(
controller: _msgController,
textAlign: TextAlign.right,
style: GoogleFonts.cairo(fontSize: 13),
decoration: const InputDecoration(hintText: "اكتب رسالتك...", border: InputBorder.none),
),
),
),
const SizedBox(width: 10),
GestureDetector(
onTap: () => _msgController.clear(),
child: const CircleAvatar(
backgroundColor: kSakhrGold,
radius: 22,
child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
),
),
],
),
),
);
}
}