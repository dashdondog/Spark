import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'router/app_router.dart';
import 'providers/booking_provider.dart';
import 'providers/profile_provider.dart';
import 'theme/app_theme.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setPrefix('clinic_connect_');
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: const ClinicConnectApp(),
    ),
  );
}

class ClinicConnectApp extends StatelessWidget {
  const ClinicConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ClinicBook',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: appRouter,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('mn', 'MN'), // Mongolian
        Locale('en', 'US'), // English
      ],
      locale: const Locale('mn', 'MN'), // Set Mongolian as default
    );
  }
}
