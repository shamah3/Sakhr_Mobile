import 'package:flutter/material.dart';

class ReviewModel {
  final int id;
  final String productName;
  final String? userName;
  final String date;
  final int rating;
  final String comment;
  final IconData icon;
  final bool isPending;
  final int? productId;
  final int? storeId;
  final String? storeName;

  ReviewModel({
    required this.id,
    required this.productName,
    this.userName,
    required this.date,
    required this.rating,
    required this.comment,
    this.icon = Icons.star_border,
    this.isPending = false,
    this.productId,
    this.storeId,
    this.storeName,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] ?? 0,
      productName: json['product'] != null ? (json['product']['name'] ?? "") : "",
      storeName: json['store'] != null ? (json['store']['name'] ?? "") : "",
      userName: json['user'] != null ? (json['user']['name'] ?? "") : "مستخدم",
      date: json['created_at'] != null 
          ? json['created_at'].toString().split('T')[0] 
          : "",
      rating: json['rating'] ?? 5,
      comment: json['comment'] ?? "",
      productId: int.tryParse(json['product_id']?.toString() ?? ""),
      storeId: int.tryParse(json['store_id']?.toString() ?? ""),
    );
  }
}
