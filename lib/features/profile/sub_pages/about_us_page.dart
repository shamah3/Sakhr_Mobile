import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:bytore/core/routes/app_routes.dart';
import 'package:bytore/core/components/custom_app_bar.dart';


class AboutUsPage extends StatelessWidget {
  const AboutUsPage({Key? key}) : super(key: key);

  // الألوان الثابتة حسب هويتك
  static const Color primaryBlue = Color(0xFF015C92);
  static const Color secondaryOrange = Color(0xFFFFA931);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      // استخدام الـ AppBar القياسي
      appBar: const CustomAppBar(title: 'عن صخر'),
      body: Column(
          children: [
            // --- AppBar المنحني الموحد ---
            // _buildCurvedAppBar(), removed

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // 1. بطاقة "من نحن"
                    _buildHeroSection(),

                    // 2. قسم الإحصائيات
                    _buildStatisticsGrid(),

                    // 3. قسم القيم
                    _buildValueSection(),

                    // 4. تذييل الصفحة
                    _buildFooterAction(),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
    );
  }


  Widget _buildHeroSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: secondaryOrange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.bolt_rounded, color: secondaryOrange, size: 40),
          ),
          const SizedBox(height: 15),
          Text(
            'نحن نحدث ثورة في عالم التقنية',
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryBlue,
            ),
          ),


          const SizedBox(height: 10),
          Text(
            'في "صخر"، لا نبيع مجرد أجهزة؛ نحن نقدم حلولاً رقمية تهدف لتطوير حياتكم اليومية. انطلقنا من اليمن لنكون الواجهة الأكثر موثوقية في عالم الإلكترونيات.',
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 14,
              height: 1.8,
              color: Colors.black, // تغيير للأسود الصريح حسب طلبك السابق
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsGrid() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _statCard('أصلية 100%', 'منتجاتنا', Icons.verified),
          const SizedBox(width: 15),
          _statCard('+10,000', 'عميل واثق', Icons.people_alt),
        ],
      ),
    );
  }

  Widget _statCard(String val, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: primaryBlue,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(icon, color: secondaryOrange, size: 28),
            const SizedBox(height: 8),
            Text(val, style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            Text(label, style: GoogleFonts.cairo(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildValueSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
          child: Text(
            'ركائزنا الأساسية',
            style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
        _valueItem(Icons.security, 'الضمان الحقيقي', 'كل قطعة مشتراة من صخر تأتي بضمانة كاملة تريح بالك.'),
        _valueItem(Icons.speed, 'سرعة الاستجابة', 'فريقنا يعمل على مدار الساعة لخدمتكم وتوصيل طلباتكم.'),
        _valueItem(Icons.price_check, 'أفضل قيمة', 'نوازن بين السعر المنافس والجودة العالية دائماً.'),
      ],
    );
  }

  Widget _valueItem(IconData icon, String title, String desc) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(15)),
            child: Icon(icon, color: primaryBlue, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black)),
                Text(desc, style: GoogleFonts.cairo(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterAction() {
    return Container(
      margin: const EdgeInsets.all(20),
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [primaryBlue, Color(0xFF015C92)]),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: secondaryOrange.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))


        ],
      ),
      child: Column(
        children: [
          Text(
            'كن جزءاً من عائلة صخر',
            style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
          ),
          const SizedBox(height: 10),
          Text(
            'تواصل معنا الآن لأي استفسار تقني',
            style: GoogleFonts.cairo(color: Colors.white.withOpacity(0.9), fontSize: 13),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () {
              // هنا يمكنك التوجه لصفحة تواصل معنا
              Get.toNamed(AppRoutes.CONTACT);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: primaryBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            ),
            child: Text('تواصل معنا', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}
