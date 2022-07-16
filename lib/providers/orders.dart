import 'dart:convert';

import "package:flutter/material.dart";
import 'package:muqaddas_shop/providers/cart.dart';
import "package:http/http.dart" as http;

class OrderItem with ChangeNotifier {
  final String id;
  final double amount;
  final List<CartItem> orderProducts;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.orderProducts,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String authToken;
  final String userId;

  Orders(this.authToken, this._orders, this.userId);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrder() async {
    final url = Uri.parse(
        "https://shopapp-24a6a-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken");

    final response = await http.get(url);
    final List<OrderItem> loadedOrders = [];

    final extracedData = json.decode(response.body);

    if (extracedData == null) {
      return;
    }

    print("orders ->>>>>>>>>>>>>>  ${response.body} ");

    extracedData.forEach((orderId, orderData) {
      loadedOrders.add(OrderItem(
        id: orderId,
        amount: orderData["amount"],
        dateTime: DateTime?.parse(orderData["dateTime"]),
        orderProducts: (orderData['orderProducts'] as List<dynamic>)
            .map(
              (item) => CartItem(
                id: item["id"],
                price: item['price'],
                quantity: item['quantity'],
                title: item['title'],
              ),
            )
            .toList(),
      ));
    });

    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.parse(
        "https://shopapp-24a6a-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken");

    final timeStamp = DateTime.now();

    final response = await http.post(url,
        body: json.encode({
          "amount": total,
          "dateTime": timeStamp.toIso8601String(),
          "orderProducts": cartProducts.map((cartProduct) {
            return {
              "id": cartProduct.id,
              "title": cartProduct.title,
              "price": cartProduct.price,
              "quantity": cartProduct.quantity,
            };
          }).toList(),
        }));

    _orders.insert(
      0,
      OrderItem(
        id: json.decode(response.body)["name"],
        amount: total,
        dateTime: timeStamp,
        orderProducts: cartProducts,
      ),
    );
    notifyListeners();
  }
}
