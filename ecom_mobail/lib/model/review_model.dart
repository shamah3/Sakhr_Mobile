import 'package:flutter/material.dart';

class ReviewModel {
  final String productName;
  final String date;
  final int? rating; // null إذا كان بانتظار التقييم
  final String? comment;
  final IconData icon;
  final bool isPending;

  ReviewModel({
    required this.productName,
    required this.date,
    this.rating,
    this.comment,
    required this.icon,
    this.isPending = false,
  });
}