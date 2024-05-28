import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:store_app/providers/auth.dart';
import 'package:store_app/providers/cart.dart';
import 'package:store_app/providers/orders.dart';
import 'package:store_app/providers/products.dart';
import 'package:store_app/screens/auth_screen.dart';
import 'package:store_app/screens/cart_screen.dart';
import 'package:store_app/screens/edit_product_scren.dart';
import 'package:store_app/screens/orders_screen.dart';
import 'package:store_app/screens/product_detail_screen.dart';
import 'package:store_app/screens/user_products_screen.dart';
import 'package:store_app/widgets/splash_screen.dart';
import '/screens/products_overview_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => Auth(),
          ),
          ChangeNotifierProxyProvider<Auth, Products>(
            update: (ctx, auth, previousProducts) => Products(auth.token, previousProducts == null? [] : previousProducts.items, auth.userId),
          ),
          ChangeNotifierProvider(
            create: (context) => Cart(),
          ),
          ChangeNotifierProxyProvider<Auth, Orders>(
            update: (ctx, auth, previousProducts) => Orders(auth.token, previousProducts==null? []:previousProducts, auth.userId),
          ),
        ],
        child: Consumer<Auth>(
          builder: (context, value, _) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'MyShop',
              theme: ThemeData(
                primarySwatch: Colors.purple,
                accentColor: Colors.deepOrange,
                fontFamily: 'Lato',
              ),
              home: value.isAuth? ProductsOverviewScreen() : FutureBuilder(
                future: value.tryAutoLogin(),
                builder: (context, authResultSnapshot) => authResultSnapshot.connectionState == ConnectionState.waiting ? SplashScreen() : AuthScreen(),
                
              ),
              routes: {
                ProductDetailScreen.routeName: (context) =>
                    ProductDetailScreen(),
                CartScreen.routeName: (context) => CartScreen(),
                OrdersScreen.routename: (context) => OrdersScreen(),
                UserProductsScreen.routeName: (context) => UserProductsScreen(),
                EditProductScreen.routeName: (context) => EditProductScreen(),
              },
            );
          },
        ));
  }
}
