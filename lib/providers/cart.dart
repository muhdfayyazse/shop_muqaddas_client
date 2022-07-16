import "package:flutter/material.dart";

class CartItem {
  final String title;
  final String id;
  final int quantity;
  final double price;

  CartItem({
    required this.title,
    required this.id,
    required this.quantity,
    required this.price,
  });
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  double get totalPrice {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total.floorToDouble();
  }

  void addItems(String title, String id, double price) {
    if (_items.containsKey(id)) {
      // increase quantity
      _items.update(
        id,
        (existingItem) => CartItem(
            title: existingItem.title,
            price: existingItem.price,
            id: existingItem.id,
            quantity: existingItem.quantity + 1),
      );
    } else {
      _items.putIfAbsent(
        id,
        () => CartItem(
          id: DateTime.now().toString(),
          quantity: 1,
          title: title,
          price: price,
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(String? productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }

  void removeSingleItem(String? productId) {
    if (!_items.containsKey(productId)) {
      return;
    }
    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId.toString(),
        (existing) => CartItem(
          id: existing.id,
          quantity: existing.quantity - 1,
          title: existing.title,
          price: existing.price,
        ),
      );
    } else if (_items[productId]!.quantity == 1) {
      _items.remove(productId);
    }
    notifyListeners();
  }
}
