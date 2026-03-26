import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bytore/core/constants/constants.dart';
import '../controllers/notification_controller.dart';
import '../models/notification_model.dart';

class NotificationView extends StatelessWidget {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationController());

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6F9),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: kTextColor, size: 20),
            onPressed: () => Get.back(),
          ),
          title: const Text(
            'الإشعارات',
            style: TextStyle(color: kTextColor, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          actions: [
            Obx(() => controller.notifications.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: _buildDeleteAllButton(context, controller),
                  )
                : const SizedBox.shrink()),
          ],
          bottom: TabBar(
            labelColor: kPrimaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: kPrimaryColor,
            dividerColor: Colors.transparent,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: const [
              Tab(text: "الكل"),
              Tab(text: "الطلبات"),
              Tab(text: "العروض"),
            ],
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return TabBarView(
            children: [
              _buildNotificationSection(controller, "الكل"),
              _buildNotificationSection(controller, "الطلبات"),
              _buildNotificationSection(controller, "العروض"),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildNotificationSection(NotificationController controller, String category) {
    final filteredList = category == "الكل"
        ? controller.notifications
        : controller.notifications.where((n) {
            final String cat = n.category ?? "الكل";
            if (category == "الطلبات" && (n.title.contains('طلب') || cat == "الطلبات")) return true;
            if (category == "العروض" && (n.title.contains('عرض') || n.title.contains('خصم') || cat == "العروض")) return true;
            return cat == category;
          }).toList();

    if (filteredList.isEmpty) return _buildEmptyState(Get.context!);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final item = filteredList[index];
        return Dismissible(
          key: Key(item.id.toString()),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            controller.deleteNotification(item.id);
          },
          background: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.delete_sweep, color: Colors.white, size: 30),
          ),
          child: _buildNotificationCard(item),
        );
      },
    );
  }

  Widget _buildNotificationCard(NotificationModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: item.iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(item.icon, color: item.iconColor, size: 24),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: kTextColor),
                      ),
                      if (!item.isRead)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: kSecondaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'جديد',
                            style: TextStyle(color: kSecondaryColor, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.body,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.timeAgo,
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteAllButton(BuildContext context, NotificationController controller) {
    return GestureDetector(
      onTap: () {
        Get.dialog(
          AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('تنبيه', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold)),
            content: const Text('هل أنت متأكد من حذف جميع الإشعارات؟', textAlign: TextAlign.right),
            actions: [
              TextButton(onPressed: () => Get.back(), child: const Text('إلغاء', style: TextStyle(color: Colors.grey))),
              TextButton(
                onPressed: () {
                  controller.clearNotifications();
                  Get.back();
                },
                child: const Text('حذف الكل', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: Colors.red.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(35),
              decoration: BoxDecoration(color: kSecondaryColor.withOpacity(0.08), shape: BoxShape.circle),
              child: const Icon(Icons.notifications_none_rounded, size: 100, color: kSecondaryColor),
            ),
            const SizedBox(height: 30),
            const Text('لا توجد إشعارات حالياً', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kTextColor)),
            const SizedBox(height: 12),
            const Text('قائمة الإشعارات الخاصة بك فارغة، سنعلمك فور وصول أي تحديث جديد.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5)),
            const SizedBox(height: 40),
            SizedBox(
              width: 220,
              child: ElevatedButton(
                onPressed: () => Get.offAllNamed('/main'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
                child: const Text('العودة للرئيسية', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
