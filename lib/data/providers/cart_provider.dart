import 'package:flutter/foundation.dart';
import '../models/product_model.dart';

class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get totalItemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(
      0.0, (sum, item) => sum + (item.product.finalSellingPriceUsd * item.quantity));

  void addToCart(ProductModel product) {
    final index = _items.indexWhere((element) => element.product.id == product.id);
    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(product: product));
    }
    notifyListeners();
  }

  void incrementQuantity(String productId) {
    final index = _items.indexWhere((element) => element.product.id == productId);
    if (index >= 0) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  void decrementQuantity(String productId) {
    final index = _items.indexWhere((element) => element.product.id == productId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void removeFromCart(String productId) {
    _items.removeWhere((element) => element.product.id == productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
