import 'dart:convert';
import 'package:cuaca/about.dart';
import 'package:cuaca/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'cuaca.dart';
import 'time_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String WEATHER_URL =
      'http://192.168.39.205/cuaca/api/read_cuaca.php';
  static const String TIME_URL =
      'https://timeapi.io/api/Time/current/zone?timeZone=Asia/Jakarta';

  late Future<Cuaca> cuacaData;
  late Future<TimeData> timeData;

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    cuacaData = fetchCuaca();
    timeData = fetchTimeData();
  }

  Future<Cuaca> fetchCuaca({String? city}) async {
    try {
      final response = await http.get(Uri.parse(WEATHER_URL));
      print('Fetch cuaca response status: ${response.statusCode}');
      print('Fetch cuaca response body: ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        if (city != null) {
          for (var item in data) {
            if (item['kota'].toLowerCase() == city.toLowerCase()) {
              return Cuaca.fromJson(item);
            }
          }
          throw Exception('City not found');
        } else {
          return Cuaca.fromJson(data[0]);
        }
      } else {
        print('Failed to load cuaca');
        throw Exception('Failed to load cuaca: ${response.body}');
      }
    } catch (e) {
      print('Error fetching cuaca: $e');
      throw Exception('Error fetching cuaca: $e');
    }
  }

  Future<TimeData> fetchTimeData() async {
    try {
      final response = await http.get(Uri.parse(TIME_URL));
      print('Fetch time response status: ${response.statusCode}');
      print('Fetch time response body: ${response.body}');
      if (response.statusCode == 200) {
        return TimeData.fromJson(json.decode(response.body));
      } else {
        print('Failed to load time data');
        throw Exception('Failed to load time data: ${response.body}');
      }
    } catch (e) {
      print('Error fetching time data: $e');
      throw Exception('Error fetching time data: $e');
    }
  }

  void _showCityNotFoundAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Kota Tidak Ditemukan'),
          content: const Text(
              'Maaf, data cuaca untuk kota yang Anda cari tidak ditemukan.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _searchCity(String city) {
    setState(() {
      cuacaData = fetchCuaca(city: city).catchError((error) {
        if (error.toString().contains('City not found')) {
          _showCityNotFoundAlert(context);
        }
        return fetchCuaca(); // Kembali ke data default jika terjadi kesalahan
      });
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        cuacaData = fetchCuaca();
      }
    });
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
                  hintStyle:
                      TextStyle(color: Colors.white70), // Warna hint text
                ),
                style: const TextStyle(color: Colors.white),
                cursorColor:
                    Colors.white, // Mengubah warna kursor menjadi putih
                onSubmitted: (query) {
                  _searchCity(query);
                  setState(() {
                    _isSearching = false;
                    _searchController.clear();
                  });
                },
              )
            : const Text('Tracking Cuaca'),
        actions: <Widget>[
          IconButton(
            icon: _isSearching
                ? const Icon(Icons.close)
                : const Icon(Icons.search),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
                image: DecorationImage(
                  image: AssetImage('images/weather.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: null,
            ),
            ListTile(
              leading: const Icon(Icons.info, color: Colors.blue),
              title:
                  const Text('Tentang', style: TextStyle(color: Colors.blue)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AboutScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.login, color: Colors.blue),
              title: const Text('Login', style: TextStyle(color: Colors.blue)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/back.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: FutureBuilder(
          future: Future.wait([cuacaData, timeData]),
          builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                  child: Text('Error: ${snapshot.error}',
                      style: TextStyle(color: Colors.white)));
            } else if (!snapshot.hasData) {
              return const Center(
                  child: Text('No data available',
                      style: TextStyle(color: Colors.white)));
            } else {
              Cuaca cuaca = snapshot.data![0] as Cuaca;
              TimeData time = snapshot.data![1] as TimeData;
              return SafeArea(
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: <Widget>[
                    Text(
                      cuaca.kota,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${cuaca.suhu} °C',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      cuaca.status,
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Card(
                      color: Colors.white.withOpacity(0.7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: <Widget>[
                            Image.network(
                              cuaca.statusImg,
                              width: 100,
                              height: 100,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            (loadingProgress
                                                    .expectedTotalBytes ??
                                                1)
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.error,
                                    color: Colors.red, size: 50);
                              },
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    child: _buildInfoItem(
                                        'Humidity', '${cuaca.humidity}%')),
                                Expanded(
                                    child: _buildInfoItem('Wind Speed',
                                        '${cuaca.windSpeed} km/h')),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    child: _buildInfoItem(
                                        'Longitude', '${cuaca.lon}')),
                                Expanded(
                                    child: _buildInfoItem(
                                        'Latitude', '${cuaca.lat}')),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    child: _buildInfoItem(
                                        'Local Time', time.time)),
                                Expanded(
                                    child: _buildInfoItem(
                                        'Local Date', time.date)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: <Widget>[
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF484747),
          ),
        ),
      ],
    );
  }
}
