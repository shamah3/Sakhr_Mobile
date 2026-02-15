import 'package:flutter/material.dart';
import 'package:bytore/core/constants/constants.dart';
import 'package:get/get.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final int notificationCount;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    this.notificationCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: Colors.white,
      elevation: 10,
      surfaceTintColor: Colors.white,
      shadowColor: Colors.black,
      height: 80, // Increased from 60
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          Expanded(child: _buildNavItem(0, "الرئيسية", Icons.home_rounded, Icons.home_outlined)),
          Expanded(child: _buildNavItem(1, "الأقسام", Icons.grid_view_rounded, Icons.grid_view_outlined)),
          const SizedBox(width: 70), // المساحة الوسطى للزر العائم
          Expanded(child: _buildNavItem(3, "السلة", Icons.shopping_cart_rounded, Icons.shopping_cart_outlined, count: notificationCount)),
          Expanded(child: _buildNavItem(4, "حسابي", Icons.person, Icons.person_outline)),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String label, IconData activeIcon, IconData inactiveIcon, {int count = 0}) {
    final isSelected = selectedIndex == index;
    final color = isSelected ? kPrimaryColor : Colors.grey.shade400;
    
    return InkWell(
      onTap: () => onItemTapped(index),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSelected ? activeIcon : inactiveIcon,
                  color: color,
                  size: 28, // Increased from 22
                ),
                if (count > 0)
                  Positioned(
                    top: -6,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: kSecondaryColor,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2), // Reduced from 4
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10, // Increased slightly from 9
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            )
          ],
        ),
      ),
    );
  }
}
