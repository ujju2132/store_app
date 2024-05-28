import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavourite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavourite = false,
  });

  Future<void> toggleFavouriteStatus(String token, userId) async {
    final oldStatus = isFavourite;
    isFavourite = !isFavourite;
    notifyListeners();
    final url =
        'https://store-1d278-default-rtdb.firebaseio.com/userFavouritess/$userId/$id.json?auth=$token';
    try {
      await http.put(
        url,
        body: json.encode(isFavourite),
      );
    } catch (error) {
      isFavourite = oldStatus;
      notifyListeners();
    }
  }
}
