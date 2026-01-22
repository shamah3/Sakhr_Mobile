import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bytore/core/constants/constants.dart';
import 'package:bytore/features/home/views/main_view.dart';
import 'package:bytore/core/controllers/cart_controller.dart';
import 'package:bytore/features/home/controllers/main_controller.dart';
import 'package:bytore/features/orders/views/tracking_view.dart';

class SuccessPage extends StatelessWidget {
  const SuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // أيقونة النجاح
              _buildSuccessIcon(),

              const SizedBox(height: 40),

              const Text(
                'تم طلبك بنجاح!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: kTextColor),
              ),

              const SizedBox(height: 20),

              const Text(
                'شكراً لتسوقك معنا، تم استلام طلبك بنجاح وسنقوم بمراجعته وتجهيزه للتوصيل في أقرب وقت ممكن.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: kTextLightColor, height: 1.6),
              ),

              const SizedBox(height: 40),

              // ملخص الطلب
              _buildOrderSummaryCard(),

              const Spacer(flex: 3),

              // زر تتبع الطلب
              _buildActionButton(
                label: 'تتبع حالة الطلب',
                onPressed: () => Get.to(() => const TrackingView()),
                isPrimary: true,
              ),

              const SizedBox(height: 15),

              // زر العودة للرئيسية - الحل المعتمد
              _buildActionButton(
                label: 'العودة للرئيسية',
                onPressed: () {
                  // 1. تصفير السلة تماماً
                  try {
                    Get.find<CartController>().clearCart();
                  } catch (e) {
                    debugPrint("CartController not found: $e");
                  }

                  // 2. تصفير التبويب النشط ليكون الرئيسية (رقم 0)
                  // نستخدم Check لضمان عدم حدوث الشاشة الحمراء
                  try {
                    if (Get.isRegistered<MainController>()) {
                      Get.find<MainController>().selectedIndex.value = 0;
                    } else {
                      // إذا لم يكن موجوداً، نقوم بتجهيزه قبل الانتقال
                      Get.put(MainController()).selectedIndex.value = 0;
                    }
                  } catch (e) {
                    debugPrint("MainController error: $e");
                  }

                  // 3. الانتقال للواجهة الرئيسية ومسح كل الصفحات السابقة
                  Get.offAll(() => const MainView());
                },
                isPrimary: false,
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ويدجيت أيقونة النجاح
  Widget _buildSuccessIcon() {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            color: Colors.green,
            size: 70,
          ),
        ),
      ),
    );
  }

  // ويدجيت ملخص الطلب
  Widget _buildOrderSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kBgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.receipt_long_rounded, color: kPrimaryColor),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("رقم الطلب", style: TextStyle(color: kTextLightColor, fontSize: 12)),
                Text("#BTR-98521", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kTextColor)),
              ],
            ),
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("الإجمالي", style: TextStyle(color: kTextLightColor, fontSize: 12)),
              Text("250 \$", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kSecondaryColor)),
            ],
          ),
        ],
      ),
    );
  }

  // ويدجيت الأزرار
  Widget _buildActionButton({required String label, required VoidCallback onPressed, required bool isPrimary}) {
    if (isPrimary) {
      return Container(
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
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 0,
          ),
          child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      );
    } else {
      return TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: kPrimaryColor,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      );
    }
  }
}