import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bytore/core/constants/constants.dart';
import 'package:bytore/features/orders/controllers/tracking_controller.dart';
import 'package:bytore/features/orders/models/order_model.dart';
import 'package:intl/intl.dart';
import 'package:bytore/features/profile/controllers/returned_products_controller.dart';
import 'package:bytore/features/profile/models/returned_product_model.dart';
import 'package:bytore/features/profile/controllers/activities_controller.dart';
import 'package:bytore/core/utils/notification_helper.dart';

class TrackingView extends GetView<TrackingController> {
  const TrackingView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is registered
    if (!Get.isRegistered<TrackingController>()) {
      Get.put(TrackingController());
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("تتبع الطلب", style: TextStyle(color: kTextColor, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_rounded, color: kTextColor, size: 24),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded, color: kTextColor, size: 24),
            onPressed: () {},
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final order = controller.order.value;
        if (order == null) {
          return const Center(child: Text("لم يتم العثور على بيانات الطلب"));
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildModernOrderHeader(order),
                      const SizedBox(height: 35),
                      const Row(
                        children: [
                          Icon(Icons.timeline_rounded, color: kPrimaryColor, size: 20),
                          SizedBox(width: 10),
                          Text(
                            'تتبع مسار الشحنة',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: kTextColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      _buildVisualTimeline(order),
                      const SizedBox(height: 35),
                      const Text(
                        'تفاصيل التوصيل',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: kTextColor),
                      ),
                      const SizedBox(height: 20),
                      _buildShippingInfoCard(order),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomAction(context, order),
          ],
        );
      }),
    );
  }

  Widget _buildModernOrderHeader(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: kPrimaryColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('رقم الطلب', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 6),
                  Text('#${order.id}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18, letterSpacing: 1)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(order.statusText, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 25),
          const Divider(color: Colors.white12, height: 1.5),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(color: Color(0xFFFFA000), shape: BoxShape.circle),
                child: const Icon(Icons.local_shipping_rounded, color: Colors.white, size: 20),
              ),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('تاريخ الطلب', style: TextStyle(color: Colors.white70, fontSize: 11)),
                      const SizedBox(height: 2),
                      Text(DateFormat('dd MMMM, yyyy', 'ar').format(order.dateTime), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 18),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVisualTimeline(OrderModel order) {
    final status = order.status;

    // تحديد الفهرس الحالي بناءً على التسلسل المنطقي
    final statusSequence = [
      OrderStatus.pending,
      OrderStatus.confirmed,
      OrderStatus.processing,
      OrderStatus.outForDelivery,
      OrderStatus.delivered,
    ];
    
    int currentIdx = statusSequence.indexOf(status);
    if (currentIdx == -1) currentIdx = 0;
    
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          _buildStep(
            icon: Icons.receipt_long_rounded,
            title: "تم استلام الطلب",
            sub: "تلقينا طلبك وبانتظار المراجعة",
            time: "الآن",
            color: currentIdx >= 0 ? const Color(0xFF4CAF50) : Colors.grey.shade300,
            isLineActive: currentIdx > 0,
            isCurrent: currentIdx == 0,
          ),
          _buildStep(
            icon: Icons.done_all_rounded,
            title: "تم التأكيد",
            sub: "تم التحقق من الطلب وتأكيده",
            time: currentIdx >= 1 ? "منذ قليل" : "--:--",
            color: currentIdx >= 1 ? const Color(0xFF4CAF50) : Colors.grey.shade300,
            isLineActive: currentIdx > 1,
            isCurrent: currentIdx == 1,
          ),
          _buildStep(
            icon: Icons.inventory_2_rounded,
            title: "جاري التجهيز",
            sub: "يتم الآن تغليف طلبك في المستودع",
            time: currentIdx >= 2 ? "تحديث الآن" : "--:--",
            color: currentIdx >= 2 ? const Color(0xFF4CAF50) : Colors.grey.shade300,
            isLineActive: currentIdx > 2,
            isCurrent: currentIdx == 2,
          ),
          _buildStep(
            icon: Icons.local_shipping_rounded,
            title: "خرج للتوصيل",
            sub: "المندوب في طريقه إلى عنوانك",
            time: currentIdx >= 3 ? "تحديث الآن" : "--:--",
            color: currentIdx >= 3 ? const Color(0xFF4CAF50) : Colors.grey.shade300,
            isLineActive: currentIdx > 3,
            isCurrent: currentIdx == 3,
          ),
          _buildStep(
            icon: Icons.check_circle_outline_rounded,
            title: "تم الاستلام",
            sub: "تم تسليم الطلب بنجاح",
            time: currentIdx >= 4 ? "تم" : "--:--",
            color: currentIdx >= 4 ? const Color(0xFF4CAF50) : Colors.grey.shade300,
            isLineActive: false,
            isLast: true,
            isCurrent: currentIdx == 4,
          ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required IconData icon,
    required String title,
    required String sub,
    required String time,
    required Color color,
    required bool isLineActive,
    bool isLast = false,
    bool isCurrent = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: isCurrent ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))] : [],
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: isLineActive ? const Color(0xFF4CAF50) : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isCurrent ? const Color(0xFFFFA000) : kTextColor,
                      ),
                    ),
                    Text(time, style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(sub, style: const TextStyle(fontSize: 13, color: Colors.grey, height: 1.4)),
                const SizedBox(height: 25),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingInfoCard(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.location_on_rounded, "عنوان التسليم", order.shippingAddress),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(height: 1, color: Color(0xFFF5F5F5)),
          ),
          _buildInfoRow(Icons.person_pin_rounded, "المستلم", "الطلب يحتوي على ${order.itemCount} عناصر"),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: kSecondaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: kSecondaryColor, size: 20),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: kTextLightColor)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: kTextColor)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomAction(BuildContext context, OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 55,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: kPrimaryColor.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                 controller.addNotification(
                  title: "الدعم الفني",
                  body: "تم استلام طلبك، سيقوم مندوبنا بالتواصل معك في أقرب وقت.",
                  color: kPrimaryColor
                );
                Get.snackbar("تنبيه", "تم إرسال طلب تواصل للدعم الفني");
              },
              icon: const Icon(Icons.headset_mic_rounded, color: Colors.white),
              label: const Text('تواصل مع المندوب', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF005B96), // Darker blue matching the design
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 15),
          TextButton(
            onPressed: () {
              Get.back();
              // تفعيل استرجاع الطلب وإضافته لتقرير المسترجعات فوراً
              try {
                if (!Get.isRegistered<ReturnedProductsController>()) {
                  Get.put(ReturnedProductsController());
                }
                
                // إضافة وهمية لأنها من داخل الطلب
                Get.find<ReturnedProductsController>().returnedProducts.insert(0, ReturnedProductModel(
                  name: order.itemCount > 0 ? "طلب #${order.id}" : "منتج",
                  orderId: order.id.toString(),
                  price: "${order.totalPrice.toStringAsFixed(0)} ريال",
                  status: 'تحت المراجعة',
                  statusColor: const Color(0xFFFFA931),
                  icon: Icons.access_time,
                ));

                NotificationHelper.showCustomSnackBar(context, "تم إرسال طلب استرجاع بنجاح", isError: false);

                // سجل النشاط
                if (Get.isRegistered<ActivitiesController>()) {
                  Get.find<ActivitiesController>().logActivity(
                    title: "تم تقديم طلب استرجاع للطلب #${order.id}",
                    type: 'return'
                  );
                }
              } catch (e) {
                print(e);
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('استرجاع الطلب', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
