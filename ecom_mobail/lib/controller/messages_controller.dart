import 'package:get/get.dart';

class MessagesController extends GetxController {
  // قائمة المحادثات التجريبية (Reactive)
  var chats = <Map<String, dynamic>>[
    {
      'name': 'فريق دعم محسوب',
      'lastMessage': 'أهلاً بك، تم حل تذكرتك بنجاح',
      'time': '10:30 ص',
      'unreadCount': 2,
      'isOnline': true,
      'image': 'https://ui-avatars.com/api/?name=Support&background=015C92&color=fff',
    },
    {
      'name': 'المهندس أحمد علي',
      'lastMessage': 'هل المنتج متوفر في فرع صنعاء؟',
      'time': 'أمس',
      'unreadCount': 0,
      'isOnline': false,
      'image': 'https://i.pravatar.cc/150?u=ahmed',
    },
  ].obs;

  void openChat(String name) {
    // منطق فتح المحادثة
    Get.snackbar("المحادثة", "سيتم فتح محادثة مع $name");
  }
}