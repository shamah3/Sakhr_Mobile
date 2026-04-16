import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bytore/core/constants/constants.dart';
import 'package:bytore/features/orders/models/order_model.dart';
import 'package:bytore/core/routes/app_routes.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bytore/features/profile/controllers/purchase_reports_controller.dart';

class MyOrdersPage extends StatelessWidget {
  const MyOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final purchaseController = Get.find<PurchaseReportsController>();

    return DefaultTabController(
      length: 7,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            "طلباتي",
            style: GoogleFonts.cairo(
              color: kTextColor, 
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: kTextColor, size: 24),
            onPressed: () => Get.back(),
          ),
          bottom: TabBar(
            isScrollable: true,
            labelColor: kPrimaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: kPrimaryColor,
            tabAlignment: TabAlignment.start,
            dividerColor: Colors.transparent,
            labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13),
            unselectedLabelStyle: GoogleFonts.cairo(fontWeight: FontWeight.normal, fontSize: 13),
            tabs: const [
              Tab(text: "الكل"),
              Tab(text: "قيد الانتظار"),
              Tab(text: "قيد التجهيز"),
              Tab(text: "قيد التوصيل"),
              Tab(text: "قيد الاستلام"),
              Tab(text: "تم الاستلام"),
              Tab(text: "متأخر"),
            ],
          ),
        ),
        body: Obx(() {
          if (purchaseController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          final orders = purchaseController.orders;
          return TabBarView(
            children: [
              _buildOrderList(orders),
              _buildOrderList(orders.where((o) => o.status == OrderStatus.pending).toList()),
              _buildOrderList(orders.where((o) => o.status == OrderStatus.processing).toList()),
              _buildOrderList(orders.where((o) => o.status == OrderStatus.outForDelivery).toList()),
              _buildOrderList(orders.where((o) => o.status == OrderStatus.readyForPickup).toList()),
              _buildOrderList(orders.where((o) => o.status == OrderStatus.delivered).toList()),
              _buildOrderList(orders.where((o) => o.status == OrderStatus.late).toList()),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildOrderList(List<OrderModel> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 20,
                  )
                ],
              ),
              child: Icon(Icons.shopping_bag_outlined, size: 60, color: Colors.grey.shade300),
            ),
            const SizedBox(height: 20),
            Text(
              "لا توجد طلبات في هذا القسم", 
              style: GoogleFonts.cairo(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(order);
      },
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    IconData statusIcon;
    switch (order.status) {
      case OrderStatus.pending: statusIcon = Icons.access_time_rounded; break;
      case OrderStatus.confirmed: statusIcon = Icons.check_circle_outline_rounded; break;
      case OrderStatus.processing: statusIcon = Icons.inventory_2_outlined; break;
      case OrderStatus.outForDelivery: statusIcon = Icons.local_shipping_outlined; break;
      case OrderStatus.readyForPickup: statusIcon = Icons.hail_rounded; break;
      case OrderStatus.delivered: statusIcon = Icons.home_work_outlined; break;
      case OrderStatus.late: statusIcon = Icons.warning_amber_rounded; break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: order.statusColor.withOpacity(0.05),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: order.statusColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(statusIcon, color: order.statusColor, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    order.statusText,
                    style: GoogleFonts.cairo(
                      color: order.statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "#${order.id}",
                    style: GoogleFonts.cairo(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildInfoColumn("التاريخ", DateFormat('dd MMM, yyyy', 'ar').format(order.dateTime)),
                      _buildInfoColumn("السعر الإجمالي", "${order.totalPrice.toStringAsFixed(0)} ر.ي", isPrimary: true),
                      _buildInfoColumn("المنتجات", "${order.itemCount} عناصر"),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 1),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.toNamed(AppRoutes.TRACKING, arguments: order),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade200),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            "عرض التفاصيل",
                            style: GoogleFonts.cairo(color: kTextColor, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Get.toNamed(AppRoutes.TRACKING, arguments: order),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            "تتبع الطلب",
                            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, {bool isPrimary = false}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.cairo(color: Colors.grey, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.cairo(
              color: isPrimary ? kPrimaryColor : kTextColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
