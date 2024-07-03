import 'dart:convert';
import 'package:cuaca/about.dart';
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
  static const String WEATHER_URL = 'http://192.168.162.205/cuaca';
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
    var uri = Uri.parse('$WEATHER_URL/api/read_cuaca.php');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      var cuacaList = jsonResponse['data'];

      if (city != null) {
        for (var item in cuacaList) {
          if (item['kota'].toLowerCase() == city.toLowerCase()) {
            return Cuaca.fromJson(item);
          }
        }
        throw Exception('City not found');
      } else {
        return Cuaca.fromJson(cuacaList[0]);
      }
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<TimeData> fetchTimeData() async {
    var uri = Uri.parse(TIME_URL);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      return TimeData.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to load time data');
    }
  }

  void _searchCity(String city) {
    setState(() {
      cuacaData = fetchCuaca(city: city);
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
                ),
                style: const TextStyle(color: Colors.white),
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
                    builder: (context) => const AboutScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder(
        future: Future.wait([cuacaData, timeData]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          } else {
            Cuaca cuaca = snapshot.data![0] as Cuaca;
            TimeData time = snapshot.data![1] as TimeData;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    cuaca.kota,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${cuaca.suhu} °C',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    cuaca.status,
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Card(
                    color: const Color(0xFFD3F1F9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: <Widget>[
                          Center(
                            child: Image.network(
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
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              _buildInfoItem('Humidity', '${cuaca.humidity}%'),
                              _buildInfoItem(
                                  'Wind Speed', '${cuaca.windSpeed} km/h'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              _buildInfoItem('Longitude', '${cuaca.lon}'),
                              _buildInfoItem('Latitude', '${cuaca.lat}'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              _buildInfoItem('Local Time', time.time),
                              _buildInfoItem('Local Date', time.date),
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
