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

      try {
        return Uri.parse(finalUrl).toString();
      } catch (e) {
        return finalUrl;
      }
    }

    return StoreModel(
      id: int.tryParse(json['id']?.toString() ?? "0") ?? 0,
      name: json['name']?.toString() ?? "بدون اسم",
      logo: fixImageUrl(json['logo']?.toString() ?? json['image_url']?.toString()),
      description: json['description']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      address: json['address']?.toString(),
      status: json['status']?.toString(),
      category: json['category']?.toString() ?? "إلكترونيات",
      rating: double.tryParse(json['rating']?.toString() ?? "4.5") ?? 4.5,
      isVerified: json['is_verified'] == 1 || json['is_verified'] == true || json['is_verified']?.toString() == "1",
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
