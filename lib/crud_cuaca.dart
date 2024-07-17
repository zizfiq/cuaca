import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminManagementPage extends StatefulWidget {
  @override
  _AdminManagementPageState createState() => _AdminManagementPageState();
}

class _AdminManagementPageState extends State<AdminManagementPage> {
  // URL API untuk operasi CRUD
  static const String URL_READ =
      'http://192.168.209.205/cuaca/api/read_cuaca.php';
  static const String URL_CREATE =
      'http://192.168.209.205/cuaca/api/create_cuaca.php';
  static const String URL_UPDATE =
      'http://192.168.209.205/cuaca/api/update_cuaca.php';
  static const String URL_DELETE_BASE =
      'http://192.168.209.205/cuaca/api/delete_cuaca.php?id=';

  // List untuk menyimpan data cuaca
  List _cuacaList = [];

  @override
  void initState() {
    super.initState();
    // Ambil data cuaca saat inisialisasi state
    _fetchCuaca();
  }

  // Fungsi untuk mengambil data cuaca dari server
  Future<void> _fetchCuaca() async {
    try {
      final response = await http.get(Uri.parse(URL_READ));
      print('Fetch cuaca response status: ${response.statusCode}');
      print('Fetch cuaca response body: ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        print('Tipe data cuaca: ${data.runtimeType}');
        print('Tipe data id: ${data[0]['id'].runtimeType}');
        setState(() {
          _cuacaList = data;
        });
      } else {
        print('Failed to load cuaca');
        throw Exception('Failed to load cuaca: ${response.body}');
      }
    } catch (e) {
      print('Error fetching cuaca: $e');
      throw Exception('Error fetching cuaca: $e');
    }
  }

  // Fungsi untuk membuat data cuaca baru di server
  Future<void> _createCuaca(Map<String, String> cuaca) async {
    print('Attempting to create cuaca: $cuaca');
    var request = http.MultipartRequest('POST', Uri.parse(URL_CREATE));
    cuaca.forEach((key, value) {
      request.fields[key] = value;
    });
    try {
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      print('Create cuaca response status: ${response.statusCode}');
      print('Create cuaca response body: $responseBody');
      if (response.statusCode == 200) {
        print('Cuaca created successfully');
        _fetchCuaca();
      } else {
        print('Failed to create cuaca');
        throw Exception('Failed to create cuaca: $responseBody');
      }
    } catch (e) {
      print('Error creating cuaca: $e');
      throw Exception('Error creating cuaca: $e');
    }
  }

  // Fungsi untuk memperbarui data cuaca yang ada di server
  Future<void> _updateCuaca(Map<String, String> cuaca) async {
    print('Attempting to update cuaca: $cuaca');
    var request = http.MultipartRequest('POST', Uri.parse(URL_UPDATE));
    cuaca.forEach((key, value) {
      request.fields[key] = value.toString();
    });
    try {
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      print('Update cuaca response status: ${response.statusCode}');
      print('Update cuaca response body: $responseBody');
      if (response.statusCode == 200) {
        print('Cuaca updated successfully');
        _fetchCuaca();
      } else {
        print('Failed to update cuaca');
        throw Exception('Failed to update cuaca: $responseBody');
      }
    } catch (e) {
      print('Error updating cuaca: $e');
      throw Exception('Error updating cuaca: $e');
    }
  }

  // Fungsi untuk menghapus data cuaca dari server
  Future<void> _deleteCuaca(String id) async {
    try {
      final response = await http.get(Uri.parse('$URL_DELETE_BASE$id'));
      print('Delete cuaca response status: ${response.statusCode}');
      print('Delete cuaca response body: ${response.body}');
      if (response.statusCode == 200) {
        print('Cuaca deleted successfully');
        _fetchCuaca();
      } else {
        print('Failed to delete cuaca');
        throw Exception('Failed to delete cuaca: ${response.body}');
      }
    } catch (e) {
      print('Error deleting cuaca: $e');
      throw Exception('Error deleting cuaca: $e');
    }
  }

  // Fungsi untuk menampilkan dialog tambah atau edit cuaca
  void _showCuacaDialog({Map<String, dynamic>? cuaca}) {
    final TextEditingController idController =
        TextEditingController(text: cuaca?['id']?.toString() ?? '');
    final TextEditingController statusController =
        TextEditingController(text: cuaca?['status']?.toString() ?? '');
    final TextEditingController suhuController =
        TextEditingController(text: cuaca?['suhu']?.toString() ?? '');
    final TextEditingController humidityController =
        TextEditingController(text: cuaca?['humidity']?.toString() ?? '');
    final TextEditingController windSpeedController =
        TextEditingController(text: cuaca?['wind_speed']?.toString() ?? '');
    final TextEditingController kotaController =
        TextEditingController(text: cuaca?['kota']?.toString() ?? '');
    final TextEditingController lonController =
        TextEditingController(text: cuaca?['lon']?.toString() ?? '');
    final TextEditingController latController =
        TextEditingController(text: cuaca?['lat']?.toString() ?? '');
    final TextEditingController statusImgController =
        TextEditingController(text: cuaca?['status_img']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(cuaca == null ? 'Add Cuaca' : 'Edit Cuaca'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: idController,
                  decoration: InputDecoration(labelText: 'ID'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: statusController,
                  decoration: InputDecoration(labelText: 'Status'),
                ),
                TextField(
                  controller: suhuController,
                  decoration: InputDecoration(labelText: 'Suhu'),
                ),
                TextField(
                  controller: humidityController,
                  decoration: InputDecoration(labelText: 'Humidity'),
                ),
                TextField(
                  controller: windSpeedController,
                  decoration: InputDecoration(labelText: 'Wind Speed'),
                ),
                TextField(
                  controller: kotaController,
                  decoration: InputDecoration(labelText: 'Kota'),
                ),
                TextField(
                  controller: lonController,
                  decoration: InputDecoration(labelText: 'Longitude'),
                ),
                TextField(
                  controller: latController,
                  decoration: InputDecoration(labelText: 'Latitude'),
                ),
                TextField(
                  controller: statusImgController,
                  decoration: InputDecoration(labelText: 'Status Image URL'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final Map<String, String> newCuaca = {
                  'id': idController.text,
                  'status': statusController.text,
                  'suhu': suhuController.text,
                  'humidity': humidityController.text,
                  'wind_speed': windSpeedController.text,
                  'kota': kotaController.text,
                  'lon': lonController.text,
                  'lat': latController.text,
                  'status_img': statusImgController.text,
                };
                if (cuaca == null) {
                  _createCuaca(newCuaca);
                } else {
                  _updateCuaca(newCuaca);
                }
                Navigator.pop(context);
              },
              child: Text(cuaca == null ? 'Add' : 'Update'),
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
        title: const Text('Manage Cuaca'),
      ),
      body: _cuacaList.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _cuacaList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Image.network(
                    _cuacaList[index]['status_img'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print('Error loading image: $error');
                      return Icon(Icons.error);
                    },
                  ),
                  title: Text(_cuacaList[index]['status']),
                  subtitle: Text(_cuacaList[index]['kota']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          final Map<String, dynamic> cuacaData =
                              Map<String, dynamic>.from(_cuacaList[index]);
                          _showCuacaDialog(cuaca: cuacaData);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _deleteCuaca(_cuacaList[index]['id'].toString());
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCuacaDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
