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
      if (!rawUrl.startsWith("http")) {
        String cleanPath = rawUrl.startsWith('/') ? rawUrl.substring(1) : rawUrl;
        return "${ApiService.storageUrl}/$cleanPath";
      }
      return rawUrl;
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
