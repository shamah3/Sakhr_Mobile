import 'package:flutter/material.dart';
import 'package:bytore/core/constants/constants.dart';
import 'package:bytore/features/product/models/product_model.dart';
import 'package:bytore/core/components/custom_image.dart';
import 'package:bytore/features/product/views/product_detail_view.dart';
import 'package:get/get.dart';
import 'package:bytore/core/controllers/cart_controller.dart';
import 'package:bytore/core/controllers/app_controller.dart';
import 'package:bytore/core/utils/notification_helper.dart';

class ItemCard extends StatelessWidget {
  final Product product;
  final bool isWishlisted;
  final VoidCallback? onWishlistToggle;
  final bool isCompact;
  
  const ItemCard({
    super.key, 
    required this.product, 
    this.isWishlisted = false,
    this.onWishlistToggle,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    final cartController = Get.find<CartController>();

    return GestureDetector(
      onTap: () => Get.to(() => ProductDetailView(product: product)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              spreadRadius: 0,
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Product Image Section (Crystal Clean)
            Padding(
              padding: const EdgeInsets.all(8.0), // Reduced from 12
              child: Container(
                height: isCompact ? 100 : 120, // Reduced from 110/130
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    // Main Image
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: CustomImage(
                          imageUrl: product.imageUrl,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    
                    // Wishlist Button (Minimalist)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: GestureDetector(
                        onTap: onWishlistToggle,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Obx(() {
                            final favorite = appController.isWishlisted(product.id);
                            return Icon(
                              favorite ? Icons.favorite : Icons.favorite_border,
                              color: favorite ? Colors.redAccent : Colors.grey.shade400,
                              size: 16,
                            );
                          }),
                        ),
                      ),
                    ),
                    
                    // Discount Badge (Modern Pill)
                    if (product.id % 2 == 0)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: kPrimaryColor.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "-15%",
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Content Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Brand & Name
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.brandName.toUpperCase(),
                          style: TextStyle(
                            fontSize: 8, // Reduced from 9
                            letterSpacing: 0.6,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12, // Reduced from 13
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),

                    // Price & Action
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Obx(() => FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  appController.getFormattedPrice(product.price),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                              )),
                              if (product.oldPrice > product.price)
                                Obx(() => Text(
                                  appController.getFormattedPrice(product.oldPrice),
                                  style: TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    fontSize: 10,
                                    color: Colors.grey.shade400,
                                  ),
                                )),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        
                        // Action Button (Buy/Price combo look)
                        GestureDetector(
                          onTap: () {
                            if (product.stock == 0) return;
                            cartController.addItem(product);
                            NotificationHelper.showCustomSnackBar(context, "تمت الإضافة للسلة", isError: false);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: product.stock == 0 ? Colors.grey.shade200 : kPrimaryColor,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.add_shopping_cart_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
