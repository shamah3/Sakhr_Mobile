class TransactionModel {
  final String title;
  final String date;
  final double amount;
  final bool isCredit;

  TransactionModel({
    required this.title,
    required this.date,
    required this.amount,
    required this.isCredit,
  });
}