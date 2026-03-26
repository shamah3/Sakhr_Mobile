import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:bytore/features/product/models/product_model.dart';
import 'package:bytore/features/stores/models/store_model.dart';
import 'package:bytore/features/stores/models/advertisement_model.dart';
import 'package:bytore/features/notifications/models/notification_model.dart';

class ApiService {

  static const String baseIp = "sakhr.etezaz.com";
  static String get baseUrl => "https://$baseIp/api";
  static String get storageUrl => "https://$baseIp/storage";
  static String get serverUrl => "https://$baseIp";

  // ==================================================
  // 🔥 جلب المنتجات (قائمة)
  // ==================================================
  Future<List<Product>> fetchProducts({String? categorySlug, int? categoryId, int? storeId, String? search}) async {
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

      debugPrint("📡 REQUEST URL: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Accept": "application/json",
        },
      );

      debugPrint("📦 STATUS CODE: ${response.statusCode}");
      debugPrint("📦 BODY: ${response.body}");

      if (response.statusCode != 200) {
        return [];
      }

      final dynamic decoded = jsonDecode(response.body);

      List<dynamic> productsList = [];

      // ✅ حالة Laravel Pagination
      if (decoded is Map) {
        if (decoded.containsKey('data')) {
           final dynamic dataKey = decoded['data'];
           if (dataKey is List) {
             productsList = dataKey;
           } else if (dataKey is Map && dataKey.containsKey('data')) {
             productsList = dataKey['data'] is List ? dataKey['data'] : [];
           }
        } else {
           // لو مش Pagination وأعطانا الماب فيها داتا مباشرة (مش تحت مفتاح داتا)
           // هذا احتمال ضعيف للـ Laravel بس بنسوي كفر للأساسي
           if (decoded.containsKey('products')) {
             productsList = decoded['products'] is List ? decoded['products'] : [];
           }
        }
      }
      // ✅ لو API رجع List مباشرة
      else if (decoded is List) {
        productsList = decoded;
      }

      debugPrint("🟢 PRODUCTS COUNT: ${productsList.length}");

      return productsList
          .where((e) => e is Map)
          .map((e) => Product.fromJson(
        Map<String, dynamic>.from(e),
      ))
          .toList();

    } catch (e, stackTrace) {
      debugPrint("🔥 Fetch Products Error: $e");
      debugPrint(stackTrace.toString());
      return [];
    }
  }

  // ==================================================
  // 🔐 تسجيل الدخول
  // ==================================================
  Future<Map<String, dynamic>> login(
      String email,
      String password,
      ) async {
    try {

      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      return jsonDecode(response.body);

    } catch (e) {
      return {
        "status": "error",
        "message": e.toString(),
      };
    }
  }

  // ==================================================
  // 📝 إرسال شكوى
  // ==================================================
  Future<bool> storeComplaint(
      Map<String, dynamic> data,
      String token,
      ) async {
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

      return response.statusCode == 200 ||
          response.statusCode == 201;

    } catch (e) {
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
        headers: {
          "Accept": "application/json",
        },
      );

      if (response.statusCode != 200) {
        return [];
      }

      final decoded = jsonDecode(response.body);

      if (decoded is Map &&
          decoded.containsKey('data')) {

        if (decoded['data'] is List) {
          return decoded['data'];
        }
      }

      if (decoded is List) {
        return decoded;
      }

      return [];

    } catch (e) {
      return [];
    }
  }

  // ==================================================
  // ❤️ جلب المفضلة
  // ==================================================
  Future<List<int>> fetchWishlist({String? token}) async {
    token ??= "YOUR_TEMP_TOKEN_HERE"; // توكن مؤقت للاستخدام لاحقاً حسب طلبك
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

      List<dynamic> list = [];
      if (decoded is Map && decoded.containsKey('data')) {
         list = decoded['data'] is List ? decoded['data'] : [];
      } else if (decoded is List) {
         list = decoded;
      }

      return list.map((e) {
        if (e is int) return e;
        if (e is Map && e.containsKey('product_id')) return int.tryParse(e['product_id'].toString()) ?? 0;
        if (e is Map && e.containsKey('id')) return int.tryParse(e['id'].toString()) ?? 0;
        return 0;
      }).where((id) => id != 0).toList();

    } catch (e) {
      debugPrint("Fetch Wishlist Error: $e");
      return [];
    }
  }

  // ==================================================
  // ❤️ إضافة / إزالة المفضلة (Toggle)
  // ==================================================
  Future<bool> toggleWishlistApi(int productId, {String? token}) async {
    token ??= "YOUR_TEMP_TOKEN_HERE";
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/wishlist/toggle"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "product_id": productId,
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("Toggle Wishlist Error: $e");
      return false;
    }
  }

  // ==================================================
  // 📣 جلب الإعلانات البانر
  // ==================================================
  Future<List<AdvertisementModel>> fetchAdvertisements() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/advertisements"),
        headers: {
          "Accept": "application/json",
        },
      );

      if (response.statusCode != 200) return [];

      final decoded = jsonDecode(response.body);
      List<dynamic> list = [];

      if (decoded is Map && decoded.containsKey('data')) {
         list = decoded['data'] is List ? decoded['data'] : [];
      } else if (decoded is List) {
         list = decoded;
      }

      return list.where((e) => e is Map).map((e) => AdvertisementModel.fromJson(Map<String, dynamic>.from(e))).toList();
    } catch (e) {
      debugPrint("Fetch Advertisements Error: $e");
      return [];
    }
  }

  // ==================================================
  // 🔥 جلب تفاصيل منتج واحد (بالـ ID)
  // ==================================================
  Future<Product?> fetchProductDetail(int id) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/products/$id"),
        headers: {
          "Accept": "application/json",
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
      debugPrint("Fetch Product Detail Error ($id): $e");
      return null;
    }
  }

  // ==================================================
  // 🏬 جلب كل المتاجر (Public)
  // ==================================================
  Future<List<StoreModel>> fetchStores() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/stores"),
        headers: {
          "Accept": "application/json",
        },
      );

      debugPrint("📡 Fetch Stores Status: ${response.statusCode}");
      
      if (response.statusCode != 200) return [];

      final decoded = jsonDecode(response.body);
      List<dynamic> list = [];
      
      if (decoded is Map && decoded.containsKey('data')) {
        list = decoded['data'] is List ? decoded['data'] : [];
      } else if (decoded is List) {
        list = decoded;
      }

      return list.where((e) => e is Map).map((e) => StoreModel.fromJson(Map<String, dynamic>.from(e))).toList();
    } catch (e) {
      debugPrint("🔥 Fetch Stores Error: $e");
      return [];
    }
  }

  // ==================================================
  // 🏬 جلب متجر واحد بالتفصيل (Public)
  // ==================================================
  Future<StoreModel?> fetchStoreDetail(int id) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/stores/$id"),
        headers: {
          "Accept": "application/json",
        },
      );

      if (response.statusCode != 200) return null;

      final decoded = jsonDecode(response.body);
      Map<String, dynamic>? data;

      if (decoded is Map) {
        data = decoded.containsKey('data') ? (decoded['data'] is Map ? decoded['data'] : null) : decoded;
      }

      if (data != null) {
        return StoreModel.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint("🔥 Fetch Store Detail Error ($id): $e");
      return null;
    }
  }

  // ==================================================
  // 🏬 إنشاء متجر (Protected)
  // ==================================================
  Future<bool> createStore(Map<String, dynamic> data, String token) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/stores"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(data),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("🔥 Create Store Error: $e");
      return false;
    }
  }

  // ==================================================
  // 🏬 تحديث متجر (Protected)
  // ==================================================
  Future<bool> updateStore(int id, Map<String, dynamic> data, String token) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/stores/$id"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(data),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("🔥 Update Store Error ($id): $e");
      return false;
    }
  }

  // ==================================================
  // 🏬 حذف متجر (Protected)
  // ==================================================
  Future<bool> deleteStore(int id, String token) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/stores/$id"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint("🔥 Delete Store Error ($id): $e");
      return false;
    }
  }

  // ==================================================
  // 📣 جلب إعلانات متجر معيّن (Public)
  // ==================================================
  Future<List<AdvertisementModel>> fetchStoreAdvertisements(int storeId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/stores/$storeId/advertisements"),
        headers: {
          "Accept": "application/json",
        },
      );

      debugPrint("📡 Fetch Store Ads Status ($storeId): ${response.statusCode}");
      
      if (response.statusCode != 200) return [];

      final decoded = jsonDecode(response.body);
      List<dynamic> list = [];
      
      if (decoded is Map && decoded.containsKey('data')) {
        list = decoded['data'] is List ? decoded['data'] : [];
      } else if (decoded is List) {
        list = decoded;
      }

      return list.where((e) => e is Map).map((e) => AdvertisementModel.fromJson(Map<String, dynamic>.from(e))).toList();
    } catch (e) {
      debugPrint("🔥 Fetch Store Ads Error ($storeId): $e");
      return [];
    }
  }

  // ==================================================
  // 📣 إنشاء إعلان لمتجر معيّن (Protected)
  // ==================================================
  Future<bool> createStoreAdvertisement(int storeId, Map<String, dynamic> data, String token) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/stores/$storeId/advertisements"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(data),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("🔥 Create Store Ad Error ($storeId): $e");
      return false;
    }
  }

  // ==================================================
  // 🔔 الإشعارات
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
      List<dynamic> list = [];

      if (decoded is Map && decoded.containsKey('data')) {
        list = decoded['data'] is List ? decoded['data'] : [];
      } else if (decoded is List) {
        list = decoded;
      }

      return list
          .where((e) => e is Map)
          .map((e) => NotificationModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      debugPrint("Fetch Notifications Error: $e");
      return [];
    }
  }

  Future<bool> createNotification(Map<String, dynamic> data, String token) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/notifications"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(data),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("Create Notification Error: $e");
      return false;
    }
  }
}