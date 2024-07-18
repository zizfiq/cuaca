import 'package:cuaca/crud_cuaca.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.get(
      Uri.parse('http://192.168.39.205/cuaca/api/read_user.php'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final users = data['data'] as List;

      final bytes = utf8.encode(_password);
      final digest = md5.convert(bytes);
      final hashedPassword = digest.toString();

      final user = users.firstWhere(
        (user) => user['email'] == _email && user['password'] == hashedPassword,
        orElse: () => null,
      );

      setState(() {
        _isLoading = false;
      });

      if (user != null) {
        if (user['role'] == 'Admin') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => AdminManagementPage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Anda tidak memiliki akses admin')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email atau password salah')),
        );
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal terhubung ke server')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Cuaca App',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              SizedBox(
                height: 50,
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Mohon masukkan email';
                    }
                    return null;
                  },
                  onSaved: (value) => _email = value!,
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                height: 50,
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Mohon masukkan password';
                    }
                    return null;
                  },
                  onSaved: (value) => _password = value!,
                ),
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      height: 50, // Same height as the text fields
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            _login();
                          }
                        },
                        child: Text('Login'),
                      ),
                    ),
              SizedBox(height: 20),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Text('Does not have account?'),
              //     TextButton(
              //       onPressed: () {
              //         // Implement sign up functionality here
              //       },
              //       child: Text('Sign in'),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
