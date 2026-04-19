import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bytore/core/constants/constants.dart';
import 'package:bytore/features/home/controllers/home_controller.dart';
import 'package:bytore/features/home/views/components/ad_banner_card.dart';
import 'package:google_fonts/google_fonts.dart';

class AdsView extends StatelessWidget {
  const AdsView({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. Clean, Minimal SliverAppBar (Compact)
          SliverAppBar(
            expandedHeight: 100,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.white,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: kTextColor, size: 18),
              onPressed: () => Get.back(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(bottom: 12),
              centerTitle: true,
              title: Text(
                "العروض والخصومات",
                style: GoogleFonts.cairo(
                  color: kTextColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              background: Container(color: Colors.white),
            ),
          ),

          // 2. Organized Info Bar (Smoother)
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 18),
                  const SizedBox(width: 8),
                  const Text(
                    "أحدث العروض المضافة",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kTextColor),
                  ),
                  const Spacer(),
                  Obx(() => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                    child: Text(
                      "${homeController.advertisements.length} عرض",
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  )),
                ],
              ),
            ),
          ),

          // 3. Main Content
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            sliver: Obx(() {
              if (homeController.advertisements.isEmpty) {
                return SliverFillRemaining(
                   hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(color: kBgColor, shape: BoxShape.circle),
                          child: Icon(Icons.no_photography_outlined, size: 60, color: Colors.grey.shade300),
                        ),
                        const SizedBox(height: 20),
                        const Text("لا توجد عروض ترويجية حالياً", style: TextStyle(color: kTextColor, fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        Text("تابعنا لتكون أول من يعلم عند إضافة عروض جديدة", style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
                      ],
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final ad = homeController.advertisements[index];
                    return AdBannerCard(ad: ad);
                  },
                  childCount: homeController.advertisements.length,
                ),
              );
            }),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 50)),
        ],
      ),
    );
  }
}
