import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:bytore/features/profile/controllers/returned_products_controller.dart';
import 'package:bytore/features/profile/models/returned_product_model.dart';


class ReturnedProductsPage extends StatelessWidget {
  ReturnedProductsPage({Key? key}) : super(key: key);

  // ربط الكنترولر
  final ReturnedProductsController controller = Get.put(ReturnedProductsController());

  // ألوان الهوية البصرية
  static const Color primaryBlue = Color(0xFF015C92);
  static const Color secondaryOrange = Color(0xFFFFA931);
  static const Color bgColor = Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // --- AppBar المنحني الموحد ---
            _buildCurvedAppBar(),

            Expanded(
              child: Obx(() => ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildSectionHeader('طلبات الاسترجاع الخاصة بك'),
                  const SizedBox(height: 15),

                  // بناء القائمة ديناميكياً من الكنترولر
                  ...controller.returnedProducts.map((product) => _buildReturnItem(product)).toList(),

                  const SizedBox(height: 30),
                  _buildReturnPolicyBox(),
                ],
              )),
            ),
          ],
        ),
      ),
      // زر عائم لطلب استرجاع جديد مربوط بدالة في الكنترولر
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => controller.addNewReturnRequest(),
        backgroundColor: primaryBlue,
        icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
        label: Text('طلب استرجاع جديد',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Widget _buildCurvedAppBar() {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryBlue, Color(0xFF0277BD)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(45),
          bottomRight: Radius.circular(45),
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            Positioned(
              right: 15,
              top: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 22),
                onPressed: () => Get.back(), // استخدام GetX للرجوع
              ),
            ),
            Center(
              child: Text(
                'المنتجات المسترجعة',
                style: GoogleFonts.cairo(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.cairo(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: primaryBlue,
      ),
    );
  }

  Widget _buildReturnItem(ReturnedProductModel product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.inventory_2_outlined, color: primaryBlue),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(product.orderId, style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 5),
                Text(product.price, style: GoogleFonts.cairo(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(product.icon, color: product.statusColor, size: 20),
              const SizedBox(height: 5),
              Text(
                product.status,
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: product.statusColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReturnPolicyBox() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: secondaryOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: secondaryOrange.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: secondaryOrange),
              const SizedBox(width: 10),
              Text(
                'تذكير بسياسة الاسترجاع',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: primaryBlue),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'يمكنك تقديم طلب استرجاع للأجهزة خلال 3 أيام من تاريخ الاستلام، بشرط أن يكون المنتج بحالته الأصلية وفي التغليف المصنعي.',
            style: GoogleFonts.cairo(fontSize: 12, height: 1.6, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
