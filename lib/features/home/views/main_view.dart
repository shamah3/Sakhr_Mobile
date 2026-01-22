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

class MainView extends GetView<MainController> {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      Navigator(
        key: controller.homeNavigatorKey,
        onGenerateRoute: (settings) => MaterialPageRoute(
          builder: (context) => const HomeView(),
        ),
      ),
      Navigator(
        key: controller.categoriesNavigatorKey,
        onGenerateRoute: (settings) => MaterialPageRoute(
          builder: (context) => const CategoriesView(),
        ),
      ),
      StoresView(onReturnHome: () => controller.onTabTapped(0)),
      CartView(onReturnHome: () => controller.onTabTapped(0)), 
      const ProfilePage(),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (controller.handleBackNavigation()) return;
        Get.back(); // Standard exit/back if controller didn't handle it
      },
      child: Scaffold(
        body: Column(
          children: [
            const CustomStatusBar(),
            Expanded(
              child: Obx(() => IndexedStack(
                index: controller.selectedIndex.value,
                children: pages,
              )),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomNavBar(),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, -4)
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(0, "الرئيسية", Icons.home_rounded, inactiveIcon: Icons.home_outlined),
              _buildNavItem(1, "الأقسام", Icons.grid_view_rounded, inactiveIcon: Icons.grid_view_outlined),
              _buildNavItem(2, "المتاجر", Icons.store_rounded, isRaised: true),
              _buildNavItem(3, "السلة", Icons.shopping_cart_rounded, inactiveIcon: Icons.shopping_cart_outlined),
              _buildNavItem(4, "حسابي", Icons.person, inactiveIcon: Icons.person_outline),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String label, IconData icon, {bool isRaised = false, IconData? inactiveIcon}) {
    final cartController = Get.find<CartController>();

    return Expanded(
      child: GestureDetector(
        onTap: () => controller.onTabTapped(index),
        behavior: HitTestBehavior.opaque,
        child: Obx(() {
          final isSelected = controller.selectedIndex.value == index;
          final Color itemColor = isSelected ? kPrimaryColor : Colors.grey.shade400;

          Widget iconWidget = Icon(isSelected ? icon : (inactiveIcon ?? icon), color: itemColor, size: 26);

          if (label == "السلة") {
            iconWidget = Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Icon(isSelected ? icon : (inactiveIcon ?? icon), color: itemColor, size: 26),
                if (cartController.totalQuantity > 0)
                  Positioned(
                    right: -3,
                    top: -5,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: kSecondaryColor, shape: BoxShape.circle),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '${cartController.totalQuantity}',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isRaised) ...[
                Transform.translate(
                  offset: const Offset(0, -18),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: kSecondaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: kSecondaryColor.withOpacity(0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 6)
                        )
                      ],
                    ),
                    child: Icon(icon, color: Colors.white, size: 22),
                  ),
                ),
                if (isSelected) 
                  Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: Text(
                      label,
                      style: const TextStyle(color: kPrimaryColor, fontSize: 11, fontWeight: FontWeight.bold)
                    ),
                  )
                else
                  const SizedBox(height: 10),
              ] else ...[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 3,
                  width: isSelected ? 25 : 0,
                  decoration: BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  margin: const EdgeInsets.only(bottom: 8),
                ),
                iconWidget,
                if (isSelected) 
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      label,
                      style: const TextStyle(color: kPrimaryColor, fontSize: 11, fontWeight: FontWeight.bold)
                    ),
                  )
                else
                  const SizedBox(height: 16),
              ],
            ],
          );
        }),
      ),
    );
  }
}
