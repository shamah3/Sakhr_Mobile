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
  final int id;
  final DateTime dateTime;
  final OrderStatus status;
  final double totalPrice;
  final int itemCount;
  final String shippingAddress;
  final List<String> itemsNames;

  OrderModel({
    required this.id,
    required this.dateTime,
    required this.status,
    required this.totalPrice,
    required this.itemCount,
    required this.shippingAddress,
    required this.itemsNames,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? 0,
      dateTime: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      status: _mapStatus(json['status'] ?? "pending"),
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      itemCount: json['items_count'] ?? 0,
      shippingAddress: json['address'] ?? "",
      itemsNames: (json['items_names'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  static OrderStatus _mapStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return OrderStatus.pending;
      case 'confirmed': return OrderStatus.confirmed;
      case 'processing': return OrderStatus.processing;
      case 'outfordelivery': 
      case 'out_for_delivery': return OrderStatus.outForDelivery;
      case 'delivered': return OrderStatus.delivered;
      case 'late': return OrderStatus.late;
      default: return OrderStatus.pending;
    }
  }

  String get statusText {
// ... (rest of old code)
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
