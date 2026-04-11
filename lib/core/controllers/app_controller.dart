import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'dart:math';
import 'package:bytore/core/constants/constants.dart';
import 'package:bytore/core/services/notification_service.dart';
import 'package:bytore/core/services/whatsapp_service.dart';
import 'package:bytore/core/services/api_service.dart';
import 'package:bytore/core/models/user_model.dart';
import 'package:bytore/features/profile/controllers/activities_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:bytore/features/notifications/models/notification_model.dart';

class AppController extends GetxController {
  final ApiService _apiService = ApiService();

  // Address State
  var selectedCity = "صنعاء".obs;
  var firstName = "".obs;
  var lastName = "".obs;
  var streetName = "".obs;
  var landmark = "".obs;
  var isLoggedIn = false.obs;
  var token = "".obs;
  var phoneNumber = "777777777".obs;
  var isBiometricEnabled = false.obs;
  var profilePicturePath = "".obs; // Local file path
  var profilePictureUrl = "".obs;  // Remote URL from platform
  var user = Rxn<UserModel>();      // Consolidated User object
  
  @override
  void onInit() {
    super.onInit();
    _loadSession().then((_) {
      _loadNotifications();
      _initWorkers();
    });
  }

  void _initWorkers() {
    // Automatically save whenever these values change
    ever(isLoggedIn, (_) => _saveSession());
    ever(token, (_) => _saveSession());
    ever(firstName, (_) => _saveSession());
    ever(lastName, (_) => _saveSession());
    ever(phoneNumber, (_) => _saveSession());
    ever(profilePicturePath, (_) => _saveSession());
    ever(profilePictureUrl, (_) => _saveSession());
    ever(isBiometricEnabled, (_) => _saveSession());
    ever(user, (_) => _saveSession());
  }

  Future<void> _loadSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      isLoggedIn.value = prefs.getBool('is_logged_in') ?? false;
      token.value = prefs.getString('user_token') ?? "";
      firstName.value = prefs.getString('first_name') ?? "";
      lastName.value = prefs.getString('last_name') ?? "";
      phoneNumber.value = prefs.getString('phone_number') ?? "777777777";
      profilePicturePath.value = prefs.getString('profile_picture_path') ?? "";
      profilePictureUrl.value = prefs.getString('profile_picture_url') ?? "";
      isBiometricEnabled.value = prefs.getBool('is_biometric_enabled') ?? false;
      
      final String? userJson = prefs.getString('user_data');
      if (userJson != null) {
        user.value = UserModel.fromJson(jsonDecode(userJson));
      }
    } catch (e) {
      debugPrint("Error loading session: $e");
    }
  }

  Future<void> _saveSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', isLoggedIn.value);
      await prefs.setString('user_token', token.value);
      await prefs.setString('first_name', firstName.value);
      await prefs.setString('last_name', lastName.value);
      await prefs.setString('phone_number', phoneNumber.value);
      await prefs.setString('profile_picture_path', profilePicturePath.value);
      await prefs.setString('profile_picture_url', profilePictureUrl.value);
      await prefs.setBool('is_biometric_enabled', isBiometricEnabled.value);
      
      if (user.value != null) {
        await prefs.setString('user_data', jsonEncode(user.value!.toJson()));
      }
    } catch (e) {
      debugPrint("Error saving session: $e");
    }
  }

  Future<void> clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('is_logged_in');
      await prefs.remove('user_token');
      await prefs.remove('first_name');
      await prefs.remove('last_name');
      await prefs.remove('phone_number');
      await prefs.remove('profile_picture_path');
      await prefs.remove('profile_picture_url');
      await prefs.remove('user_data');
      
      isLoggedIn.value = false;
      token.value = "";
      firstName.value = "";
      lastName.value = "";
      phoneNumber.value = "777777777";
      profilePicturePath.value = "";
      profilePictureUrl.value = "";
      user.value = null;
    } catch (e) {
      debugPrint("Error clearing session: $e");
    }
  }

  Future<void> _loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? notificationsJson = prefs.getString('notifications_list');
      if (notificationsJson != null) {
        final List<dynamic> decoded = jsonDecode(notificationsJson);
        notifications.assignAll(decoded.cast<Map<String, dynamic>>());
      }

      // تفعيل الإشعارات من الـ API
      if (isLoggedIn.value && token.value.isNotEmpty) {
        _fetchRemoteNotifications();
      } else if (notifications.isEmpty) {
        // Sample data if completely empty
        addNotification(title: "مرحباً بك!", body: "شكراً لاستخدامك تطبيق صخر، تصفح أحدث المنتجات الآن.", category: "الكل", color: Colors.blue);
      }
    } catch (e) {
      debugPrint("Error loading notifications: $e");
    }
  }

  Future<void> _fetchRemoteNotifications() async {
    if (token.value.isEmpty) return;
    
    try {
      final remoteNotifications = await _apiService.fetchNotifications(token.value);
      for (var remote in remoteNotifications) {
        // Check if already exists
        bool exists = notifications.any((n) => n['title'] == remote.title && n['body'] == remote.body);
        
        if (!exists) {
          notifications.insert(0, {
            'title': remote.title,
            'body': remote.body,
            'time': "الآن",
            'color': kPrimaryColor.value,
            'read': false,
            'category': 'المنصة',
          });
        }
      }
      _saveNotifications();
    } catch (e) {
      debugPrint("Error fetching remote notifications: $e");
    }
  }

  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(notifications);
      await prefs.setString('notifications_list', encoded);
    } catch (e) {
      debugPrint("Error saving notifications: $e");
    }
  }
  
  // Currency State
  var currency = "YER_OLD".obs;
  
  String get currencyName {
    switch (currency.value) {
      case 'YER_OLD': return '(ر.ي.ق)';
      case 'YER_NEW': return '(ر.ي.ج)';
      case 'SAR': return '(ر.س)';
      case 'USD': return r'$';
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
      case 'USD': priceSymbol = r"$"; break;
      default: priceSymbol = "";
    }

    if (currency.value == 'USD') {
      return r"$" + convertedPrice.toStringAsFixed(2);
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

  void toggleWishlist(int productId, {String? productName}) {
    final bool wasWishlisted = wishlistIds.contains(productId);

    if (wasWishlisted) {
      wishlistIds.remove(productId);
    } else {
      wishlistIds.add(productId);
      NotificationService().showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: 'المفضلة',
        body: 'تم إضافة المنتج للمفضلة',
      );
      
      try {
        if (Get.isRegistered<ActivitiesController>()) {
          Get.find<ActivitiesController>().logActivity(
            title: 'إضافة "${productName ?? "منتج"}" للمفضلة',
            type: 'fav'
          );
        }
      } catch (e) {
        debugPrint("Activity log error: $e");
      }
    }
  }

  // Notifications State
  var notifications = <Map<String, dynamic>>[].obs;

  int get notificationCount => notifications.where((n) => n['read'] == false).length;

  void addNotification({required String title, required String body, Color? color, String category = 'الكل'}) {
    final DateTime now = DateTime.now();
    final String timeStr = "${now.hour}:${now.minute.toString().padLeft(2, '0')}";
    
    notifications.insert(0, {
      'title': title,
      'body': body,
      'time': timeStr,
      'color': color?.value ?? kPrimaryColor.value,
      'read': false,
      'category': category,
    });
    
    _saveNotifications();
    
    // Trigger system notification
    NotificationService().showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
    );
  }

  void deleteNotification(int index) {
    if (index >= 0 && index < notifications.length) {
      notifications.removeAt(index);
      _saveNotifications();
    }
  }

  void markNotificationsAsRead() {
    for (var n in notifications) {
      n['read'] = true;
    }
    notifications.refresh();
    _saveNotifications();
  }

  void clearNotifications() {
    notifications.clear();
    _saveNotifications();
  }

  // Filter State
  var priceRange = const RangeValues(0, 50000).obs;
  var activeCategory = "الكل".obs;
  var selectedBrand = "الكل".obs;
  var selectedAvailability = "الكل".obs;

  var warrantyText = "".obs;

  void updateFilters({RangeValues? range, String? category, String? brand, String? availability, String? warranty}) {
    if (range != null) priceRange.value = range;
    if (category != null) activeCategory.value = category;
    if (brand != null) selectedBrand.value = brand;
    if (availability != null) selectedAvailability.value = availability;
    if (warranty != null) warrantyText.value = warranty;
  }

  void updateUserName(String first, String last, {String? phone}) {
    firstName.value = first;
    lastName.value = last;
    if (phone != null) phoneNumber.value = phone;
  }

  void updateLoginStatus(bool status) {
    isLoggedIn.value = status;
  }
}
