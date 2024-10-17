class Cuaca {
  final int id;
  final String status;
  final double suhu;
  final int humidity;
  final double windSpeed;
  final String kota;
  final double lon;
  final double lat;
  final String statusImg;

  const Cuaca({
    required this.id,
    required this.status,
    required this.suhu,
    required this.humidity,
    required this.windSpeed,
    required this.kota,
    required this.lon,
    required this.lat,
    required this.statusImg,
  });

  factory Cuaca.fromJson(Map<String, dynamic> json) {
    return Cuaca(
      id: json['id'],
      status: json['status'],
      suhu: json['suhu'].toDouble(),
      humidity: json['humidity'],
      windSpeed: json['wind_speed'].toDouble(),
      kota: json['kota'],
      lon: json['lon'].toDouble(),
      lat: json['lat'].toDouble(),
      statusImg: json['status_img'],
    );
  }
}
