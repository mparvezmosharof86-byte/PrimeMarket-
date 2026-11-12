import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/product_model.dart';
import '../../data/services/cj_api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CjApiService _apiService = CjApiService();
  List<ProductModel> _products = [];
  bool _isLoading = true;

  // Flash Sale Timer
  Duration _flashSaleDuration = const Duration(hours: 4, minutes: 25, seconds: 18);
  Timer? _timer;

  // Promotional Banner Images
  final List<String> _banners = [
    "https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=1000&q=80",
    "https://images.unsplash.com/photo-1607083206869-4c7672e72a8a?w=1000&q=80",
    "https://images.unsplash.com/photo-1555529669-e69e7aa0ba9a?w=1000&q=80",
  ];

  // Quick Categories
  final List<Map<String, dynamic>> _categories = [
    {"title": "Flash Deals", "icon": Icons.bolt, "color": Colors.orange},
    {"title": "Gadgets", "icon": Icons.devices_other, "color": Colors.blue},
    {"title": "Fashion", "icon": Icons.checkroom, "color": Colors.pink},
    {"title": "Home Decor", "icon": Icons.chair, "color": Colors.purple},
    {"title": "Beauty", "icon": Icons.spa, "color": Colors.teal},
    {"title": "Under \$5", "icon": Icons.local_offer, "color": Colors.green},
    {"title": "Trending", "icon": Icons.whatshot, "color": Colors.red},
    {"title": "Global Direct", "icon": Icons.public, "color": Colors.indigo},
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
    _loadProducts();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_flashSaleDuration.inSeconds > 0) {
        setState(() {
          _flashSaleDuration = _flashSaleDuration - const Duration(seconds: 1);
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  Future<void> _loadProducts() async {
    final list = await _apiService.getTrendingProducts(page: 1, size: 24);
    setState(() {
      _products = list;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(d.inHours)}:${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // ১. দারাজ/আমাজন স্টাইল স্টিকি হেডার ও সার্চবার
          SliverAppBar(
            floating: true,
            pinned: true,
            elevation: 2,
            backgroundColor: AppTheme.navyHeader,
            toolbarHeight: 65,
            title: Container(
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: "Search in PrimeMarket...",
                  hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                  prefixIcon: Icon(Icons.search, color: AppTheme.primary, size: 22),
                  suffixIcon: Icon(Icons.camera_alt_outlined, color: Colors.grey, size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                onPressed: () {},
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(30),
              child: Container(
                color: const Color(0xFF232F3E),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                child: const Row(
                  children: [
                    Icon(Icons.location_on_outlined, color: Colors.white70, size: 14),
                    SizedBox(width: 6),
                    Text(
                      "Deliver to Global / Fast Shipping Available",
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ২. ব্যানার স্লাইডার
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: CarouselSlider(
                options: CarouselOptions(
                  height: 150,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  viewportFraction: 0.92,
                  autoPlayInterval: const Duration(seconds: 4),
                ),
                items: _banners.map((url) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // ৩. ক্যাটাগরি গ্রিড (Icons)
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: SizedBox(
                height: 160,
                child: GridView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: (cat["color"] as Color).withOpacity(0.12),
                          child: Icon(cat["icon"], color: cat["color"], size: 22),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cat["title"],
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),

          // ৪. কাউন্টডাউন সহ ফ্ল্যাশ সেল সেকশন (⚡ Flash Sale)
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.all(12),
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text(
                        "⚡ FLASH SALE",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppTheme.primary),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _formatDuration(_flashSaleDuration),
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        "SHOP MORE >",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 140,
                    child: _products.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _products.take(6).length,
                            itemBuilder: (context, index) {
                              final item = _products[index];
                              return Container(
                                width: 105,
                                margin: const EdgeInsets.only(right: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: CachedNetworkImage(
                                        imageUrl: item.image,
                                        height: 90,
                                        width: 105,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "\$${item.finalSellingPriceUsd}",
                                      style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.primary, fontSize: 13),
                                    ),
                                    Text(
                                      "\$${item.marketPriceUsd}",
                                      style: const TextStyle(fontSize: 11, color: Colors.grey, decoration: TextDecoration.lineThrough),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),

          // ৫. "JUST FOR YOU" হেডার
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
              child: Row(
                children: [
                  Container(width: 4, height: 16, color: AppTheme.primary),
                  const SizedBox(width: 8),
                  const Text(
                    "JUST FOR YOU",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                  ),
                ],
              ),
            ),
          ),

          // ৬. দারাজ-স্টাইল ২-কলাম প্রোডাক্ট গ্রিড (Masonry Grid)
          _isLoading
              ? const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(30.0),
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  sliver: SliverMasonryGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    itemBuilder: (context, index) {
                      final item = _products[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxSet(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                  child: CachedNetworkImage(
                                    imageUrl: item.image,
                                    height: 170,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorWidget: (_, __, ___) => const Icon(Icons.image, size: 50, color: Colors.grey),
                                  ),
                                ),
                                Positioned(
                                  top: 6,
                                  left: 6,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.discountBadge,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Text(
                                      "-${item.discountPercentage}%",
                                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, height: 1.2),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        "\$${item.finalSellingPriceUsd}",
                                        style: const TextStyle(
                                          color: AppTheme.primary,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        "\$${item.marketPriceUsd}",
                                        style: const TextStyle(
                                          decoration: TextDecoration.lineThrough,
                                          color: Colors.grey,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  const Row(
                                    children: [
                                      Icon(Icons.star, color: Colors.amber, size: 12),
                                      Icon(Icons.star, color: Colors.amber, size: 12),
                                      Icon(Icons.star, color: Colors.amber, size: 12),
                                      Icon(Icons.star, color: Colors.amber, size: 12),
                                      Icon(Icons.star_half, color: Colors.amber, size: 12),
                                      SizedBox(width: 4),
                                      Text("4.8", style: TextStyle(fontSize: 10, color: Colors.grey)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: _products.length,
                  ),
                ),
          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }
}

// Custom BoxShadow Helper
class BoxSet extends BoxShadow {
  const BoxSet({super.color, super.offset, super.blurRadius});
}
