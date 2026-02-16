class OrderModel {
  final String id;
  final String date;
  final DateTime dateTime;
  final double total;
  final List<String> itemsNames;

  OrderModel({
    required this.id,
    required this.date,
    required this.dateTime,
    required this.total,
    required this.itemsNames,
  });
}
