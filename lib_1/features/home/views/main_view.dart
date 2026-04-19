import 'package:flutter/material.dart';
import 'package:bytore/features/profile/views/profile_page.dart';
import 'package:get/get.dart';
import 'package:bytore/core/constants/constants.dart';
import 'package:bytore/features/home/views/home_view.dart';
import 'package:bytore/features/home/views/categories_view.dart';
import 'package:bytore/features/cart/views/cart_view.dart';
import 'package:bytore/features/home/views/components/custom_status_bar.dart';
import 'package:bytore/features/stores/views/stores_view.dart';
import 'package:bytore/core/controllers/cart_controller.dart';
import 'package:bytore/features/home/controllers/main_controller.dart';
import 'package:bytore/core/routes/app_pages.dart';
import 'package:bytore/core/routes/app_routes.dart';
import 'package:bytore/features/home/views/components/custom_bottom_nav_bar.dart';

class MainView extends GetView<MainController> {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      Navigator(
        key: controller.homeNavigatorKey,
        onGenerateRoute: (settings) => _onGenerateRoute(settings, initialRoute: AppRoutes.HOME),
      ),
      Navigator(
        key: controller.categoriesNavigatorKey,
        onGenerateRoute: (settings) => _onGenerateRoute(settings, initialRoute: AppRoutes.CATEGORIES),
      ),
      Navigator(
        key: controller.storesNavigatorKey,
        onGenerateRoute: (settings) => _onGenerateRoute(settings, initialRoute: AppRoutes.STORES),
      ),
      Navigator(
        key: controller.cartNavigatorKey,
        onGenerateRoute: (settings) => _onGenerateRoute(settings, initialRoute: AppRoutes.CART),
      ),
      Navigator(
        key: controller.profileNavigatorKey,
        onGenerateRoute: (settings) => _onGenerateRoute(settings, initialRoute: AppRoutes.PROFILE),
      ),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (controller.handleBackNavigation()) return;
        Get.back(); // Standard exit/back if controller didn't handle it
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false, // Prevents FAB from moving up when keyboard appears
        extendBody: true, // Important for the notch effect
        body: Obx(() => IndexedStack(
          index: controller.selectedIndex.value,
          children: pages,
        )),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10), // Raise it above the bar
          child: SizedBox(
            height: 60,
            width: 60,
            child: FloatingActionButton(
              backgroundColor: kSecondaryColor,
              elevation: 6,
              shape: const CircleBorder(),
              onPressed: () => controller.onTabTapped(2), // Index 2 is Stores
              child: const Icon(Icons.store_rounded, color: Colors.white, size: 28),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: Obx(() {
            final cartController = Get.find<CartController>();
            return CustomBottomNavBar(
              selectedIndex: controller.selectedIndex.value,
              onItemTapped: controller.onTabTapped,
              notificationCount: cartController.totalQuantity,
            );
        }),
      ),
    );
  }

  Route? _onGenerateRoute(RouteSettings settings, {required String initialRoute}) {
    // If the route name is null or '/', use the initial route
    final name = (settings.name == null || settings.name == '/') ? initialRoute : settings.name;
    
    final page = AppPages.routes.firstWhereOrNull((p) => p.name == name);
    
    if (page != null) {
      return GetPageRoute(
        settings: settings,
        page: page.page,
        binding: page.binding,
        transition: Transition.fadeIn,
      );
    }
    return null;
  }
}


