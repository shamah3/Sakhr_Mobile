import 'package:flutter/material.dart';
import 'package:get/get.dart';

// استيراد الصفحات بناءً على هيكلية مشروعك (تأكد من صحة مسارات الـ import)
import 'view/screen/profile_page.dart';
import 'view/screen/wallet_page.dart';
import 'view/screen/reviews_page.dart';
import 'view/screen/purchase_reports_page.dart';
import 'view/screen/returned_products_page.dart';
import 'view/screen/activities_page.dart';
import 'view/screen/contact_us_page.dart';
import 'view/screen/faq_page.dart';
import 'view/screen/complaints_page.dart';
import 'view/screen/terms_and_conditions_page.dart';
import 'view/screen/privacy_policy_page.dart';
import 'view/screen/about_us_page.dart';
import 'view/screen/edit_profile_page.dart';
import 'view/screen/settings_page.dart';
import 'view/screen/my_orders_page.dart';
import 'view/screen/favorites_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/profile', // نقطة البداية

      // تعريف المسارات لربط كل الصفحات التي في صورتك
      getPages: [
        GetPage(name: '/profile', page: () => const ProfilePage()),
        GetPage(name: '/wallet', page: () =>  WalletPage()),
        GetPage(name: '/reviews', page: () =>  ReviewsPage()),
        GetPage(name: '/reports', page: () =>  PurchaseReportsPage()),
        GetPage(name: '/returns', page: () =>  ReturnedProductsPage()),
        GetPage(name: '/activity', page: () =>  ActivitiesPage()),
        GetPage(name: '/contact', page: () => const ContactUsPage()),
        GetPage(name: '/faq', page: () => const FaqPage()),
        GetPage(name: '/complaints', page: () =>  ComplaintsPage()),
        GetPage(name: '/terms', page: () =>  TermsAndConditionsPage()),
        GetPage(name: '/privacy', page: () => const PrivacyPolicyScreen()),
        GetPage(name: '/about', page: () => const AboutUsPage()),
        GetPage(name: '/edit-profile', page: () =>  EditProfileScreen()),
        GetPage(name: '/settings', page: () =>  SettingsPage()),
        GetPage(name: '/orders', page: () =>  MyOrdersPage()),
        GetPage(name: '/favorites', page: () =>  FavoritesPage()),
      ],
    );
  }
}