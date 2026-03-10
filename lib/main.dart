import 'package:flutter/material.dart';

import 'services/app_bootstrap.dart';
import 'screens/main_shell.dart';
import 'screens/intro_splash_screen.dart';
import 'services/data/a1_data_service.dart';

// ✅ yeni tema
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const k = String.fromEnvironment('GCP_TTS_KEY');
  // ignore: avoid_print
  print("GCP_TTS_KEY len = ${k.length}");

  await A1DataService.I.load();
  // ignore: avoid_print
  print("A1DataService loaded = ${A1DataService.I.isLoaded}");

  await AppBootstrap().init();
  runApp(const AlmancaAkademiApp());
}

class AlmancaAkademiApp extends StatelessWidget {
  const AlmancaAkademiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Almanca Akademi",
      // ✅ yeni theme buradan geliyor
      theme: AppTheme.darkTheme,
      home: const IntroSplashScreen(),
    );
  }
}