import 'package:flutter/material.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  int _currentIndex = 0;

  // Define profile data for each index
  static const List<Map<String, String>> _profiles = [
    {
      'name': 'Fiqri Abdul Aziz',
      'status': 'Sibuk',
      'profileImage': 'images/profile.png',
      'coverImage': 'images/cover.png'
    },
    {
      'name': 'Muhammad Siddiq',
      'status': 'Ada',
      'profileImage': 'images/profile2.jpg',
      'coverImage': 'images/cover.png'
    },
    {
      'name': 'Nadya Kusuma Indah',
      'status': 'Ada',
      'profileImage': 'images/profile3.jpg',
      'coverImage': 'images/cover.png'
    },
    {
      'name': 'Nur Atikah',
      'status': 'Ada',
      'profileImage': 'images/profile4.jpg',
      'coverImage': 'images/cover.png'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Tentang Kami',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Stack(
        children: [
          Image.asset(
            _profiles[_currentIndex]['coverImage']!,
            fit: BoxFit.cover,
            width: MediaQuery.of(context).size.width,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: kToolbarHeight),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Container(
                  margin: const EdgeInsets.only(top: 120),
                  child: ClipOval(
                    child: Image.asset(
                      _profiles[_currentIndex]['profileImage']!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  _profiles[_currentIndex]['name']!,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  _profiles[_currentIndex]['status']!,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil 1',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil 2',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil 3',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil 4',
          ),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
