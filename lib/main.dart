import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/cart/cart_coordinator.dart';
import 'core/tobacco/tobacco_access_coordinator.dart';
import 'core/theme/app_theme.dart';
import 'core/responsive/media_query_helper.dart';
import 'core/location/address_location_coordinator.dart';
import 'core/wishlist/wishlist_coordinator.dart';
import 'views/main/main_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await CartCoordinator.instance.init();
  await WishlistCoordinator.instance.init();
  await AddressLocationCoordinator.instance.init();
  await TobaccoAccessCoordinator.instance.init();

  runApp(
    DevicePreview(
      // enabled: true,

      enabled: false,
      builder: (context) => const EnchantedForestApp(),
    ),
  );
}

class EnchantedForestApp extends StatefulWidget {
  const EnchantedForestApp({super.key});

  @override
  State<EnchantedForestApp> createState() => _EnchantedForestAppState();
}

class _EnchantedForestAppState extends State<EnchantedForestApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await AddressLocationCoordinator.instance.ensureFirstInstallDetection(
        context,
      );
      await AddressLocationCoordinator.instance.syncOnAppOpenWithPrompts(
        context,
      );
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (!mounted) return;
      AddressLocationCoordinator.instance.syncOnAppOpenWithPrompts(context);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

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
      home: const MainView(),
    );
  }
}
