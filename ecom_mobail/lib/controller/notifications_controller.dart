import 'package:get/get.dart';
import 'package:flutter/material.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String time;
  final IconData icon;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.icon,
    this.isRead = false,
  });
}

class NotificationsController extends GetxController {
  // قائمة إشعارات تجريبية (Reactive)
  var notifications = <NotificationModel>[
    NotificationModel(
      id: '1',
      title: 'تم شحن طلبك!',
      body: 'الطلب رقم #12345 في طريقه إليك الآن.',
      time: 'منذ دقيقتين',
      icon: Icons.local_shipping_outlined,
    ),
    NotificationModel(
      id: '2',
      title: 'عرض خاص لفترة محدودة ⚡',
      body: 'احصل على خصم 20% على جميع ملحقات اللابتوب.',
      time: 'منذ ساعة',
      icon: Icons.local_offer_outlined,
    ),
  ].obs;

  void markAsRead(int index) {
    notifications[index].isRead = true;
    notifications.refresh(); // لتحديث الواجهة فوراً
  }

  void clearAll() {
    notifications.clear();
  }
}