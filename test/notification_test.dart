import 'package:flutter_test/flutter_test.dart';
import 'package:bytore/core/services/api_service.dart';
import 'package:bytore/core/controllers/app_controller.dart';
import 'package:get/get.dart';

class TestApiService extends ApiService {}

void main() {
  setUp(() {
    Get.testMode = true;
    Get.put(AppController());
  });

  tearDown(() {
    Get.reset();
  });

  group('Notification & Controller Tests', () {
    test('AppController addNotification adds to list', () {
      final appController = Get.find<AppController>();
      expect(appController.notifications.length, 0);
      
      appController.addNotification(title: "Test", body: "Body");
      expect(appController.notifications.length, 1);
      expect(appController.notifications[0]['title'], "Test");
    });
  });
}
