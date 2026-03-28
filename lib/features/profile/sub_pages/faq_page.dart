import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:bytore/core/components/custom_app_bar.dart';


class FaqPage extends StatelessWidget {
  const FaqPage({Key? key}) : super(key: key);

  static const Color primaryBlue = Color(0xFF015C92);
  static const Color secondaryOrange = Color(0xFFFFA931);
  static const Color bgColor = Color(0xFFF8FAFC);

  // قائمة الأسئلة (بيانات ثابتة داخل الـ View)
  static const List<Map<String, String>> faqData = [
    {
      'q': 'كيف يمكنني التأكد من أن المنتج أصلي؟',
      'a': 'جميع المنتجات في متجر صخر تأتي من وكلاء معتمدين، ونوفر مع كل جهاز كرت الضمان الخاص بالشركة المصنعة.',
    },
    {
      'q': 'كم تستغرق مدة التوصيل؟',
      'a': 'يتم التوصيل داخل محافظة عدن خلال 24 ساعة، وبقية المحافظات خلال 2-4 أيام عمل.',
    },
    {
      'q': 'هل يوفر المتجر خدمة الدفع عند الاستلام؟',
      'a': 'نعم، نوفر خدمة الدفع عند الاستلام في معظم المناطق لتوفير أعلى مستويات الأمان لعملائنا.',
    },
    {
      'q': 'كيف أستفيد من الضمان؟',
      'a': 'في حال وجود أي مشكلة تقنية، يمكنك التواصل مع خدمة العملاء وتزويدنا برقم الطلب وسنقوم بتوجيهك لأقرب مركز صيانة معتمد.',
    },
    {
      'q': 'هل يمكنني استرجاع المنتج بعد الشراء؟',
      'a': 'نعم، يمكنك استرجاع المنتج خلال 3 أيام من الاستلام بشرط أن يكون في حالته الأصلية وبتغليفه المصنعي.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: const CustomAppBar(title: 'الأسئلة الشائعة'),
      body: Column(
          children: [
            // --- AppBar المنحني الموحد ---
            // _buildCurvedAppBar(), removed

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                children: [
                  _buildSectionTitle('الأسئلة الأكثر تداولاً'),
                  const SizedBox(height: 15),

                  // عرض الأسئلة من القائمة
                  ...faqData.map((item) => _buildFAQItem(item['q']!, item['a']!)).toList(),

                  const SizedBox(height: 30),
                  _buildHelpBox(),
                ],
              ),
            ),
          ],
        ),
    );
  }

  // --- دوال البناء بنفس تصميمك بالضبط ---


  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: secondaryOrange,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryBlue,
          ),
        ),
      ],
    );
  }


  Widget _buildFAQItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: secondaryOrange,
          collapsedIconColor: primaryBlue,
          title: Text(
            question,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: primaryBlue,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                answer,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  height: 1.6,
                  color: Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpBox() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primaryBlue, primaryBlue.withOpacity(0.8)]),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          const Icon(Icons.support_agent, color: secondaryOrange, size: 40),
          const SizedBox(height: 10),
          Text(
            'لم تجد إجابة لسؤالك؟',
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            'فريق دعم صخر جاهز لمساعدتك في أي وقت',
            style: GoogleFonts.cairo(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () {
              // Get.toNamed(AppRoutes.CONTACT); // Link to Contact page
              // For now, left empty or link if route exists
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: secondaryOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            ),
            child: Text(
              'تواصل معنا',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
