import 'package:flutter/material.dart';
import 'package:bytore/core/constants/constants.dart';
import 'package:bytore/features/product/models/product_model.dart';
import 'package:get/get.dart';
import 'package:bytore/core/controllers/cart_controller.dart';
import 'package:bytore/core/components/currency_switcher.dart';
import 'package:bytore/core/controllers/app_controller.dart';
import 'package:bytore/features/home/views/components/item_card.dart';
import 'package:bytore/core/utils/notification_helper.dart';
import 'package:bytore/features/product/views/product_list_view.dart';
import 'package:bytore/features/product/controllers/product_controller.dart';



class ProductDetailView extends StatelessWidget {
  final Product product;
  const ProductDetailView({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // Initialize controller for this specific product
    final controller = Get.put(ProductController(product: product), tag: product.id.toString());
    final appController = Get.find<AppController>();
    final cartController = Get.find<CartController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 350,
            title: const Text(
              "تفاصيل المنتج",
              style: TextStyle(color: kTextColor, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            centerTitle: true,
            leading: _buildHeaderBtn(Icons.arrow_back_ios_new, () => Get.back()),
            actions: [
              Obx(() => _buildHeaderBtn(
                appController.isWishlisted(product.id) ? Icons.favorite : Icons.favorite_border,
                    () => appController.toggleWishlist(product.id),
                color: appController.isWishlisted(product.id) ? Colors.orange : kPrimaryColor,
              )),
              const SizedBox(width: 10),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Obx(() => Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  PageView.builder(
                    controller: controller.pageController,
                    onPageChanged: (index) => controller.currentImageIndex.value = index,
                    itemCount: controller.productImages.length,
                    itemBuilder: (context, index) => Container(
                      padding: const EdgeInsets.all(40),
                      child: Image.network(controller.productImages[index], fit: BoxFit.contain),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        "${controller.currentImageIndex.value + 1}/${controller.productImages.length}",
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  // Thumbnails removed as per request
                  const SizedBox.shrink(),
                ],
              )),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Directionality(
                    textDirection: controller.getDirection(product.name),
                    child: Text(
                      product.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: kTextColor),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        "${product.rating}",
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "(${product.buyerCount} تم شراؤه)",
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Obx(() => Text(appController.getFormattedPrice(controller.currentPrice), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: kPrimaryColor))),
                      const SizedBox(width: 15),
                      Obx(() => product.oldPrice > controller.currentPrice
                        ? Text(appController.getFormattedPrice(product.oldPrice), style: const TextStyle(fontSize: 14, color: Colors.grey, decoration: TextDecoration.lineThrough))
                        : const SizedBox.shrink()),
                      const Spacer(),
                      if (product.colors != null) _buildColorSelector(controller),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (product.sizes != null) ...[
                    const Text("المقاس/الحجم:", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildSizeSelector(controller),
                    const SizedBox(height: 15),
                  ],
                  Text(
                    product.stock == 0 ? "حالة المنتج: غير متوفر" : (product.status == 'On Shipment' ? "حالة المنتج: قيد الشحن" : "حالة المنتج: متوفر"),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: product.stock == 0 ? Colors.red : (product.status == 'On Shipment' ? Colors.blue : Colors.green),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildQuantityCounter(controller),
                      _buildMetaInfo(context, appController),
                    ],
                  ),
                  const SizedBox(height: 25),
                  const Text("تفاصيل المنتج", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: kTextColor)), // Added as specific request
                  const SizedBox(height: 10),
                  const Text("وصف المنتج:", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  const Text(
                    "هذا المنتج يوفر لك تجربة فريدة بجودة خامات عالية وتصميم مريح للاستخدام اليومي المكثف مع مراعاة أدق التفاصيل.",
                    style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 25),
                  _buildDetailedTabs(context),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context, appController, cartController, controller),
    );
  }

  // --- دوال بناء التبويبات والمحتوى المنبثق ---

  Widget _buildDetailedTabs(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            labelColor: kPrimaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: kSecondaryColor,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: [Tab(text: "المواصفات"), Tab(text: "التعليقات"), Tab(text: "منتجات مشابهة")],
          ),
          SizedBox(
            height: 350,
            child: TabBarView(
              children: [
                _buildSpecsTable(),
                _buildCommentsSummary(context),
                _buildRecommendations(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsSummary(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 15),
      children: [
        _commentTile("أحمد منصور", "الجودة ممتازة جداً والتوصيل كان سريعاً!", 5),
        _commentTile("سارة علي", "تصميم مريح جداً للاستخدام اليومي.", 4),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: () => _showAllReviewsSheet(context),
          style: OutlinedButton.styleFrom(side: const BorderSide(color: kSecondaryColor)),
          child: const Text("عرض المزيد", style: TextStyle(color: kSecondaryColor, fontWeight: FontWeight.bold)),
        )
      ],
    );
  }

  void _showAllReviewsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              const Text("المراجعات والتعليقات", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(height: 30),
              Expanded(
                child: ListView.builder(
                  itemCount: 5,
                  itemBuilder: (context, index) => _commentTile("مستخدم ${index + 1}", "تجربة ممتازة وجودة تستحق السعر.", 5),
                ),
              ),
                  const Divider(),
                  // Writing review section removed as per request
                  const SizedBox(height: 20),
                ],
              ),
        ),
      ),
    );
  }

  Widget _buildMetaInfo(BuildContext context, AppController appController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(product.warranty, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: kTextColor)),
            const SizedBox(width: 8),
            const Icon(Icons.verified_user_outlined, size: 16, color: Colors.orange),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text("التوصيل: ${product.deliveryTime}", style: const TextStyle(fontSize: 11, color: kTextColor, fontWeight: FontWeight.w500)),
            const SizedBox(width: 8),
            const Icon(Icons.local_shipping_outlined, size: 14, color: Colors.orange),
          ],
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () {
            Get.to(() => ProductListView(
              categoryTitle: product.storeName,
              apiCategorySlug: 'all', 
            ));
          },
          child: Text(
            "متجر: ${product.storeName}", 
            style: const TextStyle(
              fontSize: 12, 
              color: kSecondaryColor, 
              fontWeight: FontWeight.bold,
            )
          ),
        ),
        const SizedBox(height: 10),
        const CurrencySwitcher(),
      ],
    );
  }

  Widget _buildDot(int index, ProductController controller) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8, width: controller.currentImageIndex.value == index ? 20 : 8,
      decoration: BoxDecoration(color: controller.currentImageIndex.value == index ? kPrimaryColor : Colors.grey[300], borderRadius: BorderRadius.circular(4)),
    );
  }

  Widget _buildColorSelector(ProductController controller) {
    return Row(
      children: (product.colors ?? []).map((c) {
        return Obx(() {
          bool isSelected = controller.selectedColor.value == c;
          return GestureDetector(
            onTap: () => controller.updateColor(c),
            child: Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isSelected ? kPrimaryColor : Colors.grey[200]!, width: 2)
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  c['image'],
                  width: 30,
                  height: 30,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => CircleAvatar(radius: 15, backgroundColor: Color(c['colorCode'])),
                ),
              ),
            ),
          );
        });
      }).toList(),
    );
  }

  Widget _buildSizeSelector(ProductController controller) {
    return Row(
      children: (product.sizes ?? []).map((s) {
        return Obx(() {
          bool isSelected = controller.selectedSize.value == s;
          return GestureDetector(
            onTap: () => controller.updateSize(s),
            child: Container(
              margin: const EdgeInsets.only(left: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? kPrimaryColor.withOpacity(0.1) : Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isSelected ? kPrimaryColor : Colors.grey.shade300,
                  width: isSelected ? 1.5 : 1
                ),
              ),
              child: Text(
                s['name'],
                style: TextStyle(
                  color: isSelected ? kPrimaryColor : kTextColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13
                ),
              ),
            ),
          );
        });
      }).toList(),
    );
  }

  Widget _buildQuantityCounter(ProductController controller) {
    return Container(
      height: 40, decoration: BoxDecoration(color: const Color(0xFFF1F4F7), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          IconButton(onPressed: () => controller.incrementQuantity(), icon: const Icon(Icons.add, size: 20, color: kSecondaryColor)),
          Obx(() => Text("${controller.quantity.value}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
          IconButton(onPressed: () => controller.decrementQuantity(), icon: const Icon(Icons.remove, size: 20, color: kPrimaryColor)),
        ],
      ),
    );
  }

  Widget _buildHeaderBtn(IconData icon, VoidCallback onTap, {Color? color}) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: IconButton(onPressed: onTap, icon: Icon(icon, color: color ?? kPrimaryColor, size: 20)),
    );
  }

  Widget _buildSpecsTable() {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 15),
      children: [
        _specRow("الماركة", "Bytore Line"),
        _specRow("الوزن", "0.85 KG"),
        _specRow("الخامة", "كربون مقوى"),
      ],
    );
  }

  Widget _specRow(String t, String v) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(t, style: const TextStyle(color: Colors.grey, fontSize: 14)), Text(v, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))],
      ),
    );
  }

  Widget _commentTile(String name, String comment, int rating) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF8F9FB), borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Row(children: List.generate(5, (index) => Icon(Icons.star, size: 14, color: index < rating ? Colors.orange : Colors.grey[300]))),
            ],
          ),
          const SizedBox(height: 5),
          Text(comment, style: const TextStyle(color: Colors.black54, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildRecommendations() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      itemCount: 4,
      itemBuilder: (context, index) {
        final mockProduct = Product(
           id: 100 + index, 
           name: index % 2 == 0 ? "سماعة بلوتوث برو" : "شاحن سريع 65W", 
           price: (index % 2 == 0 ? 150 : 45).toDouble(), 
           oldPrice: (index % 2 == 0 ? 180 : 55).toDouble(),
           description: "وصف مختصر للمنتج المقترح", 
           brandName: "Bytore Accessories", 
           stock: 10,
           status: "New",
           warranty: "1 Year",
           deliveryTime: "3-5 days",
           imageUrl: index % 2 == 0 
              ? "https://images.unsplash.com/photo-1546435770-a3e426bf472b?q=80&w=2065&auto=format&fit=crop" 
              : "https://images.unsplash.com/photo-1583863788434-e58a36330cf0?q=80&w=1974&auto=format&fit=crop"
        );
        
        return Container(
          width: 160,
          margin: const EdgeInsets.only(left: 15),
          child: Obx(() {
            final appController = Get.find<AppController>();
            return ItemCard(
              product: mockProduct,
              isWishlisted: appController.isWishlisted(mockProduct.id),
              onWishlistToggle: () => appController.toggleWishlist(mockProduct.id),
            );
          }),  
        );
      },
    );
  }

  Widget _buildBottomBar(BuildContext context, AppController appController, CartController cartController, ProductController controller) {
    bool isUnavailable = product.stock == 0;
    bool isOnShipment = product.status == 'On Shipment';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -5),
            blurRadius: 20,
            color: Colors.black.withOpacity(0.05),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "السعر الإجمالي",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Obx(() => Text(
                  appController.getFormattedPrice(controller.currentPrice),
                  style: const TextStyle(
                    color: kPrimaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                )),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (isUnavailable) {
                    NotificationHelper.showCustomSnackBar(context, "عذراً، هذا المنتج غير متوفر حالياً ولا يمكن إضافته للسلة.", isError: true);
                    return;
                  }
                  if (isOnShipment) {
                    NotificationHelper.showCustomSnackBar(context, "هذا المنتج قيد الشحن حالياً ولا يمكن طلبه حتى يصل.", isError: false);
                    return;
                  }

                  cartController.addItem(product);
                  
                  appController.addNotification(
                    title: "تمت الإضافة للسلة",
                    body: "تم إضافة ${product.name} إلى سلة المشتريات (العدد: ${cartController.totalQuantity})",
                    color: kPrimaryColor,
                  );
                  
                  NotificationHelper.showCustomSnackBar(
                    context, 
                    "تمت الإضافة للسلة بنجاح (في السلة: ${cartController.totalQuantity})",
                    isError: false
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: (isUnavailable || isOnShipment) ? Colors.grey : kPrimaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isUnavailable ? Icons.block : (isOnShipment ? Icons.local_shipping : Icons.shopping_bag_outlined),
                      color: Colors.white
                    ),
                    const SizedBox(width: 10),
                    Text(
                      isUnavailable ? "غير متوفر" : (isOnShipment ? "قيد الشحن" : "إضافة للسلة"),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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
