import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import './product.dart';

class Products with ChangeNotifier {
  List<Product> _item = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];
  // var _showFavouritesOnly = false;
  final authtoken;
  final userId;

  Products(this.authtoken, this._item, this.userId);

  List<Product> get items {
    // if (_showFavouritesOnly) {
    //   return _item.where((element) => element.isFavourite).toList();
    // }
    return [..._item];
  }

  Product findById(String id) {
    return _item.firstWhere((element) => element.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url =
        'https://store-1d278-default-rtdb.firebaseio.com/products.json?auth=$authtoken&$filterString';
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];
      if (extractedData == null) {
        return;
      }
      url =
          'https://store-1d278-default-rtdb.firebaseio.com/userFavouritess/$userId.json?auth=$authtoken';
      final favouriteResponse = await http.get(url);
      final favouriteData = json.decode(favouriteResponse.body);
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'],
            isFavourite:
                favouriteData == null ? false : favouriteData[prodId] ?? false,
            imageUrl: prodData['imageUrl']));
      });
      _item = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addProduct(product) async {
    final url =
        'https://store-1d278-default-rtdb.firebaseio.com/products.json?auth=$authtoken';
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'creatorId': userId,
        }),
      );

      final newProduct = Product(
          id: json.decode(response.body)['name'],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl);
      _item.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  // void showAll() {
  //   _showFavouritesOnly = false;
  // }

  // void showFavouritesOnly() {
  //   _showFavouritesOnly = true;
  // }

  List<Product> get favouriteItems {
    return _item.where((element) => element.isFavourite).toList();
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _item.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url =
          'https://store-1d278-default-rtdb.firebaseio.com/products/$id.json?auth=$authtoken';
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
          }));
      _item[prodIndex] = newProduct;
    } else {
      print('...');
    }

    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    final url =
        'https://store-1d278-default-rtdb.firebaseio.com/products/$id.json?auth=$authtoken';
    final existingProductIndex =
        _item.indexWhere((element) => element.id == id);
    var existingProduct = _item[existingProductIndex];
    _item.removeWhere((element) => element.id == id);
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _item.insert(existingProductIndex, existingProduct);
      throw HttpException('Could not delete product!');
      existingProduct = null;
    }

    notifyListeners();
  }
}
