import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:bytore/features/profile/controllers/activities_controller.dart';
import 'package:bytore/core/components/custom_app_bar.dart';


class ActivitiesPage extends StatelessWidget {
  ActivitiesPage({Key? key}) : super(key: key);

  // استدعاء الكنترولر
  final ActivitiesController controller = Get.find<ActivitiesController>();

  static const Color primaryBlue = Color(0xFF015C92);
  static const Color secondaryOrange = Color(0xFFFFA931);
  static const Color bgColor = Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: const CustomAppBar(title: 'سجل الأنشطة'),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // _buildCurvedAppBar(), removed


            Expanded(
              child: Obx(() {
                // إظهار مؤشر التحميل إذا كانت البيانات لم تصل بعد
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator(color: primaryBlue));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  itemCount: controller.activities.length,
                  itemBuilder: (context, index) {
                    final item = controller.activities[index];

                    // تحديد هل نظهر عنوان التاريخ (اليوم/أمس)
                    bool showHeader = index == 0 || item.date != controller.activities[index - 1].date;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showHeader) _buildDateHeader(item.date),
                        _buildActivityItem(
                          title: item.title,
                          time: item.time,
                          icon: _getIcon(item.type),
                          iconColor: _getIconColor(item.type),
                          isLast: index == controller.activities.length - 1,
                        ),
                      ],
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // --- دوال مساعدة للأيقونات القادمة من السيرفر ---
  IconData _getIcon(String type) {
    if (type == 'buy') return Icons.shopping_cart_checkout;
    if (type == 'fav') return Icons.favorite_rounded;
    if (type == 'security') return Icons.security_rounded;
    return Icons.lock_reset_rounded;
  }

  Color _getIconColor(String type) {
    if (type == 'buy') return primaryBlue;
    if (type == 'fav') return Colors.pink;
    if (type == 'security') return secondaryOrange;
    return Colors.teal;
  }

  // --- المكونات البصرية (نفس تصميمك الأصلي) ---



  Widget _buildDateHeader(String date) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, right: 10, top: 10),
      child: Text(
        date,
        style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
      ),
    );
  }

  Widget _buildActivityItem({
    required String title,
    required String time,
    required IconData icon,
    required Color iconColor,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: iconColor.withOpacity(0.2), width: 2),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              if (!isLast)
                Expanded(child: Container(width: 2, color: Colors.grey[300])),
            ],
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
                      const SizedBox(width: 5),
                      Text(time, style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey[700])),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
