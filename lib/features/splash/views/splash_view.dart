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
    return Scaffold(
      // استخدام لون الخلفية الأساسي كما في الصورة الزرقاء
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // الشعار المخصص (BytoreLogo يتولى الحركات داخلياً)
            const BytoreLogo(size: 450),

            const SizedBox(height: 50),

            // مؤشر التحميل باللون البرتقالي كما في هويتك الجديدة
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                strokeWidth: 2,
              ),
          ],
        ),
      ),
    );
  }
}
