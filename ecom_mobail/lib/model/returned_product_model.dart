import 'package:flutter/material.dart';

class ReturnedProductModel {
  final String name;         // اسم المنتج
  final String orderId;      // رقم الطلب
  final String price;        // السعر
  final String status;       // نص الحالة (مقبول، مرفوض...)
  final Color statusColor;   // لون الحالة
  final IconData icon;       // الأيقونة المعبرة عن الحالة

  // الـ Constructor الخاص بالكلاس
  ReturnedProductModel({
    required this.name,
    required this.orderId,
    required this.price,
    required this.status,
    required this.statusColor,
    required this.icon,
  });
}