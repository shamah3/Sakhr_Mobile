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
    return StoreModel(
      id: int.tryParse(json['id']?.toString() ?? "0") ?? 0,
      name: json['name']?.toString() ?? "بدون اسم",
      logo: ApiService.fixImageUrl(
        json['logo_path']?.toString() ?? 
        json['logo_url']?.toString() ?? 
        json['shop_logo']?.toString() ??
        json['logo']?.toString() ?? 
        json['image_path']?.toString() ??
        json['image']?.toString() ?? 
        json['image_url']?.toString() ?? 
        json['avatar']?.toString()
      ),
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
