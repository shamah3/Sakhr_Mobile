import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:bytore/features/profile/controllers/policy_controller.dart';
import 'package:bytore/core/components/custom_app_bar.dart';



class PolicyPage extends StatelessWidget {
  PolicyPage({Key? key}) : super(key: key);

  // ربط الكنترولر
  final PolicyController controller = Get.put(PolicyController());

  // ألوان الهوية البصرية
  static const Color primaryBlue = Color(0xFF015C92);
  static const Color secondaryOrange = Color(0xFFFFA931);
  static const Color accentBg = Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: accentBg,
      appBar: const CustomAppBar(title: 'سياسة الاستبدال والاسترجاع'),
      body: Column(
          children: [
            // --- AppBar المنحني الموحد ---
            // _buildCurvedAppBar(), removed

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderNote(),
                    const SizedBox(height: 25),

                    _buildPolicySection(
                      icon: Icons.assignment_return_outlined,
                      title: 'مدة الاسترجاع والاستبدال',
                      content: 'يمكنك استبدال أو استرجاع المنتجات خلال 3 أيام من تاريخ استلام الطلب، بشرط أن يكون المنتج في حالته الأصلية.',
                    ),

                    _buildPolicySection(
                      icon: Icons.check_box_outlined,
                      title: 'شروط الاسترجاع',
                      content: 'يجب أن يكون المنتج غير مستخدم، وفي تغليفه الأصلي، مع كامل ملحقاته وكتيبات الإرشادات المرفقة.',
                    ),

                    _buildPolicySection(
                      icon: Icons.no_sim_outlined,
                      title: 'المنتجات المستثناة',
                      content: 'لا يمكن استرجاع البرمجيات، الأكواد الرقمية، أو المنتجات التي تم فتح غلافها المصنعي ما لم يوجد بها عيب مصنعي.',
                    ),

                    _buildPolicySection(
                      icon: Icons.payments_outlined,
                      title: 'آلية استرداد الأموال',
                      content: 'في حال الاسترجاع، يتم إعادة المبلغ إلى حسابك البنكي أو محفظتك الإلكترونية خلال 7-14 يوم عمل من فحص المنتج.',
                    ),

                    const SizedBox(height: 30),
                    _buildNeedHelpBox(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
    );
  }

  // --- بناء الـ Widgets الفرعية ---

  Widget _buildHeaderNote() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: secondaryOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: secondaryOrange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_rounded, color: secondaryOrange),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'رضاكم هو غايتنا، نضمن لكم تجربة تسوق آمنة وسهلة في متجر صخر.',
              style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold, color: primaryBlue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicySection({required IconData icon, required String title, required String content}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: secondaryOrange, size: 26),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: primaryBlue),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: accentBg, thickness: 2),
          ),
          Text(
            content,
            style: GoogleFonts.cairo(fontSize: 14, height: 1.7, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildNeedHelpBox() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: primaryBlue,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: primaryBlue.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Text(
            'لديك حالة استرجاع خاصة؟',
            style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Text(
            controller.supportMessage, // استخدام بيانات من الكنترولر
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => controller.startReturnProcess(), // استدعاء دالة من الكنترولر
            style: ElevatedButton.styleFrom(
              backgroundColor: secondaryOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            ),
            child: Text('بدء طلب استرجاع', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
