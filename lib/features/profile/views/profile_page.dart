import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bytore/core/constants/constants.dart';
import 'package:bytore/core/routes/app_routes.dart';
import 'package:bytore/core/components/custom_app_bar.dart';
import 'package:bytore/features/authentication/controllers/auth_controller.dart';
import '../../../core/controllers/app_controller.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({Key? key}) : super(key: key);

  // الألوان الأساسية للمشروع
  static const Color primaryBlue = Color(0xFF015C92);
  static const Color secondaryOrange = Color(0xFFFFA931);

  final AppController appController = Get.find<AppController>();
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: 'حسابي',
        showBackArrow:
            false, // Main tab, usually no back arrow unless deep linked
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: kTextColor, size: 24),
            onPressed: () => Get.toNamed(AppRoutes.SETTINGS),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 20),

          // 1. بطاقة المستخدم (مع رابط تعديل الملف أو تسجيل الدخول)
          Obx(() => _buildProfileCard()),

          const SizedBox(height: 20),

          // 2. أزرار الوصول السريع (المحفظة، الطلبات، المفضلة)
          Obx(
            () => appController.isLoggedIn.value
                ? _buildQuickActions()
                : const SizedBox.shrink(),
          ),

          Obx(
            () => appController.isLoggedIn.value
                ? const SizedBox(height: 25)
                : const SizedBox.shrink(),
          ),

          // 3. قسم إدارة الحساب
          Obx(
            () => appController.isLoggedIn.value
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('إدارة الحساب'),
                      _buildMenuContainer([
                        _buildMenuItem(
                          'تقارير المشتريات',
                          Icons.bar_chart_rounded,
                          () => Get.toNamed(AppRoutes.REPORTS),
                        ),
                        _buildMenuItem(
                          'المنتجات المسترجعة',
                          Icons.assignment_return_outlined,
                          () => Get.toNamed(AppRoutes.RETURNS),
                        ),
                        _buildMenuItem(
                          'سجل الأنشطة',
                          Icons.access_time_rounded,
                          () => Get.toNamed(AppRoutes.ACTIVITY),
                        ),
                        _buildMenuItem(
                          'الرسائل',
                          Icons.mail_outline_rounded,
                          () => Get.toNamed(AppRoutes.MESSAGES),
                        ),
                        _buildMenuItem(
                          'تقييماتي',
                          Icons.star_border_rounded,
                          () => Get.toNamed(AppRoutes.REVIEWS),
                          isLast: true,
                        ),
                      ]),
                    ],
                  )
                : const SizedBox.shrink(),
          ),

          const SizedBox(height: 20),

          // 4. قسم المساعدة والدعم
          _buildSectionHeader('المساعدة والدعم'),
          _buildMenuContainer([
            _buildMenuItem(
              'تواصل معنا',
              Icons.headset_mic_outlined,
              () => Get.toNamed(AppRoutes.CONTACT),
            ),
            _buildMenuItem(
              'الأسئلة الشائعة',
              Icons.help_outline_rounded,
              () => Get.toNamed(AppRoutes.FAQ),
            ),
            _buildMenuItem(
              'الشكاوى',
              Icons.warning_amber_rounded,
              () => Get.toNamed(AppRoutes.COMPLAINTS),
            ),
            _buildMenuItem(
              'سياسة الاستبدال والاسترجاع',
              Icons.cached_rounded,
              () => Get.toNamed(AppRoutes.RETURN_POLICY),
            ),
            _buildMenuItem(
              'سياسة الخصوصية',
              Icons.verified_user_outlined,
              () => Get.toNamed(AppRoutes.PRIVACY),
            ),
            _buildMenuItem(
              'الشروط والأحكام',
              Icons.gavel_rounded,
              () => Get.toNamed(AppRoutes.TERMS),
            ),
            _buildMenuItem(
              'من نحن',
              Icons.info_outline_rounded,
              () => Get.toNamed(AppRoutes.ABOUT),
              isLast: true,
            ),
          ]),

          const SizedBox(height: 20),

          // 5. زر تسجيل الخروج (يظهر فقط إذا كان مسجل الدخول)
          Obx(
            () => appController.isLoggedIn.value
                ? _buildLogoutButton()
                : const SizedBox.shrink(),
          ),

          const SizedBox(height: 120),
        ],
      ),
    );
  }

  // بطاقة البروفايل
  Widget _buildProfileCard() {
    if (!appController.isLoggedIn.value) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person_outline, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 15),
            Text(
              'أهلاً بك كزائر',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'سجل دخول للمزيد من الخصائص المذهلة',
              style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () => Get.toNamed(AppRoutes.LOGIN),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'تسجيل الدخول',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // أيقونة القلم في اليسار
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              onPressed: () => Get.toNamed(AppRoutes.EDIT_PROFILE),
              icon: const Icon(
                Icons.edit_outlined,
                color: primaryBlue,
                size: 24,
              ),
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(8),
            ),
          ),
          const CircleAvatar(
            radius: 40,
            backgroundColor: primaryBlue,
            child: CircleAvatar(
              radius: 38,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 50, color: primaryBlue),
            ),
          ),
          const SizedBox(height: 10),
          Obx(
            () => Text(
              appController.firstName.value.isEmpty
                  ? 'user'
                  : '${appController.firstName.value} ${appController.lastName.value}'
                        .trim(),
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 15),
          // زر إضافة البصمة
          Obx(
            () => appController.isBiometricEnabled.value
                ? OutlinedButton.icon(
                    onPressed: () {
                      appController.isBiometricEnabled.value = false;
                      Get.snackbar(
                        'تم',
                        'تم تعطيل استخدام البصمة على هذا الجهاز',
                      );
                    },
                    icon: const Icon(Icons.fingerprint, color: Colors.green),
                    label: Text(
                      'تم تفعيل الدخول بالبصمة',
                      style: GoogleFonts.cairo(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.green),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  )
                : OutlinedButton.icon(
                    onPressed: () async {
                      await authController.enableBiometricForCurrentUser();
                    },
                    icon: const Icon(Icons.fingerprint, color: primaryBlue),
                    label: Text(
                      'إضافة بصمة للدخول',
                      style: GoogleFonts.cairo(
                        color: primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: primaryBlue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // أزرار الوصول السريع (تفاعلية بالكامل)
  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionBtn(
            'المفضلة',
            Icons.favorite_border_rounded,
            () => Get.toNamed(AppRoutes.WISHLIST),
          ),
          _buildVerticalDivider(), // الفاصل الأزرق
          _buildActionBtn(
            'المحفظة',
            Icons.account_balance_wallet_outlined,
            () => Get.toNamed(AppRoutes.WALLET),
          ),
          _buildVerticalDivider(), // الفاصل الأزرق
          _buildActionBtn(
            'طلباتي',
            Icons.shopping_bag_outlined,
            () => Get.toNamed(AppRoutes.ORDERS),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: secondaryOrange, size: 28),
          const SizedBox(height: 5),
          Text(
            label,
            style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // الفاصل الأزرق بين الأزرار
  Widget _buildVerticalDivider() {
    return Container(height: 40, width: 1.5, color: primaryBlue);
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, right: 5),
      child: Text(
        title,
        style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildMenuContainer(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(children: items),
    );
  }

  // عناصر القائمة (الأسهم تتجه لليمين)
  Widget _buildMenuItem(
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isLast = false,
  }) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          leading: Icon(icon, color: primaryBlue, size: 24),
          title: Text(
            title,
            style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: primaryBlue,
          ),
        ),
        if (!isLast)
          Divider(height: 1, color: Colors.grey.shade100, indent: 50),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2).withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: const Icon(Icons.logout_rounded, color: Colors.red),
        title: Text(
          'تسجيل الخروج',
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        onTap: () {
          authController.logout();
        },
      ),
    );
  }
}
