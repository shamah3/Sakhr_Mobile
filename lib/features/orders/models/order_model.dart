import 'package:flutter/material.dart';

enum OrderStatus {
  pending,
  confirmed,
  processing,
  outForDelivery,
  delivered,
  late,
}

class OrderModel {
  final String id;
  final DateTime date;
  final OrderStatus status;
  final double totalPrice;
  final int itemCount;
  final String shippingAddress;

  OrderModel({
    required this.id,
    required this.date,
    required this.status,
    required this.totalPrice,
    required this.itemCount,
    required this.shippingAddress,
  });

  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return "قيد الانتظار";
      case OrderStatus.confirmed:
        return "تم التأكيد";
      case OrderStatus.processing:
        return "جاري التجهيز";
      case OrderStatus.outForDelivery:
        return "قيد التوصيل";
      case OrderStatus.delivered:
        return "تم التوصيل";
      case OrderStatus.late:
        return "متأخر";
    }
  }

  Color get statusColor {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.processing:
        return Colors.purple;
      case OrderStatus.outForDelivery:
        return Colors.indigo;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.late:
        return Colors.red;
    }
  }
}
