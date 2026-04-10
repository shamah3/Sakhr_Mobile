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
      
      String finalUrl = "";
      
      // إذا كان الرابط كاملاً
      if (rawUrl.startsWith("http")) {
        // تصحيح localhost/127.0.0.1
        if (rawUrl.contains("localhost") || rawUrl.contains("127.0.0.1")) {
          finalUrl = rawUrl
              .replaceAll("localhost", ApiService.baseIp.split(':')[0])
              .replaceAll("127.0.0.1", ApiService.baseIp.split(':')[0]);
        } else {
          finalUrl = rawUrl;
        }
      } else {
        // تنظيف المسار
        String path = rawUrl;
        if (path.startsWith('/')) path = path.substring(1);
        if (path.startsWith('public/')) path = path.substring(7);
        
        bool hasPrefix = path.startsWith('storage/') || 
                         path.startsWith('uploads/') || 
                         path.startsWith('assets/') ||
                         path.startsWith('images/');

        if (hasPrefix) {
          finalUrl = "${ApiService.serverUrl}/$path";
        } else {
          finalUrl = "${ApiService.serverUrl}/storage/$path";
        }
      }

      // التأكد من أن الرابط ليس به دبل سلاش // بعد البروتوكول
      // وتشفير الرابط للتعامل مع أي حروف خاصة في أسماء الملفات
      try {
        // تنظيف الروابط من أي مسافات أو حروف غير مسموحة
        return Uri.parse(finalUrl).toString();
      } catch (e) {
        return finalUrl;
      }
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
