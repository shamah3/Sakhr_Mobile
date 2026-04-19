import 'package:flutter/material.dart';

class ReturnedProductModel {
  final String name;
  final String orderId;
  final String price;
  final String status;
  final Color statusColor;
  final IconData icon;

  ReturnedProductModel({
    required this.name,
    required this.orderId,
    required this.price,
    required this.status,
    required this.statusColor,
    required this.icon,
  });
}
