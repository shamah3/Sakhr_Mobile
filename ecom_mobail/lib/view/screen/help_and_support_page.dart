import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

class HelpAndSupportPage extends StatelessWidget {
  const HelpAndSupportPage({Key? key}) : super(key: key);

  // الألوان الثابتة للهوية
  static const Color _primaryBlue = Color(0xFF015C92);
  static const Color _secondaryOrange = Color(0xFFFFA931);
  static const Color _bgColor = Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      // الـ AppBar الموحد بلمسة GetX
      appBar: AppBar(
        title: Text(
          'المساعدة والدعم',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: _primaryBlue,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          children: [
            // عنوان ترحيبي جذاب
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مرحباً بك، كيف يمكننا مساعدتك؟',
                  style: GoogleFonts.cairo(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _primaryBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'فريق محسوب متاح دائماً لخدمتك',
                  style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 35),

            // البطاقات بتصميم مطور
            _buildModernHelpCard(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'تواصل معنا مباشرة',
              subtitle: 'تحدث مع فريق الدعم عبر الواتساب أو الاتصال',
              onTap: () {
                // Get.to(() => const ContactUsPage());
              },
            ),
            _buildModernHelpCard(
              icon: Icons.help_outline_rounded,
              title: 'الأسئلة الشائعة',
              subtitle: 'تصفح الإجابات السريعة لمشاكلك',
              onTap: () {
                // Get.to(() => const FaqPage());
              },
            ),
            _buildModernHelpCard(
              icon: Icons.security_rounded,
              title: 'سياسات المتجر',
              subtitle: 'تعرف على حقوقك في الاسترجاع والخصوصية',
              onTap: () {
                // Get.to(() => const PolicyPage());
              },
            ),

            const SizedBox(height: 40),
            _buildSupportBadge(),
          ],
        ),
      ),
    );
  }

  // تصميم البطاقات بشكل احترافي
  Widget _buildModernHelpCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ListTile(
            onTap: onTap,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _primaryBlue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: _primaryBlue, size: 28),
            ),
          title: Text(
            title,
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            subtitle,
            style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey[600]),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: _secondaryOrange),
        ),
    );
  }

  // إضافة عنصر جمالي في أسفل الصفحة
  Widget _buildSupportBadge() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.headset_mic_rounded, size: 50, color: _secondaryOrange.withOpacity(0.4)),
          const SizedBox(height: 10),
          Text(
            'نحن هنا من أجلك 24/7',
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}