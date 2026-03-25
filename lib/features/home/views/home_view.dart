import 'package:flutter/material.dart';
import 'package:bytore/features/home/views/components/filter_bottom_sheet.dart';
import 'package:bytore/core/components/custom_image.dart';
import 'package:bytore/core/components/currency_switcher.dart';
import 'package:flutter/services.dart';
import 'package:bytore/features/wishlist/views/wishlist_view.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:bytore/features/home/views/components/item_card.dart';
import 'package:bytore/core/constants/constants.dart';
import 'package:get/get.dart';
import 'package:bytore/core/controllers/app_controller.dart';
import 'package:bytore/features/home/controllers/home_controller.dart';
import 'package:bytore/features/home/controllers/categories_controller.dart';
import 'package:bytore/features/product/views/product_list_view.dart';
import 'package:bytore/features/notifications/views/notification_view.dart';
import 'package:bytore/features/search/views/search_view.dart';
import 'package:bytore/core/routes/app_routes.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    // لا نحتاج لتعريف الكنترولر مرة أخرى لأننا نستخدم GetView<HomeController>
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(context, appController),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPillSearchBar(),
                    const SizedBox(height: 24),
                    _buildBlueBanner(),
                    const SizedBox(height: 24),
                    _buildSectionHeader("الأقسام"),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),
            _buildCategoriesSection(appController),
            const SliverToBoxAdapter(child: SizedBox(height: 35)),

            // إصلاح: Obx هنا تراقب دالة isFilterActive التي يجب أن تعتمد على متغير .obs
            Obx(() => controller.isFilterActive()
                ? _buildProductsGrid(appController)
                : SliverList(
              delegate: SliverChildListDelegate([
                _buildStandardSections(context, appController),
              ]),
            ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildStandardSections(BuildContext context, AppController appController) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              _buildSectionHeader("المنتجات الأكثر طلباً", showViewAll: true, onTap: () {
                Get.toNamed(AppRoutes.PRODUCT_LIST, arguments: {'categoryTitle': "الأكثر طلباً", 'apiCategorySlug': 'all'}, id: 1);
              }),
              const SizedBox(height: 15),
            ],
          ),
        ),
        _buildHorizontalProductList("الكل", appController),

        const SizedBox(height: 35),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              _buildSectionHeader("وصل حديثاً", showViewAll: true, onTap: () {
                Get.toNamed(AppRoutes.PRODUCT_LIST, arguments: {'categoryTitle': "وصل حديثاً", 'apiCategorySlug': 'in_stock'}, id: 1);
              }),
              const SizedBox(height: 18),
            ],
          ),
        ),
        _buildHorizontalProductList("In Stock", appController),

        const SizedBox(height: 35),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              _buildSectionHeader("الخصومات", showViewAll: true, onTap: () {
                Get.toNamed(AppRoutes.PRODUCT_LIST, arguments: {'categoryTitle': "الخصومات", 'apiCategorySlug': 'discounts'}, id: 1);
              }),
              const SizedBox(height: 18),
            ],
          ),
        ),
        _buildHorizontalProductList("الخصومات", appController),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context, AppController appController) {
    return SliverToBoxAdapter(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 20),
              child: CurrencySwitcher(),
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () => Get.to(() => const WishlistView()),
                  child: Container(
                    margin: const EdgeInsets.only(left: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: kBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(Icons.favorite_outline_rounded, color: kTextColor, size: 22),
                        Obx(() => appController.wishlistIds.isNotEmpty
                            ? Positioned(
                          right: -2, top: -2,
                          child: Container(
                              width: 10, height: 10,
                              decoration: BoxDecoration(
                                  color: kSecondaryColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 1.5)
                              )
                          ),
                        )
                            : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    appController.markNotificationsAsRead();
                    Get.to(() => const NotificationView());
                  },
                  child: Container(
                    margin: const EdgeInsets.only(left: 20, right: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: kBgColor, borderRadius: BorderRadius.circular(12)),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(Icons.notifications_none_rounded, color: kTextColor, size: 22),
                        Obx(() => appController.notificationCount > 0
                            ? Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            width: 11,
                            height: 11,
                            decoration: BoxDecoration(
                                color: kSecondaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                      color: kSecondaryColor.withOpacity(0.3),
                                      blurRadius: 4,
                                      spreadRadius: 1
                                  )
                                ]
                            ),
                          ),
                        )
                            : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPillSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.06 * 255).round()),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: kPrimaryColor, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: controller.searchController,
                    textAlign: TextAlign.right,
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        Get.to(() => SearchView(query: value));
                      }
                    },
                    decoration: const InputDecoration(
                      hintText: "ابحث عن اسم المنتج أو الوصف",
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                  ),
                ),
                VerticalDivider(width: 1, thickness: 1, color: Colors.grey.shade100, indent: 15, endIndent: 15),
                const SizedBox(width: 5),
                GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.AI_CHAT),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: kPrimaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.auto_awesome_rounded, color: kPrimaryColor, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => Get.bottomSheet(const FilterBottomSheet(), isScrollControlled: true),
          child: Container(
            height: 50, width: 50,
            decoration: BoxDecoration(
              color: kPrimaryColor,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: kPrimaryColor.withAlpha((0.3 * 255).round()),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.tune_rounded, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildBlueBanner() {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 180,
            viewportFraction: 1.0,
            autoPlay: true,
            enlargeCenterPage: false,
            onPageChanged: (index, reason) => controller.updateCarouselIndex(index),
          ),
          items: [1, 2, 3].map((i) {
            return GestureDetector(
              onTap: () {
                Get.dialog(
                  Dialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("عروض حصرية", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: CustomImage(
                              imageUrl: i == 1 
                              ? "https://images.unsplash.com/photo-1496181133206-80ce9b88a853?q=80&w=600&auto=format&fit=crop" 
                              : (i == 2 ? "https://images.unsplash.com/photo-1546435770-a3e426bf472b?q=80&w=600&auto=format&fit=crop" : "https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?q=80&w=600&auto=format&fit=crop"),
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            i == 1 ? "احصل على خصم 20% على جميع اللابتوبات!" : (i == 2 ? "اشتري ملحقين واحصل على الثالث مجاناً!" : "خصومات تصل إلى 50% على الأجهزة الذكية"),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              Get.back();
                              Get.toNamed(AppRoutes.PRODUCT_LIST, arguments: {'categoryTitle': 'الاعلانات', 'apiCategorySlug': 'all'}, id: 1);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                            ),
                            child: const Text("تصفح العروض", style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              child: Builder(
                builder: (BuildContext context) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [kPrimaryColor, kPrimaryColor.withAlpha((0.8 * 255).round())],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: 25, top: 0, bottom: 0,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                i == 1 ? "أقوى\nاللابتوبات" : (i == 2 ? "أفضل\nالملحقات" : "أجهزة\nذكية"),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 26, height: 1.1),
                              ),
                              const SizedBox(height: 15),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                decoration: BoxDecoration(color: kSecondaryColor, borderRadius: BorderRadius.circular(20)),
                                child: const Text("تسوق الآن", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          left: -10, bottom: 0, top: 0, width: 180,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(25), bottomLeft: Radius.circular(25)),
                            child: CustomImage(
                              imageUrl: i == 1 ? "https://images.unsplash.com/photo-1496181133206-80ce9b88a853?q=80&w=600&auto=format&fit=crop" : (i == 2 ? "https://images.unsplash.com/photo-1546435770-a3e426bf472b?q=80&w=600&auto=format&fit=crop" : "https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?q=80&w=600&auto=format&fit=crop"),
                              fit: i == 3 ? BoxFit.contain : BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [1, 2, 3].asMap().entries.map((entry) {
            return Container(
              width: controller.carouselIndex.value == entry.key ? 20.0 : 8.0,
              height: 8.0,
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: controller.carouselIndex.value == entry.key ? kSecondaryColor : Colors.grey.shade300,
              ),
            );
          }).toList(),
        )),
      ],
    );
  }

  Widget _buildHorizontalProductList(String category, AppController appController) {
    return Container(
      height: 280,
      margin: const EdgeInsets.only(bottom: 20),
      child: Obx(() {
        if (controller.isLoading.value && controller.allProducts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final products = controller.allProducts.where((p) =>
        category == "الكل" || p.status == category || p.name.contains(category)
        ).take(5).toList();

        final displayProducts = products.isEmpty ? controller.allProducts.take(5).toList() : products;

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: displayProducts.length,
          itemBuilder: (context, index) {
            final product = displayProducts[index];
            return Container(
              width: 180,
              margin: const EdgeInsets.only(left: 15),
              child: Obx(() => ItemCard(
                product: product,
                isWishlisted: appController.isWishlisted(product.id),
                onWishlistToggle: () => appController.toggleWishlist(product.id),
              )),
            );
          },
        );
      }),
    );
  }

  Widget _buildProductsGrid(AppController appController) {
    return Obx(() {
      if (controller.isLoading.value && controller.filteredProducts.isEmpty) {
        return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
      }

      final products = controller.filteredProducts;

      if (products.isEmpty) {
        return const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(50.0),
            child: Center(child: Text("لا توجد نتائج مطابقة للفلتر", style: TextStyle(color: Colors.grey))),
          ),
        );
      }

      return SliverPadding(
        padding: const EdgeInsets.all(20),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.65,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
          ),
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              final product = products[index];
              return Obx(() => ItemCard(
                product: product,
                isWishlisted: appController.isWishlisted(product.id),
                onWishlistToggle: () => appController.toggleWishlist(product.id),
                isCompact: true,
              ));
            },
            childCount: products.length,
          ),
        ),
      );
    });
  }

  Widget _buildCategoriesSection(AppController appController) {
    final catController = Get.put(CategoriesController());

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 50,
        child: Obx(() {
          final categories = catController.apiCategories;
          if (categories.isEmpty) return const SizedBox.shrink();

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isSelected = index == 0;

              return GestureDetector(
                onTap: () => Get.toNamed(
                    AppRoutes.PRODUCT_LIST,
                    arguments: {'categoryTitle': cat['name'], 'apiCategorySlug': cat['slug']},
                    id: 1 // الحفاظ على الشريط السفلي
                ),
                child: Container(
                  margin: const EdgeInsets.only(left: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: isSelected ? kPrimaryColor : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected ? null : Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      if (cat['icon'] != null) ...[
                        Icon(cat['icon'], color: isSelected ? Colors.white : kTextColor, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text((cat['name'] ?? "").toString(), style: TextStyle(color: isSelected ? Colors.white : kTextColor, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onTap, bool showViewAll = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(width: 5, height: 18, decoration: BoxDecoration(color: kSecondaryColor, borderRadius: BorderRadius.circular(2)),),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: kTextColor)),
          ],
        ),
        if (showViewAll && onTap != null)
          GestureDetector(
            onTap: onTap,
            child: const Row(
              children: [
                Text("عرض الكل", style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold)),
                SizedBox(width: 6),
                Icon(Icons.arrow_forward_ios, color: kSecondaryColor, size: 14),
              ],
            ),
          ),
      ],
    );
  }
}