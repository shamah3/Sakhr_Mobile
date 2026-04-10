import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bytore/core/constants/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
      body: Row(
          children: [
            _buildSidebar(),
            Expanded(child: _buildMainContent()),
          ],
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
        color: const Color(0xFFF8F9FA),
        border: Border(left: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
        }
        return ListView.builder(
          itemCount: controller.apiCategories.length,
          itemBuilder: (context, index) {
            final isSelected = controller.selectedCategoryIndex.value == index;
            final cat = controller.apiCategories[index];
            return GestureDetector(
              onTap: () => controller.selectCategory(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  // إزالة الخط الأيمن وإضافة الحواف الدائرية من الجهة اليسرى (كما في الصورة)
                  borderRadius: isSelected 
                      ? const BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20))
                      : BorderRadius.zero,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                       padding: EdgeInsets.all(isSelected ? 6 : 0),
                       decoration: BoxDecoration(
                           shape: BoxShape.circle,
                           color: isSelected ? kPrimaryColor.withOpacity(0.1) : Colors.transparent,
                       ),
                       child: _buildCategoryIcon(cat, isSelected, size: 26)
                    ),
                    const SizedBox(height: 12),
                    Text(
                      cat['name']?.toString() ?? "",
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.2,
                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
                        color: isSelected ? kPrimaryColor : kTextColor.withOpacity(0.6),
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

  Widget _buildMainContent() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
      }
      if (controller.apiCategories.isEmpty) {
        return const Center(child: Text("لا توجد أقسام متاحة", style: TextStyle(color: Colors.grey)));
      }
      final cat = controller.currentCategory;
      final filteredSubs = controller.getFilteredSubCategories();

      final List allBrands = [];
      for (var sub in filteredSubs) {
        if (sub['brands'] != null && sub['brands'] is List) {
          allBrands.addAll(sub['brands']);
        }
      }
      if (cat['brands'] != null && cat['brands'] is List) {
        allBrands.addAll(cat['brands']);
      }

      final brands = allBrands
          .where((b) => (b['name'] ?? "").toString().toLowerCase().contains(controller.searchText.value.toLowerCase()))
          .toList();

      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMainBanner(cat),

            if (filteredSubs.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildSectionHeader("الأقسام الفرعية"),
              const SizedBox(height: 16),
              _buildSubCategoriesGrid(filteredSubs),
            ],

            if (brands.isNotEmpty) ...[
              const SizedBox(height: 32),
              _buildSectionHeader("الماركات الشائعة"),
              const SizedBox(height: 16),
              _buildBrandsGrid(brands),
              const SizedBox(height: 80),
            ] else if (filteredSubs.isEmpty) ...[
              const SizedBox(height: 80),
              const Center(child: Text("لا توجد نتائج مطابقة", style: TextStyle(color: Colors.grey))),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 5, height: 18,
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(color: Colors.orange.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2)),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: kTextColor)),
      ],
    );
  }

  Widget _buildMainBanner(Map cat) {
    String imgUrl = cat['image_url'] ?? cat['image'] ?? "";
    return Container(
      height: 145,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        image: imgUrl.isNotEmpty
            ? DecorationImage(
                image: CachedNetworkImageProvider(imgUrl),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.black.withOpacity(0.6), Colors.transparent],
            begin: Alignment.bottomRight,
            end: Alignment.center,
          ),
        ),
        padding: const EdgeInsets.all(20),
        alignment: Alignment.bottomRight,
        child: Text(cat['name']?.toString() ?? "",
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSubCategoriesGrid(List subs) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 15,
        crossAxisSpacing: 12,
        childAspectRatio: 0.82,
      ),
      itemCount: subs.length,
      itemBuilder: (context, index) {
        final sub = subs[index];
        return GestureDetector(
          onTap: () => controller.navigateToProducts(sub['name'], sub['slug']),
          child: Column(
            children: [
              Container(
                width: 68, height: 68,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Center(
                  child: _buildCategoryIcon(sub, false, size: 34),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                sub['name']?.toString() ?? "",
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: kTextColor, height: 1.1),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBrandsGrid(List brands) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.1,
      ),
      itemCount: brands.length,
      itemBuilder: (context, index) {
        final brand = brands[index];
        return GestureDetector(
          onTap: () => controller.navigateToProducts("ماركة ${brand['name']}", brand['slug']),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 4, offset: const Offset(0, 1)),
              ],
              border: Border.all(color: Colors.grey.withOpacity(0.1)),
            ),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              brand['name']?.toString() ?? "",
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: kTextColor),
            ),
          ),
        );
      },
    );
  }

  // أيقونة ذكية تختار الشكل بناءً على الاسم إذا لم تتوفر صورة
  Widget _buildCategoryIcon(Map cat, bool isSelected, {double size = 22}) {
    String? imageUrl = cat['image_url'] ?? cat['image'];
    String name = (cat['name'] ?? "").toString();

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        width: size,
        height: size,
        fit: BoxFit.contain,
        placeholder: (context, url) => Icon(_getSemanticIcon(name), color: isSelected ? kPrimaryColor : Colors.grey.shade400, size: size),
        errorWidget: (context, url, error) => Icon(_getSemanticIcon(name), color: isSelected ? kPrimaryColor : Colors.grey.shade400, size: size),
      );
    }
    
    return Icon(_getSemanticIcon(name),
        color: isSelected ? kPrimaryColor : Colors.grey.shade400, size: size);
  }

  // وظيفة ذكية لاختيار أيقونة تعمد على اسم القسم
  IconData _getSemanticIcon(String name) {
    String n = name.toLowerCase();
    if (n.contains('لابتوب') || n.contains('laptop') || n.contains('حاسوب')) return Icons.laptop_mac;
    if (n.contains('شاش') || n.contains('screen') || n.contains('عرض')) return Icons.monitor;
    if (n.contains('هاتف') || n.contains('phone') || n.contains('جوال')) return Icons.phone_android;
    if (n.contains('طابع') || n.contains('print')) return Icons.print_rounded;
    if (n.contains('كاميرا') || n.contains('camera')) return Icons.camera_alt_rounded;
    if (n.contains('سماعات') || n.contains('headphone') || n.contains('صوت')) return Icons.headphones_rounded;
    if (n.contains('ساعة') || n.contains('watch')) return Icons.watch_rounded;
    if (n.contains('ألعاب') || n.contains('game') || n.contains('جيمنج')) return Icons.sports_esports_rounded;
    if (n.contains('إكسسوار') || n.contains('accessory')) return Icons.mouse_rounded;
    if (n.contains('قرص') || n.contains('disk') || n.contains('تخزين')) return Icons.save_rounded;
    if (n.contains('شبك') || n.contains('network') || n.contains('راوتر')) return Icons.router_rounded;
    if (n.contains('برمج') || n.contains('software')) return Icons.code_rounded;
    
    return Icons.category_rounded;
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
