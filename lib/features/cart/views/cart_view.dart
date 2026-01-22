import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bytore/core/components/custom_image.dart';
import 'package:bytore/core/controllers/cart_controller.dart';
import 'package:bytore/core/constants/constants.dart';
import 'package:bytore/features/checkout/views/address_page.dart';
import 'package:bytore/features/authentication/views/login_view.dart';
import 'package:bytore/core/controllers/app_controller.dart';

class CartView extends StatefulWidget {
  final VoidCallback? onReturnHome;

  const CartView({super.key, this.onReturnHome});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  final double shippingCost = 500.0;

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();
    final appController = Get.find<AppController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text('سلة التسوق',
            style: TextStyle(color: kTextColor, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: kTextColor, size: 20),
          onPressed: () {
            if (widget.onReturnHome != null) {
              widget.onReturnHome!();
            } else {
              Get.back();
            }
          },
        ),
      ),
      body: Obx(() => cart.items.isEmpty
          ? _buildEmptyCart()
          : Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildGroupHeader("المنتجات المختارة", cart.items.length),
                ...cart.items.entries.map((entry) {
                  return _buildCartItem(context, entry.value, entry.key, cart);
                }).toList(),
              ],
            ),
          ),
          _buildCompactCheckoutSection(context, cart, appController),
        ],
      )),
    );
  }

  // --- 1. تنسيق السلة الفارغة ---
  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(35),
            decoration: BoxDecoration(
              color: kSecondaryColor.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shopping_cart_outlined, size: 80, color: kSecondaryColor),
          ),
          const SizedBox(height: 25),
          const Text("سلة التسوق فارغة", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kTextColor)),
          const SizedBox(height: 10),
          const Text("ابدأ باستكشاف أفضل العروض المتاحة الآن!", textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => widget.onReturnHome != null ? widget.onReturnHome!() : Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15), elevation: 0),
            child: const Text("ابدأ التسوق", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- 2. عنصر السلة مع منطق تبديل (حذف / -) ---
  Widget _buildCartItem(BuildContext context, CartItem item, int productId, CartController cart) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CustomImage(
              imageUrl: item.product.imageUrl, 
              width: 75, 
              height: 75, 
              fit: BoxFit.cover
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: kTextColor), maxLines: 1),
                const SizedBox(height: 8),
                Obx(() => Text(
                  Get.find<AppController>().getFormattedPrice(item.product.price), 
                  style: const TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w900, fontSize: 16)
                )),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: const Color(0xFFF5F6F8), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                item.quantity.value == 1
                    ? _buildActionBtn(Icons.delete_outline_rounded, () => cart.removeItem(productId), isDelete: true)
                    : _buildActionBtn(Icons.remove, () => cart.decrementOrRemoveItem(productId)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Obx(() => Text('${item.quantity.value}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                ),
                _buildActionBtn(Icons.add, () => cart.incrementItem(productId)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(IconData icon, VoidCallback onTap, {bool isDelete = false}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2)],
        ),
        child: Icon(icon, size: 16, color: isDelete ? Colors.red : kPrimaryColor),
      ),
    );
  }

  // --- 3. قسم الدفع المحدث (تاريخ التوصيل، المسميات، وزر المتابعة) ---
  Widget _buildCompactCheckoutSection(BuildContext context, CartController cart, AppController appController) {
    double totalWithShipping = cart.totalAmount + shippingCost;
    String priceLabel = cart.items.length > 1 ? "سعر المنتجات" : "سعر المنتج";

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, -5)
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.03),
                borderRadius: BorderRadius.circular(15)
            ),
            child: Column(
              children: [
                _buildPriceRow(priceLabel, appController.getFormattedPrice(cart.totalAmount)),
                const SizedBox(height: 10),
                _buildPriceRow("تكلفة الشحن", appController.getFormattedPrice(shippingCost)),
                const Divider(height: 20, thickness: 0.5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        "تاريخ التوصيل المتوقع",
                        style: TextStyle(color: kTextColor.withOpacity(0.6), fontSize: 12)
                    ),
                    const Text(
                        "خلال 3 - 5 أيام",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.green)
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("الإجمالي النهائي", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text(
                      appController.getFormattedPrice(totalWithShipping),
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: kTextColor)
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  if (appController.isLoggedIn.value) {
                    Get.to(() => const AddressPage());
                  } else {
                    Get.to(() => LoginView(redirectToAddress: true));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                        'متابعة الشراء',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: kTextColor.withOpacity(0.6), fontSize: 13)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: kTextColor)),
      ],
    );
  }

  Widget _buildGroupHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 10,
            backgroundColor: kPrimaryColor.withOpacity(0.1),
            child: Text("$count", style: const TextStyle(color: kPrimaryColor, fontSize: 10, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}
