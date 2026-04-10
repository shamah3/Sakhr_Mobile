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
import 'package:bytore/features/home/views/ads_view.dart';
import 'package:bytore/features/home/views/components/coupon_card.dart';
import 'package:bytore/features/home/models/coupon_model.dart';
import 'package:bytore/features/home/views/all_coupons_view.dart';

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
        _buildTopSellingHorizontalList(appController),

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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              _buildSectionHeader(
                "الخصومات والكوبونات", 
                showViewAll: true,
                onTap: () => Get.to(() => const AllCouponsView()),
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
        _buildCouponsCarousel(),
      ],
    );
  }

  Widget _buildCouponsCarousel() {
    return Container(
      height: 145, // الارتفاع المثالي للتنسيق الأفقي المريح والفخم مع الظلال
      margin: const EdgeInsets.only(bottom: 20),
      child: Obx(() {
        if (controller.isCouponsLoading.value && controller.coupons.isEmpty) {
          return const Center(
            child: SizedBox(
              width: 24, height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        if (controller.coupons.isEmpty) {
          return const Center(
            child: Text("لا يوجد كوبونات متوفرة حالياً", style: TextStyle(color: Colors.grey, fontSize: 12)),
          );
        }

        final displayCoupons = controller.coupons.take(5).toList();

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: displayCoupons.length,
          itemBuilder: (context, index) {
            final coupon = displayCoupons[index];
            return CouponCard(coupon: coupon);
          },
        );
      }),
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
    return Obx(() {
      if (controller.advertisements.isEmpty) {
         return const SizedBox.shrink();
      }

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
            items: controller.advertisements.map((ad) {
              return GestureDetector(
                onTap: () {
                  Get.dialog(
                    Dialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: SingleChildScrollView(
                        child: Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("تفاصيل الإعلان", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kPrimaryColor)),
                                  IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close, size: 20)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: CustomImage(
                                  imageUrl: ad.image,
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 15),
                              Text(ad.title ?? "إعلان ترويجي", 
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: kTextColor)),
                              const SizedBox(height: 8),
                              Text(ad.description ?? "", 
                                  style: const TextStyle(fontSize: 14, color: Colors.grey, height: 1.4)),
                              
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 15),
                                child: Divider(),
                              ),
                              
                              _buildAdDetailRow(Icons.account_balance_wallet_rounded, "الميزانية", "${ad.budget?.toStringAsFixed(2) ?? '0.00'} $kCurrency"),
                              const SizedBox(height: 12),
                              _buildAdDetailRow(Icons.calendar_today_rounded, "فترة الإعلان", 
                                  "${(ad.startDate ?? '-').split('T')[0]} إلى ${(ad.endDate ?? '-').split('T')[0]}"),
                              const SizedBox(height: 12),
                              _buildAdDetailRow(Icons.store_rounded, "المتجر المعلن", ad.storeName ?? "متجر شريك"),
                              
                              const SizedBox(height: 30),
                              
                              // Buttons Row
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Get.back();
                                        if (ad.targetUrl != null && ad.targetUrl!.isNotEmpty) {
                                          // Logic to open URL
                                        } else {
                                          Get.toNamed('/product-list', arguments: {'storeId': ad.storeId, 'categoryTitle': ad.storeName ?? "المتجر"});
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: kPrimaryColor,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                        elevation: 0,
                                      ),
                                      child: const Text("زيارة المتجر", style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        Get.back();
                                        Get.toNamed('/ads');
                                      },
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        side: const BorderSide(color: kPrimaryColor, width: 1.5),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                      ),
                                      child: const Text("جميع العروض", style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
                          colors: [kPrimaryColor, kPrimaryColor.withOpacity(0.85)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                           BoxShadow(
                             color: kPrimaryColor.withOpacity(0.2),
                             blurRadius: 15,
                             offset: const Offset(0, 8),
                           ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: 18, top: 0, bottom: 0,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 1. Store Badge (Top)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.storefront_rounded, color: kSecondaryColor, size: 12),
                                        const SizedBox(width: 6),
                                        Flexible(
                                          child: Text(
                                            ad.storeName ?? "متجر مميز",
                                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  // 2. Ad Title (Middle)
                                  Text(
                                    ad.title ?? "",
                                    style: const TextStyle(
                                      color: Colors.white, 
                                      fontWeight: FontWeight.w900, 
                                      fontSize: 18, 
                                      height: 1.4,
                                      letterSpacing: 0.2,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 10),
                                  
                                  // 3. Expiry Info (Below Title)
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time_filled_rounded, color: Colors.white54, size: 12),
                                      const SizedBox(width: 4),
                                      Text(
                                        "ينتهي في: ${(ad.endDate ?? '-').split('T')[0]}",
                                        style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  
                                  // 4. Primary Action (Button)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: kSecondaryColor,
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: kSecondaryColor.withOpacity(0.2), 
                                          blurRadius: 10, 
                                          offset: const Offset(0, 4)
                                        ),
                                      ],
                                    ),
                                    child: const Text(
                                      "اكتشف العرض",
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (ad.image.isNotEmpty)
                            Positioned(
                              left: 10, bottom: 10, top: 10, width: 150,
                              child: Hero(
                                tag: 'ad_image_${ad.id}',
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: CustomImage(
                                    imageUrl: ad.image,
                                    fit: BoxFit.cover,
                                  ),
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
            children: controller.advertisements.asMap().entries.map((entry) {
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
    });
  }

  Widget _buildTopSellingHorizontalList(AppController appController) {
    return Container(
      height: 280,
      margin: const EdgeInsets.only(bottom: 20),
      child: Obx(() {
        if (controller.isLoading.value && controller.topSellingProducts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.topSellingProducts.isEmpty) {
          return _buildHorizontalProductList("الكل", appController); // Fallback to all if empty
        }

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: controller.topSellingProducts.length,
          itemBuilder: (context, index) {
            final product = controller.topSellingProducts[index];
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

  Widget _buildHorizontalProductList(String category, AppController appController) {
    return Container(
      height: 280,
      margin: const EdgeInsets.only(bottom: 20),
      child: Obx(() {
        if (controller.isLoading.value && controller.allProducts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final products = controller.allProducts.where((p) =>
        p != null && (category == "الكل" || p.status == category || p.name.contains(category))
        ).take(8).toList();

        final displayProducts = products.isEmpty ? controller.allProducts.take(8).toList() : products;

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
      child: Container(
        height: 55, // ارتفاع مثالي للبطاقات المستطيلة
        margin: const EdgeInsets.only(bottom: 15),
        child: Obx(() {
          if (catController.isLoading.value) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 2, color: kPrimaryColor));
          }
          final categories = catController.apiCategories;
          
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isAll = cat['id'] == 'all';
              // منطق تفاعلي: تحديد القسم المختار لونياً عند الضغط أو البقاء عليه
              final isSelected = catController.selectedCategoryIndex.value == index;
              
              return GestureDetector(
                onTap: () {
                  catController.selectedCategoryIndex.value = index; // تفعيل الحالة التفاعلية
                  if (isAll) {
                    Get.toNamed(AppRoutes.PRODUCT_LIST, arguments: {'categoryTitle': "الكل", 'apiCategorySlug': 'all'}, id: 1);
                  } else {
                    Get.toNamed(AppRoutes.PRODUCT_LIST, arguments: {'categoryTitle': cat['name'], 'apiCategorySlug': cat['slug']}, id: 1);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(left: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? kPrimaryColor : const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? kPrimaryColor : Colors.grey.withOpacity(0.08),
                    ),
                    boxShadow: isSelected 
                      ? [BoxShadow(color: kPrimaryColor.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))]
                      : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // الصورة بجانب النص
                      _buildCategoryIconShort(cat, isSelected, size: 24),
                      const SizedBox(width: 10),
                      Text(
                        (cat['name'] ?? "").toString(),
                        style: TextStyle(
                          color: isSelected ? Colors.white : kTextColor.withOpacity(0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
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

  // أيقونة القسم في الصفحة الرئيسية
  Widget _buildCategoryIconShort(Map cat, bool isSelected, {double size = 20}) {
    // إصلاح: عرض أيقونة الشبكة لقسم "الكل" لضمان الوضوح كما طلب المستخدم
    if (cat['id'] == 'all') {
      return Icon(Icons.grid_view_rounded, 
          color: isSelected ? Colors.white : kPrimaryColor, size: size);
    }

    String? imageUrl = cat['image_url'] ?? cat['image'];
    if (imageUrl != null && imageUrl.isNotEmpty && !imageUrl.contains("icons8.com")) { // تجنب الروابط الضعيفة
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: CustomImage(
          imageUrl: imageUrl,
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),
      );
    }
    dynamic iconData = cat['icon'];
    if (iconData is! IconData) {
      iconData = Icons.category_rounded;
    }

    return Icon(iconData,
        color: isSelected ? Colors.white : kPrimaryColor, size: size);
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

  Widget _buildAdDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: kBgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: kPrimaryColor),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kTextColor)),
          ],
        ),
      ],
    );
  }
}