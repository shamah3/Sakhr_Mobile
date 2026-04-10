
import 'package:flutter/material.dart';
import 'package:bytore/core/constants/constants.dart';
import 'package:bytore/features/product/models/product_model.dart';
import 'package:get/get.dart';
import 'package:bytore/core/components/custom_image.dart';
import 'package:bytore/core/controllers/cart_controller.dart';
import 'package:bytore/core/components/currency_switcher.dart';
import 'package:bytore/core/controllers/app_controller.dart';
import 'package:bytore/features/home/views/components/item_card.dart';
import 'package:bytore/core/utils/notification_helper.dart';
import 'package:bytore/features/product/views/product_list_view.dart';
import 'package:bytore/features/product/controllers/product_controller.dart';
import 'package:bytore/features/product/views/components/three_d_viewer.dart';
import 'package:bytore/core/components/custom_app_bar.dart';
// إضافة مكتبة الـ 3D
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:bytore/features/chat/views/chat_detail_view.dart';

class ProductDetailView extends StatelessWidget {
  final Product product;

// المتغير المسؤول عن التبديل اليدوي للـ 3D
  final RxBool isManual3DActive = false.obs;

  ProductDetailView({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProductController(product: product), tag: product.id.toString());
    final appController = Get.find<AppController>();
    final cartController = Get.find<CartController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: "تفاصيل المنتج",
        showBackArrow: true,
        actions: [
          Obx(() => IconButton(
            onPressed: () => appController.toggleWishlist(product.id),
            icon: Icon(
              appController.isWishlisted(product.id) ? Icons.favorite : Icons.favorite_border,
              color: appController.isWishlisted(product.id) ? Colors.orange : kPrimaryColor,
            ),
          )),
          const SizedBox(width: 10),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: 350,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Obx(() {
// أولاً: التحقق إذا كان المستخدم ضغط على زر الـ 3D اليدوي (فقط للملفات المحددة يدوياً)
                    if (isManual3DActive.value && 
                        product.threeDModel != null && 
                        product.threeDModel!.startsWith('assets/')) {
                      return ModelViewer(
                        src: product.threeDModel!,
                        autoRotate: true,
                        cameraControls: true,
                        backgroundColor: Colors.transparent,
                      );
                    }
// ثانياً: العرض التلقائي إذا كانت الصور 3D موجودة في الموديل
                    else if (product.threeDImages.isNotEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: ThreeDProductViewer(images: product.threeDImages, height: 280),
                      );
                    }
// ثالثاً: عرض الصور العادية
                    else {
                      return PageView.builder(
                        controller: controller.pageController,
                        onPageChanged: (index) => controller.currentImageIndex.value = index,
                        itemCount: controller.productImages.length,
                        itemBuilder: (context, index) => Container(
                          padding: const EdgeInsets.all(40),
                          child: CustomImage(
                            imageUrl: controller.productImages[index],
                            fit: BoxFit.contain,
                            width: double.infinity,
                          ),
                        ),
                      );
                    }
                  }),


                  // الزر يظهر فقط للمنتجات التي نملك لها ملف 3D محلي (أهم تعديل لطلبك)
                  if (product.threeDModel != null && product.threeDModel!.startsWith('assets/'))
                    Positioned(
                      top: 10,
                      left: 20,
                      child: Obx(() => ActionChip(
                        onPressed: () => isManual3DActive.toggle(),
                        label: Text(isManual3DActive.value ? "عرض الصور" : "عرض 3D",
                            style: const TextStyle(fontSize: 10, color: Colors.white)),
                        backgroundColor: kPrimaryColor,
                        avatar: Icon(isManual3DActive.value ? Icons.image : Icons.view_in_ar,
                            size: 14, color: Colors.white),
                      )),
                    ),

                  if (product.threeDImages.isEmpty && !isManual3DActive.value)
                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Obx(() => Text(
                          "${controller.currentImageIndex.value + 1}/${controller.productImages.length}",
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        )),
                      ),
                    ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPremiumHeader(controller, appController),
                  const SizedBox(height: 25),
                  _buildStatsRow(),
                  const SizedBox(height: 25),
                  _buildServiceSection(context),
                  const SizedBox(height: 30),

                  if (product.colors != null || product.sizes != null) ...[
                    _buildVariantSection(controller),
                    const SizedBox(height: 30),
                  ],

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("الكمية المطلوبة", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: kTextColor)),
                      _buildQuantityCounter(controller),
                    ],
                  ),
                  const SizedBox(height: 35),

                  const Text("عن المنتج", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: kTextColor)),
                  const SizedBox(height: 12),
                  Text(
                    product.description.isNotEmpty ? product.description : "هذا المنتج يوفر لك تجربة فريدة بجودة خامات عالية وتصميم مريح للاستخدام اليومي المكثف مع مراعاة أدق التفاصيل.",
                    style: TextStyle(fontSize: 14, color: Colors.black.withOpacity(0.6), height: 1.7),
                  ),

                  if (product.attributes.isNotEmpty && 
                      (product.category.toLowerCase().contains('laptop') || 
                       product.category.toLowerCase().contains('طابعات') ||
                       product.category.toLowerCase().contains('سماعات') ||
                       product.brandName.toLowerCase().contains('apple'))) ...[
                    const SizedBox(height: 35),
                    _buildPremiumTechSpecsGrid(),
                  ],

                  const SizedBox(height: 30),
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

// --- جميع الدوال المساعدة (نفس كودك الأصلي تماماً دون أي تعديل) ---

  Widget _buildPremiumHeader(ProductController controller, AppController appController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,


      children: [
        Directionality(
          textDirection: controller.getDirection(product.name),
          child: Text(
            product.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: kTextColor, height: 1.2),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Obx(() => Text(
                        appController.getFormattedPrice(controller.currentPrice),
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: kPrimaryColor),
                      )),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Obx(() => product.oldPrice > controller.currentPrice
                      ? Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        appController.getFormattedPrice(product.oldPrice),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ),
                  )
                      : const SizedBox.shrink()),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const CurrencySwitcher(),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatBadge(Icons.star_rounded, "${product.rating}", Colors.amber),
        const SizedBox(width: 12),
        _buildStatBadge(Icons.shopping_bag_rounded, "${product.buyerCount} تم شراؤه", Colors.blueGrey),
      ],
    );
  }

  Widget _buildStatBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color.withOpacity(0.9)),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceSection(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildServiceChip(
            icon: Icons.shield_outlined,
            label: "ضمان ${product.warranty}",
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildServiceChip(
            icon: Icons.local_shipping_outlined,
            label: product.deliveryTime.isNotEmpty ? product.deliveryTime : "توصيل سريع",
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () {
              Get.to(() => const ChatDetailView(), arguments: {
                'storeId': product.storeId,
                'senderName': product.storeName,
              });
            },
            child: _buildServiceChip(
              icon: Icons.chat_bubble_outline_rounded,
              label: "مراسلة المتجر",
              color: kSecondaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceChip({required IconData icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100, width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: kTextColor),
          ),
        ],
      ),
    );
  }

  Widget _buildVariantSection(ProductController controller) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (product.colors != null) ...[
            const Text("الألوان المتاحة", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kTextColor)),
            const SizedBox(height: 12),
            _buildColorSelector(controller),
            const SizedBox(height: 20),
          ],
          if (product.sizes != null) ...[
            const Text("المواصفات المختارة", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kTextColor)),
            const SizedBox(height: 12),
            _buildSizeSelector(controller),
          ],
        ],
      ),
    );
  }

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
                _buildDynamicSpecsTable(),
                _buildCommentsSummary(context),
                _buildRecommendations(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumTechSpecsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("المواصفات التقنية الفائقة", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: kTextColor)),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.8,
          ),
          itemCount: product.attributes.length,
          itemBuilder: (context, index) {
            String key = product.attributes.keys.elementAt(index);
            String value = product.attributes[key]!;
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade100),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(key, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: kTextColor), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDynamicSpecsTable() {
    if (product.attributes.isEmpty) {
      return ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 15),
        children: [
          _specRow("الماركة", product.brandName),
          _specRow("الضمان", product.warranty),
          _specRow("التوصيل", product.deliveryTime),
        ],
      );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 15),
      itemCount: product.attributes.length,
      itemBuilder: (context, index) {
        String key = product.attributes.keys.elementAt(index);
        String value = product.attributes[key]!;
        return _specRow(key, value);
      },
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
      builder: (context) => Container(
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
            const SizedBox(height: 20),
          ],
        ),
      ),
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
                child: CustomImage(
                  imageUrl: c['image'],
                  width: 30,
                  height: 30,
                  fit: BoxFit.cover,
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
          IconButton(onPressed: () => controller.incrementQuantity(), icon: const Icon(Icons.add, size: 16, color: kSecondaryColor)),
          Obx(() => Text("${controller.quantity.value}", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kTextColor))),
          IconButton(onPressed: () => controller.decrementQuantity(), icon: const Icon(Icons.remove, size: 16, color: kSecondaryColor)),
        ],
      ),
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
            imageUrl: "https://images.unsplash.com/photo-1546435770-a3e426bf472b?q=80&w=2065&auto=format&fit=crop"
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(offset: const Offset(0, -10), blurRadius: 20, color: Colors.black.withOpacity(0.04))],
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(35), topRight: Radius.circular(35)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("السعر النهائي", style: TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 2),
                  Obx(() => Text(
                    appController.getFormattedPrice(controller.currentPrice),


                    style: const TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w900, fontSize: 24),
                  )),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 3,
              child: ElevatedButton(
                onPressed: () {
                  if (isUnavailable || isOnShipment) return;
                  cartController.addItem(product);
                  appController.addNotification(title: "تمت الإضافة للسلة", body: "تم إضافة المنتج بنجاح", color: kPrimaryColor);
                  NotificationHelper.showCustomSnackBar(context, "تمت الإضافة للسلة بنجاح", isError: false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: (isUnavailable || isOnShipment) ? Colors.grey : kPrimaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: Text(isUnavailable ? "غير متوفر" : (isOnShipment ? "قيد الشحن" : "إضافة للسلة"),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}