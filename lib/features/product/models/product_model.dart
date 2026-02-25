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

  final double rating;
  final int buyerCount;

  final List<String> images;
  final List<String> threeDImages;
  final List<Map<String, dynamic>> colors;
  final List<Map<String, dynamic>> sizes;

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
    this.rating = 4.5,
    this.buyerCount = 0,
    this.images = const [],
    this.threeDImages = const [],
    this.colors = const [],
    this.sizes = const [],
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
      
      // Replace localhost/127.0.0.1 with correct IP
      String fixedUrl = rawUrl.replaceAll("localhost", ApiService.baseIp)
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
      
      debugPrint("🖼️ FINAL IMAGE URL: $fixedUrl");
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

    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? "بدون اسم",
      description: json['description'] ?? "",
      price: currentPrice,
      oldPrice: currentPrice * 1.2,
      imageUrl: image,
      brandName: json['brand'] ?? "General",
      stock: stockValue,
      status: stockValue > 0 ? "In Stock" : "Out of Stock",
      warranty: json['warranty'] ?? "",
      deliveryTime: "3 أيام",
      category: json['category']?['name'] ?? "General",

      /// ✅ أهم تعديل هنا
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
    );
  }
}