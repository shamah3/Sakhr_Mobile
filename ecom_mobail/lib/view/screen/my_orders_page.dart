
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

// --- 1. الكنترولر لإدارة الطلبات ---
enum OrderStatus { current, completed, canceled }

class OrderModel {
final String id;
final String date;
final int itemCount;
final String total;
final OrderStatus status;

OrderModel({
required this.id,
required this.date,
required this.itemCount,
required this.total,
required this.status,
});
}

class OrdersController extends GetxController {
var allOrders = <OrderModel>[
OrderModel(id: '#12345', date: '25-12-2025', itemCount: 3, total: '150,000', status: OrderStatus.current),
OrderModel(id: '#12333', date: '22-12-2025', itemCount: 1, total: '85,000', status: OrderStatus.completed),
OrderModel(id: '#12322', date: '20-12-2025', itemCount: 2, total: '45,000', status: OrderStatus.canceled),
].obs;

List<OrderModel> get currentOrders => allOrders.where((o) => o.status == OrderStatus.current).toList();
List<OrderModel> get completedOrders => allOrders.where((o) => o.status == OrderStatus.completed).toList();
List<OrderModel> get canceledOrders => allOrders.where((o) => o.status == OrderStatus.canceled).toList();
}

// --- 2. الواجهة الرئيسية لطلباتي ---
class MyOrdersPage extends StatelessWidget {
MyOrdersPage({Key? key}) : super(key: key);

final OrdersController controller = Get.put(OrdersController());

static const Color _primaryColor = Color(0xFF015C92);
static const Color _secondaryColor = Color(0xFFFFA931);
static const Color _backgroundColor = Color(0xFFF8F9FA);

@override
Widget build(BuildContext context) {
return DefaultTabController(
length: 3,
child: Scaffold(
backgroundColor: _backgroundColor,
// بناء الـ AppBar مباشرة هنا لتجنب أخطاء الـ CustomAppBar
appBar: PreferredSize(
preferredSize: const Size.fromHeight(110), // ارتفاع الـ AppBar مع الـ Tabs
child: Container(
decoration: BoxDecoration(
color: _primaryColor,
borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
boxShadow: [
BoxShadow(color: _primaryColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
],
),
child: AppBar(
title: Text(
'طلباتي',
style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold),
),
centerTitle: true,
backgroundColor: Colors.transparent,
elevation: 0,
leading: IconButton(
icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
onPressed: () => Get.back(),
),
bottom: TabBar(
labelColor: Colors.white,
unselectedLabelColor: Colors.white.withOpacity(0.7),
indicatorColor: _secondaryColor,
indicatorWeight: 3,
labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 15),
tabs: const [
Tab(text: 'الحالية'),
Tab(text: 'المكتملة'),
Tab(text: 'الملغاة'),
],
),
),
),
),
body: Directionality(
textDirection: TextDirection.rtl,
child: Obx(() => TabBarView(
children: [
_buildOrdersList(controller.currentOrders),
_buildOrdersList(controller.completedOrders),
_buildOrdersList(controller.canceledOrders),
],
)),
),
),
);
}

Widget _buildOrdersList(List<OrderModel> orders) {
if (orders.isEmpty) {
return _buildEmptyState();
}
return ListView.builder(
padding: const EdgeInsets.all(16),
itemCount: orders.length,
itemBuilder: (context, index) => _OrderCard(order: orders[index]),
);
}


Widget _buildEmptyState() {
return Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Icon(Icons.shopping_bag_outlined, size: 80, color: _secondaryColor.withOpacity(0.7)),
const SizedBox(height: 16),
Text(
'لا توجد طلبات في هذه القائمة',
style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF6C757D)),
),
],
),
);
}
}

// --- 3. بطاقة الطلب (نفس تصميمك الأصلي) ---
class _OrderCard extends StatelessWidget {
final OrderModel order;
const _OrderCard({required this.order});

@override
Widget build(BuildContext context) {
Color statusColor = const Color(0xFF015C92);
String statusText = 'طلب حالي';

if (order.status == OrderStatus.completed) {
statusColor = Colors.green;
statusText = 'طلب مكتمل';
} else if (order.status == OrderStatus.canceled) {
statusColor = const Color(0xFFDC3545);
statusText = 'طلب ملغى';
}

return Card(
margin: const EdgeInsets.only(bottom: 16),
elevation: 4,
shadowColor: Colors.black.withOpacity(0.05),
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
child: Column(
children: [
Container(
padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
decoration: BoxDecoration(
color: statusColor.withOpacity(0.1),
borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
),
child: Row(
children: [
Icon(Icons.local_shipping_outlined, color: statusColor, size: 20),
const SizedBox(width: 8),
Text(statusText, style: GoogleFonts.cairo(color: statusColor, fontWeight: FontWeight.bold)),
],
),
),
Padding(
padding: const EdgeInsets.all(16),
child: Column(
children: [
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
_buildChip(Icons.tag, order.id),
_buildChip(Icons.calendar_today_outlined, order.date),
],
),
const Divider(height: 24),
_row('عدد المنتجات:', '${order.itemCount} منتجات'),
const SizedBox(height: 8),
_row('الإجمالي:', '${order.total} ريال', isTotal: true),
const SizedBox(height: 16),
Row(
children: [
Expanded(
child: ElevatedButton(
onPressed: () {},
style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF015C92)),
child: Text('عرض التفاصيل', style: GoogleFonts.cairo(color: Colors.white)),
),
),
if (order.status == OrderStatus.current) ...[
const SizedBox(width: 8),
Expanded(
child: OutlinedButton(
onPressed: () {},
style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFFFA931)),
child: Text('تتبع الطلب', style: GoogleFonts.cairo()),
),
),
],
],
),
],
),
),
],
),
);
}

Widget _buildChip(IconData icon, String text) => Container(
padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),


child: Row(children: [
Icon(icon, size: 16, color: Colors.grey),
const SizedBox(width: 6),
Text(text, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))
]),
);

Widget _row(String t, String v, {bool isTotal = false}) => Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Text(t, style: GoogleFonts.cairo(color: Colors.grey, fontSize: 14)),
Text(v,
style: GoogleFonts.cairo(
fontWeight: FontWeight.bold, color: isTotal ? const Color(0xFF015C92) : Colors.black, fontSize: 15)),
],
);
}