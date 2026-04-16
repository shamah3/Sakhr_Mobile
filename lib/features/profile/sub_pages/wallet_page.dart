import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:bytore/features/profile/controllers/wallet_controller.dart';
import 'package:bytore/features/profile/models/wallet_model.dart';
import 'package:bytore/core/components/custom_app_bar.dart';
import 'package:bytore/core/constants/constants.dart';

class WalletPage extends StatelessWidget {
  WalletPage({Key? key}) : super(key: key);

  final WalletController controller = Get.put(WalletController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F9),
      appBar: const CustomAppBar(title: 'المحفظة الرقمية'),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Obx(() => _buildPremiumBalanceCard(controller.currentBalance)),
                _buildQuickActions(),
                _buildStatsSummary(),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 15),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'سجل العمليات الأخير',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kTextColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Obx(() {
            if (controller.transactions.isEmpty) {
              return const SliverFillRemaining(
                child: Center(child: Text('لا توجد عمليات حالياً', style: TextStyle(color: Colors.grey))),
              );
            }
            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final transaction = controller.transactions[index];
                    return _buildModernTransactionItem(transaction);
                  },
                  childCount: controller.transactions.length,
                ),
              ),
            );
          }),
          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }

  Widget _buildPremiumBalanceCard(double balance) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: kPrimaryColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: kPrimaryColor.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 10)),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            kPrimaryColor,
            kPrimaryColor.withBlue(150),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('إجمالي الرصيد المتاح', 
                    style: GoogleFonts.cairo(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${balance.toStringAsFixed(0)} ريال',
                    style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w900, fontFamily: 'sans-serif'),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                ),
                child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 35),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _balanceMiniStat("رقم المحفظة", "SAK-88220"),
              _balanceMiniStat("تحديث تلقائي", "نشط الآن"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _balanceMiniStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.cairo(color: Colors.white54, fontSize: 10)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: [
          Expanded(child: _actionBtn("إيداع سريع", Icons.add_circle_outline, Colors.green)),
          const SizedBox(width: 12),
          Expanded(child: _actionBtn("سحب رصيد", Icons.arrow_circle_down_outlined, Colors.red)),
          const SizedBox(width: 12),
          Expanded(child: _actionBtn("تحويل مالي", Icons.swap_horiz_rounded, Colors.orange)),
        ],
      ),
    );
  }

  Widget _actionBtn(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold, color: kTextColor)),
        ],
      ),
    );
  }

  Widget _buildStatsSummary() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem("صادر", "45,000", Colors.redAccent, Icons.trending_down),
          Container(height: 40, width: 1.5, color: Colors.grey.withOpacity(0.08)),
          _statItem("وارد", "120,000", Colors.blueAccent, Icons.trending_up),
        ],
      ),
    );
  }

  Widget _statItem(String title, String val, Color color, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(title, style: GoogleFonts.cairo(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 6),
        Text('$val ريال', style: TextStyle(fontWeight: FontWeight.w900, color: color, fontSize: 16, fontFamily: 'sans-serif')),
      ],
    );
  }

  Widget _buildModernTransactionItem(WalletTransaction transaction) {
    final bool isCredit = transaction.type == 'credit';
    final dateStr = "${transaction.createdAt.day}/${transaction.createdAt.month} ${transaction.createdAt.hour}:${transaction.createdAt.minute}";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.015), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCredit ? Colors.green.withOpacity(0.08) : Colors.red.withOpacity(0.08),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              isCredit ? Icons.keyboard_double_arrow_up_rounded : Icons.keyboard_double_arrow_down_rounded,
              color: isCredit ? Colors.green : Colors.red,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.description, style: GoogleFonts.cairo(fontWeight: FontWeight.w800, color: kTextColor, fontSize: 14)),
                const SizedBox(height: 4),
                Text(dateStr, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isCredit ? "+" : "-"}${transaction.amount.toStringAsFixed(0)}',
                style: TextStyle(color: isCredit ? Colors.green : Colors.red, fontWeight: FontWeight.w900, fontSize: 16, fontFamily: 'sans-serif'),
              ),
              Text(isCredit ? "إيداع" : "سحب", style: const TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}
