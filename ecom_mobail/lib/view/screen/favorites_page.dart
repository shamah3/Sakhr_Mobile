
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

// --- 1. الكنترولر لإدارة البيانات ---
class FavoritesController extends GetxController {
  var favoriteProducts = <Map<String, dynamic>>[
    {
      'id': '1',
      'name': 'لابتوب احترافي للألعاب',
      'price': '450,000',
      'image': 'https://images.unsplash.com/photo-1541807084-5c52b6b3adef?w=500&q=80',
    },
    {
      'id': '2',
      'name': 'كاميرا تصوير احترافية',
      'price': '220,000',
      'image': 'https://images.unsplash.com/photo-1510127034890-ba27088e25dc?w=500&q=80',
    },
    {
      'id': '3',
      'name': 'سماعات رأس لاسلكية',
      'price': '55,000',
      'image': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500&q=80',
    },
  ].obs;

  void removeFromFavorites(String productId) {
    favoriteProducts.removeWhere((p) => p['id'] == productId);
    Get.snackbar(
      'المفضلة',
      'تم حذف المنتج بنجاح',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      margin: const EdgeInsets.all(15),
    );
  }
}

// --- 2. صفحة المفضلة بالتصميم المطور ---
class FavoritesPage extends StatelessWidget {
  FavoritesPage({Key? key}) : super(key: key);

  final FavoritesController controller = Get.put(FavoritesController());

// الألوان الثابتة للهوية
  static const Color _primaryBlue = Color(0xFF015C92);
  static const Color _secondaryOrange = Color(0xFFFFA931);
  static const Color _bgColor = Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
// استدعاء الـ AppBar المطور
      appBar: _buildModernAppBar(),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Obx(() {
          if (controller.favoriteProducts.isEmpty) {
            return _buildEmptyState();
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.favoriteProducts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 0.68, // تحسين النسبة لتناسب التصميم الجذاب
            ),
            itemBuilder: (context, index) {
              final product = controller.favoriteProducts[index];
              return _ModernProductCard(
                product: product,
                onDelete: () => controller.removeFromFavorites(product['id']),
              );
            },
          );
        }),
      ),
    );
  }

// تصميم AppBar عصري ومحترف
  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      title: Text(
        'منتجاتي المفضلة',
        style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      centerTitle: true,
      backgroundColor: _primaryBlue,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.white),
        onPressed: () => Get.back(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border_rounded, size: 100, color: _secondaryOrange.withOpacity(0.3)),
          const SizedBox(height: 20),
          Text(
            'لا توجد مفضلات بعد',
            style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold, color: _primaryBlue),
          ),
          const SizedBox(height: 10),
          Text(
            'المنتجات التي تعجبك ستظهر هنا',
            style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// --- 3. بطاقة المنتج الجذابة (Modern UI) ---
class _ModernProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onDelete;

  const _ModernProductCard({required this.product, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
// قسم الصورة
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    image: DecorationImage(
                      image: NetworkImage(product['image']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
// قسم المعلومات
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${product['price']} ريال',
                      style: GoogleFonts.cairo(
                        color: const Color(0xFFFFA931),
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
// زر الإضافة للسلة (جذاب)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF015C92),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Icon(Icons.add_shopping_cart, size: 20, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
// زر الحذف "طائر"
          Positioned(
            top: 8,
            right: 8,
            child: InkWell(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
