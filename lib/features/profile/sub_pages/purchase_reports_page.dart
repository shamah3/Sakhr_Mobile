import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:bytore/features/profile/controllers/purchase_reports_controller.dart';
import 'package:bytore/core/components/custom_app_bar.dart';
import 'package:bytore/features/orders/models/order_model.dart';


class PurchaseReportsPage extends StatelessWidget {
  PurchaseReportsPage({Key? key}) : super(key: key);

// ربط الكنترولر
  final PurchaseReportsController controller = Get.find<PurchaseReportsController>();

  static const Color primaryBlue = Color(0xFF015C92);
  static const Color secondaryOrange = Color(0xFFFFA931);
  static const Color bgColor = Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: const CustomAppBar(title: 'تقارير المشتريات'),
      body: Column(
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
                  
                  Obx(() {
                    if (controller.isLoading.value) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: CircularProgressIndicator(color: secondaryOrange)),
                      );
                    }
                    if (controller.filteredOrders.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: Text("لا توجد مشتريات في هذه الفترة", style: GoogleFonts.cairo(color: Colors.grey))),
                      );
                    }
                    
                    return Column(
                      children: controller.filteredOrders.expand<Widget>((OrderModel order) {
                        return order.itemsNames.map<Widget>((String itemName) {
                          return _buildProductCard(
                            itemName,
                            "${order.totalPrice.toStringAsFixed(0)} ريال",
                            DateFormat('dd MMM', 'ar').format(order.dateTime),
                            order.id,
                          );
                        });
                      }).toList(),
                    );
                  }),
                ],
              ),
            ),
          ],
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
          const SizedBox(height: 25),
          AspectRatio(
            aspectRatio: 1.8,
            child: Obx(() {
              if (controller.filteredOrders.isEmpty) {
                 return Center(
                   child: Column(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       Icon(Icons.bar_chart_rounded, size: 40, color: Colors.grey[300]),
                       Text("لا توجد بيانات للعرض", style: GoogleFonts.cairo(color: Colors.grey[400], fontSize: 12)),
                     ],
                   ),
                 );
              }

              // تجميع البيانات للرسم البياني (آخر 7 فترات حسب الفلتر)
              // تبسيط: سنظهر آخر 7 طلبات كأعمدة أو نوزعهم
              final chartData = controller.filteredOrders.take(7).toList().reversed.toList();
              final maxTotal = chartData.isEmpty ? 1.0 : chartData.map((e) => e.totalPrice).reduce((a, b) => a > b ? a : b);

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: chartData.map((order) {
                  final barHeight = (order.totalPrice / (maxTotal == 0 ? 1 : maxTotal)) * 100;
                  return Tooltip(
                    message: "${order.totalPrice.toStringAsFixed(0)} ر.ي",
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 25,
                          height: barHeight.clamp(5, 120),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [secondaryOrange, secondaryOrange.withOpacity(0.6)],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat('dd/MM', 'ar').format(order.dateTime),
                          style: GoogleFonts.cairo(fontSize: 10, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            }),
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

  Widget _buildProductCard(String name, String price, String date, dynamic orderId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: Colors.grey.shade50),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  price,
                  style: GoogleFonts.cairo(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.tag, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    "#${orderId.toString()}",
                    style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.calendar_month_outlined, size: 14, color: secondaryOrange),
                  const SizedBox(width: 4),
                  Text(
                    date,
                    style: GoogleFonts.cairo(fontSize: 11, color: secondaryOrange, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
