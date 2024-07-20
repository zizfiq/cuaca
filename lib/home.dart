import 'dart:convert';
import 'package:cuaca/about.dart';
import 'package:cuaca/login.dart';
import 'package:cuaca/crud_cuaca.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'cuaca.dart';
import 'settings.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String WEATHER_URL =
      'http://192.168.39.205/cuaca/api/read_cuaca.php';
  static const String TIME_URL =
      'http://worldtimeapi.org/api/timezone/Asia/Jakarta';

  late Future<Cuaca> cuacaData;
  late Future<TimeData> timeData;

  bool _isSearching = false;
  bool _isLoggedIn = false;
  final TextEditingController _searchController = TextEditingController();

  String _tempUnit = 'Celsius';
  String _windSpeedUnit = 'km/h';

  String _username = '';

  _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _tempUnit = prefs.getString('tempUnit') ?? 'Celsius';
      _windSpeedUnit = prefs.getString('windSpeedUnit') ?? 'km/h';
    });
    // Tambahkan ini untuk me-refresh data cuaca setelah mengubah pengaturan
    _refreshData();
  }

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _loadSettings();
    cuacaData = fetchCuaca();
    timeData = fetchTimeData();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    String? loginTimeString = prefs.getString('loginTime');
    String username = prefs.getString('username') ?? '';

    if (isLoggedIn && loginTimeString != null) {
      DateTime loginTime = DateTime.parse(loginTimeString);
      DateTime now = DateTime.now();
      if (now.difference(loginTime).inHours < 1) {
        setState(() {
          _isLoggedIn = true;
          _username = username;
        });
      } else {
        await prefs.remove('isLoggedIn');
        await prefs.remove('loginTime');
        await prefs.remove('username');
      }
    }
  }

  Future<Cuaca> fetchCuaca({String? city}) async {
    try {
      final response = await http.get(Uri.parse(WEATHER_URL));
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
        throw Exception('Failed to load cuaca: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching cuaca: $e');
    }
  }

  Future<TimeData> fetchTimeData() async {
    try {
      final response = await http.get(Uri.parse(TIME_URL));
      if (response.statusCode == 200) {
        return TimeData.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load time data: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching time data: $e');
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      cuacaData = fetchCuaca();
      timeData = fetchTimeData();
    });
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
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
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
            if (_isLoggedIn) ...[
              ListTile(
                leading: const Icon(Icons.cloud, color: Colors.blue),
                title: const Text('Kelola Data Cuaca',
                    style: TextStyle(color: Colors.blue)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AdminManagementPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings, color: Colors.blue),
                title: const Text('Pengaturan',
                    style: TextStyle(color: Colors.blue)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsPage()),
                  ).then((_) => _loadSettings());
                },
              ),
              ListTile(
                leading: const Icon(Icons.info, color: Colors.blue),
                title:
                    const Text('Tentang', style: TextStyle(color: Colors.blue)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AboutScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.blue),
                title:
                    const Text('Logout', style: TextStyle(color: Colors.blue)),
                onTap: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.remove('isLoggedIn');
                  await prefs.remove('loginTime');
                  setState(() {
                    _isLoggedIn = false;
                  });
                  Navigator.pop(context); // Close the drawer
                },
              ),
            ] else ...[
              ListTile(
                leading: const Icon(Icons.settings, color: Colors.blue),
                title: const Text('Pengaturan',
                    style: TextStyle(color: Colors.blue)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsPage()),
                  ).then((_) => _loadSettings());
                },
              ),
              ListTile(
                leading: const Icon(Icons.info, color: Colors.blue),
                title:
                    const Text('Tentang', style: TextStyle(color: Colors.blue)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AboutScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.login, color: Colors.blue),
                title:
                    const Text('Login', style: TextStyle(color: Colors.blue)),
                onTap: () async {
                  bool? isLoggedIn = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                  if (isLoggedIn == true) {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.setBool('isLoggedIn', true);
                    await prefs.setString(
                        'loginTime', DateTime.now().toIso8601String());
                    String username = prefs.getString('username') ?? '';
                    setState(() {
                      _isLoggedIn = true;
                      _username = username;
                    });
                  }
                },
              ),
            ],
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
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refreshData,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: <Widget>[
                if (_isLoggedIn && _username.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      'Hello, $_username',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                FutureBuilder<Cuaca>(
                  future: cuacaData,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                          child: Text('Error: ${snapshot.error}',
                              style: TextStyle(color: Colors.white)));
                    } else if (!snapshot.hasData) {
                      return const Center(
                          child: Text('No weather data available',
                              style: TextStyle(color: Colors.white)));
                    } else {
                      Cuaca cuaca = snapshot.data!;
                      return _buildWeatherCard(cuaca);
                    }
                  },
                ),
                const SizedBox(height: 16),
                FutureBuilder<TimeData>(
                  future: timeData,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                          child: Text('Error: ${snapshot.error}',
                              style: TextStyle(color: Colors.white)));
                    } else if (!snapshot.hasData) {
                      return const Center(
                          child: Text('No time data available',
                              style: TextStyle(color: Colors.white)));
                    } else {
                      TimeData time = snapshot.data!;
                      return _buildTimeCard(time);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherCard(Cuaca cuaca) {
    return Card(
      color: Colors.white.withOpacity(0.7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Text(
              cuaca.kota,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _tempUnit == 'Celsius'
                  ? '${cuaca.suhu} °C'
                  : '${(cuaca.suhu * 9 / 5 + 32).toStringAsFixed(1)} °F',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              cuaca.status,
              style: const TextStyle(
                fontSize: 24,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 16),
            Image.network(
              cuaca.statusImg,
              width: 100,
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
                return const Icon(Icons.error, color: Colors.red, size: 50);
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: _buildInfoItem('Humidity', '${cuaca.humidity}%')),
                Expanded(
                    child: _buildInfoItem(
                        'Wind Speed',
                        _windSpeedUnit == 'km/h'
                            ? '${cuaca.windSpeed} km/h'
                            : '${(cuaca.windSpeed * 0.539957).toStringAsFixed(1)} knot')),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: _buildInfoItem('Longitude', '${cuaca.lon}')),
                Expanded(child: _buildInfoItem('Latitude', '${cuaca.lat}')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeCard(TimeData time) {
    return Card(
      color: Colors.white.withOpacity(0.7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            _buildInfoItem('Local Time', time.localTime),
            const SizedBox(height: 8),
            _buildInfoItem('Local Date', time.localDate),
          ],
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
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}

class TimeData {
  final String localTime;
  final String localDate;

  TimeData({required this.localTime, required this.localDate});

  factory TimeData.fromJson(Map<String, dynamic> json) {
    return TimeData(
      localTime: json['datetime'].substring(11, 19),
      localDate: json['datetime'].substring(0, 10),
    );
  }
}
