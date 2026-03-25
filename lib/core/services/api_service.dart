import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:bytore/features/product/models/product_model.dart';

class ApiService {

  static const String baseIp = "sakhr.etezaz.com";
  static String get baseUrl => "https://$baseIp/api";
  static String get storageUrl => "https://$baseIp/storage";
  static String get serverUrl => "https://$baseIp";

  // ==================================================
  // 🔥 جلب المنتجات
  // ==================================================
  Future<List<Product>> fetchProducts({String? categorySlug}) async {
    try {

      String url = "$baseUrl/products";

      if (categorySlug != null && categorySlug != "all") {
        url = "$url?category=$categorySlug";
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

      final decoded = jsonDecode(response.body);

      List<dynamic> productsList = [];

      // ✅ حالة Laravel Pagination
      if (decoded is Map &&
          decoded.containsKey('data')) {

        if (decoded['data'] is Map &&
            decoded['data'].containsKey('data')) {

          productsList = decoded['data']['data'];

        }
        // ✅ لو رجع data مباشرة List
        else if (decoded['data'] is List) {

          productsList = decoded['data'];

        }
      }
      // ✅ لو API رجع List مباشرة
      else if (decoded is List) {

        productsList = decoded;
      }

      debugPrint("🟢 PRODUCTS COUNT: ${productsList.length}");

      return productsList
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
}