import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:bytore/features/profile/controllers/purchase_reports_controller.dart';
import 'package:bytore/core/components/custom_app_bar.dart';


class PurchaseReportsPage extends StatelessWidget {
  PurchaseReportsPage({Key? key}) : super(key: key);

// ربط الكنترولر
  final PurchaseReportsController controller = Get.put(PurchaseReportsController());

  static const Color primaryBlue = Color(0xFF015C92);
  static const Color secondaryOrange = Color(0xFFFFA931);
  static const Color bgColor = Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: const CustomAppBar(title: 'تقارير المشتريات'),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // _buildCurvedAppBar(), removed

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildTimeFilter(),
                  const SizedBox(height: 25),

// الإحصائيات تتحدث تلقائياً عند تغيير الفلتر
                  Obx(() => Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'إجمالي الإنفاق',
                          controller.totalSpending.value,
                          Icons.account_balance_wallet_outlined,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildStatCard(
                          'عدد الطلبات',
                          controller.ordersCount.value,
                          Icons.shopping_bag_outlined,
                        ),
                      ),
                    ],
                  )),

                  const SizedBox(height: 25),
                  _buildChartSection(),
                  const SizedBox(height: 25),
                  _buildSectionTitle('ملخص المشتريات الأخيرة'),
                  _buildOrderSummaryTile('آيفون 15 برو ماكس', '450,000 ريال', '12 ديسمبر'),
                  _buildOrderSummaryTile('ساعة شاومي S3', '45,000 ريال', '05 ديسمبر'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildTimeFilter() {
    return Center(
      child: Obx(() => SegmentedButton<TimeFilter>(
        segments: const [
          ButtonSegment(value: TimeFilter.weekly, label: Text('أسبوعي')),
          ButtonSegment(value: TimeFilter.monthly, label: Text('شهري')),
          ButtonSegment(value: TimeFilter.yearly, label: Text('سنوي')),


        ],
        selected: {controller.selectedFilter.value},
        onSelectionChanged: (newSelection) {
          controller.changeFilter(newSelection.first);
        },
        style: SegmentedButton.styleFrom(
          backgroundColor: Colors.white,
          selectedBackgroundColor: secondaryOrange,
          selectedForegroundColor: Colors.white,
          side: BorderSide(color: secondaryOrange.withOpacity(0.5)),
          textStyle: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      )),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: secondaryOrange, size: 24),
          const SizedBox(height: 12),
          Text(title, style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.cairo(fontSize: 12, color: primaryBlue, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تحليل الإنفاق',
            style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 20),
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                color: primaryBlue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Obx(() => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart_rounded, size: 50, color: secondaryOrange.withOpacity(0.5)),
                    Text(
                      'الرسم البياني للإنفاق ${controller.selectedFilter.value == TimeFilter.monthly ? "الشهري" : controller.selectedFilter.value == TimeFilter.weekly ? "الأسبوعي" : "السنوي"}',
                      style: GoogleFonts.cairo(color: primaryBlue.withOpacity(0.5)),
                    ),
                  ],
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(
        title,
        style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
      ),
    );
  }

  Widget _buildOrderSummaryTile(String name, String price, String date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,


            children: [
              Text(name, style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold)),
              Text(date, style: GoogleFonts.cairo(fontSize: 11, color: secondaryOrange)),
            ],
          ),
          Text(price, style: GoogleFonts.cairo(color: primaryBlue, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
