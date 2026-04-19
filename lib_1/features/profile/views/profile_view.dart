import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bytore/core/constants/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bytore/core/controllers/app_controller.dart';
import 'package:bytore/core/routes/app_routes.dart';

import 'package:bytore/features/profile/controllers/reviews_controller.dart';

class ProfileView extends GetView<AppController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildWhiteProfileHeader(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                   _buildOrdersSummary(),
                  const SizedBox(height: 25),
                  _buildSettingsSection(
                    "حسابي",
                    [
                      _buildSettingTile(Icons.person_outline, "المعلومات الشخصية", "تعديل الاسم والبيانات"),
                      _buildSettingTile(Icons.favorite_border_rounded, "قائمة الأمنيات", "المنتجات التي فضلتها",
                          onTap: () => Get.toNamed(AppRoutes.WISHLIST)),
                      _buildSettingTile(Icons.location_on_outlined, "عناويني", "إدارة عناوين التوصيل"),
                      _buildSettingTile(Icons.payment_outlined, "البطاقات البنكية", "إدارة وسائل الدفع"),
                      _buildSettingTile(Icons.mail_outline_rounded, "الرسائل", "صندوق الوارد والمحادثات",
                          onTap: () => Get.toNamed(AppRoutes.MESSAGES)),
                    ],
                  ),
                  const SizedBox(height: 25),
                  _buildSettingsSection(
                    "الإعدادات",
                    [
                      _buildSettingTile(Icons.notifications_none_outlined, "التنبيهات", "إدارة وصول الإشعارات",
                          onTap: () => Get.toNamed(AppRoutes.NOTIFICATIONS)),
                      _buildSettingTile(Icons.language_outlined, "اللغة", "العربية"),
                      _buildSettingTile(Icons.star_rate_rounded, "تقييم صخر", "قيم تجربتك مع تطبيق صخر",
                          onTap: () {
                            if (Get.isRegistered<ReviewsController>()) {
                              Get.find<ReviewsController>().showSakhrRatingDialog();
                            } else {
                              Get.put(ReviewsController()).showSakhrRatingDialog();
                            }
                          }),
                      _buildSettingTile(Icons.help_outline_rounded, "مركز المساعدة", "تواصل معنا"),
                    ],
                  ),
                  const SizedBox(height: 30),
                  _buildLogoutButton(),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhiteProfileHeader() {
    return Obx(() => Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 30, top: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: kSecondaryColor, width: 3.5),
              boxShadow: [
                BoxShadow(
                  color: kSecondaryColor.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              ],
            ),
            child: const CircleAvatar(
              radius: 60,
              backgroundColor: kBgColor,
              backgroundImage: CachedNetworkImageProvider('https://i.pravatar.cc/150?u=male_ahmed'),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            controller.isLoggedIn.value ? "المستخدم المسجل" : 'زائر',
            style: const TextStyle(color: kTextColor, fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            controller.isLoggedIn.value ? "أهلاً بك في صخر" : 'قم بتسجيل الدخول للحصول على ميزات أكثر',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ],
      ),
    ));
  }

  Widget _buildOrdersSummary() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kDefaultRadius),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryIcon(Icons.pending_actions_rounded, "قيد التنفيذ"),
          _buildSummaryIcon(Icons.local_shipping_outlined, "تم الشحن"),
          _buildSummaryIcon(Icons.assignment_return_outlined, "المرتجع"),
          _buildSummaryIcon(Icons.star_outline_rounded, "التقييمات"),
        ],
      ),
    );
  }

  Widget _buildSummaryIcon(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: kPrimaryColor, size: 28),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kTextColor),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> tiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 5, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: kTextColor),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(kDefaultRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 15,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Column(children: tiles),
        ),
      ],
    );
  }

  Widget _buildSettingTile(IconData icon, String title, String subtitle, {VoidCallback? onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: kPrimaryColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: kPrimaryColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: kTextColor),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
      ),
      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade400),
      onTap: onTap ?? () {},
    );
  }

  Widget _buildLogoutButton() {
    return Obx(() {
      if (!controller.isLoggedIn.value) return const SizedBox.shrink();

      return InkWell(
        onTap: () => controller.updateLoginStatus(false),
        borderRadius: BorderRadius.circular(kDefaultRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(kDefaultRadius),
            border: Border.all(color: Colors.red.shade100),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: Colors.red, size: 20),
              SizedBox(width: 10),
              Text(
                'تسجيل الخروج',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    });
  }
}
