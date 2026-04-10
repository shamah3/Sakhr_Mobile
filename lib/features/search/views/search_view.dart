import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bytore/core/constants/constants.dart';
import 'package:bytore/features/home/views/components/item_card.dart';
import 'package:bytore/core/controllers/app_controller.dart';
import '../controllers/search_controller.dart' as sc;

class SearchView extends StatelessWidget {
  final String query;
  const SearchView({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(sc.SearchController(initialQuery: query), tag: query);
    final appController = Get.find<AppController>();

    return Scaffold(
      backgroundColor: kBgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: kTextColor, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(color: kBgColor, borderRadius: BorderRadius.circular(10)),
          child: TextField(
            onChanged: (val) => controller.updateSearchQuery(val),
            decoration: InputDecoration(
              hintText: query,
              prefixIcon: const Icon(Icons.search, size: 20, color: kTextLightColor),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: kPrimaryColor),
            onPressed: () => _showFilterDialog(context, controller),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(controller),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
              }
              
              if (controller.filteredProducts.isEmpty) {
                return _buildEmptyState();
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                  childAspectRatio: 0.72, 
                ),
                itemCount: controller.filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = controller.filteredProducts[index];
                  return ItemCard(
                    product: product,
                    isWishlisted: appController.isWishlisted(product.id),
                    onWishlistToggle: () => appController.toggleWishlist(product.id),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(sc.SearchController controller) {
    return Container(
      height: 60,
      color: Colors.white,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        scrollDirection: Axis.horizontal,
        itemCount: controller.filters.length,
        itemBuilder: (context, index) {
          return Obx(() {
            String filter = controller.filters[index];
            bool isSelected = controller.selectedFilter.value == filter;
            return GestureDetector(
              onTap: () => controller.updateFilter(filter),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: isSelected ? kPrimaryColor : kBgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    filter,
                    style: TextStyle(color: isSelected ? Colors.white : kTextColor, fontSize: 13),
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  void _showFilterDialog(BuildContext context, sc.SearchController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('تصفية النتائج', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildFilterOption('نطاق السعر', [r'0-500$', r'500-1500$', r'1500$+']),
            _buildFilterOption('الحالة', ['جديد', 'مستعمل نقي']),
            _buildFilterOption('الماركة', ['Apple', 'HP', 'Dell', 'Asus']),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('تطبيق الفلتر'),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String title, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: options.map((opt) => Chip(
            label: Text(opt, style: const TextStyle(fontSize: 12)),
            backgroundColor: kBgColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            side: BorderSide.none,
          )).toList(),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 15),
          const Text("لا توجد نتائج بحث", style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}
