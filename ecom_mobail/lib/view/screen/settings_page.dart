
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:nice/controller/settings_controller.dart';
import 'package:nice/view/screen/edit_profile_page.dart';

class SettingsPage extends StatelessWidget {
SettingsPage({Key? key}) : super(key: key);

final SettingsController controller = Get.put(SettingsController());

static const Color primaryBlue = Color(0xFF015C92);
static const Color secondaryOrange = Color(0xFFFFA931);

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: const Color(0xFFF8FAFC),
body: Directionality(
textDirection: TextDirection.rtl,
child: Column(
children: [
_buildCurvedAppBar('الإعدادات'),
Expanded(
child: ListView(
physics: const BouncingScrollPhysics(),
padding: const EdgeInsets.all(20),
children: [
_buildSectionHeader('الحساب والأمان'),
_buildInteractiveItem(
icon: Icons.person_outline_rounded,
title: 'تعديل الملف الشخصي',
onTap: () => Get.to(() => EditProfileScreen()),
),
_buildInteractiveItem(
icon: Icons.lock_reset_rounded,
title: 'تغيير كلمة المرور',
onTap: () => Get.to(() => const ()),
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

// اختيار العملة
Obx(() => _buildSelectionItem(
icon: Icons.monetization_on_outlined,
title: 'عملة العرض',
value: controller.selectedCurrency.value,
onTap: () => _showPicker(
context,
'اختر العملة',
['ريال يمني (YR)', 'سعودي (SAR)', 'دولار (USD)'],
controller.updateCurrency,
),
)),

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
),
);
}

// --- المكونات (Widgets) ---

Widget _buildCurvedAppBar(String title) {
return Container(
height: 140, width: double.infinity,
decoration: const BoxDecoration(
gradient: LinearGradient(colors: [primaryBlue, Color(0xFF0277BD)]),
borderRadius: BorderRadius.only(bottomLeft: Radius.circular(45), bottomRight: Radius.circular(45)),
),
child: SafeArea(child: Center(child: Text(title, style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)))),
);
}

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