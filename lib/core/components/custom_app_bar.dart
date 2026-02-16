import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bytore/core/constants/constants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackArrow;
  final VoidCallback? onBackPressed;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackArrow = true,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: Text(
        title,
        style: GoogleFonts.cairo(
          color: kTextColor,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      leading: showBackArrow
          ? IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: kTextColor,
                size: 20,
              ),
              onPressed: onBackPressed ?? () => Get.back(),
            )
          : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
