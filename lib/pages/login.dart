// ignore_for_file: use_build_context_synchronously, unnecessary_const

import 'package:flutter/material.dart';
import 'package:httpandsqlite/database/database.dart';
import 'package:httpandsqlite/model/user.dart';
import 'package:httpandsqlite/pages/purchaseDetails.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _name = TextEditingController();
  TextEditingController _pwd = TextEditingController();
  late DataBase _database;

  @override
  void initState() {
    super.initState();
    _initDBandLoad();
  }

  _initDBandLoad() async {
    await _initDB();
  }

  _initDB() async {
    _database = DataBase();
    await _database.openDatabaseConnection();
  }

  Future<Map<String, dynamic>> _validate(String name, String pwd) async {
    User? user = await _database.getUser(name);
    if (user?.name == name && user?.pwd == pwd) {
      return {'boolean': true, 'id': user?.id};
    }
    return {'boolean': false, 'id': null};
  }

  void handleUserName(TextEditingController value) {
    setState(() {
      _name = value;
    });
  }

  void handleSenha(TextEditingController value) {
    setState(() {
      _pwd = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(
                width: 0,
                height: 50,
              ),
              SizedBox(
                width: 350,
                child: Column(
                  children: [
                    const Text(
                      'Seja bem-vindo! ✨',
                      style: const TextStyle(
                          fontSize: 26.0, color: Colors.deepPurple),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    Container(
                      width: 600,
                      margin: const EdgeInsets.only(left: 18.0),
                      child: TextField(
                        style: TextStyle(fontSize: 20.0),
                        controller: _name,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          hintText: 'Insira o nome',
                          prefixIcon:
                              Icon(Icons.person, color: Colors.deepPurple),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.deepPurple),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Container(
                      width: 600,
                      margin: const EdgeInsets.only(left: 18.0),
                      child: TextField(
                        style: TextStyle(fontSize: 20.0),
                        controller: _pwd,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: 'Insira a senha',
                          prefixIcon:
                              Icon(Icons.lock, color: Colors.deepPurple),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.deepPurple),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50.0),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () async {
                    Map<String, dynamic> resultadoCredenciais = await _validate(
                      _name.text.trim(),
                      _pwd.text.trim(),
                    );
                    if (!resultadoCredenciais['boolean']) {
                      return;
                    }
                    int id = resultadoCredenciais['id'] as int;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductListDetails(id),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(130, 30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      side: const BorderSide(
                        color: Colors.deepPurple,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Entrar!',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
