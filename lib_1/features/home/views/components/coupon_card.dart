import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bytore/core/constants/constants.dart';
import 'package:bytore/features/home/models/coupon_model.dart';
import 'package:bytore/core/utils/notification_helper.dart';

class CouponCard extends StatelessWidget {
  final CouponModel coupon;

  const CouponCard({super.key, required this.coupon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _copyCode(context),
      child: Container(
        width: 300, // Unified width
        height: 110, // Unified height
        margin: const EdgeInsets.only(left: 15, right: 5, bottom: 12, top: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24), // More rounded as in image
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              spreadRadius: 0,
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Row(
            children: [
              // Left Side (RTL Content) - Details
              Expanded(
                flex: 7,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Stack(
                    children: [
                      // Verified Icon - Top Corner (Left side in RTL)
                      const Positioned(
                        top: 0, 
                        left: 0,
                        child: Icon(Icons.verified_rounded, size: 16, color: kPrimaryColor),
                      ),
                      
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Flexible(
                            child: Text(
                              coupon.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                color: kTextColor,
                                height: 1.1,
                              ),
                            ),
                          ),
                          Flexible(
                            child: Text(
                              coupon.details,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cairo(
                                fontSize: 10,
                                color: Colors.grey,
                                height: 1.1,
                              ),
                            ),
                          ),
                          
                          // Code & Copy Label
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.copy_rounded, size: 10, color: kSecondaryColor),
                              const SizedBox(width: 4),
                              Text(
                                "انسخ الكود: ${coupon.code}",
                                style: GoogleFonts.cairo(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: kSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Simple Dashed Line
              CustomPaint(
                size: const Size(1, double.infinity),
                painter: DashedLinePainter(color: Colors.grey.shade100),
              ),

              // Right Side (RTL Badge) - Discount
              Expanded(
                flex: 3,
                child: Container(
                  color: kPrimaryColor.withOpacity(0.04),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: coupon.type == 'fixed' 
                                    ? coupon.value.toInt().toString() 
                                    : '${coupon.value.toInt()}',
                                style: GoogleFonts.cairo(
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 24,
                                  height: 1,
                                ),
                              ),
                              TextSpan(
                                text: coupon.type == 'fixed' ? ' ر.ي' : '%',
                                style: GoogleFonts.cairo(
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          textDirection: TextDirection.ltr,
                        ),
                      ),
                      Text(
                        "خــصم",
                        style: GoogleFonts.cairo(
                          color: kPrimaryColor.withOpacity(0.5),
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _copyCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: coupon.code));
    NotificationHelper.showCustomSnackBar(
      context, 
      "تم نسخ الكود ${coupon.code}", 
      isError: false
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final Color color;
  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    double dashHeight = 4, dashSpace = 3, startY = 10;
    final paint = Paint()..color = color..strokeWidth = 1;
    while (startY < size.height - 10) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
