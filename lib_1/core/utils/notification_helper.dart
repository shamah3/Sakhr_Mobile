import 'package:flutter/material.dart';
import 'package:bytore/core/constants/constants.dart';

class NotificationHelper {
  static void showCustomSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo'), // Ensure font is consistent
        ),
        backgroundColor: isError ? Colors.red : kPrimaryColor, // Default blue for success, red for error
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }
}
