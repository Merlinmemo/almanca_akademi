import 'package:flutter/material.dart';

import 'screens/main_shell.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AlmancaAkademiApp());
}

class AlmancaAkademiApp extends StatelessWidget {
  const AlmancaAkademiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Almanca Akademi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const MainShell(),
    );
  }
}