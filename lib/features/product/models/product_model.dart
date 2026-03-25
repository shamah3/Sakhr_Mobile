import 'package:bytore/core/services/api_service.dart';
import 'package:flutter/foundation.dart';

class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final double oldPrice;
  final String imageUrl;
  final String brandName;
  final int stock;
  final String status;
  final String warranty;
  final String deliveryTime;
  final String storeName;
  final String category;
  final String shortDescription;
  final String region;

  final double rating;
  final int buyerCount;

  final List<String> images;
  final List<String> threeDImages;
  final List<Map<String, dynamic>> colors;
  final List<Map<String, dynamic>> sizes;
  final Map<String, String> attributes;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.oldPrice,
    required this.imageUrl,
    required this.brandName,
    required this.stock,
    required this.status,
    required this.warranty,
    required this.deliveryTime,
    this.storeName = "Bytore Official",
    this.category = "General",
    this.shortDescription = "",
    this.region = "اليمن",
    this.rating = 4.5,
    this.buyerCount = 0,
    this.images = const [],
    this.threeDImages = const [],
    this.colors = const [],
    this.sizes = const [],
    this.attributes = const {},
  });

  /// ==========================================================
  /// ✅ تحويل JSON من Laravel API
  /// ==========================================================
  factory Product.fromJson(Map<String, dynamic> json) {

    double currentPrice =
        double.tryParse(json['price']?.toString() ?? "0") ?? 0;

    /// ==========================================================
    /// ✅ معالجة الصورة الأساسية
    /// ==========================================================
    /// ==========================================================
    /// ✅ معالجة الصورة الأساسية
    /// ==========================================================
    String fixImageUrl(String? url) {
      if (url == null || url.isEmpty) return "https://via.placeholder.com/300";
      
      String rawUrl = url.trim();
      
      // ✅ Handle JSON array strings like ["image.jpg"]
      if (rawUrl.startsWith('[') && rawUrl.endsWith(']')) {
        try {
          rawUrl = rawUrl.substring(1, rawUrl.length - 1)
                         .replaceAll('"', '')
                         .replaceAll("'", "")
                         .split(',')[0].trim();
        } catch (e) {
          debugPrint("❌ Error parsing image JSON: $e");
        }
      }

      if (rawUrl.isEmpty) return "https://via.placeholder.com/300";
      
      // Replace legacy localhost/127.0.0.1 with correct URL
      String fixedUrl = rawUrl.replaceAll("http://localhost:8000", ApiService.serverUrl)
                              .replaceAll("http://127.0.0.1:8000", ApiService.serverUrl)
                              .replaceAll("localhost:8000", ApiService.serverUrl)
                              .replaceAll("127.0.0.1:8000", ApiService.serverUrl)
                              .replaceAll("localhost", ApiService.baseIp)
                              .replaceAll("127.0.0.1", ApiService.baseIp);
      
      // If it's still not absolute, prepend server path
      if (!fixedUrl.startsWith("http")) {
        String cleanPath = fixedUrl.startsWith('/') ? fixedUrl.substring(1) : fixedUrl;
        
        if (cleanPath.startsWith("upload/") || cleanPath.startsWith("storage/")) {
          fixedUrl = "${ApiService.serverUrl}/$cleanPath";
        } else if (cleanPath.startsWith("product") || cleanPath.startsWith("products")) {
          fixedUrl = "${ApiService.serverUrl}/upload/$cleanPath";
        } else {
          fixedUrl = "${ApiService.storageUrl}/$cleanPath";
        }
      }
      
      return fixedUrl;
    }

    String image = fixImageUrl(json['image_url']?.toString() ?? json['image']?.toString());

    /// ==========================================================
    /// ✅ معالجة قائمة الصور القادمة من API
    /// (images_url)
    /// ==========================================================
    List<String> galleryImages = [];

    if (json['images_url'] != null) {
      try {
        if (json['images_url'] is List) {
          galleryImages = (json['images_url'] as List)
              .map((e) => fixImageUrl(e?.toString()))
              .toList();
        }
      } catch (_) {
        galleryImages = [];
      }
    }

    /// إذا ما فيه صور إضافية → نضيف الصورة الأساسية
    if (galleryImages.isEmpty) {
      galleryImages = [image];
    }

    /// ==========================================================
    /// ✅ معالجة stock بأمان
    /// ==========================================================
    int stockValue =
        int.tryParse(json['stock']?.toString() ?? "0") ?? 0;

    /// ==========================================================
    /// ✅ معالجة الخصائص (Attributes/Characteristics)
    /// ==========================================================
    Map<String, String> extractedAttributes = {};
    if (json['attributes'] != null && json['attributes'] is Map) {
       (json['attributes'] as Map).forEach((key, value) {
         extractedAttributes[key.toString()] = value.toString();
       });
    } else if (json['characteristics'] != null && json['characteristics'] is Map) {
       (json['characteristics'] as Map).forEach((key, value) {
         extractedAttributes[key.toString()] = value.toString();
       });
    }

    String regionValue = json['region'] ?? json['location'] ?? json['city'] ?? "";
    if (regionValue.isEmpty || regionValue == "اليمن" || regionValue == "Yemen") {
      // قائمة عشوائية للمدن لزيادة الواقعية كما طلب المستخدم
      final cities = ["صنعاء", "عدن", "تعز", "إب", "الحديدة", "المكلا"];
      regionValue = cities[json['id'] != null ? (json['id'] as int) % cities.length : 0];
    }

    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? "بدون اسم",
      description: json['description'] ?? "",
      shortDescription: json['short_description'] ?? json['excerpt'] ?? json['description']?.toString().split('.').first ?? "",
      price: currentPrice,
      oldPrice: currentPrice * 1.2,
      imageUrl: image,
      brandName: json['brand'] ?? "General",
      storeName: json['store_name'] ?? json['vendor'] ?? (json['user'] is Map ? json['user']['name'] : null) ?? "سيليكون",
      region: regionValue,
      stock: stockValue,
      status: stockValue > 0 ? "In Stock" : "Out of Stock",
      warranty: json['warranty'] ?? "سنة واحدة",
      deliveryTime: "3 أيام",
      category: json['category']?['name'] ?? "General",
      images: galleryImages,
      threeDImages: json['three_d_images'] != null
          ? List<String>.from(
        (json['three_d_images'] as List)
            .map((e) => fixImageUrl(e.toString())),
      )
          : [],
      colors: json['colors'] != null
          ? List<Map<String, dynamic>>.from(json['colors'])
          : [],
      sizes: json['sizes'] != null
          ? List<Map<String, dynamic>>.from(json['sizes'])
          : [],
      attributes: extractedAttributes,
    );
  }
}