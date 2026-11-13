import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';

class StripePaymentService {
  static Future<bool> makePayment({
    required double amountUsd,
    required String customerName,
  }) async {
    try {
      // ১. ডলারকে সেন্টে (Cents) রূপান্তর
      final int amountInCents = (amountUsd * 100).round();

      // ২. Stripe-এর আসল PaymentIntent তৈরি করা
      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer ${ApiConstants.activeStripeSecretKey}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': amountInCents.toString(),
          'currency': 'usd',
          'payment_method_types[]': 'card',
          'description': 'PrimeMarket Order by $customerName',
        },
      );

      final paymentIntent = jsonDecode(response.body);

      if (response.statusCode != 200 || paymentIntent['client_secret'] == null) {
        debugPrint("❌ Stripe API Error: ${response.body}");
        return false;
      }

      // ৩. অফিশিয়াল Stripe PaymentSheet রেডি করা (কার্ড ও Google Pay সহ)
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          merchantDisplayName: ApiConstants.appName,
          style: ThemeMode.light,
          googlePay: PaymentSheetGooglePay(
            merchantCountryCode: 'US',
            currencyCode: 'USD',
            testEnv: !ApiConstants.isStripeLive,
          ),
        ),
      );

      // ৪. স্ক্রিনের নিচ থেকে অফিশিয়াল Stripe পেমেন্ট শিট ওপেন করা
      await Stripe.instance.presentPaymentSheet();
      return true;
    } on StripeException catch (e) {
      debugPrint("⚠️ Stripe Cancelled/Error: ${e.error.localizedMessage}");
      return false;
    } catch (e) {
      debugPrint("❌ Unexpected Error: $e");
      return false;
    }
  }
}
