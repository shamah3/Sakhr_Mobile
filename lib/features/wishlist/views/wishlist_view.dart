import 'package:flutter/material.dart';
import 'package:bytore/core/constants/constants.dart';
import 'package:get/get.dart';
import 'package:bytore/core/components/custom_image.dart';
import 'package:bytore/core/controllers/app_controller.dart';
import 'package:bytore/core/controllers/cart_controller.dart';
import 'package:bytore/features/home/controllers/home_controller.dart';
import 'package:bytore/features/product/models/product_model.dart';
import 'package:bytore/core/utils/notification_helper.dart';
import 'package:bytore/features/home/controllers/main_controller.dart';

class WishlistView extends StatelessWidget {
  const WishlistView({super.key});

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    final homeController = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: Obx(() => appController.wishlistIds.isNotEmpty
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: kTextColor, size: 20),
              onPressed: () => Get.back(),
            )
          : const SizedBox.shrink()
        ),
        title: const Text(
          'المفضلة',
          style: TextStyle(color: kTextColor, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: const [SizedBox(width: 55)],
      ),
      body: Obx(() {
        if (appController.wishlistIds.isEmpty) return _buildEmptyState(context);

        // Filter products from homeController
        final wishlistItems = homeController.allProducts
            .where((p) => appController.wishlistIds.contains(p.id))
            .toList();

        if (wishlistItems.isEmpty) {
          // If homeController doesn't have products yet, we might need a fetch or a loading state
          if (homeController.isLoading.value) {
            return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
          }
          return _buildEmptyState(context);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: wishlistItems.length,
          itemBuilder: (context, index) {
            final item = wishlistItems[index];
            return _buildWishlistItem(context, item, appController);
          },
        );
      }),
    );
  }

  Widget _buildWishlistItem(BuildContext context, Product item, AppController appController) {
    bool isUnavailable = item.stock == 0;
    bool isOnShipment = item.status == 'On Shipment';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Opacity(
                opacity: isUnavailable ? 0.6 : 1.0,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CustomImage(
                        imageUrl: item.imageUrl, 
                        fit: BoxFit.contain,
                        width: 80, // Approximate width based on context if needed, or let it fill
                        height: 80,
                      ),
                    ),
                  ),
                ),
              ),
              if (isUnavailable)
                Positioned.fill(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                      child: const Text("نافذ", style: TextStyle(color: Colors.white, fontSize: 10)),
                    ),
                  ),
                ),
              if (isOnShipment && !isUnavailable)
                Positioned(
                  top: 0, left: 0,
                  child: Container(
                     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(8)),
                      child: const Text("شحن", style: TextStyle(color: Colors.white, fontSize: 8)),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Opacity(
              opacity: isUnavailable ? 0.6 : 1.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: kTextColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          appController.toggleWishlist(item.id);
                          appController.addNotification(
                            title: "تحديث المفضلة",
                            body: "تم إزالة ${item.name} من قائمة أمنياتك.",
                            color: Colors.redAccent,
                          );
                        },
                        child: const Icon(Icons.favorite_rounded, color: kSecondaryColor, size: 22),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.verified_user_outlined, size: 10, color: kSecondaryColor),
                      const SizedBox(width: 4),
                      Text(
                        item.warranty,
                        style: const TextStyle(fontSize: 9, color: kTextColor),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.local_shipping_outlined, size: 10, color: kSecondaryColor),
                      const SizedBox(width: 4),
                      Text(
                        item.deliveryTime,
                        style: const TextStyle(fontSize: 9, color: kTextColor, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        appController.getFormattedPrice(item.price),
                        style: const TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      _buildAddToCartBtn(context, item, appController, isUnavailable, isOnShipment),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddToCartBtn(BuildContext context, Product item, AppController appController, bool isUnavailable, bool isOnShipment) {
    final cartController = Get.find<CartController>();
    return GestureDetector(
      onTap: () {
        if (isUnavailable) {
          NotificationHelper.showCustomSnackBar(context, "هذا المنتج غير متوفر حالياً", isError: false);
          return;
        }
        if (isOnShipment) {
           NotificationHelper.showCustomSnackBar(context, "هذا المنتج قيد الشحن", isError: false);
           return;
        }

        cartController.addItem(item);

        NotificationHelper.showCustomSnackBar(
          context, 
          "تم إضافة ${item.name} إلى السلة بنجاح",
          isError: false
        );

        appController.addNotification(
          title: "تمت الإضافة للسلة",
          body: "تم إضافة ${item.name} إلى سلة المشتريات بنجاح.",
          color: kPrimaryColor,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: (isUnavailable || isOnShipment) ? Colors.grey : kPrimaryColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: kPrimaryColor.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Text(
          isUnavailable ? "غير متوفر" : (isOnShipment ? "شحن" : "إضافة للسلة"),
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(35),
            decoration: BoxDecoration(
              color: kSecondaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_outline_rounded,
              size: 100,
              color: kSecondaryColor,
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            "قائمة الأمنيات فارغة",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kTextColor),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 45),
            child: Text(
              "لم تقم بإضافة أي منتج لمفضلاتك بعد. تسوق الآن واحفظ ما يعجبك هنا!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: () {
                Get.back(); // Close Wishlist
                Get.find<MainController>().onTabTapped(0); // Switch to Home
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 0,
              ),
              child: const Text('اكتشف المنتجات', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
