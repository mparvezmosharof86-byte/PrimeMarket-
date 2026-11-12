import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/theme/app_theme.dart';
import 'order_success_screen.dart';

class CheckoutWebviewScreen extends StatefulWidget {
  final String checkoutUrl;
  final String title;

  const CheckoutWebviewScreen({
    super.key,
    required this.checkoutUrl,
    this.title = "PrimeMarket Official Checkout",
  });

  @override
  State<CheckoutWebviewScreen> createState() => _CheckoutWebviewScreenState();
}

class _CheckoutWebviewScreenState extends State<CheckoutWebviewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
            // পেমেন্ট সফল হওয়ার সাথে সাথে অটোমেটিক লাইভ ট্র্যাকিং স্ক্রিনে শিফট করবে
            if (url.contains('success') ||
                url.contains('order-detail') ||
                url.contains('thank-you') ||
                url.contains('orderSuccess') ||
                url.contains('pay-success')) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => OrderSuccessScreen()),
              );
            }
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.navyHeader,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            ),
        ],
      ),
    );
  }
}
