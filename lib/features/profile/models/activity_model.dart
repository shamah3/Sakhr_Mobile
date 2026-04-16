class ActivityModel {
  final String title;
  final String time;
  final String date; // اليوم أو أمس أو تاريخ محدد
  final String type; // لتحديد الأيقونة واللون

  ActivityModel({required this.title, required this.time, required this.date, required this.type});

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    // Assuming backend returns created_at etc.
    String parsedTime = "اليوم";
    String parsedDate = "اليوم";
    if (json['created_at'] != null) {
      DateTime dt = DateTime.parse(json['created_at']);
      parsedTime = "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
      parsedDate = "${dt.day}/${dt.month}/${dt.year}";
    }

    return ActivityModel(
      title: json['title'] ?? json['description'] ?? 'نشاط',
      type: json['type'] ?? 'info',
      time: parsedTime,
      date: parsedDate,
    );
  }
}
