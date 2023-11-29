// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:shared_preferences/shared_preferences.dart';
import 'package:httpandsqlite/model/product.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class QuantityDetails extends StatefulWidget {
  final Product product;

  const QuantityDetails(this.product, {super.key});

  @override
  State<QuantityDetails> createState() => _QuantityDetailsState();
}

class _QuantityDetailsState extends State<QuantityDetails> {
  late SharedPreferences sharedPref;
  @override
  void initState() {
    super.initState();
    _initSharedPref();
  }

  void _initSharedPref() async {
    sharedPref = await SharedPreferences.getInstance();
  }

  int quantity = 1;

  Future<void> _addProductList(int quantity) async {
    List<Map<String, dynamic>> products = [];
    String? productsJson = sharedPref.getString('products');
    if (productsJson != null && productsJson.isNotEmpty) {
      products = List<Map<String, dynamic>>.from(jsonDecode(productsJson));
    }

    bool existentProduct = false;

    for (int i = 0; i < products.length; i++) {
      if (products[i]['id'] == widget.product.id) {
        products[i]['quantity'] += quantity;
        products[i]['price'] += widget.product.price;
        existentProduct = true;
        break;
      }
    }

    if (!existentProduct) {
      Map<String, dynamic> newProduct = {
        "id": widget.product.id,
        "name": widget.product.name,
        "price": widget.product.price,
        "quantity": quantity,
      };
      products.add(newProduct);
    }
    sharedPref.setString('products', jsonEncode(products));
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = widget.product.price * quantity;
    double discountedPrice = totalPrice;

    if (quantity > 10) {
      double discountPercentage = 0.05;
      double discountAmount = totalPrice * discountPercentage;
      discountedPrice = totalPrice - discountAmount;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Produto ✨'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${widget.product.name}',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 10),
                TextButton(
                  onPressed: () {
                    setState(() {
                      quantity = (quantity > 1) ? quantity - 1 : 1;
                    });
                  },
                  child: const Icon(Icons.remove),
                ),
                Text(
                  quantity.toString(),
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      quantity++;
                    });
                  },
                  child: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Preço Total: R\$ ${totalPrice.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18.0,
                decoration: quantity > 10 ? TextDecoration.lineThrough : TextDecoration.none,
              ),
            ),
            if (quantity > 10) ...[
              const SizedBox(height: 10),
              Text(
                'Desconto: - R\$ ${(totalPrice - discountedPrice).toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 10),
              Text(
              'Preço com Desconto: R\$ ${discountedPrice.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _addProductList(quantity);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                textStyle: TextStyle(fontSize: 18.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  side: const BorderSide(
                    color: Colors.deepPurple,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart),
                  const SizedBox(width: 15.0),
                  const Text('Adicionar ao carrinho!'),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                textStyle: TextStyle(fontSize: 18.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  side: const BorderSide(
                    color: Colors.deepPurple,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_back),
                  const SizedBox(width: 15.0),
                  const Text('Voltar para a lista de produtos!'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
