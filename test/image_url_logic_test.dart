import 'package:flutter_test/flutter_test.dart';
import 'package:bytore/features/product/models/product_model.dart';
import 'package:bytore/core/services/api_service.dart';

void main() {
  group('Product Image URL Fix Tests', () {
    test('should replace localhost and 127.0.0.1 with ApiService.baseIp', () {
      final json = {
        'id': 1,
        'image_url': 'http://localhost:8000/storage/products/image1.jpg',
      };
      
      final product = Product.fromJson(json);
      
      expect(product.imageUrl, contains(ApiService.baseIp));
      expect(product.imageUrl, isNot(contains('localhost')));
    });

    test('should handle 127.0.0.1 correctly', () {
      final json = {
        'id': 1,
        'image_url': 'http://127.0.0.1:8000/storage/products/image1.jpg',
      };
      
      final product = Product.fromJson(json);
      
      expect(product.imageUrl, contains(ApiService.baseIp));
      expect(product.imageUrl, isNot(contains('127.0.0.1')));
    });

    test('should handle JSON array string ["image.jpg"]', () {
      final json = {
        'id': 1,
        'image_url': '["products/image1.jpg"]',
      };
      
      final product = Product.fromJson(json);
      
      expect(product.imageUrl, contains('products/image1.jpg'));
      expect(product.imageUrl, isNot(contains('[')));
      expect(product.imageUrl, startsWith(ApiService.serverUrl + "/upload/"));
    });

    test('should prefix products/ paths with serverUrl/upload/', () {
      final json = {
        'id': 1,
        'image': 'products/image1.jpg',
      };
      
      final product = Product.fromJson(json);
      
      expect(product.imageUrl, startsWith(ApiService.serverUrl + "/upload/"));
      expect(product.imageUrl, contains('products/image1.jpg'));
    });

    test('should handle leading slash in relative paths', () {
      final json = {
        'id': 1,
        'image': '/products/image1.jpg',
      };
      
      final product = Product.fromJson(json);
      
      expect(product.imageUrl, startsWith(ApiService.serverUrl + "/upload/"));
      // Ensure no double slash
      expect(product.imageUrl, isNot(contains('upload//')));
    });

    test('should handle gallery images conversion and JSON cleanup', () {
      final json = {
        'id': 1,
        'images_url': [
          'http://localhost:8000/storage/1.jpg',
          '["products/2.jpg"]'
        ],
      };
      
      final product = Product.fromJson(json);
      
      expect(product.images.length, 2);
      expect(product.images[0], contains(ApiService.baseIp));
      expect(product.images[1], contains('products/2.jpg'));
      expect(product.images[1], isNot(contains('[')));
    });
  });
}
