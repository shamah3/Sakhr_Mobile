import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bytore/core/constants/constants.dart';
import 'package:bytore/features/home/views/components/item_card.dart';
import 'package:bytore/core/controllers/app_controller.dart';
import 'package:bytore/features/home/controllers/categories_controller.dart';
import '../controllers/product_list_controller.dart';

class ProductListView extends StatelessWidget {
  final String categoryTitle;
  final String apiCategorySlug;

  const ProductListView({
    super.key,
    this.categoryTitle = "",
    this.apiCategorySlug = "",
  });

  @override
  Widget build(BuildContext context) {
    final args =
        (ModalRoute.of(context)?.settings.arguments as Map?) ?? Get.arguments as Map?;

    final String actualTitle = (categoryTitle.isNotEmpty && categoryTitle != "المنتجات")
        ? categoryTitle
        : (args?['categoryTitle'] ?? "المنتجات");

    final String actualSlug = (apiCategorySlug.isNotEmpty && apiCategorySlug != "all")
        ? apiCategorySlug
        : (args?['apiCategorySlug'] ?? "all");

    final controller = Get.put(
      ProductListController(
        initialSlug: actualSlug,
        initialTitle: actualTitle,
      ),
      tag: actualSlug,
      permanent: false,
    );

    if (controller.categoryTitle.value != actualTitle ||
        controller.categorySlug.value != actualSlug) {
      Future.microtask(
              () => controller.updateCategory(actualSlug, actualTitle));
    }

    final appController = Get.find<AppController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context, controller),

      // ✅ الحل هنا — لا تستخدم LayoutBuilder مع Expanded
      body: Column(
        children: [
          _buildCategoriesBar(controller),
          _buildSubCategoriesBar(controller),

          // ✅ هذا هو التصحيح المهم
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.filteredProducts.isEmpty) {
                return const Center(
                  child: Text("لا توجد منتجات في هذا القسم"),
                );
              }

              return _buildProductsGrid(controller, appController);
            }),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // APP BAR
  // =====================================================

  PreferredSizeWidget _buildAppBar(
      BuildContext context, ProductListController controller) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new,
            color: kTextColor, size: 20),
        onPressed: () => Navigator.maybePop(context),
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
          : Text(
        controller.categoryTitle.value,
        style: const TextStyle(
            color: kTextColor, fontWeight: FontWeight.bold),
      )),
      actions: [
        Obx(
              () => IconButton(
            icon: Icon(
              controller.isSearching.value
                  ? Icons.close
                  : Icons.search,
              color: kTextColor,
            ),
            onPressed: controller.toggleSearch,
          ),
        ),
      ],
    );
  }

  // =====================================================
  // CATEGORIES BAR
  // =====================================================

  Widget _buildCategoriesBar(ProductListController controller) {
    final catController = Get.put(CategoriesController());

    return Obx(() {
      final categories = catController.apiCategories;
      if (categories.isEmpty) return const SizedBox.shrink();

      return SizedBox(
        height: 50,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final cat = categories[index];

          return Obx(() {
            final bool isSelected =
                controller.categorySlug.value == cat['slug'];

            return GestureDetector(
              onTap: () =>
                  controller.updateCategory(cat['slug']!, cat['name']!),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                padding:
                const EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? kPrimaryColor
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? null
                      : Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  cat['name']!,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : kTextColor,
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
  });
}

  // =====================================================
  // SUB CATEGORIES
  // =====================================================

  Widget _buildSubCategoriesBar(ProductListController controller) {
    final catController = Get.find<CategoriesController>();

    return Obx(() {
      final categories = catController.apiCategories;
      if (categories.isEmpty) return const SizedBox.shrink();

      final currentCategory = categories.firstWhere(
            (c) => c['slug'] == controller.categorySlug.value,
        orElse: () => {},
      );

      if (currentCategory.isEmpty ||
          currentCategory['subcategories'] == null ||
          (currentCategory['subcategories'] as List).isEmpty) {
        return const SizedBox.shrink();
      }

      final subCategories =
      currentCategory['subcategories'] as List;

      return SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          itemCount: subCategories.length,
          itemBuilder: (context, index) {
            final subCat = subCategories[index];
            final bool isSelected =
                controller.subCategorySlug.value ==
                    subCat['slug'];

            return GestureDetector(
              onTap: () =>
                  controller.updateSubCategory(subCat['slug']),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                padding:
                const EdgeInsets.symmetric(horizontal: 15),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? kSecondaryColor.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? kSecondaryColor
                        : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  subCat['name']!,
                  style: TextStyle(
                    color: isSelected
                        ? kSecondaryColor
                        : Colors.grey,
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

  // =====================================================
  // PRODUCTS GRID
  // =====================================================

  Widget _buildProductsGrid(
      ProductListController controller,
      AppController appController) {

    final products = controller.filteredProducts;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: products.length,
      itemBuilder: (context, i) {
        final product = products[i];

        return Obx(() => ItemCard(
          product: product,
          isCompact: true,
          isWishlisted:
          appController.isWishlisted(product.id),
          onWishlistToggle: () =>
              appController.toggleWishlist(product.id),
        ));
      },
    );
  }
}