import 'package:bytore/core/services/api_service.dart';

class AdvertisementModel {
  final int id;
  final int storeId;
  final String? title;
  final String? description;
  final String image;
  final String? link;
  final double? budget;
  final String? startDate;
  final String? endDate;
  final String? targetUrl;
  final String? storeName;
  final String? storeLogo;

  AdvertisementModel({
    required this.id,
    required this.storeId,
    this.title,
    this.description,
    required this.image,
    this.link,
    this.budget,
    this.startDate,
    this.endDate,
    this.targetUrl,
    this.storeName,
    this.storeLogo,
  });

  factory AdvertisementModel.fromJson(Map<String, dynamic> json) {
    String fixImageUrl(String? url) {
      if (url == null || url.isEmpty) {
        return "";
      }
      
      String rawUrl = url.trim();
      
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
        } else if (cleanPath.startsWith("public/")) {
           fixedUrl = "${ApiService.serverUrl}/${cleanPath.replaceFirst('public/', '')}";
        } else {
          fixedUrl = "${ApiService.storageUrl}/$cleanPath";
        }
      }
      
      return fixedUrl;
    }

    final store = json['store'] as Map<String, dynamic>?;

    return AdvertisementModel(
      id: json['id'] ?? 0,
      storeId: json['store_id'] ?? 0,
      title: json['title'],
      description: json['description'],
      image: fixImageUrl(json['image'] ?? json['image_url']),
      link: json['link'],
      budget: json['budget'] != null ? double.tryParse(json['budget'].toString()) : null,
      startDate: json['start_date'],
      endDate: json['end_date'],
      targetUrl: json['target_url'],
      storeName: store?['name'],
      storeLogo: fixImageUrl(store?['logo_path']),
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
      'budget': budget,
      'start_date': startDate,
      'end_date': endDate,
      'target_url': targetUrl,
      'store_name': storeName,
      'store_logo': storeLogo,
    };
  }
}
