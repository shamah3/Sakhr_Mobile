import 'package:bytore/core/services/api_service.dart';

class AdvertisementModel {
  final int id;
  final int storeId;
  final String? title;
  final String? description;
  final String image;
  final String? link;

  AdvertisementModel({
    required this.id,
    required this.storeId,
    this.title,
    this.description,
    required this.image,
    this.link,
  });

  factory AdvertisementModel.fromJson(Map<String, dynamic> json) {
    String fixImageUrl(String? url) {
      if (url == null || url.isEmpty) return "https://via.placeholder.com/600x300";
      String rawUrl = url.trim();
      if (!rawUrl.startsWith("http")) {
        String cleanPath = rawUrl.startsWith('/') ? rawUrl.substring(1) : rawUrl;
        return "${ApiService.storageUrl}/$cleanPath";
      }
      return rawUrl;
    }

    return AdvertisementModel(
      id: json['id'] ?? 0,
      storeId: json['store_id'] ?? 0,
      title: json['title'],
      description: json['description'],
      image: fixImageUrl(json['image'] ?? json['image_url']),
      link: json['link'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'title': title,
      'description': description,
      'image': image,
      'link': link,
    };
  }
}
