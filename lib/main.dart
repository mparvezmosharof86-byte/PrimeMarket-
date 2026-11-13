import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'core/constants/api_constants.dart';
import 'core/theme/app_theme.dart';
import 'data/providers/cart_provider.dart';
import 'presentation/screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // স্বয়ংক্রিয়ভাবে টেস্ট অথবা লাইভ চাবি লোড করবে
  Stripe.publishableKey = ApiConstants.activeStripePublishableKey;
  await Stripe.instance.applySettings();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const PrimeMarketApp(),
    ),
  );
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
