import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  // --- نظام التصميم ---
  static const Color _primaryColor = Color(0xFF007BFF);
  static const Color _backgroundColor = Colors.white;
  static const Color _surfaceColor = Color(0xFFF8F9FA);
  static const Color _borderColor = Color(0xFFE9ECEF);
  static const Color _textPrimary = Color(0xFF212529);
  static const Color _textSubtle = Color(0xFF6C757D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(
          'استعادة كلمة المرور',
          style: GoogleFonts.cairo(
            color: _textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: _backgroundColor,
        foregroundColor: _textPrimary,
        elevation: 0,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 32),
              const Icon(Icons.lock_reset_rounded, size: 80, color: _primaryColor),
              const SizedBox(height: 16),
              Text(
                'لا تقلق، يحدث ذلك!',
                style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'أدخل بريدك الإلكتروني المسجل وسنرسل لك رابطاً للاستعادة.',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(color: _textSubtle, fontSize: 16),
              ),
              const SizedBox(height: 32),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  filled: true,
                  fillColor: _surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: _borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: _borderColor),
                  ),
                  prefixIcon: const Icon(Icons.email_outlined, color: _textSubtle),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: _primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'إرسال رابط الاستعادة',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}