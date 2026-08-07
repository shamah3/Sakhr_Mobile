import 'package:bytore/features/profile/controllers/messages_controller.dart';
import 'package:bytore/features/stores/models/store_model.dart';
import 'package:bytore/features/chat/views/chat_detail_view.dart';
import 'package:bytore/core/components/custom_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class MessagesPage extends GetView<MessagesController> {
  const MessagesPage({super.key});

  static const Color kSakhrBlue = Color(0xFF015C92);
  static const Color kSakhrGold = Color(0xFFFFA931);
  static const Color kBgColor = Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<MessagesController>()) Get.put(MessagesController());

    return Scaffold(
      backgroundColor: kBgColor,
      appBar: AppBar(
        backgroundColor: kSakhrBlue,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "مركز رسائل المتاجر",
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () => controller.fetchStores(),
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          )
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: kSakhrBlue));
              }

              final stores = controller.filteredStores;
              if (stores.isEmpty) {
                return _buildEmptyState();
              }

              return GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 0.85,
                ),
                itemCount: stores.length,
                itemBuilder: (context, index) => _buildStoreCard(stores[index]),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: kSakhrBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(15),
        ),
        child: TextField(
          onChanged: (v) => controller.searchQuery.value = v,
          textAlign: TextAlign.right,
          style: GoogleFonts.cairo(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            hintText: "بحث عن متجر...",
            hintStyle: GoogleFonts.cairo(color: Colors.white.withOpacity(0.5)),
            border: InputBorder.none,
            icon: const Icon(Icons.search_rounded, color: Colors.white70, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildStoreCard(StoreModel store) {
    return GestureDetector(
      onTap: () {
        Get.to(() => const ChatDetailView(), id: 3, arguments: {
          'storeId': store.id,
          'senderName': store.name,
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: kSakhrBlue.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: CustomImage(
                    imageUrl: store.logo ?? "",
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
                if (store.isVerified)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.verified_rounded, color: Colors.blue, size: 18),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              store.name,
              style: GoogleFonts.cairo(fontWeight: FontWeight.w900, color: kSakhrBlue, fontSize: 14),
            ),
            Text(
              store.category ?? "متجر إلكتروني",
              style: GoogleFonts.cairo(color: Colors.grey, fontSize: 10),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: kSakhrGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "مراسلة الآن",
                style: GoogleFonts.cairo(color: kSakhrGold, fontWeight: FontWeight.bold, fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.store_mall_directory_outlined, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 15),
          Text(
            "لا توجد متاجر مسجلة حالياً",
            style: GoogleFonts.cairo(color: Colors.grey, fontSize: 14),
          ),
          TextButton(
            onPressed: () => controller.fetchStores(),
            child: Text("تحديث البيانات", style: GoogleFonts.cairo(color: kSakhrGold)),
          ),
        ],
      ),
    );
  }
}
