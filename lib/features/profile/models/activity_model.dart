class ActivityModel {
  final String title;
  final String time;
  final String date; // اليوم أو أمس أو تاريخ محدد
  final String type; // لتحديد الأيقونة واللون

  ActivityModel({required this.title, required this.time, required this.date, required this.type});
}
