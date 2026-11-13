import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/product_model.dart';
import '../../data/providers/cart_provider.dart';
import '../../data/services/stripe_payment_service.dart';
import 'order_success_screen.dart';

class NativeCheckoutScreen extends StatefulWidget {
  final ProductModel? product;

  const NativeCheckoutScreen({super.key, this.product});

  @override
  State<NativeCheckoutScreen> createState() => _NativeCheckoutScreenState();
}

class _NativeCheckoutScreenState extends State<NativeCheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();

  bool _isProcessing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _processOrder(double totalAmount) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    // আসল Stripe Native PaymentSheet কল করা
    final bool isPaid = await StripePaymentService.makePayment(
      amountUsd: totalAmount,
      customerName: _nameController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (isPaid) {
      if (widget.product == null) {
        Provider.of<CartProvider>(context, listen: false).clearCart();
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OrderSuccessScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Payment Cancelled or Invalid API Keys! Check Stripe Keys."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final isSingleProduct = widget.product != null;

    final double subtotal = isSingleProduct
        ? widget.product!.finalSellingPriceUsd
        : cart.subtotal;
    const double shipping = 0.00;
    final double total = subtotal + shipping;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text("Order Checkout", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: AppTheme.navyHeader,
      ),
      body: _isProcessing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppTheme.primary),
                  SizedBox(height: 16),
                  Text("Opening Secure Stripe Gateway...", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            )
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ১. ডেলিভারি ঠিকানা সেকশন
                    _buildSectionContainer(
                      title: "Delivery Address",
                      icon: Icons.location_on_outlined,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(labelText: "Full Name", prefixIcon: Icon(Icons.person_outline)),
                            validator: (val) => val == null || val.isEmpty ? "Required" : null,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(labelText: "Mobile Phone Number", prefixIcon: Icon(Icons.phone_outlined)),
                            validator: (val) => val == null || val.isEmpty ? "Required" : null,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _cityController,
                            decoration: const InputDecoration(labelText: "City / District", prefixIcon: Icon(Icons.location_city)),
                            validator: (val) => val == null || val.isEmpty ? "Required" : null,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _addressController,
                            decoration: const InputDecoration(labelText: "Street Address, House / Apt", prefixIcon: Icon(Icons.home_outlined)),
                            validator: (val) => val == null || val.isEmpty ? "Required" : null,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ২. প্রোডাক্ট সামারি
                    _buildSectionContainer(
                      title: "Order Items Summary",
                      icon: Icons.shopping_bag_outlined,
                      child: isSingleProduct
                          ? _buildProductRow(widget.product!.title, widget.product!.image, widget.product!.finalSellingPriceUsd, 1)
                          : Column(
                              children: cart.items.map((item) {
                                return _buildProductRow(item.product.title, item.product.image, item.product.finalSellingPriceUsd, item.quantity);
                              }).toList(),
                            ),
                    ),

                    const SizedBox(height: 14),

                    // ৩. পেমেন্ট মেথড ট্রাস্ট ব্যাজ
                    _buildSectionContainer(
                      title: "Payment Method (Powered by Stripe)",
                      icon: Icons.lock_outline,
                      child: Row(
                        children: [
                          _buildBadge("VISA", const Color(0xFF1A1F71)),
                          const SizedBox(width: 8),
                          _buildBadge("Mastercard", const Color(0xFFEB001B)),
                          const SizedBox(width: 8),
                          _buildBadge("G Pay", Colors.black87),
                          const Spacer(),
                          const Text("Encrypted", style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ৪. পেমেন্ট সামারি
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Subtotal Items", style: TextStyle(color: Colors.grey)),
                              Text("\$${subtotal.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Global Air Shipping", style: TextStyle(color: Colors.grey)),
                              Text("FREE", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Total Payable", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              Text(
                                "\$${total.toStringAsFixed(2)}",
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.primary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ৫. পে বাটন
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 3,
                        ),
                        onPressed: () => _processOrder(total),
                        child: Text(
                          "Pay with Card / GPay  \$${total.toStringAsFixed(2)}",
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSectionContainer({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const Divider(height: 18),
          child,
        ],
      ),
    );
  }

  Widget _buildProductRow(String title, String image, double price, int qty) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: CachedNetworkImage(imageUrl: image, width: 50, height: 50, fit: BoxFit.cover),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                Text("\$$price x $qty", style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
