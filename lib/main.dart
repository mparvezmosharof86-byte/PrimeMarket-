import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/main_navigation_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PrimeMarketApp());
}

class PrimeMarketApp extends StatelessWidget {
  const PrimeMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PrimeMarket',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainNavigationScreen(),
    );
  }
}
