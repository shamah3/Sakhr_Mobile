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
  final bool isCompact; // Added for adaptive height
  
  const ItemCard({
    super.key, 
    required this.product, 
    this.isWishlisted = false,
    this.onWishlistToggle,
    this.isCompact = false, // Default is false (used for Home)
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
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 0,
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Stack(
              children: [
                // Product Image Container
                Container(
                  height: isCompact ? 90 : 100, // Reduced to fit more content below
                  width: double.infinity,
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade100, width: 1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: CustomImage(
                        imageUrl: product.imageUrl,
                        fit: BoxFit.contain,
                        width: double.infinity,
                      ),
                    ),
                  ),
                ),
                // Discount Badge (Top Right)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "${(product.id * 7 + 10) % 30 + 5}%",
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                // Wishlist Icon (Top Left)
                Positioned(
                  top: 10,
                  left: 10,
                  child: GestureDetector(
                    onTap: onWishlistToggle,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 12,
                      child: Obx(() => Icon(
                        appController.isWishlisted(product.id) ? Icons.favorite : Icons.favorite_border,
                        color: appController.isWishlisted(product.id) ? kSecondaryColor : Colors.grey,
                        size: 14,
                      )),
                    ),
                  ),
                ),
              ],
            ),
            // Main Content with Opacity if unavailable
            // Use Expanded to fill remaining vertical space and avoid overflow
            Expanded(
              child: Opacity(
                opacity: product.stock == 0 ? 0.6 : 1.0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribute space
                    children: [
                      // Product Name
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isCompact ? 11 : 12,
                          color: kTextColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      
                      // Short Description (2 lines)
                      SizedBox(
                        height: 28, // Fix height for 2 lines
                        child: Text(
                          product.shortDescription.isNotEmpty ? product.shortDescription : product.name,
                          style: TextStyle(fontSize: 10, color: Colors.black.withOpacity(0.5), height: 1.2),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Combined Status and Stock row to save space
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            product.stock == 0 ? "غير متوفر" : (product.status == 'On Shipment' ? "قيد الشحن" : "متوفر"),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: product.stock == 0 ? Colors.red : (product.status == 'On Shipment' ? Colors.blue : Colors.green),
                            ),
                          ),
                          Text(
                            "المخزون: ${product.stock}",
                            style: TextStyle(fontSize: 9, color: product.stock < 5 ? Colors.red.shade700 : Colors.green.shade700, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      
                      // Rating
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            "${product.rating}",
                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black54),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "(${product.buyerCount} مبيع)",
                              style: const TextStyle(fontSize: 8, color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      
                      const Spacer(), // Push bottom elements down

                      // Attributes (Simplified to 1 line)
                      if (product.attributes.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            product.attributes.entries.take(2).map((e) => "${e.key}: ${e.value}").join(" | "),
                            style: TextStyle(fontSize: 7.5, color: Colors.grey.shade600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      const SizedBox(height: 2),

                      // Price and Cart
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Obx(() => Text(
                                appController.getFormattedPrice(product.price),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: kPrimaryColor,
                                ),
                              )),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              if (product.stock == 0) {
                                NotificationHelper.showCustomSnackBar(context, "هذا المنتج غير متوفر", isError: false);
                                return;
                              }
                              if (product.status == 'On Shipment') {
                                NotificationHelper.showCustomSnackBar(context, "هذا المنتج قيد الشحن حالياً", isError: false);
                                return;
                              }

                              cartController.addItem(product);

                              NotificationHelper.showCustomSnackBar(
                                context,
                                "تمت الإضافة للسلة (في السلة: ${cartController.totalQuantity})",
                                isError: false,
                              );

                              appController.addNotification(
                                title: "تمت الإضافة للسلة",
                                body: "تم إضافة ${product.name} (عدد العناصر: ${cartController.totalQuantity})",
                                color: kPrimaryColor,
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.all(isCompact ? 6 : 8),
                              decoration: BoxDecoration(
                                color: (product.stock == 0 || product.status == 'On Shipment') ? Colors.grey.shade300 : kPrimaryColor,
                                borderRadius: BorderRadius.circular(isCompact ? 8 : 10),
                                boxShadow: [BoxShadow(color: kPrimaryColor.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
                              ),
                              child: Icon(Icons.shopping_cart_outlined, color: Colors.white, size: isCompact ? 16 : 18),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 2),

                      // Footer: Warranty and Delivery
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.verified_user_outlined, size: 8, color: Colors.orange), // Reduced size
                                const SizedBox(width: 2),
                                Flexible(
                                  child: Text(
                                    product.warranty,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 7.5, color: Colors.black87, fontWeight: FontWeight.bold), // Reduced font
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.local_shipping_outlined, size: 8, color: Colors.orange), // Reduced size
                                const SizedBox(width: 2),
                                Flexible(
                                  child: Text(
                                    product.deliveryTime,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 7.5, color: Colors.black87, fontWeight: FontWeight.bold), // Reduced font
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

