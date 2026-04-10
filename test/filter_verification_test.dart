import 'package:flutter_test/flutter_test.dart';
import 'package:bytore/features/product/models/product_model.dart';
import 'package:bytore/core/controllers/app_controller.dart';
import 'package:get/get.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    Get.put(AppController());
  });

  tearDown(() {
    Get.reset();
  });

  group('Product Model Tests', () {
    test('fromJson parses rating and buyerCount correctly', () {
      final json = {
        'id': 1,
        'title': 'Test Product',
        'price': 100.0,
        'description': 'Desc',
        'category': 'Tech',
        'image': 'img.png',
        'rating': {'rate': 4.8, 'count': 200}
      };

      final product = Product.fromJson(json);
      expect(product.rating, 4.8);
      expect(product.buyerCount, 200);
    });

    test('fromJson uses defaults when rating missing', () {
      final json = {
        'id': 1,
        'title': 'Test Product',
        'price': 100.0,
        'description': 'Desc',
        'category': 'Tech',
        'image': 'img.png',
      };

      final product = Product.fromJson(json);
      expect(product.rating, 4.5); // Default
      expect(product.buyerCount, 100); // Default
    });
  });

  group('AppController Filter Tests', () {
    test('Default availability is Available', () {
      final appController = Get.find<AppController>();
      expect(appController.selectedAvailability.value, 'متوفر');
    });

    test('updateFilters updates state correctly', () {
      final appController = Get.find<AppController>();
      appController.updateFilters(availability: 'غير متوفر');
      expect(appController.selectedAvailability.value, 'غير متوفر');
    });
  });
}
