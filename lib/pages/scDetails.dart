// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:httpandsqlite/database/database.dart';
import 'package:httpandsqlite/model/product.dart';
import 'package:httpandsqlite/pages/productDetails.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SCDetails extends StatefulWidget {
  const SCDetails({Key? key}) : super(key: key);

  @override
  State<SCDetails> createState() => _SCDetailsState();
}

class _SCDetailsState extends State<SCDetails> {
  late SharedPreferences sharedPref;
  late List<Product> products;
  late DataBase _database;

  @override
  void initState() {
    super.initState();
    products = [];
    _initAndLoad();
  }

  _initAndLoad() async {
    sharedPref = await SharedPreferences.getInstance();
    await _initDB();
    await _loadProducts();
  }

  _initDB() async {
    _database = DataBase();
    await _database.openDatabaseConnection();
  }

  Future<void> _loadProducts() async {
    List<Product> productList = await _database.getProducts(sharedPref);
    setState(() {
      products = productList;
    });
  }

  Future<void> _removeProduct(Product product) async {
    List<Product> products = await _database.getProducts(sharedPref);
    products.removeWhere((p) => p.id == product.id);
    sharedPref.setString('products', jsonEncode(products));
    await _loadProducts();
  }

  void _showRemoveDialog(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remover Produto'),
          content: const Text(
              'Tem certeza de que deseja remover este produto do carrinho?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _removeProduct(product);
                Navigator.of(context).pop();
              },
              child: const Text('Remover'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrinho de Compras ✨'),
      ),
      body: products.isNotEmpty
          ? ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                Product product = products[index];

                return Card(
                  elevation: 5.0,
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 8.0),
                  child: ListTile(
                    title: Text(
                      '${product.name} | PN: ${product.id}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Quantidade: ${product.quantity}'),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Preço total: R\$ ${(product.price! * double.tryParse(product.quantity.toString())!).toStringAsFixed(2)}',
                          style: TextStyle(
                              fontSize: product.quantity > 10 ? 12.0 : 14.0,
                              decoration: product.quantity > 10
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              color: product.quantity > 10
                                  ? Colors.black
                                  : Colors.deepPurple),
                        ),
                        if (product.quantity != null &&
                            product.quantity! > 10) ...[
                          Text(
                            'Desconto: R\$ ${(product.price! * double.tryParse(product.quantity.toString())! * 0.05).toStringAsFixed(2)}',
                            style: const TextStyle(
                                color: Colors.deepPurple, fontSize: 12),
                          ),
                          Text(
                            'Preço total: R\$ ${(product.price * double.tryParse(product.quantity.toString()) - (product.price! * double.tryParse(product.quantity.toString())! * 0.05)).toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.deepPurple,
                              fontSize: 14,
                            ),
                          ),
                        ]
                      ],
                    ),
                    onLongPress: () {
                      _showRemoveDialog(context, product);
                    },
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProductDetails(product: product),
                        ),
                      );
                    },
                  ),
                );
              },
            )
          : const Center(
              child: Text('Ainda não há nenhum produto no carrinho.'),
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Pedido enviado ✨'),
                    content: const Text('Pedido enviado com sucesso!'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
            },
            child: Icon(Icons.send),
          ),
          SizedBox(height: 10.0),
          FloatingActionButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: Icon(Icons.logout),
          ),
        ],
      ),
    );
  }
}
