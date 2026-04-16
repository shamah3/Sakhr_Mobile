import 'package:flutter/material.dart';

enum OrderStatus {
  pending,
  confirmed,
  processing,
  outForDelivery,
  readyForPickup,
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
  final List<int> productIds;

  OrderModel({
    required this.id,
    required this.dateTime,
    required this.status,
    required this.totalPrice,
    required this.itemCount,
    required this.shippingAddress,
    required this.itemsNames,
    required this.productIds,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    List items = json['order_items'] ?? json['items'] ?? [];
    
    return OrderModel(
      id: json['id'] ?? 0,
      dateTime: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      status: _mapStatus(json['status'] ?? "pending"),
      totalPrice: double.tryParse((json['total_amount'] ?? json['total_price'] ?? 0).toString()) ?? 0.0,
      itemCount: items.isNotEmpty ? items.length : (json['items_count'] ?? 0),
      shippingAddress: json['shipping_address'] ?? json['address'] ?? "",
      itemsNames: items.isNotEmpty 
          ? items.map((e) => e['product'] != null ? e['product']['name'].toString() : 'منتج').toList()
          : (json['items_names'] as List? ?? []).map((e) => e.toString()).toList(),
      productIds: items.isNotEmpty
          ? items.map((e) => int.tryParse(e['product_id'].toString()) ?? 0).toList()
          : (json['product_ids'] as List? ?? []).map((e) => int.tryParse(e.toString()) ?? 0).toList(),
    );
  }

  static OrderStatus _mapStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return OrderStatus.pending;
      case 'confirmed': return OrderStatus.confirmed;
      case 'processing': return OrderStatus.processing;
      case 'outfordelivery': 
      case 'out_for_delivery': 
      case 'shipped': return OrderStatus.outForDelivery;
      case 'ready_for_pickup':
      case 'readyforpickup': return OrderStatus.readyForPickup;
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
        return "قيد التجهيز";
      case OrderStatus.outForDelivery:
        return "قيد التوصيل";
      case OrderStatus.readyForPickup:
        return "قيد الاستلام";
      case OrderStatus.delivered:
        return "تم الاستلام";
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
      case OrderStatus.readyForPickup:
        return Colors.teal;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.late:
        return Colors.red;
    }
  }
}
