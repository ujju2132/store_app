import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:store_app/providers/products.dart';
import '../providers/product.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlControler = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editedPRoduct =
      Product(id: null, title: '', description: '', price: 0, imageUrl: '');
  var _isInit = true;
  var _isLoading = false;
  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    if (_isInit) {
      var ProductId = ModalRoute.of(context)?.settings.arguments as String;
      if (ProductId != null) {
        _editedPRoduct =
            Provider.of<Products>(context, listen: false).findById(ProductId);
        _initValues = {
          'title': _editedPRoduct.title,
          'description': _editedPRoduct.description,
          'price': _editedPRoduct.price.toString(),
          'imageUrl': '',
        };
        _imageUrlControler.text = _editedPRoduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void initState() {
    // TODO: implement initState
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlControler.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState?.validate();
    if (!isValid) {
      return;
    }
    _form.currentState?.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedPRoduct.id != null) {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_editedPRoduct.id, _editedPRoduct);
      
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedPRoduct);
      } catch (error) {
        await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('An error occuced'),
                  content: Text('Something went wrong'),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Okay!')),
                  ],
                )
        );
      } 
      // finally {
      //   setState(() {
      //     _isLoading = false;
      //   });
      //   Navigator.of(context).pop();
      // }
      
    }
    setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();

    // Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: [
          IconButton(
            onPressed: _saveForm,
            icon: Icon(Icons.save),
          )
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                  key: _form,
                  child: ListView(
                    children: [
                      TextFormField(
                        initialValue: _initValues['title'],
                        decoration: InputDecoration(labelText: 'Title'),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (value) {
                          FocusScope.of(context).requestFocus(_priceFocusNode);
                        },
                        onSaved: (value) {
                          _editedPRoduct = Product(
                              id: _editedPRoduct.id,
                              isFavourite: _editedPRoduct.isFavourite,
                              title: value.toString(),
                              description: _editedPRoduct.description,
                              price: _editedPRoduct.price,
                              imageUrl: _editedPRoduct.imageUrl);
                        },
                        validator: (String value) {
                          if (value.isEmpty) {
                            return 'Please enter some valid value';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        initialValue: _initValues['price'],
                        decoration: InputDecoration(labelText: 'Price'),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        focusNode: _priceFocusNode,
                        onFieldSubmitted: (value) {
                          FocusScope.of(context)
                              .requestFocus(_descriptionFocusNode);
                        },
                        onSaved: (Value) {
                          _editedPRoduct = Product(
                              id: _editedPRoduct.id,
                              isFavourite: _editedPRoduct.isFavourite,
                              title: _editedPRoduct.title,
                              description: _editedPRoduct.description,
                              price: double.parse(Value.toString()),
                              imageUrl: _editedPRoduct.imageUrl);
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter a price';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          if (double.parse(value) <= 0) {
                            return 'Please enter a number greater than Zero';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        initialValue: _initValues['description'],
                        decoration: InputDecoration(labelText: 'Description'),
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                        focusNode: _descriptionFocusNode,
                        onSaved: (Value) {
                          _editedPRoduct = Product(
                              id: _editedPRoduct.id,
                              isFavourite: _editedPRoduct.isFavourite,
                              title: _editedPRoduct.title,
                              description: Value.toString(),
                              price: _editedPRoduct.price,
                              imageUrl: _editedPRoduct.imageUrl);
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter a description';
                          }
                          if (value.length < 10) {
                            return 'Should be atleast 10 characters long';
                          }
                          return null;
                        },
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            margin: EdgeInsets.only(
                              top: 8,
                              right: 10,
                            ),
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: Colors.grey,
                              ),
                            ),
                            child: _imageUrlControler.text.isEmpty
                                ? Text(
                                    'Enter a Url',
                                    textAlign: TextAlign.center,
                                  )
                                : Container(
                                    child: Image.network(
                                      _imageUrlControler.text,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                          Expanded(
                            child: TextFormField(
                              decoration:
                                  InputDecoration(labelText: 'Image Url'),
                              keyboardType: TextInputType.url,
                              textInputAction: TextInputAction.done,
                              focusNode: _imageUrlFocusNode,
                              controller: _imageUrlControler,
                              onEditingComplete: () {
                                setState(() {});
                              },
                              onFieldSubmitted: (value) {
                                _saveForm();
                              },
                              onSaved: (Value) {
                                _editedPRoduct = Product(
                                    id: _editedPRoduct.id,
                                    isFavourite: _editedPRoduct.isFavourite,
                                    title: _editedPRoduct.title,
                                    description: _editedPRoduct.description,
                                    price: _editedPRoduct.price,
                                    imageUrl: Value.toString());
                              },
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter an image URL';
                                }
                                if (value.endsWith('.png') &&
                                    !value.endsWith('.jpg') &&
                                    !value.endsWith('.jpeg')) {
                                  return 'Please enter a valid URL';
                                }
                                if (!value.startsWith('http') &&
                                    !value.startsWith('https')) {
                                  return 'Please enter a valid URL';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  )),
            ),
    );
  }
}
