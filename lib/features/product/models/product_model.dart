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
  final int storeId;
  final String? storeLogo;
  final String category;
  final String shortDescription;
  final String region;
  final String? threeDModel;
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
    this.storeId = 1,
    this.storeLogo,
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
    this.threeDModel,
  });

  /// ==========================================================
  /// ✅ تحويل JSON من Laravel API
  /// ==========================================================
  factory Product.fromJson(Map<String, dynamic> json) {

    double currentPrice =
        double.tryParse(json['price']?.toString() ?? "0") ?? 0;

    /// ==========================================================
    /// ✅ معالجة الصورة الأساسية وتحسين الروابط
    /// ==========================================================
    String fixImageUrl(String? url) {
      if (url == null || url.isEmpty) {
        return ""; // صورة فارغة للشفافية
      }
      
      String rawUrl = url.trim();

      // ✅ Handle Local Assets directly
      if (rawUrl.startsWith('assets/')) {
        return rawUrl;
      }
      
      // ✅ Handle JSON array strings like ["image.jpg"]
      // DEPRECATED: We now prefer handling lists properly in fromJson
      if (rawUrl.startsWith('[') && rawUrl.endsWith(']')) {
        try {
          String clean = rawUrl.substring(1, rawUrl.length - 1)
                         .replaceAll('"', '')
                         .replaceAll("'", "");
          if (clean.contains(',')) {
             rawUrl = clean.split(',')[0].trim();
          } else {
             rawUrl = clean.trim();
          }
        } catch (e) {
          debugPrint("❌ Error parsing image JSON: $e");
        }
      }

      if (rawUrl.isEmpty) return "";
      
      // Replace legacy localhost/127.0.0.1/local IPs with correct server URL
      String fixedUrl = rawUrl.replaceAll("http://localhost:8000", ApiService.serverUrl)
                              .replaceAll("http://127.0.0.1:8000", ApiService.serverUrl)
                              .replaceAll("http://192.168.8.196:8000", ApiService.serverUrl)
                              .replaceAll("http://10.0.2.2:8000", ApiService.serverUrl)
                              .replaceAll("localhost:8000", ApiService.serverUrl)
                              .replaceAll("127.0.0.1:8000", ApiService.serverUrl)
                              .replaceAll("192.168.8.196:8000", ApiService.serverUrl)
                              .replaceAll("10.0.2.2:8000", ApiService.serverUrl)
                              .replaceAll("localhost", ApiService.baseIp)
                              .replaceAll("127.0.0.1", ApiService.baseIp)
                              .replaceAll("http://sakhr.etezaz.com", ApiService.serverUrl)
                              .replaceAll("https://sakhr.etezaz.com", ApiService.serverUrl);
      
      // If it's still not absolute, prepend server path
      if (!fixedUrl.startsWith("http")) {
        // Remove leading slash if exists
        String cleanPath = fixedUrl.startsWith('/') ? fixedUrl.substring(1) : fixedUrl;
        
        // Handle Laravel common storage paths
        if (cleanPath.startsWith("upload/") || cleanPath.startsWith("storage/")) {
          fixedUrl = "${ApiService.serverUrl}/$cleanPath";
        } else if (cleanPath.startsWith("public/")) {
           fixedUrl = "${ApiService.serverUrl}/${cleanPath.replaceFirst('public/', '')}";
        } else if (cleanPath.contains("products") || cleanPath.contains("images")) {
           if (cleanPath.contains("storage/")) {
             fixedUrl = "${ApiService.serverUrl}/$cleanPath";
           } else {
             fixedUrl = "${ApiService.storageUrl}/$cleanPath";
           }
        } else {
          fixedUrl = "${ApiService.storageUrl}/$cleanPath";
        }
      }
      
      return fixedUrl;
    }

    String image = fixImageUrl(
      json['image_url']?.toString() ??
      json['image']?.toString() ??
      json['image_path']?.toString() ??
      json['path']?.toString() ??
      json['photo']?.toString() ??
      json['thumbnail']?.toString() ??
      json['cover_image']?.toString() ??
      json['primary_image']?.toString()
    );

    /// ==========================================================
    /// ✅ معالجة قائمة الصور القادمة من API
    /// (images_url OR images relationship)
    /// ==========================================================
    List<String> galleryImages = [];

    if (json['images_urls'] != null && json['images_urls'] is List) {
       galleryImages = (json['images_urls'] as List)
          .map((e) => fixImageUrl(e?.toString()))
          .where((url) => url.isNotEmpty)
          .toList();
    } else if (json['images'] != null && json['images'] is List) {
      galleryImages = (json['images'] as List)
          .map((e) => fixImageUrl(e['image_path'] ?? e['image_url'] ?? e['image']?.toString()))
          .where((url) => url.isNotEmpty)
          .toList();
    } else if (json['images_url'] != null) {
      try {
        if (json['images_url'] is List) {
          galleryImages = (json['images_url'] as List)
              .map((e) => fixImageUrl(e?.toString()))
              .where((url) => url.isNotEmpty)
              .toList();
        } else if (json['images_url'] is String && json['images_url'].startsWith('[')) {
           // Handle stringified JSON array
           String clean = json['images_url'].substring(1, json['images_url'].length - 1)
                         .replaceAll('"', '')
                         .replaceAll("'", "");
           galleryImages = clean.split(',').map((e) => fixImageUrl(e.trim())).where((url) => url.isNotEmpty).toList();
        }
      } catch (_) {
        galleryImages = [];
      }
    }

    /// التزامن بين الصورة الرئيسية ومعرض الصور
    if (image.isEmpty && galleryImages.isNotEmpty) {
      image = galleryImages.first;
    } else if (galleryImages.isEmpty && image.isNotEmpty) {
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
    int parsedId = int.tryParse(json['id']?.toString() ?? "0") ?? 0;

    if (regionValue.isEmpty || regionValue == "اليمن" || regionValue == "Yemen") {
      final cities = ["صنعاء", "عدن", "تعز", "إب", "الحديدة", "المكلا"];
      regionValue = cities[parsedId % cities.length];
    }

    // Parse Warranty
    String parsedWarranty = json['warranty']?.toString() ?? "";
    if (parsedWarranty.isEmpty || parsedWarranty == "null" || parsedWarranty == "بدون ضمان") {
      if (json['warranty_duration'] != null && json['warranty_duration'].toString().isNotEmpty && json['warranty_duration'].toString() != "null") {
        String wUnit = json['warranty_unit']?.toString() ?? "";
        if (wUnit == "months" || wUnit == "month") wUnit = "أشهر";
        else if (wUnit == "years" || wUnit == "year") wUnit = "سنوات";
        else if (wUnit == "days" || wUnit == "day") wUnit = "أيام";
        parsedWarranty = "${json['warranty_duration']} $wUnit".trim();
      } else {
        parsedWarranty = "بدون ضمان";
      }
    }

    // Parse Brand
    String parsedBrand = "بدون ماركة";
    if (json['brand'] is Map && json['brand']['name'] != null) {
      parsedBrand = json['brand']['name'].toString();
    } else if (json['manual_brand'] != null && json['manual_brand'].toString().isNotEmpty && json['manual_brand'].toString() != "null") {
      parsedBrand = json['manual_brand'].toString();
    } else if (json['brand'] != null && json['brand'].toString().isNotEmpty && json['brand'].toString() != "null" && json['brand'] is! Map) {
      parsedBrand = json['brand'].toString();
    }

    return Product(
      id: parsedId,
      name: json['name']?.toString() ?? "بدون اسم",
      description: json['description']?.toString() ?? "",
      shortDescription: json['short_description'] ?? json['excerpt'] ?? json['description']?.toString().split('.').first ?? "",
      price: currentPrice,
      oldPrice: currentPrice * 1.2,
      imageUrl: image,
      brandName: parsedBrand,
      storeName: json['store']?['name']?.toString() ?? json['store_name'] ?? json['vendor'] ?? (json['user'] is Map ? json['user']['name'] : null) ?? "سيليكون",
      storeId: int.tryParse(json['store']?['id']?.toString() ?? json['store_id']?.toString() ?? json['vendor_id']?.toString() ?? (json['user'] is Map ? json['user']['id']?.toString() : "1") ?? "1") ?? 1,
      storeLogo: fixImageUrl(
          json['store']?['logo_url'] ?? 
          json['store']?['logo_path'] ?? 
          json['store_logo'] ?? 
          json['vendor_logo']
      ),
      region: regionValue,
      stock: stockValue,
      status: json['status']?.toString() ?? (stockValue > 0 ? "In Stock" : "Out of Stock"),
      warranty: parsedWarranty,
      deliveryTime: "3 أيام",
      category: json['category']?['name'] ?? "General",
      images: galleryImages,
      threeDImages: (json['three_sixty_images'] ?? json['three_d_images']) != null
          ? List<String>.from(
        ((json['three_sixty_images'] ?? json['three_d_images']) as List)
            .map((e) => fixImageUrl(e.toString())),
      )
          : [],
      colors: json['colors'] != null
          ? List<Map<String, dynamic>>.from(json['colors']).map((c) {
              return {
                ...c,
                'image': fixImageUrl(c['image_url'] ?? c['image_path'] ?? c['image']?.toString()),
              };
            }).toList()
          : [],
      sizes: json['sizes'] != null
          ? List<Map<String, dynamic>>.from(json['sizes'])
          : [],
      attributes: extractedAttributes,
      threeDModel: json['three_d_model'] != null ? fixImageUrl(json['three_d_model']) : _getMappedLocal3DModel(json['name']?.toString() ?? ""),
    );
  }

  static String? _getMappedLocal3DModel(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('mac') || lowerName.contains('laptop') || lowerName.contains('لابتوب')) {
      return 'assets/models/Mac.glb';
    } else if (lowerName.contains('printer') || lowerName.contains('طابعة')) {
      return 'assets/models/printer3.glb';
    } else if (lowerName.contains('سماعة') || lowerName.contains('headphone') || lowerName.contains('h1')) {
      return 'assets/models/h1glb.glb';
    } else if (lowerName.contains('h2')) {
      return 'assets/models/h2glb.glb';
    } else if (lowerName.contains('h3')) {
      return 'assets/models/h3.glb';
    } else if (lowerName.contains('p4')) {
      return 'assets/models/p4glb.glb';
    } else if (lowerName.contains('p5')) {
      return 'assets/models/p5.glb';
    } else if (lowerName.contains('p6')) {
      return 'assets/models/p6.glb';
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'short_description': shortDescription,
      'price': price,
      'oldPrice': oldPrice,
      'image_url': imageUrl,
      'brand': brandName,
      'store_name': storeName,
      'store_id': storeId,
      'region': region,
      'stock': stock,
      'status': status,
      'warranty': warranty,
      'category': {'name': category},
      'images_url': images,
      'three_d_images': threeDImages,
      'colors': colors,
      'sizes': sizes,
      'attributes': attributes,
      'three_d_model': threeDModel,
    };
  }
}