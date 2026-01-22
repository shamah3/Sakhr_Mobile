import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  // --- نظام الألوان الموحد لمشروع محسوب ---
  static const Color primaryColor = Color(0xFF015C92);
  static const Color accentColor = Color(0xFFFFA931);
  static const Color bgColor = Color(0xFFFDFDFD);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // --- AppBar المنحني (نفس نمط صفحة الشروط) ---
            _buildCurvedAppBar(context),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                children: [
                  _buildIntroSection(),
                  const Divider(height: 40, thickness: 1),

                  _PolicyCard(
                    title: '1. المعلومات التي نجمعها',
                    icon: Icons.info_outline,
                    content: '• المعلومات الشخصية: الاسم، العنوان، البريد الإلكتروني، ورقم الهاتف عند التسجيل.\n'
                        '• بيانات التواصل: أي بيانات تزودنا بها عند الإبلاغ عن مشكلة أو تقديم شكوى.',
                  ),

                  _PolicyCard(
                    title: '2. كيف نستخدم معلوماتك؟',
                    icon: Icons.settings_suggest_outlined,
                    content: '• تحسين جودة خدمات متجر محسوب وتطوير التجربة.\n'
                        '• الرد على استفساراتكم التقنية والمتعلقة بالطلبات.\n'
                        '• إرسال إشعارات تأكيد الطلب وتحديثات الشحن.\n'
                        '• تسهيل وصول الأجهزة الإلكترونية إلى عنوانك بدقة.',
                  ),

                  _PolicyCard(
                    title: '3. مشاركة المعلومات',
                    icon: Icons.share_outlined,
                    content: 'نلتزم بعدم بيع بياناتك، ويقتصر الوصول إليها على الموظفين المختصين أو في حالات:\n'
                        '• الاستجابة للإجراءات القانونية السارية في اليمن.\n'
                        '• حماية أمن المتجر ومنع عمليات الاحتيال.\n'
                        '• تزويد شركات الشحن بالبيانات اللازمة للتوصيل.',
                  ),

                  // قسم خاص بتعليمات فيسبوك (UI متميز)
                  _buildFacebookSection(),

                  _PolicyCard(
                    title: '4. إدارة معلومات حسابك',
                    icon: Icons.manage_accounts_outlined,
                    content: 'يمكنك تصحيح بياناتك عبر الإعدادات في التطبيق. لإلغاء الحساب تماماً، يرجى مراسلتنا على: support@mahsoob.com\n'
                        'ملاحظة: قد نحتفظ ببعض البيانات لأغراض قانونية أو إذا وجد دين مستحق على الحساب.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurvedAppBar(BuildContext context) {
    return Container(
      height: 150,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, Color(0xFF0277BD)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            Center(
              child: Text(
                'سياسة الخصوصية',
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildIntroSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'سياسة الخصوصية - متجر محسوب',
          style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
        ),
        Text(
          'التحديث الأخير: ديسمبر 2025',
          style: GoogleFonts.cairo(fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 15),
        Text(
          'إن استخدامك لمتجر محسوب يعني قبولك لسياسة الخصوصية. نهدف إلى حماية بياناتك وضمان سريتها التامة وفقاً لأعلى المعايير القانونية.',
          style: GoogleFonts.cairo(fontSize: 14, height: 1.6, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildFacebookSection() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.facebook, color: Color(0xFF1877F2)),
              const SizedBox(width: 10),
              Text(
                'إزالة ارتباط Facebook',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: primaryColor),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'لحذف أنشطتك في محسوب المرتبطة بفيسبوك:\n'
            '1. من إعدادات Facebook اختر "التطبيقات ومواقع الويب".\n'
            '2. ابحث عن "محسوب" وانقر إزالة.',
            style: GoogleFonts.cairo(fontSize: 13, height: 1.6),
          ),
        ],
      ),
    );
  }
}

class _PolicyCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;

  const _PolicyCard({required this.title, required this.content, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: PrivacyPolicyScreen.accentColor, size: 22),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: PrivacyPolicyScreen.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(right: 32),
            child: Text(
              content,
              style: GoogleFonts.cairo(
                fontSize: 14,
                height: 1.7,
                color: Colors.black, // لون نص داكن مريح
              ),
            ),
          ),
        ],
      ),
    );
  }
}
