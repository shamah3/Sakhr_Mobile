import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:bytore/features/profile/controllers/returned_products_controller.dart';
import 'package:bytore/features/profile/models/returned_product_model.dart';
import 'package:bytore/core/components/custom_app_bar.dart';



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
      appBar: const CustomAppBar(title: 'المنتجات المسترجعة'),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // --- AppBar المنحني الموحد ---
            // _buildCurvedAppBar(), removed

            Expanded(
              child: Obx(() => ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildSectionHeader('طلبات الاسترجاع الخاصة بك'),
                  const SizedBox(height: 15),

                  // بناء القائمة ديناميكياً من الكنترولر
                  if (controller.returnedProducts.isEmpty)
                    Center(child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text("لا توجد منتجات مسترجعة حالياً", style: GoogleFonts.cairo(color: Colors.grey)),
                    ))
                  else
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
        border: Border.all(color: Colors.grey.shade50),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: product.statusColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(product.icon, color: product.statusColor, size: 20),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text("رقم الطلب: ", style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey)),
                        Text(product.orderId, style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              Text(product.price, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: primaryBlue, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 15),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: product.statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  product.status,
                  style: GoogleFonts.cairo(color: product.statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 30)),
                child: Text("عرض التفاصيل", style: GoogleFonts.cairo(fontSize: 11, color: Colors.blue)),
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
