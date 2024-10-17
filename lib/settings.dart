import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _tempUnit = 'Celsius';
  String _windSpeedUnit = 'km/h';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _tempUnit = prefs.getString('tempUnit') ?? 'Celsius';
      _windSpeedUnit = prefs.getString('windSpeedUnit') ?? 'km/h';
    });
  }

  _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('tempUnit', _tempUnit);
    await prefs.setString('windSpeedUnit', _windSpeedUnit);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Satuan Suhu',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: _tempUnit,
              items: ['Celsius', 'Fahrenheit'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _tempUnit = newValue;
                  });
                  _saveSettings();
                }
              },
            ),
            const SizedBox(height: 20),
            const Text('Satuan Kecepatan Angin',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: _windSpeedUnit,
              items: ['km/h', 'knot'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _windSpeedUnit = newValue;
                  });
                  _saveSettings();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
