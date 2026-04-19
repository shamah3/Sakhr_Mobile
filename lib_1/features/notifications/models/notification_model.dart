import 'package:bytore/core/constants/constants.dart';
import 'package:flutter/material.dart';

class NotificationModel {
  final int id;
  final String title;
  final String body;
  final String? category;
  final DateTime createdAt;
  final bool isRead;
  final Color iconColor;
  final IconData icon;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.category,
    required this.createdAt,
    this.isRead = false,
    this.iconColor = kPrimaryColor,
    this.icon = Icons.notifications_none_rounded,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final String title = json['title'] ?? "";
    
    return NotificationModel(
      id: json['id'] ?? 0,
      title: title,
      body: json['content'] ?? json['body'] ?? "",
      category: json['category'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      isRead: json['read_at'] != null || (json['is_read'] ?? false),
      iconColor: _getColorForTitle(title),
      icon: _getIconForTitle(title),
    );
  }

  static Color _getColorForTitle(String title) {
    if (title.contains('تحديث')) return Colors.blue;
    if (title.contains('تأكيد')) return Colors.green;
    if (title.contains('عرض') || title.contains('خصم')) return Colors.orange;
    if (title.contains('سلة')) return Colors.deepPurple;
    return kPrimaryColor;
  }

  static IconData _getIconForTitle(String title) {
    if (title.contains('تحديث')) return Icons.update_rounded;
    if (title.contains('تأكيد')) return Icons.check_circle_outline_rounded;
    if (title.contains('عرض') || title.contains('خصم')) return Icons.local_offer_outlined;
    if (title.contains('سلة')) return Icons.shopping_cart_outlined;
    return Icons.notifications_none_rounded;
  }

  String get timeAgo {
    final difference = DateTime.now().difference(createdAt);
    if (difference.inDays > 0) return "${difference.inDays} يوم";
    if (difference.inHours > 0) return "${difference.inHours} ساعة";
    if (difference.inMinutes > 0) return "${difference.inMinutes} دقيقة";
    return "الآن";
  }
}
