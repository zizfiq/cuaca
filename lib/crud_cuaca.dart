import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminManagementPage extends StatefulWidget {
  @override
  _AdminManagementPageState createState() => _AdminManagementPageState();
}

class _AdminManagementPageState extends State<AdminManagementPage> {
  static const String URL_READ =
      'http://192.168.39.205/cuaca/api/read_cuaca.php';
  static const String URL_CREATE =
      'http://192.168.39.205/cuaca/api/create_cuaca.php';
  static const String URL_UPDATE =
      'http://192.168.39.205/cuaca/api/update_cuaca.php';
  static const String URL_DELETE_BASE =
      'http://192.168.39.205/cuaca/api/delete_cuaca.php?id=';

  List _cuacaList = [];
  List _filteredCuacaList = [];
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCuaca();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchCuaca() async {
    try {
      final response = await http.get(Uri.parse(URL_READ));
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        setState(() {
          _cuacaList = data;
          _filteredCuacaList = data;
        });
      } else {
        throw Exception('Failed to load cuaca');
      }
    } catch (e) {
      throw Exception('Error fetching cuaca: $e');
    }
  }

  void _onSearchChanged() {
    _filterCuacaList(_searchController.text);
  }

  void _filterCuacaList(String query) {
    final filtered = _cuacaList.where((cuaca) {
      final kota = cuaca['kota'].toLowerCase();
      final input = query.toLowerCase();
      return kota.contains(input);
    }).toList();
    setState(() {
      _filteredCuacaList = filtered;
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _filteredCuacaList = _cuacaList;
      }
    });
  }

  Future<void> _createCuaca(Map<String, String> cuaca) async {
    var request = http.MultipartRequest('POST', Uri.parse(URL_CREATE));
    cuaca.forEach((key, value) {
      request.fields[key] = value;
    });
    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        _fetchCuaca();
      } else {
        throw Exception('Failed to create cuaca');
      }
    } catch (e) {
      throw Exception('Error creating cuaca: $e');
    }
  }

  Future<void> _updateCuaca(Map<String, String> cuaca) async {
    var request = http.MultipartRequest('POST', Uri.parse(URL_UPDATE));
    cuaca.forEach((key, value) {
      request.fields[key] = value.toString();
    });
    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        _fetchCuaca();
      } else {
        throw Exception('Failed to update cuaca');
      }
    } catch (e) {
      throw Exception('Error updating cuaca: $e');
    }
  }

  Future<void> _deleteCuaca(String id) async {
    try {
      final response = await http.get(Uri.parse('$URL_DELETE_BASE$id'));
      if (response.statusCode == 200) {
        _fetchCuaca();
      } else {
        throw Exception('Failed to delete cuaca');
      }
    } catch (e) {
      throw Exception('Error deleting cuaca: $e');
    }
  }

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

  Future<void> _refreshData() async {
    await _fetchCuaca();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                onSubmitted: (query) {
                  _filterCuacaList(query);
                  setState(() {
                    _isSearching = false;
                    _searchController.clear();
                  });
                },
              )
            : const Text('Kelola Cuaca'),
        actions: [
          IconButton(
            icon: _isSearching
                ? const Icon(Icons.close)
                : const Icon(Icons.search),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: _filteredCuacaList.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: _filteredCuacaList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Image.network(
                      _filteredCuacaList[index]['status_img'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.error);
                      },
                    ),
                    title: Text(_filteredCuacaList[index]['status']),
                    subtitle: Text(_filteredCuacaList[index]['kota']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.green),
                          onPressed: () {
                            final Map<String, dynamic> cuacaData =
                                Map<String, dynamic>.from(
                                    _filteredCuacaList[index]);
                            _showCuacaDialog(cuaca: cuacaData);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            final id = _filteredCuacaList[index]['id'];
                            _deleteCuaca(id);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCuacaDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
