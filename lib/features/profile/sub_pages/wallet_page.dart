import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:bytore/features/profile/controllers/wallet_controller.dart';
import 'package:bytore/features/profile/models/wallet_model.dart';
import 'package:bytore/core/components/custom_app_bar.dart';


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
      appBar: const CustomAppBar(title: 'المحفظة المالية'),
      body: Column(
          children: [
            // AppBar الموحد لمتجر محسوب
            // _buildCurvedAppBar(), removed

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

  Widget _buildTransactionItem(WalletTransaction transaction) {
    final bool isCredit = transaction.type == 'credit';
    final dateStr = "${transaction.createdAt.day}-${transaction.createdAt.month}-${transaction.createdAt.year}";

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
          backgroundColor: isCredit ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
          child: Icon(
            isCredit ? Icons.add : Icons.remove,
            color: isCredit ? Colors.green : Colors.red,
          ),
        ),
        title: Text(transaction.description, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(dateStr, style: const TextStyle(fontSize: 11)),
        trailing: Text(
          '${transaction.amount.toStringAsFixed(0)} ريال',
          style: TextStyle(
            color: isCredit ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
