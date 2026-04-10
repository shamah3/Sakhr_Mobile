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

      List<Product> products = productsList
          .where((e) => e is Map)
          .map((e) => Product.fromJson(
        Map<String, dynamic>.from(e),
      ))
          .toList();

      // ✅ إضافة منتجات تجريبية (Mock Products) للاستعراض 3D والمواصفات الفاخرة
      
      // 1. MacBook Pro
      products.add(Product(
        id: 9991,
        name: "MacBook Pro 13‑inch (M1, 2020)",
        description: "أداء مذهل بفضل شريحة Apple M1 الجبارة التي تغير كل شيء.",
        price: 1299.0,
        oldPrice: 1499.0,
        imageUrl: "https://www.apple.com/v/macbook-pro-13/m/images/overview/hero_endframe__e9u9v80816m6_large.jpg",
        brandName: "Apple",
        stock: 5,
        status: "In Stock",
        warranty: "سنتين",
        deliveryTime: "يوم واحد",
        category: "Laptops",
        storeName: "Silicon Store",
        attributes: {
          "المعالج (CPU)": "Apple M1 Chip",
          "الرام (RAM)": "16GB Unified Memory",
          "التخزين (Storage)": "512GB SSD",
          "الشاشة (Display)": "13.3-inch Retina Display",
          "كرت الشاشة (GPU)": "Apple Integrated 8-Core GPU",
          "البطارية": "حتى 20 ساعة",
          "الوزن": "1.4 kg",
        },
        storeId: 102,
        threeDModel: "assets/models/Mac.glb",
      ));

      // 2. 3D Printer
      products.add(Product(
        id: 9992,
        name: "Creality Ender 3 V2 - 3D Printer",
        description: "طابعة ثلاثية الأبعاد احترافية بدقة عالية وسهولة في الاستخدام.",
        price: 249.0,
        oldPrice: 299.0,
        imageUrl: "https://m.media-amazon.com/images/I/61S-E1p-n9L._AC_SX679_.jpg",
        brandName: "Creality",
        stock: 10,
        status: "In Stock",
        warranty: "سنة واحدة",
        deliveryTime: "3 أيام",
        category: "الطابعات",
        storeName: "3D World",
        attributes: {
          "تكنولوجيا الطباعة": "FDM",
          "حجم الطباعة": "220 x 220 x 250 mm",
          "سرعة الطباعة": "100 mm/s",
          "دقة الطباعة": "+/- 0.1 mm",
          "درجة حرارة الفوهة": "حتى 250 درجة",
        },
        storeId: 105,
        threeDImages: [
             "https://images.unsplash.com/photo-1631021464303-12503254e01e?q=80&w=500&auto=format&fit=crop",
             "https://images.unsplash.com/photo-1581092160607-ee22621dd758?q=80&w=500&auto=format&fit=crop",
             "https://images.unsplash.com/photo-1543269664-56bc44165f4d?q=80&w=500&auto=format&fit=crop",
        ],
        threeDModel: "assets/models/printer3.glb",
      ));

      // 3. 3D Headphone
      products.add(Product(
        id: 9993,
        name: "Apple AirPods Max",
        description: "تجربة استماع لا مثيل لها مع إلغاء ضجيج نشط وصوت سينمائي.",
        price: 549.0,
        oldPrice: 599.0,
        imageUrl: "https://www.apple.com/v/airpods-max/f/images/overview/hero/hero_green__f6stkcl9u9im_large.png",
        brandName: "Apple",
        stock: 15,
        status: "In Stock",
        warranty: "سنة واحدة",
        deliveryTime: "فوري",
        category: "السماعات",
        storeName: "Apple Store",
        attributes: {
          "المحرك": "Apple Dynamic Driver",
          "إلغاء الضجيج": "Active Noise Cancellation",
          "الصوت المكاني": "Spatial Audio",
          "البطارية": "حتى 20 ساعة استماع",
          "الوزن": "384.8 grams",
        },
        storeId: 101,
        threeDImages: [
             "https://hosting.photobucket.com/images/i/Silicon_Yemen/headphone_1.png",
             "https://hosting.photobucket.com/images/i/Silicon_Yemen/headphone_2.png",
             "https://hosting.photobucket.com/images/i/Silicon_Yemen/headphone_3.png",
        ],
        threeDModel: "assets/models/Head1 (2).glb",
      ));

      return products;

    } catch (e, stackTrace) {
      debugPrint("🔥 Fetch Products Error: $e");
      debugPrint(stackTrace.toString());
      return [];
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
      
      if (response.statusCode != 200) {
        debugPrint("🔥 Fetch Stores Error Body: ${response.body}");
        return [];
      }

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

  // ==================================================
  // 🔐 المصادقة (Login/Logout)
  // ==================================================

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      debugPrint("📡 Login Request: email=$email");
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      debugPrint("📡 Login Response Code: ${response.statusCode}");
      debugPrint("📡 Login Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded.containsKey('data')) {
          return decoded['data'] is Map ? decoded['data'] : null;
        }
      }
      return null;
    } catch (e) {
      debugPrint("🔥 Login Error: $e");
      return null;
    }
  }

  Future<bool> logout(String token) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/logout"),
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
  // 👤 الملف الشخصي (Profile)
  // ==================================================

  Future<bool> updateUserProfile(Map<String, dynamic> data, String token) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/user/profile"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(data),
      );

      debugPrint("📡 Update Profile Status: ${response.statusCode}");
      debugPrint("📡 Update Profile Response: ${response.body}");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("🔥 Update Profile Error: $e");
      return false;
    }
  }

  Future<String?> uploadProfilePicture(String filePath, String token) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse("$baseUrl/user/profile/image"), // Assuming this endpoint pattern
      );
      
      request.headers.addAll({
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      });
      
      request.files.add(await http.MultipartFile.fromPath('image', filePath));
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      debugPrint("📡 Upload Image Status: ${response.statusCode}");
      debugPrint("📡 Upload Image Response: ${response.body}");
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded.containsKey('data')) {
           final data = decoded['data'];
           if (data is Map && data.containsKey('profile_photo_url')) {
             return data['profile_photo_url'];
           }
        }
        return "SUCCESS"; // Fallback if URL not in response but upload was successful
      }
      return null;
    } catch (e) {
      debugPrint("🔥 Upload Profile Picture Error: $e");
      return null;
    }
  }

  // ==================================================
  // 👥 إدارة العملاء (Admin)
  // ==================================================
  Future<bool> saveAdminCustomer({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String fingerprint,
    String? profileImagePath,
    String? token,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse("$baseUrl/admin/management/customers"),
      );
      
      if (token != null && token.isNotEmpty) {
        request.headers.addAll({
          "Authorization": "Bearer $token",
        });
      }
      
      request.headers.addAll({"Accept": "application/json"});

      request.fields['first_name'] = firstName;
      request.fields['last_name'] = lastName;
      request.fields['email'] = email;
      request.fields['phone'] = phone;
      // You can adjust the key for fingerprint logic based on the backend schema
      request.fields['fingerprint'] = fingerprint;

      if (profileImagePath != null && profileImagePath.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('profile_picture', profileImagePath));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint("📡 Save Admin Customer Status: ${response.statusCode}");
      debugPrint("📡 Save Admin Customer Response: ${response.body}");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("🔥 Save Admin Customer Error: $e");
      return false;
    }
  }

  Future<bool> sendChatMessage(int storeId, String message, String token) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/stores/$storeId/messages"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "message": message,
        }),
      );

      debugPrint("📡 Send Message Status: ${response.statusCode}");
      debugPrint("📡 Send Message Response: ${response.body}");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("🔥 Send Chat Message Error: $e");
      return false;
    }
  }

  // ==================================================
  // 💳 طرق الدفع
  // ==================================================

  Future<List<PaymentMethodModel>> fetchPaymentMethods() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/payment-methods"),
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

      return list
          .where((e) => e is Map)
          .map((e) => PaymentMethodModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      debugPrint("Fetch Payment Methods Error: $e");
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
      List<dynamic> list = [];

      if (decoded is Map && decoded.containsKey('data')) {
        list = decoded['data'] is List ? decoded['data'] : [];
      } else if (decoded is List) {
        list = decoded;
      }

      return list
          .where((e) => e is Map)
          .map((e) => OrderModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      debugPrint("Fetch Orders Error: $e");
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
      Map<String, dynamic>? data;

      if (decoded is Map) {
        data = decoded.containsKey('data') ? (decoded['data'] is Map ? decoded['data'] : null) : decoded;
      }

      if (data != null) {
        return OrderModel.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint("Fetch Order Detail Error ($id): $e");
      return null;
    }
  }

  Future<OrderModel?> createOrder(Map<String, dynamic> data, String token) async {
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
          orderData = decoded.containsKey('data') ? (decoded['data'] is Map ? decoded['data'] : null) : decoded;
        }
        if (orderData != null) {
          return OrderModel.fromJson(orderData);
        }
      }
      return null;
    } catch (e) {
      debugPrint("Create Order Error: $e");
      return null;
    }
  }

  // ==================================================
  // 💰 المحفظة
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
      Map<String, dynamic>? data;

      if (decoded is Map) {
        data = decoded.containsKey('data') ? (decoded['data'] is Map ? decoded['data'] : null) : decoded;
      }

      if (data != null) {
        return WalletModel.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint("Fetch Wallet Error: $e");
      return null;
    }
  }

  // ==========================================
  // 📨 الشكاوى (Complaints)
  // ==========================================

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
      List<dynamic> list = [];
      if (decoded is Map && decoded.containsKey('data')) {
        list = decoded['data'] is List ? decoded['data'] : [];
      } else if (decoded is List) {
        list = decoded;
      }

      return list.map((json) => ComplaintModel.fromJson(json)).toList();
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

  // ==========================================
  // ⭐ التقييمات (Reviews)
  // ==========================================

  Future<List<ReviewModel>> fetchProductReviews(int productId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/products/$productId/reviews"),
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

      return list.map((json) => ReviewModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint("Fetch Reviews Error: $e");
      return [];
    }
  }

  Future<bool> createReview(Map<String, dynamic> data, String token) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/reviews"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(data),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("Create Review Error: $e");
      return false;
    }
  }
}
