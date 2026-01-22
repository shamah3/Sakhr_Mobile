import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:nice/controller/wallet_controller.dart';

class WalletPage extends StatelessWidget {
  WalletPage({Key? key}) : super(key: key);

  // ربط الكنترولر
  final WalletController controller = Get.put(WalletController());

  static const Color primaryBlue = Color(0xFF015C92);
  static const Color secondaryOrange = Color(0xFFFFA931);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // AppBar الموحد لمتجر محسوب
            _buildCurvedAppBar(),

            // بطاقة الرصيد التفاعلية
            Obx(() => _buildBalanceCard(controller.currentBalance)),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'سجل العمليات الأخير',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // قائمة العمليات المربوطة بـ Obx
            Expanded(
              child: Obx(() {
                if (controller.transactions.isEmpty) {
                  return const Center(child: Text('لا توجد عمليات حالياً'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: controller.transactions.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final transaction = controller.transactions[index];
                    return _buildTransactionItem(transaction);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurvedAppBar() {
    return Container(
      height: 130,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [primaryBlue, Color(0xFF0277BD)]),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
              onPressed: () => Get.back(),
            ),
            Center(
              child: Text('المحفظة المالية',
                  style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(double balance) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [secondaryOrange, Color(0xFFFF8C00)]),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: secondaryOrange.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Text('رصيدك المتاح', style: GoogleFonts.cairo(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 5),
          Text(
            '${balance.toStringAsFixed(0)} ريال',
            style: const TextStyle(color: Colors.white, fontSize: 35, fontWeight: FontWeight.bold, fontFamily: 'sans-serif'),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(transaction) {

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5)],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: transaction.isCredit ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
          child: Icon(
            transaction.isCredit ? Icons.add : Icons.remove,
            color: transaction.isCredit ? Colors.green : Colors.red,
          ),
        ),
        title: Text(transaction.title, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(transaction.date, style: const TextStyle(fontSize: 11)),
        trailing: Text(
          '${transaction.amount.toStringAsFixed(0)} ريال',
          style: TextStyle(
            color: transaction.isCredit ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}