import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../core/constants/api_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/product_model.dart';
import '../../data/providers/cart_provider.dart';
import 'checkout_webview_screen.dart';

class ProductDetailsScreen extends StatelessWidget {
  final ProductModel product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(product.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        backgroundColor: AppTheme.navyHeader,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.white,
              width: double.infinity,
              height: 340,
              child: Hero(
                tag: product.id,
                child: CachedNetworkImage(
                  imageUrl: product.image,
                  fit: BoxFit.contain,
                  errorWidget: (_, __, ___) => const Icon(Icons.image, size: 80, color: Colors.grey),
                ),
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        "\$${product.finalSellingPriceUsd}",
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "\$${product.marketPriceUsd}",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.discountBadge,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "-${product.discountPercentage}% OFF",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    product.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, height: 1.3),
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      Icon(Icons.star_half, color: Colors.amber, size: 16),
                      SizedBox(width: 6),
                      Text("4.8 | 240+ Ratings | 500+ Sold", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(top: 8),
              child: const Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.local_shipping_outlined, color: AppTheme.primary, size: 22),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Fast Global Delivery", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text("Estimated 7 - 12 days directly to your doorstep", style: TextStyle(color: Colors.grey, fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 24),
                  Row(
                    children: [
                      Icon(Icons.verified_user_outlined, color: Colors.green, size: 22),
                      SizedBox(width: 10),
                      Text("100% Authentic & Buyer Protection Guaranteed", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Product Highlights", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    product.description.isEmpty
                        ? "Premium grade product with imported factory manufacturing. Optimized for daily usage with durable quality and guaranteed warranty directly backed by PrimeMarket Global Hub."
                        : product.description,
                    style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 90),
          ],
        ),
      ),
      bottomSheet: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, -3)),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFB300),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  cart.addToCart(product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Added to Cart Successfully!"),
                      duration: Duration(seconds: 2),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: const Text("Add to Cart", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CheckoutWebviewScreen(
                        checkoutUrl: ApiConstants.wed2cStoreUrl,
                      ),
                    ),
                  );
                },
                child: const Text("Buy Now", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
