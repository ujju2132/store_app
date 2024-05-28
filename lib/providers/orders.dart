import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:store_app/widgets/order_items.dart';
import './cart.dart';

class Order {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  Order({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<Order> _orders;
  final token;
  final String userId;

  Orders(this.token, [this._orders = const [], this.userId]);


  List<Order> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
  final url =
      'https://store-1d278-default-rtdb.firebaseio.com/orders/$userId.json?auth=$token';
  final response = await http.get(url);
  final List<Order> loadedOrders = [];
  
  if (response.statusCode != 200) {
    // Handle the case when the HTTP request is not successful
    // You can show an error message or throw an exception
    throw Exception('Failed to fetch orders');
  }
  
  final extractedData = json.decode(response.body) as Map<String, dynamic>;

  if (extractedData == null) {
    return;
  }
  print(extractedData);

  extractedData.forEach((orderId, orderData) {
    loadedOrders.add(Order(
      id: orderId,
      amount: orderData['amount'],
      products: (orderData['products'] as List<dynamic>)
          .map((items) => CartItem(
              id: items['id'],
              title: items['title'],
              quantity: items['quantity'],
              price: items['price']))
          .toList(),
      dateTime: DateTime.parse(orderData['dateTime']),
    ));
  });

  _orders = loadedOrders.reversed.toList();
  notifyListeners();
}


  Future<void> addOrders(List<CartItem> carProducts, double total) async {
    final url =
        'https://store-1d278-default-rtdb.firebaseio.com/orders/$userId.json?auth=$token';
    final timestamp = DateTime.now();
    final response = await http.post(url,
        body: json.encode({
          'amount': total,
          'dateTime': timestamp.toIso8601String(),
          'products': carProducts
              .map((e) => {
                    'id': e.id,
                    'title': e.title,
                    'quantity': e.quantity,
                    'price': e.price
                  })
              .toList(),
        }));
    _orders.insert(
        0,
        Order(
            id: json.decode(response.body)['name'],
            amount: total,
            products: carProducts,
            dateTime: DateTime.now()));
    notifyListeners();
  }
}
