import 'package:flutter/material.dart';
import 'dart:math';
import '../../core/theme/app_theme.dart';
import 'main_navigation_screen.dart';

class OrderSuccessScreen extends StatelessWidget {
  final String orderId;

  OrderSuccessScreen({super.key, String? orderId})
      : orderId = orderId ?? "PM-${Random().nextInt(899999) + 100000}";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text("Order Confirmation", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.navyHeader,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ১. সাকসেস হেডার ব্যাজ
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 36,
                    backgroundColor: Color(0xFFE8F5E9),
                    child: Icon(Icons.check_circle, color: Colors.green, size: 50),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Order Placed Successfully!",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black87),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Thank you for shopping with PrimeMarket Global Hub",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Order ID: #$orderId",
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ২. দারাজ/আমাজন স্টাইল লাইভ ট্র্যাকিং টাইমলাইন (Live Stepper)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.local_shipping, color: AppTheme.primary, size: 22),
                      SizedBox(width: 8),
                      Text(
                        "Live Shipment Tracking",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Standard Global Air Delivery (7 - 12 Business Days)",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const Divider(height: 28),

                  // স্টেপ ১: অর্ডার কনফার্মড
                  _buildTrackingStep(
                    title: "Order Confirmed & Paid",
                    subtitle: "Payment received via Secure Gateway",
                    isCompleted: true,
                    isCurrent: false,
                  ),
                  // স্টেপ ২: চায়না ওয়্যারহাউজ প্রসেসিং
                  _buildTrackingStep(
                    title: "Processing at Global Hub (China)",
                    subtitle: "Supplier packaging and inspection in progress",
                    isCompleted: true,
                    isCurrent: true,
                  ),
                  // স্টেপ ৩: বিমানে শিপমেন্ট
                  _buildTrackingStep(
                    title: "Dispatched via Air Cargo",
                    subtitle: "Handed over to international air logistics",
                    isCompleted: false,
                    isCurrent: false,
                  ),
                  // স্টেপ ৪: কাস্টমস ক্লিয়ারেন্স
                  _buildTrackingStep(
                    title: "Customs Clearance",
                    subtitle: "Arrived at destination country port",
                    isCompleted: false,
                    isCurrent: false,
                  ),
                  // স্টেপ ৫: কুরিয়ার ডেলিভারি
                  _buildTrackingStep(
                    title: "Out for Delivery",
                    subtitle: "Local courier heading to your doorstep",
                    isCompleted: false,
                    isCurrent: false,
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ৩. বাটন
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
                    (route) => false,
                  );
                },
                child: const Text(
                  "Continue Shopping",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingStep({
    required String title,
    required String subtitle,
    required bool isCompleted,
    required bool isCurrent,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 11,
              backgroundColor: isCompleted
                  ? Colors.green
                  : isCurrent
                      ? AppTheme.primary
                      : Colors.grey.shade300,
              child: Icon(
                isCompleted ? Icons.check : Icons.circle,
                size: 13,
                color: Colors.white,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? Colors.green : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isCurrent ? AppTheme.primary : Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }
