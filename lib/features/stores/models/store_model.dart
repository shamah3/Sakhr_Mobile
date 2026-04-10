import 'package:bytore/core/services/api_service.dart';

class StoreModel {
  final int id;
  final String name;
  final String? logo;
  final String? description;
  final String? phone;
  final String? email;
  final String? address;
  final String? status;
  final String category;
  final double rating;
  final bool isVerified;

  StoreModel({
    required this.id,
    required this.name,
    this.logo,
    this.description,
    this.phone,
    this.email,
    this.address,
    this.status,
    this.category = "عام",
    this.rating = 4.5,
    this.isVerified = false,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    String fixImageUrl(String? url) {
      if (url == null || url.isEmpty) return "https://via.placeholder.com/300";
      String rawUrl = url.trim();
      
      // إذا كان الرابط كاملاً، نتحقق مما إذا كان يشير إلى localhost ونصححه
      if (rawUrl.startsWith("http")) {
        if (rawUrl.contains("localhost") || rawUrl.contains("127.0.0.1")) {
          return rawUrl
              .replaceAll("localhost", ApiService.baseIp.split(':')[0])
              .replaceAll("127.0.0.1", ApiService.baseIp.split(':')[0]);
        }
        return rawUrl;
      }
      
      // تنظيف المسار
      String path = rawUrl;
      if (path.startsWith('/')) path = path.substring(1);
      
      // إزالة public/ إذا وجدت
      if (path.startsWith('public/')) path = path.substring(7);
      
      // التحقق مما إذا كان المسار يحتوي بالفعل على storage أو uploads أو assets
      bool hasPrefix = path.startsWith('storage/') || 
                       path.startsWith('uploads/') || 
                       path.startsWith('assets/') ||
                       path.startsWith('images/');

      if (hasPrefix) {
        return "${ApiService.serverUrl}/$path";
      }

      // الحالة الافتراضية الأكثر شيوعاً في لارافل
      return "${ApiService.serverUrl}/storage/$path";
    }

    return StoreModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? "بدون اسم",
      logo: fixImageUrl(json['logo'] ?? json['image_url']),
      description: json['description'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      status: json['status'],
      category: json['category'] ?? "إلكترونيات",
      rating: double.tryParse(json['rating']?.toString() ?? "4.5") ?? 4.5,
      isVerified: json['is_verified'] == 1 || json['is_verified'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo': logo,
      'description': description,
      'phone': phone,
      'email': email,
      'address': address,
      'status': status,
      'category': category,
      'rating': rating,
      'is_verified': isVerified,
    };
  }
}
