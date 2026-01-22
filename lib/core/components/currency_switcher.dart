import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bytore/core/controllers/app_controller.dart';
import 'package:bytore/core/constants/constants.dart';

class CurrencySwitcher extends GetView<AppController> {
  final bool isLight;

  const CurrencySwitcher({super.key, this.isLight = false});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (String newValue) {
        controller.changeCurrency(newValue);
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      offset: const Offset(0, 45),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        _buildMenuItem('YER_OLD', 'ريال يمني قديم (ر.ي.ق)'),
        _buildMenuItem('YER_NEW', 'ريال يمني جديد (ر.ي.ج)'),
        _buildMenuItem('SAR', 'ريال سعودي (ر.س)'),
        _buildMenuItem('USD', 'دولار (\$)'),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: kBgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.currency_exchange, color: kTextColor, size: 18),
            const SizedBox(width: 8),
            Obx(() => Text(
              controller.currencyName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: kTextColor,
              ),
            )),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(String value, String text) {
    return PopupMenuItem<String>(
      value: value,
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }
}
