import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bytore/core/constants/constants.dart';
import '../controllers/categories_controller.dart';
import 'components/item_card.dart';

class CategoriesView extends GetView<CategoriesController> {
  const CategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CategoriesController>()) Get.put(CategoriesController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildPremiumAppBar(),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            // Sidebar first (Far right in RTL)
            _buildAdvancedSidebar(),
            // Main content last (Remaining space on the left)
            Expanded(child: _buildMainContent()),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildPremiumAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.white,
      centerTitle: false,
      leading: Obx(() => IconButton(
            icon: Icon(
              controller.isSearchActive.value ? Icons.close_rounded : Icons.search_rounded,
              color: kTextColor,
            ),
            onPressed: controller.toggleSearch,
          )),
      title: Obx(() => controller.isSearchActive.value
          ? Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                autofocus: true,
                onChanged: controller.onSearchChanged,
                decoration: const InputDecoration(
                  hintText: "ابحث عن منتج أو قسم...",
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, size: 20, color: Colors.grey),
                  hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            )
          : const Text(
              "الكتالوج الاحترافي",
              style: TextStyle(
                color: kTextColor,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            )),
      actions: [
        if (!controller.isSearchActive.value)
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.tune_rounded, color: kTextColor),
                onPressed: () => _showFilterSheet(),
              ),
              Obx(() => (controller.selectedBrands.isNotEmpty || controller.showOnlyInStock.value)
                  ? Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      ),
                    )
                  : const SizedBox.shrink()),
            ],
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildAdvancedSidebar() {
    return Container(
      width: 110, // Optimally widened for category icons and text
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border(left: BorderSide(color: Colors.grey.shade100, width: 1)),
      ),
      child: Column(
        children: [
          // Section: Categories Scroll
          Expanded(
            child: Obx(() => ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: controller.apiCategories.length,
              itemBuilder: (context, index) {
                final cat = controller.apiCategories[index];
                return Obx(() {
                  final isSelected = controller.selectedCategoryIndex.value == index;
                  return _buildSidebarItem(cat, isSelected, index);
                });
              },
            )),
          ),
          
          // Section: Quick Filters
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                _buildFilterIcon(Icons.tune_rounded, "الفلاتر", () => _showFilterSheet()),
                const SizedBox(height: 20),
                _buildFilterIcon(Icons.sort_rounded, "الترتيب", () => _showSortSheet()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(Map cat, bool isSelected, int index) {
    return GestureDetector(
      onTap: () => controller.selectCategory(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0277BD) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF0277BD).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image Container
            SizedBox(
              height: 28, // Increased from 24
              width: 28,  // Increased from 24
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: (cat['image_url'] != null && cat['image_url'].toString().isNotEmpty && cat['id'] != 'all')
                    ? Image.network(
                        cat['image_url'],
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Icon(
                          _getCategoryIcon(cat['id']),
                          color: isSelected ? Colors.white : Colors.grey.shade400,
                          size: 22, // Increased from 20
                        ),
                      )
                    : Icon(
                        _getCategoryIcon(cat['id']),
                        color: isSelected ? Colors.white : Colors.grey.shade400,
                        size: 22, // Increased from 20
                      ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              cat['name'] ?? "",
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                fontSize: 10, // Increased from 9 for better readability
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(dynamic id) {
    if (id == 'all') return Icons.grid_view_rounded;
    return Icons.category_rounded;
  }

  Widget _buildFilterIcon(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Icon(icon, size: 20, color: kTextColor),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: kTextColor)),
        ],
      ),
    );
  }

  Widget _buildSubCategoriesList() {
    return Obx(() {
      final subs = controller.getFilteredSubCategories();
      if (subs.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text("الأقسام الفرعية", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: kTextColor)),
          ),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: subs.length,
              itemBuilder: (context, index) {
                final sub = subs[index];
                return GestureDetector(
                  onTap: () => controller.navigateToProducts(sub['name'], sub['slug']),
                  child: Container(
                    width: 80,
                    margin: const EdgeInsets.only(left: 12),
                    child: Column(
                      children: [
                        Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: (sub['image_url'] != null && sub['image_url'].toString().isNotEmpty)
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(sub['image_url'], fit: BoxFit.cover),
                                )
                              : const Icon(Icons.category_outlined, color: Colors.grey),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          sub['name'] ?? "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      );
    });
  }

  Widget _buildBrandsList() {
    return Obx(() {
      final brands = controller.getAggregatedBrands();
      if (brands.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text("الماركات", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: kTextColor)),
          ),
          SizedBox(
            height: 45,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: brands.length,
              itemBuilder: (context, index) {
                final brand = brands[index];
                final brandId = int.tryParse(brand['id']?.toString() ?? "");
                final isSelected = brandId != null && controller.selectedBrands.contains(brandId);
                
                return GestureDetector(
                  onTap: () {
                    final int? bid = int.tryParse(brand['id']?.toString() ?? "");
                    if (bid != null) controller.toggleBrand(bid);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? kPrimaryColor : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSelected ? kPrimaryColor : Colors.grey.shade200),
                      boxShadow: isSelected 
                        ? [BoxShadow(color: kPrimaryColor.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 3))]
                        : [],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (brand['brand_logo_url'] != null && brand['brand_logo_url'].toString().isNotEmpty)
                           Padding(
                             padding: const EdgeInsets.only(left: 6),
                             child: Image.network(
                               brand['brand_logo_url'], 
                               height: 18, 
                               width: 18, 
                               color: isSelected ? Colors.white : null,
                               errorBuilder: (c,e,s) => const SizedBox.shrink(),
                             ),
                           ),
                        Text(
                          brand['name'] ?? "",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : kTextColor.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      );
    });
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        // Navigation / Breadcrumbs
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              const Text("الرئيسية", style: TextStyle(fontSize: 11, color: Colors.grey)),
              const Icon(Icons.chevron_left_rounded, size: 14, color: Colors.grey),
              Obx(() => Text(
                controller.currentCategory['name'] ?? "الكل",
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: kTextColor),
              )),
              const Spacer(),
              Obx(() => Text(
                "${controller.products.length} منتج",
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w600),
              )),
            ],
          ),
        ),

        // 🔗 Sub-categories Section (Interactive)
        _buildSubCategoriesList(),
        
        // 🏷️ Brands Section (Interactive)
        _buildBrandsList(),

        // Product Grid
        Expanded(
          child: Obx(() {
            if (controller.isProductsLoading.value) {
              return const Center(child: CircularProgressIndicator(strokeWidth: 2));
            }
            if (controller.products.isEmpty) {
              return _buildEmptyState();
            }
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.44, // Slightly taller to prevent text overflow
              ),
              itemCount: controller.products.length,
              itemBuilder: (context, index) {
                return ItemCard(product: controller.products[index], isCompact: true);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade200),
        const SizedBox(height: 16),
        const Text("لا توجد منتجات تطابق بحثك", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
      ],
    );
  }

  void _showFilterSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("تصفية النتائج", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 24),
            
            // Price Filter
            const Text("نطاق السعر", style: TextStyle(fontWeight: FontWeight.bold)),
            Obx(() => RangeSlider(
              values: controller.priceRange.value,
              min: 0,
              max: 500000,
              divisions: 50,
              activeColor: kPrimaryColor,
              labels: RangeLabels(
                controller.priceRange.value.start.round().toString(),
                controller.priceRange.value.end.round().toString(),
              ),
              onChanged: controller.updatePriceRange,
            )),
            
            // Stock Filter
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("المتوفر في المخزن فقط", style: TextStyle(fontWeight: FontWeight.bold)),
                Obx(() => Switch(
                  value: controller.showOnlyInStock.value,
                  onChanged: controller.toggleStockFilter,
                  activeColor: kPrimaryColor,
                )),
              ],
            ),
            
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("عرض النتائج", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortSheet() {
    final sortOptions = ["الأحدث", "السعر: من الأقل", "السعر: من الأعلى"];
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("ترتيب حسب", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            ...sortOptions.map((opt) => ListTile(
              title: Text(opt, style: const TextStyle(fontWeight: FontWeight.w600)),
              trailing: Obx(() => controller.sortBy.value == opt ? const Icon(Icons.check_circle, color: kPrimaryColor) : const SizedBox()),
              onTap: () {
                controller.updateSort(opt);
                Get.back();
              },
            )),
          ],
        ),
      ),
    );
  }
}
