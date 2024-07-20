import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  int _currentIndex = 0;

  // Define profile data for each index
  static const List<Map<String, dynamic>> _profiles = [
    {
      'name': 'Fiqri Abdul Aziz',
      'status': 'Software Developer',
      'profileImage': 'images/profile.png',
      'coverImage': 'images/cover.png',
      'instagram': 'https://www.instagram.com/fiqri.aaziz',
      'laptopImage': 'images/asus.png',
      'politeknikImage': 'images/polbeng.png',
      'email': 'fiqri@gmail.com',
      'phone': '+628123456789'
    },
    {
      'name': 'Muhammad Siddiq',
      'status': 'Project Manager',
      'profileImage': 'images/profile2.jpg',
      'coverImage': 'images/cover.png',
      'instagram': 'https://www.instagram.com/muhammadsiddiq',
      'laptopImage': 'images/acer.png',
      'politeknikImage': 'images/polbeng.png',
      'email': 'siddiq@gmail.com',
      'phone': '+628987654321'
    },
    {
      'name': 'Nadya Kusuma Indah',
      'status': 'Team Leader',
      'profileImage': 'images/profile3.jpg',
      'coverImage': 'images/cover.png',
      'instagram': 'https://www.instagram.com/yayaki23_',
      'laptopImage': 'images/lenovo.png',
      'politeknikImage': 'images/polbeng.png',
      'email': 'nadya@gmail.com',
      'phone': '+6281122334455'
    },
    {
      'name': 'Nur Atikah',
      'status': 'UI/UX Designer',
      'profileImage': 'images/profile4.jpg',
      'coverImage': 'images/cover.png',
      'instagram': 'https://www.instagram.com/atikahnrr_',
      'laptopImage': 'images/asus.png',
      'politeknikImage': 'images/polbeng.png',
      'email': 'atikah@gmail.com',
      'phone': '+6289988776655'
    },
  ];

  void _launchURL(String url) async {
    if (!await launch(url)) throw 'Could not launch $url';
  }

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _profiles[_currentIndex]['name']!,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                        height:
                            4), // Memberikan sedikit jarak antara nama dan status
                    Text(
                      _profiles[_currentIndex]['status']!,
                      style: const TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                child: Row(
                  children: [
                    Image.asset(
                      _profiles[_currentIndex]['laptopImage']!,
                      width: 70,
                      height: 70,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  'Email: ${_profiles[_currentIndex]['email']}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  'Phone: ${_profiles[_currentIndex]['phone']}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                child: Row(
                  children: [
                    Image.asset(
                      _profiles[_currentIndex]['politeknikImage']!,
                      width: 50,
                      height: 50,
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () =>
                          _launchURL(_profiles[_currentIndex]['instagram']!),
                      child: Image.asset(
                        'images/instagram.png',
                        width: 100,
                        height: 100,
                      ),
                    ),
                  ],
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
