import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bytore/core/constants/constants.dart';
import 'package:bytore/features/home/views/components/item_card.dart';
import 'package:bytore/features/home/controllers/home_controller.dart';
import 'package:bytore/core/controllers/app_controller.dart';

class AdsView extends StatelessWidget {
  const AdsView({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    final appController = Get.find<AppController>();

    // For demo purposes, we'll show all "discounted" or special products.
    // In a real app, you might filter by a specific "ad" criteria.
    final adProducts = homeController.allProducts.take(10).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("العروض والخصومات", style: TextStyle(color: kTextColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: kTextColor),
          onPressed: () => Get.back(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Banner Image for the page
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: kPrimaryColor,
              borderRadius: BorderRadius.circular(20),
              image: const DecorationImage(
                image: NetworkImage("https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?q=80&w=2070&auto=format&fit=crop"),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                  begin: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(20),
              alignment: Alignment.bottomRight,
              child: const Text(
                "خصومات تصل إلى 70%\nعلى الإلكترونيات",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
                textAlign: TextAlign.right,
              ),
            ),
          ),
          const SizedBox(height: 30),
          
          const Text("عروض مميزة لك", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kTextColor)),
          const SizedBox(height: 20),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
            ),
            itemCount: adProducts.length,
            itemBuilder: (context, index) {
               return Obx(() => ItemCard(
                product: adProducts[index],
                isWishlisted: appController.isWishlisted(adProducts[index].id),
                onWishlistToggle: () => appController.toggleWishlist(adProducts[index].id),
                isCompact: true,
              ));
            },
          ),
        ],
      ),
    );
  }
}
