import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bytore/features/profile/models/review_model.dart';
import 'package:intl/intl.dart';
import 'package:bytore/core/controllers/app_controller.dart';
import 'package:bytore/core/services/api_service.dart';
import 'package:bytore/features/profile/controllers/purchase_reports_controller.dart';
import 'package:bytore/features/profile/controllers/activities_controller.dart';
import 'package:bytore/features/orders/models/order_model.dart';
import 'package:bytore/features/product/controllers/product_controller.dart';

class ReviewsController extends GetxController with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  final ApiService _apiService = ApiService();
  final AppController _appController = Get.find<AppController>();

  // قائمة التقييمات المكتملة
  var reviewedList = <ReviewModel>[].obs;

  // قائمة بانتظار التقييم
  var pendingList = <ReviewModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    
    // تحميل البيانات
    fetchUserReviews();
    _loadPendingData();
    
    // الاستماع للتغييرات في الطلبات
    final purchaseController = Get.find<PurchaseReportsController>();
    ever(purchaseController.orders, (_) => _loadPendingData());
  }

  var isLoading = false.obs;

  Future<void> fetchUserReviews() async {
    try {
      isLoading.value = true;
      final token = _appController.token.value;
      if (token.isEmpty) return;

      // This is a list of all reviews by this user
      // Note: The API might need a specific endpoint for user reviews, 
      // but for now we often fetch all reviews and filter or use a dedicated endpoint.
      // If sakhr.etezaz.com/api/reviews (GET) exists for current user:
      // final fetched = await _apiService.fetchUserReviews(token); 
      // reviewedList.assignAll(fetched);
    } catch (e) {
      debugPrint("Error fetching user reviews: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _loadPendingData() {
    pendingList.clear();
    
    try {
      final purchaseController = Get.find<PurchaseReportsController>();
      for (OrderModel order in purchaseController.orders) {
        for (int i = 0; i < order.itemsNames.length; i++) {
          final itemName = order.itemsNames[i];
          final productId = order.productIds.length > i ? order.productIds[i] : null;

          if (productId == null) continue;

          // نتأكد أنه لم يتم تقييمه مسبقاً
          if (!reviewedList.any((r) => r.productId == productId)) {
             pendingList.add(ReviewModel(
              id: 0,
              productId: productId,
              productName: itemName,
              date: "تم الشراء في ${DateFormat('dd/MM/yyyy', 'ar').format(order.dateTime)}",
              icon: Icons.shopping_bag_outlined,
              isPending: true,
              rating: 0,
              comment: "",
            ));
          }
        }
      }
    } catch (e) {
      print("Error loading pending reviews: $e");
    }
  }

  // دالة لإضافة تقييم جديد مدمجة مع API
  void addReview(ReviewModel pendingItem, double rating, String comment) async {
    if (pendingItem.productId == null) return;

    try {
      isLoading.value = true;
      final token = _appController.token.value;
      if (token.isEmpty) return;

      final data = {
        "product_id": pendingItem.productId,
        "rating": rating.toInt(),
        "comment": comment,
      };

      final success = await _apiService.createReview(data, token);
      
      if (success) {
        // حذفه من قائمة الانتظار
        pendingList.remove(pendingItem);

        // ✅ تحديث قائمة التعليقات في تفاصيل المنتج إذا كانت الواجهة مفتوحة
        try {
          final String tag = pendingItem.productId.toString();
          if (Get.isRegistered<ProductController>(tag: tag)) {
             Get.find<ProductController>(tag: tag).fetchReviews();
          }
        } catch (e) {
          debugPrint("Note: Could not refresh ProductController: $e");
        }

        // إضافة للأنشطة
        try {
          Get.find<ActivitiesController>().logActivity(
            title: "تقييم منتج: ${pendingItem.productName}",
            type: 'star'
          );
        } catch (e) {}
        
        Get.snackbar("شكراً لك", "تم إضافة تقييمك بنجاح", 
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        Get.snackbar("خطأ", "فشل إضافة التقييم", backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      debugPrint("Error adding review: $e");
    } finally {
      isLoading.value = false;
    }
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

  // --- 🌟 تقييم منصة صخر (Platform Rating) 🌟 ---

  // دالة لإظهار نافذة تقييم المنصة (تستدعى تلقائياً أو يدوياً)
  void showSakhrRatingDialog() {
    double tempRating = 5;
    final commentController = TextEditingController();

    Get.defaultDialog(
      title: "تقييم منصة صخر",
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF015C92)),
      content: Column(
        children: [
          const Text(
            "رأيك يهمنا! كيف كانت تجربتك مع صخر؟",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 20),
          StatefulBuilder(
            builder: (context, setState) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () {
                      setState(() => tempRating = index + 1.0);
                    },
                    icon: Icon(
                      Icons.star_rounded, 
                      color: index < tempRating ? Colors.orange : Colors.grey[300], 
                      size: 35
                    ),
                  );
                }),
              );
            }
          ),
          const SizedBox(height: 15),
          TextField(
            controller: commentController,
            decoration: InputDecoration(
              hintText: "أخبرنا بمزيد من التفاصيل (اختياري)",
              hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            maxLines: 3,
          ),
        ],
      ),
      confirm: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF015C92),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
          ),
          onPressed: () {
            submitSakhrReview(tempRating, commentController.text);
            Get.back();
          },
          child: const Text("إرسال التقييم", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
      barrierDismissible: true,
    );
  }

  // إرسال تقييم صخر (Store ID = 1)
  void submitSakhrReview(double rating, String comment) async {
    try {
      isLoading.value = true;
      final token = _appController.token.value;
      if (token.isEmpty) return;

      final success = await _apiService.postStoreReview(
        storeId: 1, // ID الخاص بمنصة صخر
        rating: rating.toInt(),
        comment: comment,
        token: token,
      );

      if (success) {
        // إضافة للأنشطة
        try {
          Get.find<ActivitiesController>().logActivity(
            title: "تقييم منصة صخر: $rating نجوم",
            type: 'star'
          );
        } catch (e) {}

        Get.snackbar(
          "شكراً لك", 
          "نسعى دائماً لتقديم الأفضل لك في صخر", 
          backgroundColor: Colors.green, 
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar("تنبيه", "فشل إرسال التقييم، يرجى المحاولة لاحقاً", backgroundColor: Colors.orange, colorText: Colors.white);
      }
    } catch (e) {
      debugPrint("Error submitting Sakhr review: $e");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}
