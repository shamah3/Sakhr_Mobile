import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bytore/features/product/management/product_management_controller.dart';
import 'package:bytore/core/constants/constants.dart';
import 'package:bytore/core/components/custom_app_bar.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class ProductManagementDetailView extends GetView<ProductManagementController> {
  const ProductManagementDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int productId = Get.arguments as int;
    
    // Fetch detail when view opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchProductDetail(productId);
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'تفاصيل المنتج للمراجعة'),
      body: Obx(() {
        if (controller.isLoading.value && controller.selectedProduct.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final product = controller.selectedProduct.value;
        if (product == null) {
          return const Center(child: Text("تعذر جلب بيانات المنتج"));
        }

        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageGallery(product),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatusBadge(product.status),
                        const SizedBox(height: 12),
                        Text(
                          product.name,
                          style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${product.price} ريال",
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            color: kPrimaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(height: 30),
                        _buildInfoRow("اسم المتجر", product.storeName, Icons.storefront),
                        _buildInfoRow("الفئة", product.category, Icons.category_outlined),
                        _buildInfoRow("الكمية", product.stock.toString(), Icons.inventory_2_outlined),
                        _buildInfoRow("المنطقة", product.region, Icons.location_on_outlined),
                        const Divider(height: 30),
                        Text(
                          "الوصف",
                          style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          product.description,
                          style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey[700], height: 1.6),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _buildActionButtons(product.id),
          ],
        );
      }),
    );
  }

  Widget _buildImageGallery(dynamic product) {
    if (product.threeDModel != null && product.threeDModel!.isNotEmpty) {
      return Container(
        height: 350,
        width: double.infinity,
        color: Colors.white,
        child: ModelViewer(
          src: product.threeDModel!,
          autoRotate: true,
          cameraControls: true,
          backgroundColor: Colors.transparent,
          alt: "معاينة 3D",
        ),
      );
    }
    
    return Container(
      height: 300,
      width: double.infinity,
      color: Colors.grey[100],
      child: Image.network(
        product.imageUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.image_not_supported, size: 100, color: Colors.grey),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    switch (status.toLowerCase()) {
      case 'approved': color = Colors.green; text = "موافق عليه"; break;
      case 'rejected': color = Colors.red; text = "مرفوض"; break;
      case 'pending': color = Colors.orange; text = "قيد المراجعة"; break;
      default: color = Colors.blue; text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.cairo(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 10),
          Text(label, style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey[600])),
          const Spacer(),
          Text(value, style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(int id) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _confirmAction("approved", id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text("موافقة", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _confirmAction("rejected", id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text("رفض", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmAction(String status, int id) {
    final title = status == "approved" ? "تأكيد الموافقة" : "تأكيد الرفض";
    final message = status == "approved" ? "هل أنت متأكد من الموافقة على هذا المنتج؟" : "هل أنت متأكد من رفض هذا المنتج؟";

    Get.dialog(
      AlertDialog(
        title: Text(title, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        content: Text(message, style: GoogleFonts.cairo()),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("إلغاء", style: GoogleFonts.cairo(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.updateStatus(id, status);
            },
            child: Text(
              status == "approved" ? "موافقة" : "رفض",
              style: GoogleFonts.cairo(color: status == "approved" ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
