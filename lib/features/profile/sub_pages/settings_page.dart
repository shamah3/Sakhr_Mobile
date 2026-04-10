import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:bytore/features/profile/controllers/settings_controller.dart';
import 'package:bytore/core/routes/app_routes.dart';
import 'package:bytore/core/components/custom_app_bar.dart';


class SettingsPage extends StatelessWidget {
  SettingsPage({Key? key}) : super(key: key);

  final SettingsController controller = Get.put(SettingsController());

  static const Color primaryBlue = Color(0xFF015C92);
  static const Color secondaryOrange = Color(0xFFFFA931);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CustomAppBar(title: 'الإعدادات'),
      body: Column(
          children: [
            // _buildCurvedAppBar('الإعدادات'), removed
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                children: [
                  _buildSectionHeader('الحساب والأمان'),
                  _buildInteractiveItem(
                    icon: Icons.person_outline_rounded,
                    title: 'تعديل الملف الشخصي',
                    onTap: () => Get.toNamed(AppRoutes.EDIT_PROFILE),
                  ),
                  _buildInteractiveItem(
                    icon: Icons.lock_reset_rounded,
                    title: 'تغيير كلمة المرور',
                    onTap: () => Get.to(() => const SizedBox()), // Placeholder for change password
                  ),
  
                  const SizedBox(height: 25),
                  _buildSectionHeader('التفضيلات'),
  
                  // اختيار المحافظة
                  Obx(() => _buildSelectionItem(
                    icon: Icons.map_outlined,
                    title: 'المحافظة الحالية',
                    value: controller.selectedGovernorate.value,
                    onTap: () => _showPicker(
                      context,
                      'اختر المحافظة',
                      ['عدن', 'صنعاء', 'تعز', 'حضرموت'],
                      controller.updateGovernorate,
                    ),
                  )),
  
                  // اختيار العملة (بتنسيق مشابه للشاشة الرئيسية)
                  Obx(() => _buildCurrencySelectionItem(context)),
  
                  // مفتاح الإشعارات
                  Obx(() => _buildSwitchItem(
                    icon: Icons.notifications_active_outlined,
                    title: 'تنبيهات العروض والطلبات',
                    value: controller.notificationsEnabled.value,
                    onChanged: controller.toggleNotifications,
                  )),
  
                  const SizedBox(height: 40),
                  _buildLogoutButton(),
                ],
              ),
            ),
          ],
        ),
    );
  }

  // --- المكونات (Widgets) ---


  Widget _buildInteractiveItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return Card(
      elevation: 0, margin: const EdgeInsets.only(bottom: 12),


      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: primaryBlue),
        title: Text(title, style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      ),
    );
  }

  Widget _buildCurrencySelectionItem(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: const Icon(Icons.currency_exchange_rounded, color: secondaryOrange),
        title: Text('عملة العرض', style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600)),
        trailing: PopupMenuButton<String>(
          onSelected: (String newValue) {
            controller.updateCurrency(newValue);
          },
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          offset: const Offset(0, 40),
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            _buildCurrencyMenuItem('ريال يمني قديم (ر.ي.ق)'),
            _buildCurrencyMenuItem('ريال يمني جديد (ر.ي.ج)'),
            _buildCurrencyMenuItem('ريال سعودي (ر.س)'),
            _buildCurrencyMenuItem('دولار (\$)'),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  controller.selectedCurrency,
                  style: GoogleFonts.cairo(
                    color: primaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildCurrencyMenuItem(String text) {
    return PopupMenuItem<String>(
      value: text,
      child: Text(
        text,
        textAlign: TextAlign.right,
        style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }

  Widget _buildSelectionItem({required IconData icon, required String title, required String value, required VoidCallback onTap}) {
    return Card(
      elevation: 0, margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: secondaryOrange),
        title: Text(title, style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600)),
        trailing: Text(value, style: GoogleFonts.cairo(color: primaryBlue, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSwitchItem({required IconData icon, required String title, required bool value, required Function(bool) onChanged}) {
    return Card(
      elevation: 0, margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: SwitchListTile(
        activeColor: secondaryOrange,
        secondary: Icon(icon, color: primaryBlue),
        title: Text(title, style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600)),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  void _showPicker(BuildContext context, String title, List<String> options, Function(String) onSelect) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: primaryBlue)),
            const Divider(),
            ...options.map((option) => ListTile(
              title: Text(option, textAlign: TextAlign.center, style: GoogleFonts.cairo()),
              onTap: () { onSelect(option); Get.back(); },
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      child: Text(title, style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[700])),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: controller.logout,
        icon: const Icon(Icons.logout, color: Colors.white),
        label: Text('تسجيل الخروج', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.white)),
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0277BD), padding: const EdgeInsets.all(15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
      ),
    );
  }
}
