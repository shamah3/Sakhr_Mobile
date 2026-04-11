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
      final String url = "$baseUrl/products/$id";
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

      if (response.statusCode != 200) return [];

      final dynamic decoded = jsonDecode(response.body);
      List<dynamic> list = [];

      if (decoded is Map && decoded.containsKey('data')) {
        list = decoded['data'] is List ? decoded['data'] : [];
      } else if (decoded is List) {
        list = decoded;
      } else if (decoded is Map && decoded.containsKey('advertisements')) {
        list = decoded['advertisements'] is List ? decoded['advertisements'] : [];
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
        Uri.parse("$baseUrl/stores/$storeId/ads"),
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
  // 🔐 المصادقة والـ OTP (Mock)
  // ==================================================
  Future<bool> sendOtp(String phoneNumber) async {
    // محاكاة إرسال OTP
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<String?> verifyOtp(String phoneNumber, String code) async {
    // محاكاة التحقق من OTP
    await Future.delayed(const Duration(seconds: 1));
    if (code == "123456") return "mock_token_123456";
    return null;
  }

  Future<void> logout(String token) async {
    // محاكاة تسجيل الخروج
    await Future.delayed(const Duration(seconds: 1));
  }

  // ==================================================
  // 🔥 جلب المنتجات الأكثر مبيعاً
  // ==================================================
  Future<List<Product>> fetchTopSellingProducts() async {
    try {
      final String url = "$baseUrl/products/top-selling";
      final response = await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
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
      return list.where((e) => e is Map).map((e) => Product.fromJson(Map<String, dynamic>.from(e))).toList();
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
}
