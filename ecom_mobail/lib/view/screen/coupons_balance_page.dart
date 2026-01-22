
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

// --- 1. الكنترولر لإدارة بيانات المحفظة ---
class WalletController extends GetxController {
var balance = "17,500".obs;
var transactions = <Map<String, dynamic>>[
{
'title': 'شراء منتج #12345',
'amount': -15000.0,
'isCredit': false,
'date': '28-12-2025',
},
{
'title': 'إيداع رصيد',
'amount': 50000.0,
'isCredit': true,
'date': '25-12-2025',
},
{
'title': 'استرجاع منتج #12322',
'amount': 4500.0,
'isCredit': true,
'date': '22-12-2025',
},
].obs;

void applyCoupon(String code) {
if (code.isNotEmpty) {
Get.snackbar("القسائم", "تم تطبيق القسيمة بنجاح",
backgroundColor: Colors.green, colorText: Colors.white);
}
}
}

// --- 2. الواجهة الرئيسية للمحفظة ---
class CouponsBalancePage extends StatelessWidget {
CouponsBalancePage({Key? key}) : super(key: key);

// تعريف الكنترولر
final WalletController controller = Get.put(WalletController());

// الألوان الثابتة للهوية
static const Color _primaryColor = Color(0xFF015C92);
static const Color _secondaryColor = Color(0xFFF8F9FA);
static const Color _accentOrange = Color(0xFFFFA931);
static const Color _textPrimary = Color(0xFF212529);
static const Color _creditColor = Colors.green;
static const Color _debitColor = Color(0xFFDC3545);

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: const Color(0xFFF8F9FA),
// بناء AppBar مدمج لتجنب أخطاء الكلاسات الخارجية
appBar: AppBar(
title: Text('المحفظة والقسائم',
style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.white)),
centerTitle: true,
backgroundColor: _primaryColor,
elevation: 0,
shape: const RoundedRectangleBorder(
borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
),
leading: IconButton(
icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
onPressed: () => Get.back(),
),
),
body: Directionality(
textDirection: TextDirection.rtl,
child: SingleChildScrollView(
padding: const EdgeInsets.all(16),
child: Column(
crossAxisAlignment: CrossAxisAlignment.stretch,
children: [
_buildBalanceCard(),
const SizedBox(height: 25),
_buildCouponsSection(),
const SizedBox(height: 25),
_buildTransactionsSection(),
],
),
),
),
);
}

// بطاقة الرصيد (تصميم جذاب)
Widget _buildBalanceCard() {
return Container(
padding: const EdgeInsets.all(24),
decoration: BoxDecoration(
gradient: const LinearGradient(
colors: [_primaryColor, Color(0xFF0173B7)],
begin: Alignment.topLeft,
end: Alignment.bottomRight,
),
borderRadius: BorderRadius.circular(20),
boxShadow: [
BoxShadow(color: _primaryColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
],
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
children: [
const Icon(Icons.account_balance_wallet_outlined, color: _accentOrange, size: 28),
const SizedBox(width: 10),
Text('الرصيد الحالي', style: GoogleFonts.cairo(color: Colors.white70, fontSize: 16)),
],
),
const SizedBox(height: 10),
Obx(() => Text(
'${controller.balance.value} ريال',
style: GoogleFonts.cairo(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
)),
const Divider(color: Colors.white24, height: 30),
ElevatedButton.icon(
onPressed: () {},
icon: const Icon(Icons.add_card, color: _accentOrange),
label: Text('شحن المحفظة الآن',
style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: _primaryColor)),
style: ElevatedButton.styleFrom(
backgroundColor: Colors.white,
minimumSize: const Size(double.infinity, 50),
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
),
),
],
),
);
}

// قسم القسائم
Widget _buildCouponsSection() {
final TextEditingController couponText = TextEditingController();
return Container(
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(20),
border: Border.all(color: Colors.grey.withOpacity(0.1)),
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text('هل لديك قسيمة خصم؟',
style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold)),
const SizedBox(height: 15),
Row(
children: [
Expanded(
child: TextField(
controller: couponText,
decoration: InputDecoration(
hintText: 'أدخل الرمز هنا...',
filled: true,
fillColor: _secondaryColor,
border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
),
),
),
const SizedBox(width: 10),
ElevatedButton(
onPressed: () => controller.applyCoupon(couponText.text),
style: ElevatedButton.styleFrom(
backgroundColor: _primaryColor,
padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
),
child: Text('تطبيق', style: GoogleFonts.cairo(color: Colors.white)),
),
],
),
],
),
);
}

// سجل العمليات
Widget _buildTransactionsSection() {
return Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Padding(
padding: const EdgeInsets.symmetric(horizontal: 5),
child: Text('آخر العمليات المودعة والمسحوبة',
style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: _textPrimary)),
),
const SizedBox(height: 15),
Obx(() => ListView.separated(
shrinkWrap: true,
physics: const NeverScrollableScrollPhysics(),
itemCount: controller.transactions.length,
separatorBuilder: (_, __) => const SizedBox(height: 10),
itemBuilder: (context, index) {
final item = controller.transactions[index];
final bool isCredit = item['isCredit'];
return Container(
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(15),
),
child: ListTile(
leading: CircleAvatar(
backgroundColor: (isCredit ? _creditColor : _debitColor).withOpacity(0.1),
child: Icon(isCredit ? Icons.add : Icons.remove,
color: isCredit ? _creditColor : _debitColor),
),
title: Text(item['title'], style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14)),


subtitle: Text(item['date'], style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey)),
trailing: Text(
'${isCredit ? '+' : ''}${item['amount']} ر.ي',
style: GoogleFonts.cairo(
color: isCredit ? _creditColor : _debitColor,
fontWeight: FontWeight.bold,
),
),
),
);
},
)),
],
);
}
}