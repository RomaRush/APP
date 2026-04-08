import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'core/theme/app_theme.dart';
import 'screens/welcome_screen.dart';
import 'screens/main_screen.dart';
// import 'screens/auth/login_screen.dart';
// import 'screens/email_verification_screen.dart';
import 'core/providers/finance_provider.dart';
import 'core/providers/health_provider.dart';
import 'core/providers/work_provider.dart';
import 'core/providers/nutrition_provider.dart';
import 'core/providers/user_provider.dart';
import 'core/services/weather_service.dart';
import 'core/providers/smart_life_provider.dart';
import 'core/providers/notes_provider.dart';
import 'core/providers/todo_provider.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  // Note: This requires google-services.json (Android) and GoogleService-Info.plist (iOS)
  // If not present, this line might crash or warn.
  // try {
  //   await Firebase.initializeApp();
  // } catch (e) {
  //   debugPrint('Firebase Init Error: $e');
  // }
  
  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  // Enable edge-to-edge
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(const DayloApp());
}

class DayloApp extends StatelessWidget {
  const DayloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FinanceProvider()),
        ChangeNotifierProvider(create: (_) => HealthProvider()),
        ChangeNotifierProvider(create: (_) => WorkProvider()),
        ChangeNotifierProvider(create: (_) => NutritionProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => NotesProvider()),
        ChangeNotifierProvider(create: (_) => TodoProvider()),
        ChangeNotifierProvider(create: (_) => WeatherService()..fetchWeather()),
        ChangeNotifierProxyProvider4<HealthProvider, WorkProvider, FinanceProvider, NutritionProvider, SmartLifeProvider>(
          create: (context) => SmartLifeProvider(
            health: Provider.of<HealthProvider>(context, listen: false),
            work: Provider.of<WorkProvider>(context, listen: false),
            finance: Provider.of<FinanceProvider>(context, listen: false),
            nutrition: Provider.of<NutritionProvider>(context, listen: false),
          ),
          update: (context, health, work, finance, nutrition, previous) =>
              SmartLifeProvider(
            health: health,
            work: work,
            finance: finance,
            nutrition: nutrition,
          ),
        ),
      ],
      child: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          return MaterialApp(
            title: 'DAYLO',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.theme,
            locale: userProvider.appLocale,
            supportedLocales: const [
              Locale('en', ''),
              Locale('ru', ''),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // TEMPORARY: Bypass authentication for development
    return const MainScreen();
  }
}
