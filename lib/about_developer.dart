import 'package:flutter/material.dart';

// ignore: must_be_immutable
class AboutDeveloper extends StatelessWidget {
  List<String> fileName = ['images/fiqri.jpg', 'images/polbeng.png'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Developer'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 30.0,
                ),
                CircleAvatar(
                  radius: 100,
                  backgroundImage: AssetImage(fileName[0]),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                const Text(
                  'Fiqri Abdul Aziz',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                const Text(
                  'Bidang Minat : Software Engineering',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontStyle: FontStyle.italic,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.email,
                      color: Colors.green,
                    ),
                    SizedBox(width: 5.0),
                    Text(
                      'fiqrioke89@gmail.com',
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30.0,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.asset(
                    fileName[1],
                    height: 200.0,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                const Text(
                  'Politeknik Negeri Bengkalis',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                const Text(
                  'Jurusan : Teknik Informatika',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                const Text(
                  'Prodi : D4 Rekayasa Perangkat Lunak',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(
                  height: 30.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
