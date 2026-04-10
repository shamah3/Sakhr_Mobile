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

  // الشريط الجانبي بتنسيق احترافي (صور دائرية)
  Widget _buildSidebar() {
    return Container(
      width: 100, // زيادة العرض قليلاً للتناسب مع الصور
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        border: Border(left: BorderSide(color: Colors.grey.withOpacity(0.08))),
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
              child: Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.transparent,
                      borderRadius: isSelected 
                          ? const BorderRadius.only(topLeft: Radius.circular(24), bottomLeft: Radius.circular(24))
                          : BorderRadius.zero,
                    ),
                    child: Column(
                      children: [
                        // الصورة الدائرية
                        Container(
                          width: 54, height: 54,
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: isSelected ? Border.all(color: kPrimaryColor, width: 2) : null,
                            color: isSelected ? Colors.white : Colors.transparent,
                            boxShadow: isSelected ? [BoxShadow(color: kPrimaryColor.withOpacity(0.1), blurRadius: 10)] : null,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: _buildCategorySidebarImage(cat),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                            color: isSelected ? kTextColor : kTextColor.withOpacity(0.5),
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // مؤشر التنقل الجانبي
                  if (isSelected)
                    Positioned(
                      right: 0,
                      top: 25,
                      bottom: 25,
                      width: 4,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: kPrimaryColor,
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(4), bottomLeft: Radius.circular(4)),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildCategorySidebarImage(Map cat) {
    if (cat['id'] == 'all') {
      return Container(
        color: Colors.white,
        child: const Icon(Icons.grid_view_rounded, color: kPrimaryColor, size: 24),
      );
    }
    String imageUrl = cat['image_url'] ?? cat['image'] ?? "";
    if (imageUrl.isNotEmpty && !imageUrl.contains("icons8.com")) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(color: Colors.grey.shade100),
        errorWidget: (context, url, error) => Container(color: Colors.grey.shade100, child: const Icon(Icons.broken_image_outlined, size: 20, color: Colors.grey)),
      );
    }
    return Container(
      color: Colors.grey.shade100,
      child: Icon(cat['id'] == 'all' ? Icons.grid_view_rounded : Icons.category_rounded, color: Colors.grey.shade300, size: 24),
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

      // استخدام دالة التجميع الذكية للماركات
      final List brands = cat['id'] == 'all' 
          ? controller.getAggregatedBrands() 
          : (cat['brands'] as List? ?? []).where((b) => 
               (b['name'] ?? "").toString().toLowerCase().contains(controller.searchText.value.toLowerCase())).toList();

      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMainBanner(cat),
            
            const SizedBox(height: 12), // Reduced from 18
            
            if (filteredSubs.isNotEmpty) ...[
              _buildSectionHeader("الأقسام الفرعية"),
              const SizedBox(height: 8), 
              _buildSubCategoriesGrid(filteredSubs),
            ],

            if (brands.isNotEmpty) ...[
              const SizedBox(height: 12), // Reduced from 18
              _buildSectionHeader("الماركات الشائعة"),
              const SizedBox(height: 8), 
              _buildBrandsGrid(brands),
              const SizedBox(height: 40), // Reduced from 80
            ] else if (filteredSubs.isEmpty) ...[
              const SizedBox(height: 40), // Reduced from 80
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
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imgUrl.isNotEmpty)
              CachedNetworkImage(
                imageUrl: imgUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.grey.shade50),
              ),
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
              bottom: 18, left: 18, right: 18,
              child: Text(
                cat['name']?.toString() ?? "",
                style: const TextStyle(
                  color: Colors.white, 
                  fontSize: 18, 
                  fontWeight: FontWeight.w900, 
                  letterSpacing: 0.5,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 2))],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubCategoriesGrid(List subs) {
    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero, // Add this to remove default padding
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: subs.length,
      itemBuilder: (context, index) {
        final sub = subs[index];
        return GestureDetector(
          onTap: () => controller.navigateToProducts(sub['name'], sub['slug']),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade50),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50, height: 50, // Fixed icon container size
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: _buildCategoryIcon(sub, false, size: 26),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // ضبط ارتفاع النص لضمان محاذاة الصناديق أفقياً بشكل موحد
                  SizedBox(
                    height: 28, // Height for approx 2 lines
                    child: Text(
                      sub['name']?.toString() ?? "",
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: kTextColor, height: 1.1),
                    ),
                  ),
                ],
              ),
            ),
        );
      },
    );
  }

  Widget _buildBrandsGrid(List brands) {
    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero, // Add this to remove default padding
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.3, // Branded pill look
      ),
      itemCount: brands.length,
      itemBuilder: (context, index) {
        final brand = brands[index];
        return GestureDetector(
          onTap: () => controller.navigateToProducts("ماركة ${brand['name']}", brand['slug']),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.withOpacity(0.04)),
            ),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              brand['name']?.toString() ?? "",
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: kTextColor),
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
    // تحسين وتوسيع منطق اختيار الأيقونات ليكون أكثر دقة واحترافية
    if (n.contains('لابتوب') || n.contains('laptop') || n.contains('حاسوب') || n.contains('كتاب') || n.contains('بوك')) {
      if (n.contains('ألترا') || n.contains('ultra')) return Icons.laptop_mac; // أيقونة أنحف للألترا بوك
      if (n.contains('جيمنج') || n.contains('gaming')) return Icons.computer_rounded;
      return Icons.laptop_rounded;
    }
    if (n.contains('شاش') || n.contains('screen') || n.contains('عرض') || n.contains('مراقب')) {
      if (n.contains('منحنية') || n.contains('curved')) return Icons.monitor_rounded;
      if (n.contains('مكتب') || n.contains('office')) return Icons.desktop_windows_rounded;
      return Icons.monitor;
    }
    if (n.contains('هاتف') || n.contains('phone') || n.contains('جوال') || n.contains('موبايل')) {
      return Icons.smartphone_rounded;
    }
    if (n.contains('طابع') || n.contains('print')) return Icons.print_rounded;
    if (n.contains('كاميرا') || n.contains('camera') || n.contains('تصوير')) return Icons.camera_alt_rounded;
    if (n.contains('سماعات') || n.contains('headphone') || n.contains('صوت') || n.contains('بلوتوث')) {
      if (n.contains('رأس') || n.contains('over-ear')) return Icons.headphones_rounded;
      return Icons.headset_rounded;
    }
    if (n.contains('ساعة') || n.contains('watch') || n.contains('ذكية')) return Icons.watch_rounded;
    if (n.contains('ألعاب') || n.contains('game') || n.contains('جيمنج') || n.contains('بلايستيشن')) return Icons.sports_esports_rounded;
    if (n.contains('إكسسوار') || n.contains('accessory') || n.contains('ماوس') || n.contains('لوحة')) return Icons.mouse_rounded;
    if (n.contains('قرص') || n.contains('disk') || n.contains('تخزين')) return Icons.save_rounded;
    if (n.contains('شبك') || n.contains('network') || n.contains('راوتر') || n.contains('واي-فاي')) return Icons.router_rounded;
    if (n.contains('برمج') || n.contains('software')) return Icons.code_rounded;
    if (n.contains('منزل') || n.contains('home') || n.contains('بيت')) return Icons.home_work_rounded;
    
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
