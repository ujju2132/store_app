import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:store_app/providers/products.dart';
import 'package:store_app/screens/edit_product_scren.dart';
import '../screens/edit_product_scren.dart';
import '../providers/product.dart';

class UserProductItem extends StatelessWidget {
  final String id;
  final String title;
  final String immageUrl;

  UserProductItem(
    this.id,
    this.title,
    this.immageUrl,
  );

  @override
  
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(context);
    return Column(
      children: [
        ListTile(
          title: Text(title),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(immageUrl),
          ),
          trailing: Container(
            width: 100,
            child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(EditProductScreen.routeName, arguments: id);
                  },
                  icon: Icon(Icons.edit),
                  color: Theme.of(context).primaryColor,
                ),
                IconButton(
                  onPressed: () async {
                    try {
                      await Provider.of<Products>(context, listen: false)
                          .deleteProduct(id);
                    } catch (error) {
                      
                    }
                  },
                  icon: Icon(Icons.delete),
                  color: Theme.of(context).errorColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
