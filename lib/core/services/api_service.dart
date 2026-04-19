import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:bytore/features/product/models/product_model.dart';
import 'package:bytore/features/stores/models/store_model.dart';
import 'package:bytore/features/stores/models/advertisement_model.dart';
import 'package:bytore/features/notifications/models/notification_model.dart';
import 'package:bytore/features/checkout/models/payment_method_model.dart';
import 'package:bytore/features/checkout/models/floosak_payment_attempt_model.dart';
import 'package:bytore/features/orders/models/order_model.dart';
import 'package:bytore/features/profile/models/wallet_model.dart';
import 'package:bytore/features/profile/models/complaint_model.dart';
import 'package:bytore/features/profile/models/review_model.dart';
import 'package:bytore/features/profile/models/activity_model.dart';
import 'package:bytore/core/models/user_model.dart';
import 'package:bytore/core/controllers/app_controller.dart';
import 'package:bytore/features/home/models/coupon_model.dart';
import 'package:get/get.dart';

class ApiService {
  static const String baseIp = "192.168.8.196:8000";
  static String get baseUrl => "http://$baseIp/api/v1";
  static String get storageUrl => "http://$baseIp/storage";
  static String get serverUrl => "http://$baseIp";

  static String fixImageUrl(String? url) {
    if (url == null || url.isEmpty) return "";
    String rawUrl = url.trim();

    // 1. Handle Absolute URLs
    if (rawUrl.startsWith("http")) {
      return rawUrl
          .replaceAll("localhost:8000", baseIp)
          .replaceAll("127.0.0.1:8000", baseIp)
          .replaceAll("localhost", baseIp.split(':')[0])
          .replaceAll("127.0.0.1", baseIp.split(':')[0]);
    }

    // 2. Handle Asset Paths
    if (rawUrl.startsWith("assets/")) return rawUrl;

    // 3. Handle Relative Paths
    String path = rawUrl.startsWith('/') ? rawUrl.substring(1) : rawUrl;

    // Check if path already contains storage/ or uploads/
    if (path.contains("storage/")) {
      // Extract portion from storage onwards to avoid doubling
      path = path.substring(path.indexOf("storage/"));
      return "$serverUrl/$path";
    }

    if (path.startsWith("public/")) path = path.replaceFirst("public/", "");
    if (path.startsWith("upload/") || path.startsWith("uploads/")) {
      return "$serverUrl/$path";
    }

    // Default fallback to storageUrl
    return "$storageUrl/$path";
  }

  // ==================================================
  // 🔥 جلب المنتجات (قائمة)
  // ==================================================
  Future<List<Product>> fetchProducts({
    String? categorySlug,
    int? categoryId,
    int? storeId,
    int? brandId,
    String? search,
    String? token,
  }) async {
    try {
      String url = "$baseUrl/products";
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
      if (brandId != null) {
        params.add("brand_id=$brandId");
      }
      if (search != null && search.isNotEmpty) {
        params.add("search=$search");
      }

      if (params.isNotEmpty) {
        url = "$url?${params.join("&")}";
      }

      debugPrint("📡 PRODUCTS REQUEST: $url");

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              "Accept": "application/json",
              if (token != null && token.isNotEmpty)
                "Authorization": "Bearer $token",
            },
          )
          .timeout(const Duration(seconds: 30));

      debugPrint("📡 [DEBUG] PRODUCTS RESPONSE STATUS: ${response.statusCode}");
      debugPrint("📡 [DEBUG] PRODUCTS RESPONSE BODY: ${response.body}");

      if (response.statusCode != 200) {
        throw "Server Error [${response.statusCode}] at $url. Body: ${response.body.substring(0, response.body.length > 50 ? 50 : response.body.length)}";
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
      debugPrint("📡 [DEBUG] FOUND ${productsList.length} PRODUCTS IN JSON");

      for (var e in productsList) {
        if (e is Map) {
          try {
            var product = Product.fromJson(Map<String, dynamic>.from(e));
            parsedProducts.add(product);
          } catch (err) {
            debugPrint(
              "⚠️ ERROR PARSING INDIVIDUAL PRODUCT (ID: ${e['id']}): $err",
            );
          }
        }
      }

      debugPrint(
        "✅ SUCCESSFULLY PARSED ${parsedProducts.length} OUT OF ${productsList.length} PRODUCTS",
      );
      return parsedProducts;
    } catch (e) {
      debugPrint("🔥 Fetch Products Error: $e");
      rethrow;
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
      Map<String, dynamic>? data = decoded is Map
          ? (decoded['data'] is Map ? decoded['data'] : decoded)
          : null;
      return data != null ? OrderModel.fromJson(data) : null;
    } catch (e) {
      return null;
    }
  }

  Future<OrderModel?> createOrder(
    Map<String, dynamic> data,
    String token,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/orders"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        Map<String, dynamic>? orderData;
        if (decoded is Map) {
          orderData = decoded.containsKey('data')
              ? (decoded['data'] is Map ? decoded['data'] : null)
              : decoded;
        }
        if (orderData != null) {
          return OrderModel.fromJson(orderData);
        }
      } else {
        final errorData = jsonDecode(response.body);
        String errorMsg = errorData['message'] ?? "Unknown Server Error";
        if (errorData['errors'] != null) {
          errorMsg += ": " + errorData['errors'].toString();
        }
        throw Exception(errorMsg);
      }
      return null;
    } catch (e) {
      debugPrint("🔥 Create Order Error: $e");
      rethrow;
    }
  }

  // ==================================================
  // 🔥 جلب تفاصيل منتج واحد (بالـ ID)
  // ==================================================
  Future<Product?> fetchProductDetail(int id, {String? token}) async {
    try {
      final String url = "$baseUrl/products/$id";
      debugPrint("📡 PRODUCT DETAIL REQUEST: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Accept": "application/json",
          if (token != null && token.isNotEmpty)
            "Authorization": "Bearer $token",
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
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode != 200) return [];

      final dynamic decoded = jsonDecode(response.body);
      List<dynamic> list = [];

      if (decoded is Map && decoded.containsKey('data')) {
        list = decoded['data'] is List ? decoded['data'] : [];
      } else if (decoded is List) {
        list = decoded;
      } else if (decoded is Map && decoded.containsKey('advertisements')) {
        list = decoded['advertisements'] is List
            ? decoded['advertisements']
            : [];
      }

      return list
          .where((e) => e is Map)
          .map((e) => AdvertisementModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      debugPrint("🔥 Fetch Ads Error: $e");
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
      final String? token = appController.token.value.isNotEmpty
          ? appController.token.value
          : null;

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
          if (d is List)
            list = d;
          else if (d is Map && d.containsKey('data'))
            list = d['data'] is List ? d['data'] : [];
          else if (d is Map && d.containsKey('coupons'))
            list = d['coupons'] is List ? d['coupons'] : [];
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
  // 📣 الإشعارات
  // ==================================================
  Future<List<NotificationModel>> fetchNotifications(String token) async {
    try {
      final appController = Get.find<AppController>();
      final userId = appController.user.value?.id ?? 0;
      if (userId <= 0) {
        return [];
      }

      final response = await http.get(
        Uri.parse("$baseUrl/notifications/$userId"),
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

  Future<bool> createNotification(
    Map<String, dynamic> data,
    String token,
  ) async {
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

  Future<bool> updateProductStatus(
    int id,
    String status, {
    String? token,
  }) async {
    try {
      final String url = "$baseUrl/admin/management/products/$id/status";
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          if (token != null && token.isNotEmpty)
            "Authorization": "Bearer $token",
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
      final response = await http
          .get(
            Uri.parse("$baseUrl/categories"),
            headers: {"Accept": "application/json"},
          )
          .timeout(const Duration(seconds: 30));

      debugPrint(
        "📡 [DEBUG] CATEGORIES RESPONSE STATUS: ${response.statusCode}",
      );
      debugPrint("📡 [DEBUG] CATEGORIES RESPONSE BODY: ${response.body}");

      if (response.statusCode != 200) return [];
      final decoded = jsonDecode(response.body);

      if (decoded is Map && decoded.containsKey('data')) {
        final dynamic d = decoded['data'];
        if (d is List) return d;
        if (d is Map && d.containsKey('categories')) {
          return d['categories'] is List ? d['categories'] : [];
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
      Map<String, dynamic>? data = decoded is Map
          ? (decoded['data'] is Map ? decoded['data'] : decoded)
          : null;
      return data != null ? WalletModel.fromJson(data) : null;
    } catch (e) {
      debugPrint("Fetch Wallet Error: $e");
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
      return list
          .map((e) {
            if (e is int) return e;
            if (e is Map)
              return int.tryParse(
                    e['product_id']?.toString() ?? e['id']?.toString() ?? "0",
                  ) ??
                  0;
            return 0;
          })
          .where((id) => id != 0)
          .toList();
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

      List<StoreModel> parsedStores = list
          .where((e) => e is Map)
          .map((e) => StoreModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      debugPrint("✅ SUCCESSFULLY FETCHED STORES: ${parsedStores.length}");
      return parsedStores;
    } catch (e) {
      debugPrint("🔥 Fetch Stores Error: $e");
      rethrow;
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

  Future<bool> updateStore(
    int id,
    Map<String, dynamic> data,
    String token,
  ) async {
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
        Uri.parse("$baseUrl/product-reviews?product_id=$productId"),
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

  Future<List<ReviewModel>> fetchUserReviews(String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/product-reviews"),
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
          .map((e) => ReviewModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> createReview(Map<String, dynamic> data, String token) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/product-reviews"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(data),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        debugPrint("❌ REVIEW API FAILED: ${response.statusCode}");
        debugPrint("❌ BODY: ${response.body}");
        return false;
      }
      return true;
    } catch (e) {
      debugPrint("🔥 Review Error Catch: $e");
      return false;
    }
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
      debugPrint("Fetch Complaints Error: $e");
      return [];
    }
  }

  Future<bool> createComplaint(Map<String, dynamic> data, String token) async {
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
      debugPrint("Create Complaint Error: $e");
      return false;
    }
  }

  // ==================================================
  // 🔐 المصادقة والـ OTP (Mock/Remote)
  // ==================================================
  Future<Map<String, dynamic>?> login(
    String identifier,
    String password,
  ) async {
    try {
      debugPrint("📡 Login Request: identifier=$identifier");
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"identifier": identifier, "password": password}),
      );

      debugPrint("📡 Login Response Code: ${response.statusCode}");
      debugPrint("📡 Login Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded.containsKey('data')) {
          return decoded['data'] is Map ? decoded['data'] : null;
        }
      }
      throw Exception(
        _responseMessage(
          _decodedResponseMap(response),
          "فشل تسجيل الدخول، تأكد من صحة البيانات",
        ),
      );
    } catch (e) {
      debugPrint("🔥 Login Error: $e");
      rethrow;
    }
  }

  Future<bool> logout(String token) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/logout"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Logout Error: $e");
      return false;
    }
  }

  // ==================================================
  // 🔐 المصادقة والـ OTP والـ Biometric
  // ==================================================

  /// نظام تسجيل الدخول الموحد (إنشاء حساب أو دخول تلقائي بالبصمة)
  Future<Map<String, dynamic>?> customerBioAuthOrRegister({
    required String phone,
    required String biometricToken,
    String? name,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/customers"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "phone": phone,
          "biometric_token": biometricToken,
          "name": name,
        }),
      );

      debugPrint("📡 Bio Auth Status: ${response.statusCode}");
      debugPrint("📡 Bio Auth Response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded.containsKey('data')) {
          return Map<String, dynamic>.from(decoded['data']);
        }
      }
      return null;
    } catch (e) {
      debugPrint("🔥 Bio Auth Error: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> biometricLogin(String biometricToken) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/biometric-login"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"biometric_token": biometricToken}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded.containsKey('data')) {
          return Map<String, dynamic>.from(decoded['data']);
        }
      }

      throw Exception(
        _responseMessage(
          _decodedResponseMap(response),
          "فشل تسجيل الدخول بالبصمة",
        ),
      );
    } catch (e) {
      debugPrint("🔥 Biometric Login Error: $e");
      rethrow;
    }
  }

  Future<bool> enableBiometric({
    required String biometricToken,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/enable-biometric"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"biometric_token": biometricToken}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }

      throw Exception(
        _responseMessage(
          _decodedResponseMap(response),
          "فشل تفعيل الدخول بالبصمة",
        ),
      );
    } catch (e) {
      debugPrint("🔥 Enable Biometric Error: $e");
      rethrow;
    }
  }

  Future<String?> sendOtp(String phone) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/send-code"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"phone": phone}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        // Extracts the code from Laravel's sendResponse(['code' => $code])
        if (decoded is Map && decoded.containsKey('data')) {
          return decoded['data']['code']?.toString();
        }
      }
      return null;
    } catch (e) {
      debugPrint("🔥 Send OTP Error: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> verifyOtp(String phone, String code) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/verify-code"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"phone": phone, "code": code}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded.containsKey('data')) {
          return Map<String, dynamic>.from(decoded['data']);
        }
      } else {
        debugPrint("❌ Verify OTP Failed: ${response.body}");
      }
      return null;
    } catch (e) {
      debugPrint("🔥 Verify OTP Error: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchUserProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/auth/me"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      debugPrint("📡 Fetch Profile Status: ${response.statusCode}");
      final decoded = _decodedResponseMap(response);

      if (response.statusCode == 401) {
        debugPrint("❌ Fetch Profile Failed: ${response.body}");
        throw Exception("Unauthenticated.");
      }

      if (response.statusCode == 200 &&
          decoded['status'] != false &&
          decoded['data'] is Map) {
        return Map<String, dynamic>.from(decoded['data']);
      }

      debugPrint("❌ Fetch Profile Failed: ${response.body}");
      return null;
    } catch (e) {
      debugPrint("🔥 Fetch Profile Error: $e");
      rethrow;
    }
  }

  Future<UserModel?> fetchCurrentUser(String token) async {
    try {
      final userData = await fetchUserProfile(token);
      if (userData == null) return null;

      return UserModel.fromJson(userData);
    } catch (e) {
      debugPrint("🔥 Fetch Current User Error: $e");
      return null;
    }
  }

  // ==================================================
  // 🔐 تغيير كلمة السر
  // ==================================================
  Future<bool> changePassword({
    required int userId,
    required String oldPassword,
    required String newPassword,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/change-password"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "user_id": userId,
          "old_password": oldPassword,
          "new_password": newPassword,
        }),
      );

      debugPrint(
        "📡 Change Password Response: ${response.statusCode} - ${response.body}",
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("🔥 Change Password Error: $e");
      return false;
    }
  }

  // ==================================================
  // 🔐 تسجيل حساب جديد
  // ==================================================
  Future<Map<String, dynamic>?> registerCustomer({
    required String firstName,
    required String lastName,
    required String phone,
    required String password,
    String fingerprint = "1",
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/customers"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "name": [
            firstName,
            lastName,
          ].where((part) => part.trim().isNotEmpty).join(' '),
          "first_name": firstName,
          "last_name": lastName,
          "phone": phone,
          "password": password,
          "fingerprint": fingerprint,
        }),
      );

      debugPrint("📡 Register Response Code: ${response.statusCode}");
      debugPrint("📡 Register Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded.containsKey('data')) {
          return Map<String, dynamic>.from(decoded['data']);
        }
        return decoded is Map ? Map<String, dynamic>.from(decoded) : {};
      }
      throw Exception(
        _responseMessage(_decodedResponseMap(response), "فشل إنشاء الحساب"),
      );
    } catch (e) {
      debugPrint("🔥 Register Error: $e");
      rethrow;
    }
  }

  // ==================================================
  // 👤 الملف الشخصي (Profile)
  // ==================================================
  Future<bool> updateUserProfile(
    Map<String, dynamic> data,
    String token,
  ) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/auth/profile"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(data),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("🔥 Update Profile Error: $e");
      return false;
    }
  }

  // Alias for compatibility
  Future<bool> saveAdminCustomer({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    String? fingerprint,
    String? profileImagePath,
    required String token,
  }) async {
    return updateUserProfile({
      "first_name": firstName,
      "last_name": lastName,
      "email": email,
      "phone": phone,
      if (fingerprint != null) "fingerprint": fingerprint,
    }, token);
  }

  Future<String?> uploadProfilePicture(String filePath, String token) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse("$baseUrl/auth/profile/image"),
      );
      request.headers.addAll({
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      });
      request.files.add(await http.MultipartFile.fromPath('image', filePath));
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded.containsKey('data')) {
          final data = decoded['data'];
          if (data is Map && data.containsKey('profile_photo_url')) {
            return data['profile_photo_url'];
          }
        }
        return "SUCCESS";
      }
      return null;
    } catch (e) {
      debugPrint("🔥 Upload Profile Picture Error: $e");
      return null;
    }
  }

  // ==================================================
  // 🔥 جلب المنتجات الأكثر مبيعاً
  // ==================================================
  Future<List<Product>> fetchTopSellingProducts() async {
    try {
      final String url = "$baseUrl/products/top-selling";
      final response = await http.get(
        Uri.parse(url),
        headers: {"Accept": "application/json"},
      );
      if (response.statusCode != 200) return [];
      final decoded = jsonDecode(response.body);
      List<dynamic> list = [];
      if (decoded is Map && decoded.containsKey('data')) {
        list = decoded['data'] is List ? decoded['data'] : [];
      } else if (decoded is List) {
        list = decoded;
      } else if (decoded is Map && decoded.containsKey('products')) {
        list = decoded['products'] is List ? decoded['products'] : [];
      }
      return list
          .where((e) => e is Map)
          .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      debugPrint("🔥 Fetch Top Selling Error: $e");
      return [];
    }
  }

  // ==================================================
  // 🎟️ جلب كوبونات البائع
  // ==================================================
  Future<List<CouponModel>> fetchVendorCoupons({required int storeId}) async {
    try {
      final String url = "$baseUrl/stores/$storeId/discounts";
      final response = await http.get(
        Uri.parse(url),
        headers: {"Accept": "application/json"},
      );
      if (response.statusCode != 200) return [];
      final dynamic decoded = jsonDecode(response.body);
      List<dynamic> list = [];
      if (decoded is Map && decoded.containsKey('data')) {
        list = decoded['data'] is List ? decoded['data'] : [];
      } else if (decoded is List) {
        list = decoded;
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
  // 🤖 الشات بوت
  // ==================================================
  Future<List<dynamic>> fetchChatbotRules() async {
    try {
      final String url = "$baseUrl/chatbot/rules";
      final response = await http.get(
        Uri.parse(url),
        headers: {"Accept": "application/json"},
      );
      if (response.statusCode != 200) return [];
      final dynamic decoded = jsonDecode(response.body);
      List<dynamic> list = [];
      if (decoded is Map && decoded.containsKey('data')) {
        list = decoded['data'] is List ? decoded['data'] : [];
      } else if (decoded is List) {
        list = decoded;
      }
      return list;
    } catch (e) {
      debugPrint("🔥 Fetch Chatbot Rules Error: $e");
      return [];
    }
  }

  Future<bool> sendChatbotResponse(
    Map<String, dynamic> data, {
    String? token,
  }) async {
    try {
      final String url = "$baseUrl/chatbot/responses";
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          if (token != null && token.isNotEmpty)
            "Authorization": "Bearer $token",
        },
        body: jsonEncode(data),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("🔥 Send Chatbot Response Error: $e");
      return false;
    }
  }

  Future<List<dynamic>> fetchChatHistory(String token) async {
    try {
      final String url = "$baseUrl/chatbot/history";
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode != 200) return [];
      final dynamic decoded = jsonDecode(response.body);

      if (decoded is Map && decoded.containsKey('data')) {
        return decoded['data'] is List ? decoded['data'] : [];
      }
      return [];
    } catch (e) {
      debugPrint("🔥 Fetch Chat History Error: $e");
      return [];
    }
  }

  // ==================================================
  // 🔍 البحث الذكي (AI Agent)
  // ==================================================
  Future<String?> smartSearch(String query, {String? token}) async {
    try {
      final String url = "$baseUrl/search/smart";
      debugPrint("📡 SMART SEARCH REQUEST: $url | query: $query");

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          if (token != null && token.isNotEmpty)
            "Authorization": "Bearer $token",
        },
        body: jsonEncode({"query": query}),
      );

      debugPrint("📡 SMART SEARCH RESPONSE STATUS: ${response.statusCode}");
      debugPrint("📡 SMART SEARCH RESPONSE BODY: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          return decoded['data']['answer'];
        }
      }
      return null;
    } catch (e) {
      debugPrint("🔥 Smart Search Error: $e");
      return null;
    }
  }

  // 💬 الدردشة مع المتاجر
  Future<bool> sendChatMessage(
    int storeId,
    String message,
    String token,
  ) async {
    try {
      final String url =
          "$baseUrl/messages"; // تم التعديل ليطابق المسار الفعلي في Laravel
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"store_id": storeId, "message": message}),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("🔥 Send Chat Message Error: $e");
      return false;
    }
  }

  // ⭐️ إرسال تقييم منتج
  Future<bool> postProductReview({
    required int productId,
    required int userId,
    required int rating,
    required String comment,
    required String token,
  }) async {
    return createReview({
      "product_id": productId,
      "user_id": userId,
      "rating": rating,
      "comment": comment,
    }, token);
  }

  // ⭐️ إرسال تقييم متجر (سيستخدم الآن الـ endpoint الموحد أو الخاص به)
  Future<bool> postStoreReview({
    required int storeId,
    required int rating,
    required String comment,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/store-reviews"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "store_id": storeId,
          "rating": rating,
          "comment": comment,
        }),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("🔥 Post Store Review Error: $e");
      return false;
    }
  }

  // 🛡️ جسور البيانات الجديدة (Data Bridges)

  // ⚡ سجل أنشطة العملاء
  Future<bool> postCustomerActivity(
    Map<String, dynamic> data,
    String token,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/customer-activities"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(data),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("🔥 Post Activity Error: $e");
      return false;
    }
  }

  Future<List<ActivityModel>> fetchActivities(String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/customer-activities"),
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
          .map((e) => ActivityModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // 📦 المرتجعات
  Future<void> postReturnRequest(
    Map<String, dynamic> data,
    String token,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/returns"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(data),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        debugPrint("❌ RETURN API FAILED: ${response.statusCode}");
        debugPrint("❌ BODY: ${response.body}");
        throw Exception(
          _responseMessage(
            _decodedResponseMap(response),
            "فشل إرسال طلب الإرجاع",
          ),
        );
      }
    } catch (e) {
      debugPrint("🔥 Post Return Error: $e");
      rethrow;
    }
  }

  // 🎧 الدعم الفني
  Future<bool> postSupportTicket(
    Map<String, dynamic> data,
    String token,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/support"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(data),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("🔥 Post Support Error: $e");
      return false;
    }
  }

  // 💳 طرق الدفع
  Future<List<PaymentMethodModel>> fetchPaymentMethods() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/payment-methods"),
        headers: {"Accept": "application/json"},
      );
      if (response.statusCode != 200) return [];
      final decoded = jsonDecode(response.body);
      List<dynamic> list = (decoded is Map ? decoded['data'] : decoded) ?? [];
      return list
          .where((e) => e is Map)
          .map((e) => PaymentMethodModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      debugPrint("Fetch Payment Methods Error: $e");
      return [];
    }
  }

  Future<FloosakPaymentAttemptModel> initiateFloosakPayment(
    int orderId,
    String token,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/orders/$orderId/payments/floosak/initiate"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      return FloosakPaymentAttemptModel.fromJson(
        _dataMapFromEnvelope(response, "فشل بدء عملية الدفع عبر فلوسك"),
      );
    } catch (e) {
      debugPrint("Floosak Initiate Error: $e");
      rethrow;
    }
  }

  Future<FloosakPaymentAttemptModel> confirmFloosakPayment(
    int paymentAttemptId,
    String otp,
    String token,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/payments/floosak/$paymentAttemptId/confirm"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"otp": otp}),
      );

      return FloosakPaymentAttemptModel.fromJson(
        _dataMapFromEnvelope(response, "فشل تأكيد رمز الدفع عبر فلوسك"),
      );
    } catch (e) {
      debugPrint("Floosak Confirm Error: $e");
      rethrow;
    }
  }

  Future<FloosakPaymentAttemptModel> fetchFloosakPaymentStatus(
    int paymentAttemptId,
    String token,
  ) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/payments/floosak/$paymentAttemptId"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      return FloosakPaymentAttemptModel.fromJson(
        _dataMapFromEnvelope(response, "فشل جلب حالة الدفع عبر فلوسك"),
      );
    } catch (e) {
      debugPrint("Floosak Status Error: $e");
      rethrow;
    }
  }

  Map<String, dynamic> _dataMapFromEnvelope(
    http.Response response,
    String fallbackMessage,
  ) {
    final decoded = _decodedResponseMap(response);
    final isSuccessEnvelope = decoded['status'] != false;
    final isHttpSuccess =
        response.statusCode >= 200 && response.statusCode < 300;

    if (!isHttpSuccess || !isSuccessEnvelope) {
      throw Exception(_responseMessage(decoded, fallbackMessage));
    }

    final data = decoded['data'];
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    throw Exception(fallbackMessage);
  }

  Map<String, dynamic> _decodedResponseMap(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {}

    return <String, dynamic>{};
  }

  String _responseMessage(
    Map<String, dynamic> decoded,
    String fallbackMessage,
  ) {
    final message = decoded['message'];
    if (message is String && message.trim().isNotEmpty) {
      return message;
    }
    if (message is Map || message is List) {
      return jsonEncode(message);
    }

    final errors = decoded['errors'];
    if (errors != null) {
      return errors.toString();
    }

    return fallbackMessage;
  }
}
