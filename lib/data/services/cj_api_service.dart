import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/product_model.dart';

class CjApiService {
  String? _accessToken;
  DateTime? _tokenExpiry;

  // ১. এক্সেস টোকেন জেনারেটর
  Future<String?> getValidAccessToken() async {
    if (_accessToken != null && _tokenExpiry != null && DateTime.now().isBefore(_tokenExpiry!)) {
      return _accessToken;
    }

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.getAccessTokenUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"apiKey": ApiConstants.cjApiKey}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['result'] == true && data['data'] != null) {
          _accessToken = data['data']['accessToken'];
          _tokenExpiry = DateTime.now().add(const Duration(days: 14));
          return _accessToken;
        }
      }
    } catch (e) {
      debugPrint("❌ CJ Auth Error: $e");
    }
    return null;
  }

  // ২. ট্রেন্ডিং প্রোডাক্টস
  Future<List<ProductModel>> getTrendingProducts({int page = 1, int size = 20}) async {
    final token = await getValidAccessToken();
    if (token == null) return [];

    try {
      final url = Uri.parse("${ApiConstants.productListUrl}?pageNum=$page&pageSize=$size");
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "CJ-Access-Token": token,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['result'] == true && body['data'] != null && body['data']['list'] != null) {
          final List list = body['data']['list'];
          return list.map((item) => ProductModel.fromCJJson(item)).toList();
        }
      }
    } catch (e) {
      debugPrint("❌ Product Fetch Error: $e");
    }
    return [];
  }

  // ৩. প্রোডাক্ট সার্চ মেথড
  Future<List<ProductModel>> searchProducts(String keyword, {int page = 1, int size = 20}) async {
    final token = await getValidAccessToken();
    if (token == null) return [];

    try {
      final url = Uri.parse("${ApiConstants.productListUrl}?productNameEn=$keyword&pageNum=$page&pageSize=$size");
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "CJ-Access-Token": token,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['result'] == true && body['data'] != null && body['data']['list'] != null) {
          final List list = body['data']['list'];
          return list.map((item) => ProductModel.fromCJJson(item)).toList();
        }
      }
    } catch (e) {
      debugPrint("❌ Search Error: $e");
    }
    return [];
  }
}
