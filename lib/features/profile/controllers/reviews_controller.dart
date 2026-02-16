import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bytore/features/profile/models/review_model.dart';
import 'package:bytore/features/profile/controllers/purchase_reports_controller.dart';

class ReviewsController extends GetxController with GetSingleTickerProviderStateMixin {
  late TabController tabController;

  // قائمة التقييمات المكتملة
  var reviewedList = <ReviewModel>[].obs;

  // قائمة بانتظار التقييم
  var pendingList = <ReviewModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    
    // تحميل البيانات
    _loadData();
    
    // الاستماع للتغييرات في الطلبات
    final purchaseController = Get.find<PurchaseReportsController>();
    ever(purchaseController.orders, (_) => _loadData());
  }

  void _loadData() {
    // 1. تحديث قائمة "بانتظار التقييم" من الطلبات الحديثة
    // نفترض أن كل عنصر في الطلبات يحتاج تقييم
    pendingList.clear();
    
    try {
      final purchaseController = Get.find<PurchaseReportsController>();
      for (var order in purchaseController.orders) {
        // إضافة كل منتج في الطلب كعنصر قابل للتقييم
        for (var itemName in order.itemsNames) {
          // نتأكد أنه لم يتم تقييمه مسبقاً
          if (!reviewedList.any((r) => r.productName == itemName)) {
             pendingList.add(ReviewModel(
              productName: itemName,
              date: "تم الشراء في ${order.date}",
              icon: Icons.shopping_bag_outlined,
              isPending: true,
            ));
          }
        }
      }
    } catch (e) {
      print("Error loading reviews: $e");
    }
  }

  // دالة لإضافة تقييم جديد
  void addReview(ReviewModel pendingItem, double rating, String comment) {
    reviewedList.insert(0, ReviewModel(
      productName: pendingItem.productName,
      date: "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
      rating: rating.toInt(),
      comment: comment,
      icon: Icons.check_circle,
      isPending: false,
    ));
    
    // حذفه من قائمة الانتظار
    pendingList.remove(pendingItem);
    
    Get.snackbar(
      "شكراً لك", 
      "تم إضافة تقييمك بنجاح", 
      backgroundColor: Colors.green, 
      colorText: Colors.white
    );
  }

  // إظهار نافذة التقييم
  void showRatingDialog(ReviewModel item) {
    double tempRating = 5;
    final commentController = TextEditingController();

    Get.defaultDialog(
      title: "تقييم ${item.productName}",
      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      content: Column(
        children: [
          const Text("ما هو تقييمك للمنتج؟"),
          const SizedBox(height: 15),
          // نجوم التقييم
          StatefulBuilder(
            builder: (context, setState) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () {
                      setState(() {
                         tempRating = index + 1.0;
                      });
                    },
                    icon: Icon(
                      Icons.star, 
                      color: index < tempRating ? Colors.orange : Colors.grey[300], 
                      size: 30
                    ),
                  );
                }),
              );
            }
          ),
          const SizedBox(height: 15),
          TextField(
            controller: commentController,
            decoration: const InputDecoration(
              hintText: "أكتب تعليقك هنا...",
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            maxLines: 3,
          ),
        ],
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF015C92)),
        onPressed: () {
          addReview(item, tempRating, commentController.text);
          Get.back();
        },
        child: const Text("إرسال التقييم", style: TextStyle(color: Colors.white)),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text("إلغاء", style: TextStyle(color: Colors.grey)),
      ),
    );
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}
