import 'package:flutter/material.dart';

import 'core/constants/app_strings.dart';
import 'core/presentation/auth_gate.dart';
import 'core/theme/app_theme.dart';

class ExomaniaApp extends StatelessWidget {
  const ExomaniaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      home: const AuthGate(),
    );
  }
}
