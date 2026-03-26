import 'package:flutter/material.dart';

class ComplaintModel {
  final int id;
  final String type;
  final String? orderId;
  final String message;
  final String status;
  final DateTime createdAt;
  final String? reply;

  ComplaintModel({
    required this.id,
    required this.type,
    this.orderId,
    required this.message,
    required this.status,
    required this.createdAt,
    this.reply,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    return ComplaintModel(
      id: json['id'] ?? 0,
      type: json['type'] ?? "عام",
      orderId: json['order_id']?.toString(),
      message: json['message'] ?? "",
      status: json['status'] ?? "pending",
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      reply: json['reply'],
    );
  }

  String get statusText {
    switch (status.toLowerCase()) {
      case 'pending': return "قيد الانتظار";
      case 'processing': return "جاري المراجعة";
      case 'resolved': return "تم الرد";
      case 'closed': return "مغلق";
      default: return status;
    }
  }

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'processing': return Colors.blue;
      case 'resolved': return Colors.green;
      case 'closed': return Colors.grey;
      default: return Colors.blue;
    }
  }
}
