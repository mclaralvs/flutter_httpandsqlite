// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:shared_preferences/shared_preferences.dart';
import 'package:httpandsqlite/pages/quantityDetails.dart';
import 'package:httpandsqlite/database/database.dart';
import 'package:httpandsqlite/pages/scDetails.dart';
import 'package:httpandsqlite/model/product.dart';
import 'package:flutter/material.dart';

class ProductListDetails extends StatefulWidget {
  final int id;
  const ProductListDetails(this.id, {Key? key}) : super(key: key);

  @override
  State<ProductListDetails> createState() => _PurchaseDetailsState();
}

class _PurchaseDetailsState extends State<ProductListDetails> {
  late SharedPreferences sharedPref;
  late DataBase _database;
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    _initDBandLoad();
  }

  _initDBandLoad() async {
    sharedPref = await SharedPreferences.getInstance();
    await _initDB();
    await _loadProdutos();
  }

  _initDB() async {
    _database = DataBase();
    await _database.openDatabaseConnection();
  }

  _loadProdutos() async {
    List<Product> productList = await _database.getAllProducts();
    setState(() {
      products = productList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista de Produtos ✨')),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (BuildContext context, int index) {
          final product = products[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${product.name}',
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Part Number: ${product.id.toString()}',
                      style: const TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Preço: R\$ ${product.price.toString()}',
                      style: const TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuantityDetails(product),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.info),
                          const SizedBox(width: 15.0),
                          const Text('Detalhes'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SCDetails(),
            ),
          );
        },
        child: Icon(Icons.shopping_cart),
      ),
    );
  }
}
