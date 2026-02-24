import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/responsive/media_query_helper.dart';
import 'views/home/home_view.dart';

void main() {
  runApp(
    DevicePreview(
      // enabled: true,
      enabled: false,
      builder: (context) => const EnchantedForestApp(),
    ),
  );
}

class EnchantedForestApp extends StatelessWidget {
  const EnchantedForestApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize responsive MediaQuery logic right at root level context
    // before initializing Theme which uses AppTextStyles relying on MediaQueryHelper
    MediaQueryHelper.init(context);

    return MaterialApp(
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      title: 'Enchanted Forest App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode:
          ThemeMode.system, // Supports both dark and light modes automatically
      home: const HomeView(),
    );
  }
}
