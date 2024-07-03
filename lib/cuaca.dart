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
      suhu: json['suhu'].toDouble(), // Ensure suhu is double
      humidity: json['humidity'],
      windSpeed: json['wind_speed'].toDouble(), // Ensure windSpeed is double
      kota: json['kota'],
      lon: json['lon'].toDouble(), // Ensure lon is double
      lat: json['lat'].toDouble(), // Ensure lat is double
      statusImg: json['status_img'],
    );
  }
}
