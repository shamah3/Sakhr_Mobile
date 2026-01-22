import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bytore/core/constants/constants.dart';
import 'package:bytore/data/category_data.dart';
import 'package:bytore/features/home/views/components/item_card.dart';
import 'package:bytore/core/controllers/app_controller.dart';
import '../controllers/product_list_controller.dart';

class ProductListView extends StatelessWidget {
  final String categoryTitle;
  final String apiCategorySlug;
  
  const ProductListView({
    super.key, 
    this.categoryTitle = "المنتجات", 
    this.apiCategorySlug = "all"
  });

  @override
  Widget build(BuildContext context) {
    // Inject controller with unique tag for this category to avoid state sharing
    final controller = Get.put(
      ProductListController(initialSlug: apiCategorySlug, initialTitle: categoryTitle),
      tag: apiCategorySlug
    );
    final appController = Get.find<AppController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(controller),
      body: Column(
        children: [
          _buildCategoriesBar(controller),
          _buildSubCategoriesBar(controller),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.filteredProducts.isEmpty) {
                return const Center(child: Text("لا توجد منتجات في هذا القسم"));
              }
              return _buildProductsGrid(controller, appController);
            }),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ProductListController controller) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: kTextColor),
        onPressed: () => Get.back(),
      ),
      title: Obx(() => controller.isSearching.value 
        ? TextField(
            autofocus: true,
            style: const TextStyle(color: kTextColor),
            onChanged: controller.updateSearch,
            decoration: const InputDecoration(
              hintText: "ابحث عن منتج...",
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.grey),
            ),
          )
        : Text(controller.categoryTitle.value, style: const TextStyle(color: kTextColor, fontWeight: FontWeight.bold))
      ),
      actions: [
        Obx(() => IconButton(
          icon: Icon(controller.isSearching.value ? Icons.close : Icons.search, color: kTextColor),
          onPressed: controller.toggleSearch,
        )),
      ],
    );
  }

  Widget _buildCategoriesBar(ProductListController controller) {
    final categories = CategoryData.categories;
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemBuilder: (context, index) {
          final cat = categories[index];
          return Obx(() {
            final bool isSelected = controller.categorySlug.value == cat['slug'];
            return GestureDetector(
              onTap: () => controller.updateCategory(cat['slug']!, cat['name']!),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? kPrimaryColor : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected ? null : Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  cat['name']!,
                  style: TextStyle(
                    color: isSelected ? Colors.white : kTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildSubCategoriesBar(ProductListController controller) {
    return Obx(() {
      final currentCategory = CategoryData.categories.firstWhere(
        (c) => c['slug'] == controller.categorySlug.value, 
        orElse: () => {}
      );

      if (currentCategory.isEmpty || currentCategory['subcategories'] == null || (currentCategory['subcategories'] as List).isEmpty) {
        return const SizedBox.shrink();
      }

      final subCategories = currentCategory['subcategories'] as List;

      return Container(
        height: 40,
        margin: const EdgeInsets.only(bottom: 10),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: subCategories.length,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          itemBuilder: (context, index) {
            final subCat = subCategories[index];
            final bool isSelected = controller.subCategorySlug.value == subCat['slug'];
            
            return GestureDetector(
              onTap: () => controller.updateSubCategory(subCat['slug']),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                padding: const EdgeInsets.symmetric(horizontal: 15),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? kSecondaryColor.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSelected ? kSecondaryColor : Colors.grey.shade300),
                ),
                child: Text(
                  subCat['name']!,
                  style: TextStyle(
                    color: isSelected ? kSecondaryColor : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildProductsGrid(ProductListController controller, AppController appController) {
    final products = controller.filteredProducts;
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, 
        childAspectRatio: 0.85, 
        crossAxisSpacing: 15, 
        mainAxisSpacing: 15
      ),
      itemCount: products.length,
      itemBuilder: (context, i) {
        final product = products[i];
        return Obx(() => ItemCard(
          product: product,
          isCompact: true,
          isWishlisted: appController.isWishlisted(product.id),
          onWishlistToggle: () => appController.toggleWishlist(product.id),
        ));
      },
    );
  }
}
