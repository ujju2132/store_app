import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:store_app/screens/edit_product_scren.dart';
import 'package:store_app/widgets/app_drawer.dart';
import 'package:store_app/widgets/user_product_items.dart';
import '../providers/products.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products-screeen';

  Future<Void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false).fetchAndSetProducts(true);
  }
  @override
  Widget build(BuildContext context) {
    // final productsData = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context,  EditProductScreen.routeName);
            },
            icon: const Icon(Icons.add),
          )
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (context, snapshot) => snapshot.connectionState == ConnectionState.waiting? Center(child: CircularProgressIndicator(),) : RefreshIndicator(
          onRefresh:  () => _refreshProducts(context),
          child: Consumer<Products>(
            builder:(context, productsData, _) => Padding(
              padding: EdgeInsets.all(8),
              child: ListView.builder(
                itemCount: productsData.items.length,
                itemBuilder: (_, i) => UserProductItem(
                    productsData.items[i].id,
                    productsData.items[i].title, productsData.items[i].imageUrl),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
