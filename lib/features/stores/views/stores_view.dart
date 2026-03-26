import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bytore/core/constants/constants.dart';
import 'package:bytore/features/product/views/product_list_view.dart';
import 'package:carousel_slider/carousel_slider.dart'; // Import Carousel
import 'package:bytore/core/components/custom_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bytore/features/stores/models/store_model.dart';
import '../controllers/stores_controller.dart';

class StoresView extends GetView<StoresController> {
  final VoidCallback? onReturnHome;
  const StoresView({super.key, this.onReturnHome});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<StoresController>()) {
      Get.put(StoresController());
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildWhiteHeader(),
            const SizedBox(height: 15),
            _buildBanners(), // Added banners as requested
            _buildSearchField(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
                }
                if (controller.filteredStores.isEmpty) {
                  return const Center(child: Text("لا توجد نتائج"));
                }
                return GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                    ),
                    itemCount: controller.filteredStores.length,
                    itemBuilder: (context, index) => _buildStoreCard(controller.filteredStores[index]),
                  );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhiteHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          if (onReturnHome != null)
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, color: kTextColor, size: 20),
              onPressed: onReturnHome,
            ),
          const Expanded(
            child: Center(
              child: Text(
                'المتاجر الشريكة',
                style: TextStyle(color: kTextColor, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
          if (onReturnHome != null)
             const SizedBox(width: 40), // Balance the title
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: kBgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          onChanged: controller.filterStores,
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            hintText: 'ابحث عن اسم المتجر',
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search_rounded, color: kPrimaryColor),
            suffixIcon: Obx(() => controller.searchText.value.isNotEmpty 
              ? IconButton(
                  icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                  onPressed: () => controller.filterStores(''),
                ) 
              : const SizedBox.shrink()),
          ),
        ),
      ),
    );
  }

  Widget _buildStoreCard(StoreModel store) {
    return GestureDetector(
      onTap: () {
        Get.to(() => ProductListView(
          categoryTitle: store.name,
          apiCategorySlug: 'all', 
          storeId: store.id,
        ));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kPrimaryColor.withOpacity(0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: kPrimaryColor.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      Stack(
                        children: [
                          Container(
                            height: 70,
                            width: 70,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: kSecondaryColor, width: 2),
                              boxShadow: [
                                 BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
                              ]
                            ),
                            child: CustomImage(
                              imageUrl: store.logo ?? "",
                              fit: BoxFit.contain,
                            ),
                          ),
                          if (store.isVerified)
                            Positioned(
                              bottom: 2,
                              right: 2,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                child: const Icon(Icons.verified_rounded, color: Colors.blue, size: 16),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        store.name,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: kTextColor),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        store.category,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: kTextLightColor, fontSize: 10),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: kBgColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                             const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                             const SizedBox(width: 4),
                             Text(
                               '${store.rating}',
                               style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                             ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildBanners() {
    return Obx(() {
      if (controller.advertisements.isEmpty) return const SizedBox.shrink();
      
      return Column(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: 160,
              viewportFraction: 0.92,
              autoPlay: true,
              enlargeCenterPage: true,
            ),
            items: controller.advertisements.map((ad) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(horizontal: 0.0),
                    decoration: BoxDecoration(
                      color: kPrimaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(ad.image),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
                      ),
                    ),
                    child: (ad.title != null || ad.description != null) 
                      ? Center(
                          child: Text(
                            "${ad.title ?? ''}\n${ad.description ?? ''}".trim(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white, 
                              fontWeight: FontWeight.bold, 
                              fontSize: 18, 
                              shadows: [Shadow(blurRadius: 10, color: Colors.black, offset: Offset(0, 2))]
                            ),
                          ),
                        )
                      : null,
                  );
                },
              );
            }).toList(),
          ),
        ],
      );
    });
  }
}
