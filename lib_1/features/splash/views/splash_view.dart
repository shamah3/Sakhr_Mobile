import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bytore/core/constants/constants.dart';
import 'package:bytore/features/home/views/main_view.dart';

// ملاحظة: تأكد أن كلاس BytoreLogo يدعم إظهار النص بالإنجليزية أو سنكتبه يدوياً هنا
import 'package:bytore/core/components/bytore_logo.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();

    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(          builder: (context) => const MainView(),
        ));
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final logoSize = screenWidth * 0.85; // 85% من عرض الشاشة

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // الشعار في مركز الشاشة بدقة تامة من جميع الاتجاهات
          Align(
            alignment: Alignment.center,
            child: BytoreLogo(size: logoSize, animate: true),
          ),
          // مؤشر التحميل في أسفل الشاشة
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                strokeWidth: 2.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
