import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/product_model.dart';
import '../../data/providers/cart_provider.dart';
import 'order_success_screen.dart';

class NativeCheckoutScreen extends StatefulWidget {
  final ProductModel? product; // যদি সিঙ্গেল আইটেম "Buy Now" থেকে আসে

  const NativeCheckoutScreen({super.key, this.product});

  @override
  State<NativeCheckoutScreen> createState() => _NativeCheckoutScreenState();
}

class _NativeCheckoutScreenState extends State<NativeCheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  // Shipping Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();

  // Card Payment Controllers
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardHolderController = TextEditingController();

  bool _isProcessing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardHolderController.dispose();
    super.dispose();
  }

  void _processOrder(double totalAmount) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    // সিকিউর ট্রানজ্যাকশন সিমুলেশন (৩ সেকেন্ড)
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // কার্ট থেকে আসলে কার্ট ক্লিয়ার করে দেওয়া
    if (widget.product == null) {
      Provider.of<CartProvider>(context, listen: false).clearCart();
    }

    setState(() => _isProcessing = false);

    // সরাসরি লাইভ ট্র্যাকিং সাকসেস স্ক্রিনে শিফট
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => OrderSuccessScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final isSingleProduct = widget.product != null;

    final double subtotal = isSingleProduct
        ? widget.product!.finalSellingPriceUsd
        : cart.subtotal;
    const double shipping = 0.00; // ফ্রি গ্লোবাল ডেলিভারি
    final double total = subtotal + shipping;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text("Order Checkout", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: AppTheme.navyHeader,
      ),
      body: _isProcessing
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: AppTheme.primary),
                  const SizedBox(height: 20),
                  const Text("Securing Payment via Encrypted Gateway...", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 6),
                  Text("Communicating with Global Air Warehouse", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
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
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _cityController,
                                  decoration: const InputDecoration(labelText: "City / District", prefixIcon: Icon(Icons.location_city)),
                                  validator: (val) => val == null || val.isEmpty ? "Required" : null,
                                ),
                              ),
                            ],
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

                    // ৩. কার্ড পেমেন্ট সেকশন (Visa, Mastercard, Amex)
                    _buildSectionContainer(
                      title: "Payment Method (Card)",
                      icon: Icons.credit_card,
                      trailing: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: const Color(0xFF1A1F71), borderRadius: BorderRadius.circular(3)),
                            child: const Text("VISA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: const Color(0xFFEB001B), borderRadius: BorderRadius.circular(3)),
                            child: const Text("MC", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _cardNumberController,
                            keyboardType: TextInputType.number,
                            maxLength: 19,
                            decoration: const InputDecoration(
                              labelText: "Card Number",
                              hintText: "4242 •••• •••• 4242",
                              prefixIcon: Icon(Icons.payment),
                              counterText: "",
                            ),
                            validator: (val) => val == null || val.length < 15 ? "Valid Card Required" : null,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _expiryController,
                                  keyboardType: TextInputType.datetime,
                                  maxLength: 5,
                                  decoration: const InputDecoration(labelText: "MM/YY", hintText: "12/28", counterText: ""),
                                  validator: (val) => val == null || !val.contains("/") ? "MM/YY" : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _cvvController,
                                  keyboardType: TextInputType.number,
                                  maxLength: 4,
                                  obscureText: true,
                                  decoration: const InputDecoration(labelText: "CVV", hintText: "•••", counterText: ""),
                                  validator: (val) => val == null || val.length < 3 ? "CVV" : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _cardHolderController,
                            decoration: const InputDecoration(labelText: "Cardholder Name", prefixIcon: Icon(Icons.badge_outlined)),
                            validator: (val) => val == null || val.isEmpty ? "Required" : null,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.lock_outline, size: 14, color: Colors.green),
                              const SizedBox(width: 6),
                              Text("256-Bit SSL Encryption Guaranteed", style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                            ],
                          ),
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

                    // ৫. কনফার্ম ও পে বাটন
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
                          "Place Order & Pay \$${total.toStringAsFixed(2)}",
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

  Widget _buildSectionContainer({
    required String title,
    required IconData icon,
    Widget? trailing,
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
              const Spacer(),
              if (trailing != null) trailing,
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
            child: CachedNetworkImage(
              imageUrl: image,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
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
