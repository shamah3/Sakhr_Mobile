import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:bytore/core/bindings/initial_binding.dart';
import 'package:bytore/core/services/notification_service.dart';
import 'package:bytore/core/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Sakhr صخر',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.cairoTextTheme(),
        primaryColor: const Color(0xFF015C92),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF015C92),
          secondary: const Color(0xFFFFA931),
        ),
      ),
      locale: const Locale('ar'),
      fallbackLocale: const Locale('ar'),
      supportedLocales: const [
        Locale('ar'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialBinding: InitialBinding(),
      getPages: AppPages.routes,
      initialRoute: AppPages.INITIAL,
    );
  }
}
