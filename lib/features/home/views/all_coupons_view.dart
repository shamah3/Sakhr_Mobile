import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bytore/core/constants/constants.dart';
import 'package:bytore/features/home/controllers/home_controller.dart';
import 'package:bytore/features/home/views/components/coupon_card.dart';

class AllCouponsView extends StatelessWidget {
  const AllCouponsView({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: kTextColor, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "جميع الخصومات والكوبونات",
          style: GoogleFonts.cairo(
            color: kTextColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isCouponsLoading.value && controller.coupons.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.coupons.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_offer_outlined, size: 60, color: Colors.grey.shade300),
                const SizedBox(height: 10),
                Text(
                  "لا توجد كوبونات متاحة حالياً",
                  style: GoogleFonts.cairo(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          itemCount: controller.coupons.length,
          itemBuilder: (context, index) {
            final coupon = controller.coupons[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SizedBox(
                width: double.infinity,
                child: CouponCard(coupon: coupon),
              ),
            );
          },
        );
      }),
    );
  }
}
