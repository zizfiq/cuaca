// time_data.dart
class TimeData {
  final String time;
  final String date;

  TimeData({required this.time, required this.date});

  factory TimeData.fromJson(Map<String, dynamic> json) {
    return TimeData(
      time: json['time'],
      date: json['date'],
    );
  }
}
