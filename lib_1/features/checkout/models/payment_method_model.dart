import 'package:flutter/material.dart';

class PaymentMethodModel {
  final String id;
  final String name;
  final String? description;
  final String? iconUrl;
  final bool isActive;

  PaymentMethodModel({
    required this.id,
    required this.name,
    this.description,
    this.iconUrl,
    this.isActive = true,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: (json['id'] ?? '').toString(),
      name: json['name'] ?? "",
      description: json['description'],
      iconUrl: json['icon_url'] ?? json['image'],
      isActive: json['is_active'] ?? true,
    );
  }

  IconData get defaultIcon {
    switch (id) {
      case 'cash':
        return Icons.money_rounded;
      case 'bank_transfer':
        return Icons.account_balance_rounded;
      case 'wallet':
      case 'floosak_wallet':
        return Icons.account_balance_wallet_rounded;
    }

    if (name.contains('كاش') || name.contains('نقد')) {
      return Icons.money_rounded;
    }
    if (name.contains('بنكي') || name.contains('تحويل')) {
      return Icons.account_balance_rounded;
    }
    if (name.contains('بطاقة') || name.contains('فيزا')) {
      return Icons.credit_card_rounded;
    }
    if (name.contains('محفظة')) {
      return Icons.account_balance_wallet_rounded;
    }
    return Icons.payment_rounded;
  }
}
