import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import 'package:bytore/core/components/custom_app_bar.dart';


class ContactUsPage extends StatelessWidget {
  const ContactUsPage({Key? key}) : super(key: key);

  // --- الهوية البصرية لمتجر محسوب (نفس ألوانك) ---
  static const Color primaryBlue = Color(0xFF015C92);
  static const Color secondaryOrange = Color(0xFFFFA931);
  static const Color backgroundColor = Color(0xFFF8FAFC);

  // دالة فتح الروابط (بقيت كما هي ولكن يمكن استدعاؤها عبر GetX)
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: const CustomAppBar(title: 'تواصل معنا'),
      body: Column(
          children: [
            // --- AppBar المنحني الموحد ---
            // _buildCurvedAppBar(), removed

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                child: Column(
                  children: [
                    _buildHeroIcon(),
                    const SizedBox(height: 25),
                    Text(
                      'كيف يمكننا مساعدتك؟',
                      style: GoogleFonts.cairo(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'فريق دعم صخر متواجد لخدمتك والإجابة على استفساراتك في أسرع وقت ممكن.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 35),

                    // قنوات التواصل (الروابط)
                    _buildContactMethod(
                      icon: Icons.chat_bubble_outline_rounded,
                      title: 'عبر الواتساب',
                      subtitle: 'محادثة فورية مع فريق الدعم',
                      color: const Color(0xFF25D366),
                      onTap: () => _launchURL('https://wa.me/967777123456'),
                    ),

                    _buildContactMethod(
                      icon: Icons.phone_in_talk_rounded,
                      title: 'اتصال هاتفي',
                      subtitle: '+967 777 123 456',
                      color: primaryBlue,
                      onTap: () => _launchURL('tel:+967777123456'),
                    ),

                    _buildContactMethod(
                      icon: Icons.alternate_email_rounded,
                      title: 'البريد الإلكتروني',
                      subtitle: 'support@sakhr.com',
                      color: secondaryOrange,
                      onTap: () => _launchURL('mailto:support@sakhr.com'),
                    ),

                    const SizedBox(height: 20),
                    _buildSocialSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
    );
  }

  // --- المكونات البصرية بنفس تصميمك بالضبط ---


  Widget _buildHeroIcon() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: const Icon(
        Icons.headset_mic_rounded,
        size: 60,
        color: secondaryOrange,
      ),
    );
  }

  Widget _buildContactMethod({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(
          title,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16, color: primaryBlue),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
      ),
    );
  }

  Widget _buildSocialSection() {
    return Column(
      children: [
        Text(
          'أو تابعنا عبر منصاتنا',
          style: GoogleFonts.cairo(fontSize: 13, color: Colors.grey[500]),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _socialCircle(Icons.facebook, const Color(0xFF1877F2)),
            const SizedBox(width: 15),
            _socialCircle(Icons.camera_alt_rounded, const Color(0xFFE4405F)),
            const SizedBox(width: 15),
            _socialCircle(Icons.language_rounded, primaryBlue),
          ],
        )
      ],
    );
  }

  Widget _socialCircle(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}
