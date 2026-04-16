import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bytore/core/constants/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/categories_controller.dart';

class CategoriesView extends GetView<CategoriesController> {
  const CategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CategoriesController>()) Get.put(CategoriesController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildPremiumAppBar(),
      body: Row(
        children: [
          _buildElegantSidebar(),
          Expanded(child: _buildMainContent()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildPremiumAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.white,
      leading: Obx(() => IconButton(
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(controller.isSearchActive.value ? Icons.close : Icons.search, color: kTextColor, size: 20),
        ),
        onPressed: controller.toggleSearch,
      )),
      title: Obx(() => controller.isSearchActive.value
          ? TextField(
              autofocus: true,
              onChanged: (val) => controller.searchText.value = val,
              decoration: const InputDecoration(
                hintText: "ابحث عن قسم أو منتج...",
                border: InputBorder.none,
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            )
          : const Text(
              "تصنيفات صخر",
              style: TextStyle(color: kTextColor, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5),
            )),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.tune_rounded, color: kTextColor),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildElegantSidebar() {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFE),
        border: Border(left: BorderSide(color: Colors.grey.withOpacity(0.08), width: 1.5)),
      ),
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: kPrimaryColor, strokeWidth: 2));
        }
        return ListView.builder(
          itemCount: controller.apiCategories.length,
          itemBuilder: (context, index) {
            final isSelected = controller.selectedCategoryIndex.value == index;
            final cat = controller.apiCategories[index];
            final String name = cat['name']?.toString() ?? "";
            
            return GestureDetector(
              onTap: () => controller.selectCategory(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  border: isSelected ? const Border(right: BorderSide(color: kPrimaryColor, width: 4)) : null,
                ),
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: isSelected ? kPrimaryColor.withOpacity(0.1) : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: _buildCategorySidebarImage(cat, isSelected),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                          color: isSelected ? kPrimaryColor : Colors.blueGrey.shade300,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildCategorySidebarImage(Map cat, bool isSelected) {
    if (cat['id'] == 'all') {
      return Icon(Icons.dashboard_customize_rounded, color: isSelected ? kPrimaryColor : Colors.grey.shade400, size: 24);
    }
    String imageUrl = (cat['image_url'] ?? cat['image'] ?? "").toString();
    if (imageUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(color: Colors.grey.shade50),
        errorWidget: (context, url, error) => Icon(Icons.category_outlined, color: Colors.grey.shade300, size: 20),
      );
    }
    return Icon(Icons.category_rounded, color: Colors.grey.shade300, size: 24);
  }

  Widget _buildMainContent() {
    return Obx(() {
      if (controller.isLoading.value) return const SizedBox.shrink();
      
      final cat = controller.currentCategory;
      final filteredSubs = controller.getFilteredSubCategories();
      final brands = controller.getAggregatedBrands();

      return CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Banner
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildBannerCard(cat),
            ),
          ),

          // Brands Section
          if (brands.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _buildHeader("أبرز الماركات"),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: brands.length,
                  itemBuilder: (context, index) => _buildBrandItem(brands[index]),
                ),
              ),
            ),
          ],

          // Sub-categories
          if (filteredSubs.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: _buildHeader("الأقسام الفرعية"),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildSubCatItem(filteredSubs[index]),
                  childCount: filteredSubs.length,
                ),
              ),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 50)),
        ],
      );
    });
  }

  Widget _buildBrandItem(Map brand) {
    String logoUrl = (brand['brand_logo_url'] ?? brand['image_url'] ?? "").toString();
    return GestureDetector(
      onTap: () => controller.navigateToProducts(brand['name'] ?? "", brand['slug'] ?? ""),
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(left: 12),
        child: Column(
          children: [
            Container(
              height: 65, width: 65,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade100, width: 1),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: logoUrl.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(8),
                        child: CachedNetworkImage(
                          imageUrl: logoUrl,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => Container(color: Colors.grey.shade50),
                          errorWidget: (context, url, e) => Icon(Icons.business_rounded, color: Colors.grey.shade300),
                        ),
                      )
                    : Icon(Icons.business_rounded, color: Colors.grey.shade300),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              brand['name'] ?? "",
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: kTextColor),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Row(
      children: [
        Container(width: 4, height: 18, decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: kTextColor)),
      ],
    );
  }

  Widget _buildBannerCard(Map cat) {
    String imgUrl = (cat['image_url'] ?? cat['image'] ?? "").toString();
    return Container(
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imgUrl.isNotEmpty)
              CachedNetworkImage(imageUrl: imgUrl, fit: BoxFit.cover)
            else
              Container(color: kPrimaryColor.withOpacity(0.8)),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            Positioned(
              bottom: 15, right: 15,
              child: Text(
                cat['name']?.toString() ?? "",
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubCatItem(Map sub) {
    return GestureDetector(
      onTap: () => controller.navigateToProducts(sub['name'], sub['slug']),
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade100),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Center(
                child: _buildCategoryIcon(sub),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            sub['name']?.toString() ?? "",
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: kTextColor, height: 1.1),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryIcon(Map sub) {
    String name = (sub['name'] ?? "").toString();
    return Icon(_getIconForName(name), color: kPrimaryColor, size: 28);
  }

  IconData _getIconForName(String name) {
    String n = name.toLowerCase();
    if (n.contains('هاتف') || n.contains('جوال')) return Icons.smartphone_rounded;
    if (n.contains('كمبيوتر') || n.contains('لابتوب')) return Icons.laptop_mac_rounded;
    if (n.contains('ساعة')) return Icons.watch_rounded;
    if (n.contains('سماع')) return Icons.headset_rounded;
    if (n.contains('كاميرا')) return Icons.camera_alt_rounded;
    if (n.contains('حقائب')) return Icons.backpack_rounded;
    return Icons.category_rounded;
  }
}
