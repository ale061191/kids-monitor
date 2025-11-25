import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/app_config.dart';
import 'services/service_locator.dart';
import 'services/background_service.dart';
import 'providers/device_provider.dart';
import 'providers/permission_provider.dart';
import 'providers/monitoring_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/setup/setup_screen.dart';
import 'screens/home/home_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock orientation to portrait (skip on web)
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  // Initialize Supabase
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  // Setup service locator
  await setupServiceLocator();

  // Initialize background service (only on mobile platforms)
  if (!kIsWeb) {
    try {
      await initializeBackgroundService();
    } catch (e) {
      debugPrint('Background service not available on this platform: $e');
    }
  }

  runApp(const ChildModuleApp());
}

class ChildModuleApp extends StatelessWidget {
  const ChildModuleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DeviceProvider()),
        ChangeNotifierProvider(create: (_) => PermissionProvider()),
        ChangeNotifierProvider(create: (_) => MonitoringProvider()),
      ],
      child: MaterialApp(
        title: 'SafeKids Monitor',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
        routes: {
          '/setup': (context) => const SetupScreen(),
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}

