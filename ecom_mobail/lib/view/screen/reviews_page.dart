import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:nice/controller//reviews_controller.dart';
import 'package:nice/model/review_model.dart';

class ReviewsPage extends StatelessWidget {
  ReviewsPage({Key? key}) : super(key: key);

  final ReviewsController controller = Get.put(ReviewsController());

  static const Color primaryBlue = Color(0xFF015C92);
  static const Color secondaryOrange = Color(0xFFFFA931);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            _buildCurvedAppBar(),

// التبويبات (Tabs)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: TabBar(
                controller: controller.tabController,
                indicatorColor: secondaryOrange,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: primaryBlue,
                unselectedLabelColor: Colors.grey,
                labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14),
                tabs: const [
                  Tab(text: 'تم التقييم'),
                  Tab(text: 'بانتظار التقييم'),
                ],
              ),
            ),

            Expanded(
              child: TabBarView(
                controller: controller.tabController,
                children: [
                  _buildList(controller.reviewedList, isReviewed: true),
                  _buildList(controller.pendingList, isReviewed: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurvedAppBar() {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [primaryBlue, Color(0xFF0277BD)]),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(45), bottomRight: Radius.circular(45)),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
              onPressed: () => Get.back(),
            ),
            Center(
              child: Text('تقييماتي',
                  style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<ReviewModel> list, {required bool isReviewed}) {
    return Obx(() => ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return isReviewed ? _buildReviewCard(item) : _buildPendingCard(item);
      },
    ));
  }

  Widget _buildReviewCard(ReviewModel review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: primaryBlue.withOpacity(0.1), child: Icon(review.icon, color: primaryBlue)),


              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.productName, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(review.date, style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                      (index) => Icon(Icons.star,
                      size: 16, color: index < (review.rating ?? 0) ? secondaryOrange : Colors.grey[300]),
                ),
              ),
            ],
          ),
          const Divider(height: 25),
          Text(review.comment ?? '', style: GoogleFonts.cairo(fontSize: 13, height: 1.6, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildPendingCard(ReviewModel review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: secondaryOrange.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.pending_actions, color: secondaryOrange),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(review.productName, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(review.date, style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: secondaryOrange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 15),
            ),
            child: Text('قيم الآن',
                style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}