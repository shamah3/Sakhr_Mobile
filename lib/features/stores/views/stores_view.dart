import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bytore/core/constants/constants.dart';
import 'package:bytore/features/product/views/product_list_view.dart';
import 'package:carousel_slider/carousel_slider.dart'; 
import 'package:bytore/core/components/custom_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bytore/features/stores/models/store_model.dart';
import '../controllers/stores_controller.dart';
import 'package:bytore/core/routes/app_routes.dart';

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
            _buildBanners(), 
            _buildSearchField(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
                }
                if (controller.hasError.value) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_off_rounded, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          const Text(
                            "تعذّر تحميل المتاجر",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kTextColor),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: controller.loadStores,
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text("إعادة المحاولة"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                if (controller.filteredStores.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 56, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        const Text("لا توجد نتائج", style: TextStyle(color: kTextLightColor, fontSize: 15)),
                      ],
                    ),
                  );
                }
                return GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 0.60,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.05))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (onReturnHome != null)
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: kTextColor, size: 20),
              onPressed: onReturnHome,
            )
          else
            const SizedBox(width: 48),
            
          const Expanded(
            child: Center(
              child: Text(
                'المتاجر الشريكة',
                style: TextStyle(
                  color: kTextColor, 
                  fontWeight: FontWeight.w900, 
                  fontSize: 18,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(30), 
          border: Border.all(color: Colors.grey.withOpacity(0.05)),
        ),
        child: TextField(
          onChanged: controller.filterStores,
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            hintText: 'ابحث عن اسم المتجر',
            hintStyle: TextStyle(color: Colors.grey.withOpacity(0.6), fontSize: 13),
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF455A64), size: 22),
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
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
        Get.toNamed(
          AppRoutes.PRODUCT_LIST,
          arguments: {
            'categoryTitle': store.name,
            'apiCategorySlug': 'all',
            'storeId': store.id,
          },
          id: 4, // Stores Navigator ID
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.withOpacity(0.08), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 85,
                    width: 85,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: kSecondaryColor.withOpacity(0.7), width: 2),
                      boxShadow: [
                        BoxShadow(color: kSecondaryColor.withOpacity(0.12), blurRadius: 12, spreadRadius: 2)
                      ]
                    ),
                    child: ClipOval(
                      child: CustomImage(
                        imageUrl: store.logo ?? "",
                        fit: BoxFit.contain, // Show full logo without cropping
                        width: 85,
                        height: 85,
                      ),
                    ),
                  ),
                  if (store.isVerified)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.verified_rounded, color: Color(0xFF2196F3), size: 24),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 18), 
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  store.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5, color: kTextColor, letterSpacing: -0.3),
                ),
              ),
              const SizedBox(height: 6), 
              Text(
                store.category,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 18), 
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F4),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${store.rating}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF3C4043)),
                    ),
                  ],
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
              height: 170, 
              viewportFraction: 0.92,
              autoPlay: true,
              enlargeCenterPage: true,
              autoPlayCurve: Curves.fastOutSlowIn,
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
            ),
            items: controller.advertisements.map((ad) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: CachedNetworkImage(
                              imageUrl: ad.image,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(color: Colors.grey.shade100),
                              errorWidget: (context, url, error) => Container(
                                color: kPrimaryColor.withOpacity(0.1),
                                child: const Icon(Icons.image_outlined, color: kPrimaryColor, size: 40),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.1),
                                    Colors.black.withOpacity(0.8),
                                  ],
                                  stops: const [0.4, 0.7, 1.0],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 20,
                            left: 20,
                            right: 20,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (ad.title != null)
                                  Text(
                                    ad.title!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white, 
                                      fontWeight: FontWeight.w900, 
                                      fontSize: 18,
                                      shadows: [Shadow(blurRadius: 10, color: Colors.black45, offset: Offset(0, 2))],
                                    ),
                                  ),
                                if (ad.description != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      ad.description!,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9), 
                                        fontWeight: FontWeight.w600, 
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
        ],
      );
    });
  }
}
