import 'package:flutter/material.dart';

class BytoreLogo extends StatefulWidget {
  final double size;
  final bool animate;

  const BytoreLogo({
    super.key,
    this.size = 300,
    this.animate = true,
  });

  @override
  State<BytoreLogo> createState() => _BytoreLogoState();
}

class _BytoreLogoState extends State<BytoreLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
        );
      },
      child: SizedBox(
        width: widget.size,
        height: widget.size * 0.7,
        child: Image.asset(
          'assets/images/sakhr_logo.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
