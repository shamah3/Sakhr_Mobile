import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bytore/features/product/management/product_management_controller.dart';
import 'package:bytore/core/constants/constants.dart';
import 'package:bytore/core/components/custom_app_bar.dart';
import 'package:bytore/core/routes/app_routes.dart';
import 'package:bytore/features/product/models/product_model.dart';

class ProductManagementView extends GetView<ProductManagementController> {
  const ProductManagementView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: 'إدارة المنتجات التابعة',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: kTextColor),
            onPressed: () => controller.fetchProducts(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.products.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.filteredProducts.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: () => controller.fetchProducts(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = controller.filteredProducts[index];
                    return _buildProductCard(product);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      color: Colors.white,
      child: Obx(() => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip("الكل"),
            _buildFilterChip("pending", label: "قيد المراجعة"),
            _buildFilterChip("approved", label: "تمت الموافقة"),
            _buildFilterChip("rejected", label: "مرفوض"),
          ],
        ),
      )),
    );
  }

  Widget _buildFilterChip(String value, {String? label}) {
    final isSelected = controller.filterStatus.value == value;
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: FilterChip(
        label: Text(
          label ?? value,
          style: GoogleFonts.cairo(
            fontSize: 12,
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) => controller.changeFilter(value),
        selectedColor: kPrimaryColor,
        checkmarkColor: Colors.white,
        backgroundColor: Colors.grey.shade100,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    Color statusColor;
    String statusText;

    switch (product.status.toLowerCase()) {
      case 'approved':
        statusColor = Colors.green;
        statusText = "موافق عليه";
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusText = "مرفوض";
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusText = "قيد المراجعة";
        break;
      default:
        statusColor = Colors.blue;
        statusText = product.status;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () => Get.toNamed(
          AppRoutes.PRODUCT_MANAGEMENT_DETAIL,
          arguments: product.id,
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(color: Colors.grey[200], child: const Icon(Icons.image_not_supported)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.storeName,
                      style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${product.price} ريال",
                          style: GoogleFonts.cairo(
                            color: kPrimaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            statusText,
                            style: GoogleFonts.cairo(
                              color: statusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "لا توجد منتجات حالياً",
            style: GoogleFonts.cairo(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
