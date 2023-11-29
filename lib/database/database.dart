import 'package:shared_preferences/shared_preferences.dart';
import 'package:httpandsqlite/model/user.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/product.dart';
import 'dart:convert';

class DataBase {
  late Database _database;

  late List<String> inserts = [
    "INSERT INTO User(id, name, pwd) VALUES(1,'maria', 'password')",
    "INSERT INTO User(id, name, pwd) VALUES(2,'clara', 'password')",
    "INSERT INTO User(id, name, pwd) VALUES(3,'gabriel', 'password')",
    "INSERT INTO User(id, name, pwd) VALUES(4,'livia', 'password')",
    "INSERT INTO User(id, name, pwd) VALUES(5,'lexie', 'password')",
    "INSERT INTO User(id, name, pwd) VALUES(6,'taylor', 'password')",
    "INSERT INTO User(id, name, pwd) VALUES(7,'lana', 'password')",
  ];

  Future<void> openDatabaseConnection() async {
    final String path = join(await getDatabasesPath(), 'database6.db');
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE User(id INTEGER PRIMARY KEY, name TEXT, pwd TEXT)',
        );
        await db.execute(
          'CREATE TABLE Product(id INTEGER PRIMARY KEY, name TEXT, price REAL)',
        );
        for (var element in inserts) {
          await db.execute(element);
        }
      },
    );
  }

  Future<List<User>> getAllUsers() async {
    final List<Map<String, dynamic>> maps = await _database.query('User');
    return List.generate(maps.length, (i) {
      return User(
        id: maps[i]['id'],
        name: maps[i]['name'],
        pwd: maps[i]['pwd'],
      );
    });
  }

  Future<User?> getUser(String name) async {
    List<Map<String, dynamic>> maps = await _database.query(
      'User',
      where: 'name = ?',
      whereArgs: [name],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }

    return null;
  }

  Future<List<Product>> getAllProducts() async {
    final response =
        await http.get(Uri.parse('https://api.escuelajs.co/api/v1/products'));

    final List<Map<String, dynamic>> maps = await _database.query('Product');

    List<dynamic> data = [];
    if (response.statusCode == 200) {
      data = jsonDecode(response.body);
    }

    if (maps.isEmpty) {
      for (var item in data) {
        await _database.execute(
          "INSERT INTO Product(id, name, price) VALUES (?, ?, ?)",
          [item['id'], item['title'], item['price']],
        );
      }
    }

    return List.generate(maps.length, (i) {
      return Product(
        id: maps[i]['id'],
        name: maps[i]['name'],
        price: maps[i]['price'],
      );
    });
  }

  Future<List<Product>> getProducts(SharedPreferences sharedPreferences) async {
    String? productJson = sharedPreferences.getString('products');
    if (productJson != null && productJson.isNotEmpty) {
      List<dynamic> productList = jsonDecode(productJson);

      List<Map<String, dynamic>> productMapList =
          productList.map((item) => item as Map<String, dynamic>).toList();

      List<Product> products =
          productMapList.map((map) => Product.fromMap(map)).toList();

      return products;
    } else {
      return [];
    }
  }
}