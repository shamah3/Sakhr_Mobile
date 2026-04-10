import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:bytore/features/product/models/product_model.dart';
import 'package:bytore/features/stores/models/store_model.dart';
import 'package:bytore/features/stores/models/advertisement_model.dart';
import 'package:bytore/features/notifications/models/notification_model.dart';
import 'package:bytore/features/checkout/models/payment_method_model.dart';
import 'package:bytore/features/orders/models/order_model.dart';
import 'package:bytore/features/profile/models/wallet_model.dart';
import 'package:bytore/features/profile/models/complaint_model.dart';
import 'package:bytore/features/profile/models/review_model.dart';
import 'package:bytore/core/controllers/app_controller.dart';
import 'package:bytore/features/home/models/coupon_model.dart';
import 'package:get/get.dart';

class ApiService {
  static const String baseIp = "192.168.8.196:8000";
  static String get baseUrl => "http://$baseIp/api/v1";
  static String get storageUrl => "http://$baseIp/storage";
  static String get serverUrl => "http://$baseIp";

  // ==================================================
  // 🔥 جلب المنتجات (قائمة)
  // ==================================================
  Future<List<Product>> fetchProducts({
    String? categorySlug,
    int? categoryId,
    int? storeId,
    String? search,
    String? token,
  }) async {
    try {
      String url = "$baseUrl/products/top-selling";
      List<String> params = [];

      if (categorySlug != null && categorySlug != "all") {
        params.add("category=$categorySlug");
      }
      if (categoryId != null) {
        params.add("category_id=$categoryId");
      }
      if (storeId != null) {
        params.add("store_id=$storeId");
      }
      if (search != null && search.isNotEmpty) {
        params.add("search=$search");
      }

      if (params.isNotEmpty) {
        url = "$url?${params.join("&")}";
      }

      debugPrint("📡 PRODUCTS REQUEST: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Accept": "application/json",
          if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode != 200) {
        debugPrint("❌ API ERROR [${response.statusCode}]: ${response.body}");
        return [];
      }

      final dynamic decoded = jsonDecode(response.body);
      List<dynamic> productsList = [];

      if (decoded is Map) {
        if (decoded.containsKey('data')) {
          final dynamic d = decoded['data'];
          if (d is List) {
            productsList = d;
          } else if (d is Map && d.containsKey('data')) {
            productsList = d['data'] is List ? d['data'] : [];
          }
        } else if (decoded.containsKey('products')) {
          productsList = decoded['products'] is List ? decoded['products'] : [];
        }
      } else if (decoded is List) {
        productsList = decoded;
      }

      List<Product> parsedProducts = [];
      for (var e in productsList) {
        if (e is Map) {
          try {
            parsedProducts.add(Product.fromJson(Map<String, dynamic>.from(e)));
          } catch (err) {
            debugPrint("⚠️ ERROR PARSING INDIVIDUAL PRODUCT: $err");
          }
        }
      }

      debugPrint("✅ SUCCESSFULLY FETCHED PRODUCTS: ${parsedProducts.length}");
      return parsedProducts;
    } catch (e) {
      debugPrint("🔥 Fetch Products Error: $e");
      return [];
    }
  }

  // ==================================================
  // 📦 الطلبات
  // ==================================================
  Future<List<OrderModel>> fetchOrders(String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/orders"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      if (response.statusCode != 200) return [];
      final decoded = jsonDecode(response.body);
      List<dynamic> list = (decoded is Map ? decoded['data'] : decoded) ?? [];
      return list
          .where((e) => e is Map)
          .map((e) => OrderModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<OrderModel?> fetchOrderDetail(int id, String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/orders/$id"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      if (response.statusCode != 200) return null;
      final decoded = jsonDecode(response.body);
      Map<String, dynamic>? data = decoded is Map ? (decoded['data'] is Map ? decoded['data'] : decoded) : null;
      return data != null ? OrderModel.fromJson(data) : null;
    } catch (e) {
      return null;
    }
  }

  // ==================================================
  // 🔥 جلب تفاصيل منتج واحد (بالـ ID)
  // ==================================================
  Future<Product?> fetchProductDetail(int id, {String? token}) async {
    try {
      final String url = "$baseUrl/admin/management/products/$id";
      debugPrint("📡 PRODUCT DETAIL REQUEST: $url");
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Accept": "application/json",
          if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode != 200) return null;

      final dynamic decoded = jsonDecode(response.body);
      Map<String, dynamic>? productData;

      if (decoded is Map) {
        if (decoded.containsKey('data')) {
          final dynamic d = decoded['data'];
          productData = d is Map ? Map<String, dynamic>.from(d) : null;
        } else {
          productData = Map<String, dynamic>.from(decoded);
        }
      }

      if (productData != null) {
        return Product.fromJson(productData);
      }
      return null;
    } catch (e) {
      debugPrint("🔥 Fetch Product Detail Error ($id): $e");
      return null;
    }
  }

  // ==================================================
  // 📣 جلب الإعلانات
  // ==================================================
  Future<List<AdvertisementModel>> fetchAdvertisements() async {
    try {
      final String url = "$baseUrl/admin/ads";
      debugPrint("📡 ADS REQUEST: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Accept": "application/json",
        },
      );

      if (response.statusCode != 200) {
        debugPrint("❌ ADS API ERROR [${response.statusCode}]: ${response.body}");
        return [];
      }

      final dynamic decoded = jsonDecode(response.body);
      List<dynamic> list = [];

      if (decoded is Map && decoded.containsKey('data')) {
        final d = decoded['data'];
        if (d is List) list = d;
        else if (d is Map && d.containsKey('data')) list = d['data'] is List ? d['data'] : [];
      } else if (decoded is List) {
        list = decoded;
      } else if (decoded is Map && decoded.containsKey('advertisements')) {
        list = decoded['advertisements'] is List ? decoded['advertisements'] : [];
      }

      debugPrint("📦 ADS RAW DATA: ${list.length} items found");

      List<AdvertisementModel> ads = [];
      for (var e in list) {
        if (e is Map) {
          try {
            ads.add(AdvertisementModel.fromJson(Map<String, dynamic>.from(e)));
          } catch (err) {
            debugPrint("⚠️ Failed to parse single ad: $err");
          }
        }
      }

      debugPrint("✅ ADS PARSED: ${ads.length} items");
      return ads;
    } catch (e) {
      debugPrint("🔥 Fetch Ads Exception: $e");
      return [];
    }
  }

  // ==================================================
  // 🎟️ جلب كوبونات الخصم (Management)
  // ==================================================
  Future<List<CouponModel>> fetchCoupons() async {
    try {
      final String url = "$baseUrl/admin/discounts";
      debugPrint("📡 COUPONS REQUEST: $url");

      final appController = Get.find<AppController>();
      final String? token = appController.token.value.isNotEmpty ? appController.token.value : null;

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Accept": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
      );

      debugPrint("📡 [DEBUG] COUPONS RESPONSE BODY: ${response.body}");
      debugPrint("📡 [DEBUG] COUPONS STATUS CODE: ${response.statusCode}");

      if (response.statusCode != 200) {
        debugPrint("❌ [DEBUG] COUPONS API FAILED");
        return [];
      }

      final dynamic decoded = jsonDecode(response.body);
      List<dynamic> list = [];

      if (decoded is List) {
        list = decoded;
      } else if (decoded is Map) {
        // 1. Check common wrap keys
        if (decoded.containsKey('data')) {
          final dynamic d = decoded['data'];
          if (d is List) list = d;
          else if (d is Map && d.containsKey('data')) list = d['data'] is List ? d['data'] : [];
          else if (d is Map && d.containsKey('coupons')) list = d['coupons'] is List ? d['coupons'] : [];
        }
        
        // 2. If still empty, search for ANY list in the top level (Smart Scan)
        if (list.isEmpty) {
          decoded.forEach((key, value) {
            if (value is List && list.isEmpty) {
              list = value;
              debugPrint("📡 [SMART SCAN] Found list in key: $key");
            }
          });
        }
      }

      final parsed = list
          .where((e) => e is Map)
          .map((e) => CouponModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      debugPrint("📡 [DEBUG] PARSED ${parsed.length} COUPONS");
      return parsed;
    } catch (e) {
      debugPrint("🔥 Fetch Coupons Error: $e");
      return [];
    }
  }

  // ==================================================
  // 🏪 جلب كوبونات المتاجر (Vendor Coupons)
  // ==================================================
  Future<List<CouponModel>> fetchVendorCoupons({int? storeId}) async {
    try {
      // الرابط الأساسي لخصومات التجار
      String url = "$baseUrl/vendor/coupons";
      if (storeId != null) {
        url += "?store_id=$storeId";
      }
      
      debugPrint("📡 VENDOR COUPONS REQUEST: $url");

      final appController = Get.find<AppController>();
      final String? token = appController.token.value.isNotEmpty ? appController.token.value : null;

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Accept": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
      );

      debugPrint("📡 [DEBUG] VENDOR COUPONS STATUS: ${response.statusCode}");
      if (response.statusCode != 200) return [];

      final dynamic decoded = jsonDecode(response.body);
      List<dynamic> list = [];

      if (decoded is List) {
        list = decoded;
      } else if (decoded is Map) {
        if (decoded.containsKey('data')) {
          final dynamic d = decoded['data'];
          if (d is List) list = d;
          else if (d is Map && d.containsKey('data')) list = d['data'] is List ? d['data'] : [];
        }
        
        if (list.isEmpty) {
          decoded.forEach((key, value) {
            if (value is List && list.isEmpty) list = value;
          });
        }
      }

      return list
          .where((e) => e is Map)
          .map((e) => CouponModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      debugPrint("🔥 Fetch Vendor Coupons Error: $e");
      return [];
    }
  }

  // ==================================================
  // 📣 الإشعارات
  // ==================================================
  Future<List<NotificationModel>> fetchNotifications(String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/notifications"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      if (response.statusCode != 200) return [];
      final decoded = jsonDecode(response.body);
      List<dynamic> list = (decoded is Map ? decoded['data'] : decoded) ?? [];
      return list
          .where((e) => e is Map)
          .map((e) => NotificationModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> createNotification(Map<String, dynamic> data, String token) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/notifications"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(data),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // ==================================================
  // ⚙️ إدارة المنتجات (Management)
  // ==================================================

  Future<List<Product>> fetchManagementProducts({String? token}) async {
    return fetchProducts(token: token); // Use the management endpoint
  }

  Future<Product?> fetchManagementProductDetail(int id, {String? token}) async {
    return fetchProductDetail(id, token: token); // Use the management endpoint
  }

  Future<bool> updateProductStatus(int id, String status, {String? token}) async {
    try {
      final String url = "$baseUrl/admin/management/products/$id/status";
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
        },
        body: jsonEncode({"status": status}),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("🔥 Update Status Error: $e");
      return false;
    }
  }

  // ==================================================
  // 📂 جلب الأقسام
  // ==================================================
  Future<List<dynamic>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/categories"),
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode != 200) return [];
      final decoded = jsonDecode(response.body);

      if (decoded is Map && decoded.containsKey('data')) {
        final data = decoded['data'];
        if (data is List) return data;
        if (data is Map && data.containsKey('categories')) {
          return data['categories'] is List ? data['categories'] : [];
        }
        return [];
      }
      if (decoded is List) return decoded;
      return [];
    } catch (e) {
      debugPrint("🔥 Categories Error: $e");
      return [];
    }
  }

  // ==================================================
  // ❤️ المفضلة والمحفظة
  // ==================================================
  Future<WalletModel?> fetchWallet(String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/wallet"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      if (response.statusCode != 200) return null;
      final decoded = jsonDecode(response.body);
      Map<String, dynamic>? data = decoded is Map ? (decoded['data'] is Map ? decoded['data'] : decoded) : null;
      return data != null ? WalletModel.fromJson(data) : null;
    } catch (e) {
      return null;
    }
  }

  Future<List<int>> fetchWishlist({String? token}) async {
    if (token == null) return [];
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/wishlist"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      if (response.statusCode != 200) return [];
      final decoded = jsonDecode(response.body);
      List<dynamic> list = (decoded is Map ? decoded['data'] : decoded) ?? [];
      return list.map((e) {
        if (e is int) return e;
        if (e is Map) return int.tryParse(e['product_id']?.toString() ?? e['id']?.toString() ?? "0") ?? 0;
        return 0;
      }).where((id) => id != 0).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> toggleWishlistApi(int productId, {String? token}) async {
    if (token == null) return false;
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/wishlist/toggle"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"product_id": productId}),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // ==================================================
  // 🏬 المتاجر
  // ==================================================
  Future<List<StoreModel>> fetchStores() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/stores"),
        headers: {"Accept": "application/json"},
      );
      if (response.statusCode != 200) return [];
      final decoded = jsonDecode(response.body);
      List<dynamic> list = (decoded is Map ? decoded['data'] : decoded) ?? [];
      return list
          .where((e) => e is Map)
          .map((e) => StoreModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> createStore(Map<String, dynamic> data, String token) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/stores"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(data),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateStore(int id, Map<String, dynamic> data, String token) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/stores/$id?_method=PUT"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(data),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteStore(int id, String token) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/stores/$id"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  Future<List<AdvertisementModel>> fetchStoreAdvertisements(int storeId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/stores/$storeId/advertisements"),
        headers: {"Accept": "application/json"},
      );
      if (response.statusCode != 200) return [];
      final decoded = jsonDecode(response.body);
      List<dynamic> list = (decoded is Map ? decoded['data'] : decoded) ?? [];
      return list
          .where((e) => e is Map)
          .map((e) => AdvertisementModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // ==================================================
  // 💬 التقييمات والشكاوى
  // ==================================================
  Future<List<ReviewModel>> fetchProductReviews(int productId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/products/$productId/reviews"),
        headers: {"Accept": "application/json"},
      );
      if (response.statusCode != 200) return [];
      final decoded = jsonDecode(response.body);
      List<dynamic> list = (decoded is Map ? decoded['data'] : decoded) ?? [];
      return list
          .where((e) => e is Map)
          .map((e) => ReviewModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> createReview(Map<String, dynamic> data, String token) async {
    try {
      final productId = data['product_id'];
      if (productId == null) return false;

      final response = await http.post(
        Uri.parse("$baseUrl/products/$productId/reviews"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(data),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> createComplaint(Map<String, dynamic> data, String token) async {
    return storeComplaint(data, token);
  }

  Future<List<ComplaintModel>> fetchComplaints(String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/complaints"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      if (response.statusCode != 200) return [];
      final decoded = jsonDecode(response.body);
      List<dynamic> list = (decoded is Map ? decoded['data'] : decoded) ?? [];
      return list
          .where((e) => e is Map)
          .map((e) => ComplaintModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> storeComplaint(Map<String, dynamic> data, String token) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/complaints"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(data),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // ==================================================
  // 🔐 المصادقة والمستخدمين (Auth & Customers)
  // ==================================================
  
  Future<bool> sendOtp(String phone) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/send-code"),
        headers: {"Accept": "application/json", "Content-Type": "application/json"},
        body: jsonEncode({"phone": phone}),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("🔥 sendOtp Error: $e");
      return false;
    }
  }

  Future<String?> verifyOtp(String phone, String code) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/verify-code"),
        headers: {"Accept": "application/json", "Content-Type": "application/json"},
        body: jsonEncode({"phone": phone, "code": code}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        return decoded['token']; // assuming the token is returned in 'token'
      }
      return null;
    } catch (e) {
      debugPrint("🔥 verifyOtp Error: $e");
      return null;
    }
  }

  Future<bool> registerCustomer(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/customers"),
        headers: {"Accept": "application/json", "Content-Type": "application/json"},
        body: jsonEncode(data),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("🔥 registerCustomer Error: $e");
      return false;
    }
  }

  Future<bool> logout(String token) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/logout"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      return response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204;
    } catch (e) {
      debugPrint("🔥 logout Error: $e");
      return false;
    }
  }

  Future<bool> changePassword(String currentPassword, String newPassword, String token) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/change-password"),
        headers: {"Accept": "application/json", "Content-Type": "application/json", "Authorization": "Bearer $token"},
        body: jsonEncode({"current_password": currentPassword, "new_password": newPassword, "new_password_confirmation": newPassword}),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // ==================================================
  // 💸 الدفع والطلبات والاسترجاع
  // ==================================================
  Future<List<PaymentMethodModel>> fetchPaymentMethods() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/payment-methods"), headers: {"Accept": "application/json"});
      if (response.statusCode != 200) return [];
      final decoded = jsonDecode(response.body);
      List<dynamic> list = (decoded is Map ? decoded['data'] : decoded) ?? [];
      return list.where((e) => e is Map).map((e) => PaymentMethodModel.fromJson(Map<String, dynamic>.from(e))).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> createOrder(Map<String, dynamic> data, String token) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/orders"),
        headers: {"Accept": "application/json", "Content-Type": "application/json", "Authorization": "Bearer $token"},
        body: jsonEncode(data),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> createShippingAddress(Map<String, dynamic> data, String token) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/shipping-addresses"),
        headers: {"Accept": "application/json", "Content-Type": "application/json", "Authorization": "Bearer $token"},
        body: jsonEncode(data),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> submitCustomReturn(Map<String, dynamic> data, String token) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/returns"),
        headers: {"Accept": "application/json", "Content-Type": "application/json", "Authorization": "Bearer $token"},
        body: jsonEncode(data),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // ==================================================
  // 💬 التفاعل والشات والدعم
  // ==================================================
  Future<Map<String, dynamic>> sendChatbotMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/chatbot/responses"),
        headers: {"Accept": "application/json", "Content-Type": "application/json"},
        body: jsonEncode({"message": message}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  Future<void> logCustomerActivity(Map<String, dynamic> data) async {
    try {
      await http.post(
        Uri.parse("$baseUrl/customer-activities"),
        headers: {"Accept": "application/json", "Content-Type": "application/json"},
        body: jsonEncode(data),
      );
    } catch (e) {
      debugPrint("Activity Log Error: $e");
    }
  }

  Future<bool> createStoreReview(Map<String, dynamic> data, String token) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/store-reviews"),
        headers: {"Accept": "application/json", "Content-Type": "application/json", "Authorization": "Bearer $token"},
        body: jsonEncode(data),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> submitSupportTicket(Map<String, dynamic> data, String token) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/support"),
        headers: {"Accept": "application/json", "Content-Type": "application/json", "Authorization": "Bearer $token"},
        body: jsonEncode(data),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> sendMessageToVendor(Map<String, dynamic> data, String token) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/messages"),
        headers: {"Accept": "application/json", "Content-Type": "application/json", "Authorization": "Bearer $token"},
        body: jsonEncode(data),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
