class WalletModel {
  final double balance;
  final String currency;
  final List<WalletTransaction> transactions;

  WalletModel({
    required this.balance,
    required this.currency,
    required this.transactions,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    var transList = (json['transactions'] as List? ?? [])
        .map((e) => WalletTransaction.fromJson(e))
        .toList();
    
    return WalletModel(
      balance: (json['balance'] ?? 0).toDouble(),
      currency: json['currency'] ?? "YER",
      transactions: transList,
    );
  }
}

class WalletTransaction {
  final int id;
  final double amount;
  final String type; // credit / debit
  final String description;
  final DateTime createdAt;

  WalletTransaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.description,
    required this.createdAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'] ?? 0,
      amount: (json['amount'] ?? 0).toDouble(),
      type: json['type'] ?? "debit",
      description: json['description'] ?? "",
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }
}
