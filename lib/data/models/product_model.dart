class ProductModel {
  final String id;
  final String title;
  final String image;
  final double wholesalePriceUsd;
  final double suggestedRetailPriceUsd;
  final String categoryName;
  final String description;

  // Smart Computed Fields
  final double finalSellingPriceUsd;
  final double marketPriceUsd;
  final int discountPercentage;

  ProductModel({
    required this.id,
    required this.title,
    required this.image,
    required this.wholesalePriceUsd,
    required this.suggestedRetailPriceUsd,
    required this.categoryName,
    required this.description,
    required this.finalSellingPriceUsd,
    required this.marketPriceUsd,
    required this.discountPercentage,
  });

  factory ProductModel.fromCJJson(Map<String, dynamic> json) {
    // Parse Base CJ Prices
    double wholesale = 0.0;
    if (json['sellPrice'] != null) {
      wholesale = double.tryParse(json['sellPrice'].toString().split('-').first.trim()) ?? 5.0;
    }

    double suggestedRetail = 0.0;
    if (json['suggestedRetailPrice'] != null) {
      suggestedRetail = double.tryParse(json['suggestedRetailPrice'].toString()) ?? (wholesale * 2.0);
    } else {
      suggestedRetail = wholesale * 2.0;
    }

    // --- ডায়নামিক স্মার্ট প্রাইসিং অ্যালগরিদম ---
    // ১. সর্বনিম্ন নিরাপদ মূল্য: পাইকারি মূল্য + ১৫% নিশ্চিত লাভ
    double floorPrice = wholesale * 1.15;

    // ২. মার্কেট মূল্যের চেয়ে ১০% কমে আকর্ষণীয় বিক্রয়মূল্য নির্ধারণ
    double calculatedSellingPrice = suggestedRetail * 0.90;

    // নিরাপত্তা চেক: বিক্রয়মূল্য ফ্লোর প্রাইসের নিচে নামবে না
    if (calculatedSellingPrice < floorPrice) {
      calculatedSellingPrice = floorPrice;
    }

    // ডিসকাউন্ট পার্সেন্টেজ গণনা
    int discount = 0;
    if (suggestedRetail > calculatedSellingPrice) {
      discount = (((suggestedRetail - calculatedSellingPrice) / suggestedRetail) * 100).round();
    }
    if (discount <= 0) discount = 15;

    return ProductModel(
      id: json['pid'] ?? json['id'] ?? '',
      title: json['productNameEn'] ?? json['productName'] ?? 'Exclusive Imported Item',
      image: json['productImage'] ?? '',
      wholesalePriceUsd: wholesale,
      suggestedRetailPriceUsd: suggestedRetail,
      categoryName: json['categoryName'] ?? 'Trending',
      description: json['description'] ?? '',
      finalSellingPriceUsd: double.parse(calculatedSellingPrice.toStringAsFixed(2)),
      marketPriceUsd: double.parse(suggestedRetail.toStringAsFixed(2)),
      discountPercentage: discount,
    );
  }
}
