import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bytore/core/constants/constants.dart';
import 'package:bytore/features/home/models/coupon_model.dart';

class CouponCard extends StatelessWidget {
  final CouponModel coupon;

  const CouponCard({super.key, required this.coupon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: coupon.code));
        Get.snackbar(
          "تم النسخ!",
          "تم نسخ الكود ${coupon.code} إلى الحافظة",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: kPrimaryColor,
          colorText: Colors.white,
          borderRadius: 12,
          margin: const EdgeInsets.all(15),
          duration: const Duration(seconds: 2),
        );
      },
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(left: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: kPrimaryColor.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Left Section (Discount)
              Positioned(
                left: 0, top: 0, bottom: 0, width: 90,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [kPrimaryColor, Color(0xFF1E3A8A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        coupon.discountText.split(" ")[0],
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                        ),
                      ),
                      Text(
                        coupon.discountText.split(" ").length > 1 ? coupon.discountText.split(" ")[1] : "",
                        style: GoogleFonts.cairo(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Dashed Line Simulation
              Positioned(
                left: 90, top: 10, bottom: 10,
                child: CustomPaint(
                  painter: DashedLinePainter(),
                ),
              ),

              // Right Section (Details)
              Positioned(
                left: 105, right: 10, top: 10, bottom: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      coupon.title,
                      style: GoogleFonts.cairo(
                        color: kTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      coupon.details,
                      style: GoogleFonts.cairo(
                        color: Colors.grey,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: kBgColor,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: kPrimaryColor.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.copy_rounded, size: 12, color: kPrimaryColor),
                          const SizedBox(width: 5),
                          Text(
                            coupon.code,
                            style: GoogleFonts.cairo(
                              color: kPrimaryColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Semi-circles for the ticket look
              Positioned(
                left: 85, top: -8,
                child: Container(
                  width: 16, height: 16,
                  decoration: const BoxDecoration(color: Color(0xFFF8FAFC), shape: BoxShape.circle),
                ),
              ),
              Positioned(
                left: 85, bottom: -8,
                child: Container(
                  width: 16, height: 16,
                  decoration: const BoxDecoration(color: Color(0xFFF8FAFC), shape: BoxShape.circle),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashHeight = 5, dashSpace = 3, startY = 0;
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 1;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
