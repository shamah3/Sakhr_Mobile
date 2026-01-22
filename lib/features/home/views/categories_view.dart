import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bytore/core/constants/constants.dart';
import 'package:bytore/data/category_data.dart';
import '../controllers/categories_controller.dart';

class CategoriesView extends GetView<CategoriesController> {
  const CategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    // التأكد من حقن الكنترولر لتجنب أخطاء التوجيه
    if (!Get.isRegistered<CategoriesController>()) Get.put(CategoriesController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildDynamicAppBar(),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            _buildSidebar(),
            Expanded(child: _buildMainContent()),
          ],
        ),
      ),
    );
  }

  // شريط علوي يتبدل بين العنوان وحقل البحث - أيقونة البحث في اليمين
  PreferredSizeWidget _buildDynamicAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Obx(() => IconButton(
        icon: Icon(controller.isSearchActive.value ? Icons.close : Icons.search, color: kTextColor),
        onPressed: controller.toggleSearch,
      )),
      title: Obx(() => controller.isSearchActive.value
          ? TextField(
        autofocus: true,
        onChanged: (val) => controller.searchText.value = val,
        decoration: const InputDecoration(
          hintText: "ابحث عن قسم أو ماركة...",
          border: InputBorder.none,
        ),
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      )
          : const Text(
        "تصفح الأقسام",
        style: TextStyle(color: kTextColor, fontSize: 18, fontWeight: FontWeight.bold),
      )),
      centerTitle: true,
    );
  }

  // الشريط الجانبي بتنسيق الشاشة الرئيسية
  Widget _buildSidebar() {
    return Container(
      width: 85,
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFB),
        border: Border(left: BorderSide(color: Colors.grey.shade100)),
      ),
      child: ListView.builder(
        itemCount: CategoryData.categories.length,
        itemBuilder: (context, index) {
          return Obx(() {
            final isSelected = controller.selectedCategoryIndex.value == index;
            final cat = CategoryData.categories[index];
            return GestureDetector(
              onTap: () => controller.selectCategory(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  border: isSelected ? const Border(right: BorderSide(color: kPrimaryColor, width: 3)) : null,
                ),
                child: Column(
                  children: [
                    Icon(cat['icon'] ?? Icons.apps,
                        color: isSelected ? kPrimaryColor : Colors.grey.shade400, size: 22),
                    const SizedBox(height: 8),
                    Text(cat['name'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? kPrimaryColor : kTextColor
                        )),
                  ],
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildMainContent() {
    return Obx(() {
      final cat = controller.currentCategory;
      final filteredSubs = controller.getFilteredSubCategories();

      // قائمة الماركات مع الفلترة اللحظية
      final brands = ["Apple", "HP", "Dell", "Samsung", "Asus", "Lenovo"]
          .where((b) => b.toLowerCase().contains(controller.searchText.value.toLowerCase()))
          .toList();

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // البانر المتغير حسب القسم
            _buildMainBanner(cat),

            const SizedBox(height: 25),
            _buildSectionTitle("الأقسام الفرعية"),
            const SizedBox(height: 15),

            // أقسام فرعية بتمرير أفقي ودوائر ملونة
            _buildHorizontalSubCategories(filteredSubs),

            const SizedBox(height: 30),
            _buildSectionTitle("الماركات الشائعة"),
            const SizedBox(height: 15),

            // ماركات بتنسيق مربعات ملونة بـ kBgColor
            _buildBrandsGrid(brands),
            const SizedBox(height: 80),
          ],
        ),
      );
    });
  }

  Widget _buildMainBanner(Map cat) {
    return Container(
      height: 130,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: NetworkImage(cat['image'] ?? ""),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.black.withOpacity(0.5), Colors.transparent],
            begin: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(15),
        alignment: Alignment.bottomRight,
        child: Text(cat['name'],
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // الأقسام الفرعية: تمرير أفقي ودوائر
  Widget _buildHorizontalSubCategories(List subs) {
    if (subs.isEmpty) return const Text("لا توجد نتائج", style: TextStyle(color: Colors.grey, fontSize: 11));

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: subs.length,
        itemBuilder: (context, index) {
          final sub = subs[index];
          return GestureDetector(
            onTap: () => controller.navigateToProducts(sub['name'], sub['slug']),
            child: Container(
              width: 80,
              margin: const EdgeInsets.only(left: 15),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: kBgColor, // نفس لون الماركات لتوحيد الهوية
                      shape: BoxShape.circle,
                    ),
                    child: Icon(sub['icon'] ?? Icons.category_rounded, color: kPrimaryColor, size: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(sub['name'],
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: kTextColor)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // الماركات: مربعات ملونة بـ kBgColor
  Widget _buildBrandsGrid(List brands) {
    if (brands.isEmpty) return const Text("لا توجد نتائج", style: TextStyle(color: Colors.grey, fontSize: 11));

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.8,
      ),
      itemCount: brands.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => controller.navigateToProducts("ماركة ${brands[index]}", brands[index].toLowerCase()),
          child: Container(
            decoration: BoxDecoration(
              color: kBgColor, // اللون الموحد للأقسام والماركات
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Center(
              child: Text(brands[index],
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kTextColor)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
            width: 4, height: 16,
            decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(2))
        ),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kTextColor)),
      ],
    );
  }
}