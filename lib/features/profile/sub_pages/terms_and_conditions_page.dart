import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:bytore/features/profile/controllers/terms_controller.dart';
import 'package:bytore/core/components/custom_app_bar.dart';


class TermsAndConditionsPage extends StatelessWidget {
  TermsAndConditionsPage({Key? key}) : super(key: key);

  // ربط الكنترولر
  final TermsController controller = Get.put(TermsController());

  static const Color primaryColor = Color(0xFF015C92);
  static const Color secondaryColor = Color(0xFFFFA931);
  static const Color backgroundColor = Color(0xFFFDFDFD);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: const CustomAppBar(title: 'الشروط والأحكام'),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // _buildCustomAppBar(), removed

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                children: [
                  const SizedBox(height: 10),
                  _buildHeaderSection(),
                  const Divider(height: 40, thickness: 1, color: Color(0xFFEEEEEE)),

                  // بناء الأقسام ديناميكياً من الكنترولر
                  ...controller.sections.map((sec) => _PolicySectionWidget(
                    title: sec['title'] as String,
                    content: sec['content'] as String,
                    points: sec['points'] as List<String>,
                  )).toList(),

                  const SizedBox(height: 20),
                  _buildFooterNote(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildHeaderSection() {
    return Column(
      children: [
        Text(
          'مرحباً بك في متجر محسوب للأجهزة الإلكترونية',
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w800, color: primaryColor),
        ),
        const SizedBox(height: 8),
        Text(
          'التحديث الأخير: ${controller.lastUpdate}',
          style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildFooterNote() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: secondaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: secondaryColor.withOpacity(0.3)),
      ),
      child: Text(
        'عند تزويدنا بمعلوماتك، فإنك تمنح محسوب الحق في تقديمها لأطراف ثالثة لغرض إيصال طلبك.',
        textAlign: TextAlign.center,
        style: GoogleFonts.cairo(fontSize: 13, color: primaryColor, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ويدجت داخلي لعرض أقسام السياسة
class _PolicySectionWidget extends StatelessWidget {
  final String title;
  final String content;
  final List<String> points;

  const _PolicySectionWidget({required this.title, required this.content, required this.points});


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 5, height: 25, decoration: BoxDecoration(color: const Color(0xFFFFA931), borderRadius: BorderRadius.circular(10))),
              const SizedBox(width: 10),
              Text(title, style: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.bold, color: const Color(0xFF015C92))),
            ],
          ),
          const SizedBox(height: 12),
          Text(content, style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)),
          const SizedBox(height: 10),
          ...points.map((point) => Padding(
            padding: const EdgeInsets.only(bottom: 8, right: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(padding: EdgeInsets.only(top: 8), child: Icon(Icons.circle, size: 6, color: Color(0xFFFFA931))),
                const SizedBox(width: 10),
                Expanded(child: Text(point, style: GoogleFonts.cairo(fontSize: 14, height: 1.6, color: const Color(0xFF555555)))),
              ],
            ),
          ),
          ).toList(),
        ],
      ),
    );
  }
}
