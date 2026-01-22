import 'package:get/get.dart';
import 'package:bytore/features/splash/views/splash_view.dart';
import 'package:bytore/features/home/views/main_view.dart';
import 'package:bytore/features/home/views/home_view.dart';
import 'package:bytore/features/home/views/categories_view.dart';
import 'package:bytore/features/stores/views/stores_view.dart';
import 'package:bytore/features/cart/views/cart_view.dart';
import 'package:bytore/features/product/views/product_detail_view.dart';
import 'package:bytore/features/product/views/product_list_view.dart';
import 'package:bytore/features/authentication/views/login_view.dart';
import 'package:bytore/features/authentication/views/otp_verification_view.dart';
import 'package:bytore/features/home/controllers/main_controller.dart';
import 'package:bytore/features/home/controllers/home_controller.dart';
import 'package:bytore/features/checkout/views/address_page.dart';
import 'package:bytore/features/checkout/views/payment_page.dart';
import 'package:bytore/features/checkout/views/success_page.dart';
import 'package:bytore/features/wishlist/views/wishlist_view.dart';
import 'package:bytore/features/orders/views/tracking_view.dart';
import 'package:bytore/features/profile/views/profile_page.dart';

// Profile Sub-Pages Imports
import 'package:bytore/features/profile/sub_pages/wallet_page.dart';
import 'package:bytore/features/profile/sub_pages/settings_page.dart';
import 'package:bytore/features/profile/sub_pages/edit_profile_page.dart';
import 'package:bytore/features/profile/sub_pages/purchase_reports_page.dart';
import 'package:bytore/features/profile/sub_pages/returned_products_page.dart';
import 'package:bytore/features/profile/sub_pages/activities_page.dart';
import 'package:bytore/features/profile/sub_pages/reviews_page.dart';
import 'package:bytore/features/profile/sub_pages/contact_us_page.dart';
import 'package:bytore/features/profile/sub_pages/faq_page.dart';
import 'package:bytore/features/profile/sub_pages/complaints_page.dart';
import 'package:bytore/features/profile/sub_pages/policy_page.dart';
import 'package:bytore/features/profile/sub_pages/privacy_policy_page.dart';
import 'package:bytore/features/profile/sub_pages/terms_and_conditions_page.dart';
import 'package:bytore/features/profile/sub_pages/about_us_page.dart';

// Bindings
import 'package:bytore/features/home/bindings/home_binding.dart';
import 'package:bytore/features/home/bindings/categories_binding.dart';
import 'package:bytore/features/authentication/bindings/auth_binding.dart';
import 'package:bytore/features/checkout/bindings/checkout_binding.dart';
import 'package:bytore/features/product/bindings/product_list_binding.dart';
import 'package:bytore/features/stores/bindings/stores_binding.dart';

import 'app_routes.dart';

class AppPages {
  static const INITIAL = AppRoutes.SPLASH;

  static final routes = [
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => const SplashView(),
    ),
    GetPage(
      name: AppRoutes.MAIN,
      page: () => const MainView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => MainController());
        Get.lazyPut(() => HomeController());
      }),
    ),
    GetPage(
      name: AppRoutes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.CATEGORIES,
      page: () => const CategoriesView(),
      binding: CategoriesBinding(),
    ),
    GetPage(
      name: AppRoutes.STORES,
      page: () => const StoresView(),
      binding: StoresBinding(),
    ),
    GetPage(
      name: AppRoutes.PRODUCT_LIST,
      page: () => ProductListView(
        categoryTitle: Get.arguments?['categoryTitle'] ?? '',
        apiCategorySlug: Get.arguments?['apiCategorySlug'] ?? 'all',
      ),
      binding: ProductListBinding(),
    ),
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => LoginView(redirectToAddress: Get.arguments?['redirectToAddress'] ?? false),
      binding: AuthBinding(),// الربط هنا صحيح تماماً
    ),
    GetPage(
      name: AppRoutes.OTP,
      page: () => OtpVerificationView(
        phoneNumber: Get.arguments?['phoneNumber'] ?? '',
        redirectToAddress: Get.arguments?['redirectToAddress'] ?? false,
      ),
      binding: AuthBinding(), // تأكدنا من ربط الكنترولر بشاشة الـ OTP أيضاً
    ),
    GetPage(
      name: AppRoutes.CHECKOUT_ADDRESS,
      page: () => const AddressPage(),
      binding: CheckoutBinding(),
    ),
    GetPage(
      name: AppRoutes.CHECKOUT_PAYMENT,
      page: () => const PaymentPage(),
      binding: CheckoutBinding(),
    ),
    GetPage(
      name: AppRoutes.CHECKOUT_SUCCESS,
      page: () => const SuccessPage(),
      binding: CheckoutBinding(),
    ),
    GetPage(
      name: AppRoutes.WISHLIST,
      page: () => const WishlistView(),
    ),
    GetPage(
      name: AppRoutes.TRACKING,
      page: () => const TrackingView(),
    ),
    GetPage(
      name: AppRoutes.PROFILE,
      page: () => const ProfilePage(),
    ),
    GetPage(
      name: AppRoutes.WALLET,
      page: () => WalletPage(),
    ),
    GetPage(
      name: AppRoutes.SETTINGS,
      page: () => SettingsPage(),
    ),
    GetPage(
      name: AppRoutes.EDIT_PROFILE,
      page: () => EditProfileScreen(),
    ),
    GetPage(
      name: AppRoutes.REPORTS,
      page: () => PurchaseReportsPage(),
    ),
    GetPage(
      name: AppRoutes.RETURNS,
      page: () => ReturnedProductsPage(),
    ),
    GetPage(
      name: AppRoutes.ACTIVITY,
      page: () => ActivitiesPage(),
    ),
    GetPage(
      name: AppRoutes.REVIEWS,
      page: () => ReviewsPage(),
    ),
    GetPage(
      name: AppRoutes.CONTACT,
      page: () => ContactUsPage(),
    ),
    GetPage(
      name: AppRoutes.FAQ,
      page: () => FaqPage(),
    ),
    GetPage(
      name: AppRoutes.COMPLAINTS,
      page: () => ComplaintsPage(),
    ),
    GetPage(
      name: AppRoutes.RETURN_POLICY,
      page: () => PolicyPage(),
    ),
    GetPage(
      name: AppRoutes.PRIVACY,
      page: () => const PrivacyPolicyScreen(),
    ),
    GetPage(
      name: AppRoutes.TERMS,
      page: () => TermsAndConditionsPage(),
    ),
    GetPage(
      name: AppRoutes.ABOUT,
      page: () => const AboutUsPage(),
    ),
  ];
}