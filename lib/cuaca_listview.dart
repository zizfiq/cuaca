import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cuaca/about_developer.dart';
import 'package:cuaca/detail_cuaca.dart';
import 'cuaca.dart';

class CuacaListView extends StatefulWidget {
  const CuacaListView({super.key});

  @override
  CuacaListViewState createState() => CuacaListViewState();
}

class CuacaListViewState extends State<CuacaListView> {
  static const String URL = 'http://192.168.162.205/cuaca';
  late Future<List<Cuaca>> result_data;

  @override
  void initState() {
    super.initState();
    result_data = _fetchCuaca();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuaca App'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return AboutDeveloper();
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Cuaca>>(
        future: _fetchCuaca(),
        builder: (context, snapshot) {
          return RefreshIndicator(
            onRefresh: _pullRefresh,
            child: Center(child: _listView(snapshot)),
          );
        },
      ),
    );
  }

  Future<void> _pullRefresh() async {
    setState(() {
      result_data = _fetchCuaca();
    });
  }

  Widget _listView(AsyncSnapshot snapshot) {
    if (snapshot.hasData) {
      List<Cuaca> data = snapshot.data;
      return _cuacaListView(data);
    } else if (snapshot.hasError) {
      return Text("${snapshot.error}");
    }
    return const CircularProgressIndicator();
  }

  Future<List<Cuaca>> _fetchCuaca() async {
    var uri = Uri.parse('$URL/api/read_cuaca.php');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      List jsonData = jsonResponse['data'];
      return jsonData.map((cuaca) => Cuaca.fromJson(cuaca)).toList();
    } else {
      throw Exception('Failed to load data from API');
    }
  }

  ListView _cuacaListView(List<Cuaca> data) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        return _tile(context, data[index]);
      },
    );
  }

  ListTile _tile(BuildContext context, Cuaca data) => ListTile(
      title: Text(
        data.kota,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 20,
        ),
      ),
      subtitle: Text('Suhu: ${data.suhu}°C\nKelembaban: ${data.humidity}%'),
      leading: Image.network(
        data.statusImg, // URL default jika status_img null
        width: 50,
        height: 100,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      (loadingProgress.expectedTotalBytes ?? 1)
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.error, color: Colors.red, size: 50);
        },
      ),
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return DetailCuaca(data: data);
        }));
        final snackBar = SnackBar(
          duration: const Duration(seconds: 1),
          content: Text("Anda memilih ${data.kota}"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      });
}
