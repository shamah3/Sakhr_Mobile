import 'package:flutter/material.dart';
import 'package:bytore/core/constants/constants.dart';

class BytoreLogo extends StatelessWidget {
  final double size;
  final Color? textColor;
  final bool showText;

  const BytoreLogo({
    super.key,
    this.size = 20,
    this.textColor,
    this.showText = true,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Basket Mark
        Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          child: Icon(
            Icons.shopping_cart_rounded,
            color: Colors.white,
            size: size,
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 15),
          Text(
            'BYTORE',
            style: TextStyle(
              color: textColor ?? Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: size * 0.25,
              letterSpacing: 4.0,
            ),
          ),
        ],
      ],
    );
  }
}
