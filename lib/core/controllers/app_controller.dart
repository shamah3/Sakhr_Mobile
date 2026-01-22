import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'dart:math';
import 'package:bytore/core/constants/constants.dart';
import 'package:bytore/core/services/notification_service.dart';
import 'package:bytore/core/services/whatsapp_service.dart';

class AppController extends GetxController {
  // Address State
  var selectedCity = "صنعاء".obs;
  var firstName = "".obs;
  var lastName = "".obs;
  var streetName = "".obs;
  var landmark = "".obs;
  var isLoggedIn = false.obs;
  
  final Map<String, String> _users = {"777777777": "123456"}.obs;

  // Currency State
  var currency = "YER_OLD".obs;
  
  String get currencyName {
    switch (currency.value) {
      case 'YER_OLD': return '(ر.ي.ق)';
      case 'YER_NEW': return '(ر.ي.ج)';
      case 'SAR': return '(ر.س)';
      case 'USD': return '\$';
      default: return '(ر.ي.ق)';
    }
  }

  // Exchange Rates
  final Map<String, double> _exchangeRates = {
    'YER_OLD': 530.0,
    'YER_NEW': 1650.0,
    'SAR': 3.75,
    'USD': 1.0,
  };

  String getFormattedPrice(double basePriceInUsd) {
    double rate = _exchangeRates[currency.value] ?? 1.0;
    double convertedPrice = basePriceInUsd * rate;
    
    String priceSymbol = "";
    switch (currency.value) {
      case 'YER_OLD': priceSymbol = "ر.ي.ق"; break;
      case 'YER_NEW': priceSymbol = "ر.ي.ج"; break;
      case 'SAR': priceSymbol = "ر.س"; break;
      case 'USD': priceSymbol = "\$"; break;
      default: priceSymbol = "";
    }

    if (currency.value == 'USD') {
      return "\$${convertedPrice.toStringAsFixed(2)}";
    } else {
      if (currency.value.startsWith('YER')) {
         return "${convertedPrice.round()} $priceSymbol";
      }
      return "${convertedPrice.toStringAsFixed(2)} $priceSymbol";
    }
  }

  void changeCurrency(String newCurrency) {
    currency.value = newCurrency;
  }

  String get selectedAddress => "${selectedCity.value}، ${streetName.value}" + (landmark.value.isNotEmpty ? " (${landmark.value})" : "");

  void updateAddress({
    String? city,
    String? fName,
    String? lName,
    String? street,
    String? landmark,
  }) {
    if (city != null) selectedCity.value = city;
    if (fName != null) firstName.value = fName;
    if (lName != null) lastName.value = lName;
    if (street != null) streetName.value = street;
    if (landmark != null) this.landmark.value = landmark;
  }

  // Wishlist State
  var wishlistIds = <int>{}.obs;

  bool isWishlisted(int productId) => wishlistIds.contains(productId);

  void toggleWishlist(int productId) {
    if (wishlistIds.contains(productId)) {
      wishlistIds.remove(productId);
    } else {
      wishlistIds.add(productId);
      NotificationService().showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: 'المفضلة',
        body: 'تم إضافة المنتج للمفضلة',
      );
    }
  }

  // Notifications State
  var notifications = <Map<String, dynamic>>[].obs;

  int get notificationCount => notifications.where((n) => n['read'] == false).length;

  void addNotification({required String title, required String body, Color? color}) {
    final DateTime now = DateTime.now();
    final String timeStr = "${now.hour}:${now.minute.toString().padLeft(2, '0')}";
    
    notifications.insert(0, {
      'title': title,
      'body': body,
      'time': timeStr,
      'color': color?.value ?? kPrimaryColor.value,
      'read': false,
    });
  }

  void deleteNotification(int index) {
    if (index >= 0 && index < notifications.length) {
      notifications.removeAt(index);
    }
  }

  void markNotificationsAsRead() {
    for (var n in notifications) {
      n['read'] = true;
    }
    notifications.refresh();
  }

  void clearNotifications() => notifications.clear();

  // Filter State
  var priceRange = const RangeValues(100, 5000).obs;
  var activeCategory = "الكل".obs;
  var selectedBrand = "الكل".obs;
  var selectedAvailability = "متوفر".obs;
  var warrantyText = "".obs;

  void updateFilters({RangeValues? range, String? category, String? brand, String? availability, String? warranty}) {
    if (range != null) priceRange.value = range;
    if (category != null) activeCategory.value = category;
    if (brand != null) selectedBrand.value = brand;
    if (availability != null) selectedAvailability.value = availability;
    if (warranty != null) warrantyText.value = warranty;
  }

  void updateLoginStatus(bool status) => isLoggedIn.value = status;
}
