import 'package:flutter/material.dart';
import 'package:bytore/features/stores/models/advertisement_model.dart';
import 'package:bytore/core/components/custom_image.dart';
import 'package:bytore/core/constants/constants.dart';
import 'package:get/get.dart';

class AdBannerCard extends StatelessWidget {
  final AdvertisementModel ad;

  const AdBannerCard({super.key, required this.ad});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showAdDetail(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Image Header with Store Badge
                Stack(
                  children: [
                    Hero(
                      tag: 'ad_image_${ad.id}',
                      child: CustomImage(
                        imageUrl: ad.image,
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 20,
                      left: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (ad.storeLogo != null && ad.storeLogo!.isNotEmpty) ...[
                               CircleAvatar(
                                 radius: 12,
                                 backgroundImage: NetworkImage(ad.storeLogo!),
                               ),
                               const SizedBox(width: 8),
                            ],
                            Text(
                              ad.storeName ?? "متجر مميز",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: kTextColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (ad.budget != null)
                      Positioned(
                        bottom: 20,
                        right: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: kSecondaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "ميزانية: ${ad.budget?.toStringAsFixed(0)} $kCurrency",
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),

                // 2. Info Section (Centered)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    children: [
                      Text(
                        ad.title ?? "عرض حصري",
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: kTextColor, height: 1.5),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        ad.description ?? "اكتشف هذا العرض الحصري واستمتع بأفضل الأسعار.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: kTextColor.withOpacity(0.4), height: 1.5),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildCenteredInfo(Icons.event_available_rounded, "ينتهي", (ad.endDate ?? '-').split('T')[0]),
                            Container(width: 1, height: 30, color: Colors.grey.withOpacity(0.1), margin: const EdgeInsets.symmetric(horizontal: 20)),
                            _buildCenteredInfo(Icons.account_balance_wallet_rounded, "الميزانية", "${ad.budget?.toStringAsFixed(0) ?? '0'} $kCurrency"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCenteredInfo(IconData icon, String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: kPrimaryColor.withOpacity(0.5)),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: kTextColor)),
      ],
    );
  }

  void _showAdDetail(BuildContext context) {
    // We can reuse the same beautiful dialog logic here if needed, or expand it
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 80),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Blue Brand Header (Thin Bar)
              Container(
                height: 6,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
              ),
              
              Stack(
                children: [
                   ClipRRect(
                    // Slightly adjusted radius because of the bar above
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(0)),
                    child: CustomImage(imageUrl: ad.image, height: 160, width: double.infinity, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 15, right: 15,
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.close_rounded, size: 20, color: kTextColor),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ad.title ?? "", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: kTextColor)),
                    const SizedBox(height: 10),
                    Text(ad.description ?? "", style: TextStyle(fontSize: 15, color: kTextColor.withOpacity(0.6), height: 1.6)),
                    const SizedBox(height: 25),
                    
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      decoration: BoxDecoration(
                        color: kBgColor,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: kPrimaryColor.withOpacity(0.04)),
                      ),
                      child: Column(
                        children: [
                          _buildPopupRow(Icons.storefront_rounded, "المتجر", ad.storeName ?? "متجر شريك"),
                          const Divider(height: 15),
                          _buildPopupRow(Icons.account_balance_wallet_rounded, "الميزانية", "${ad.budget?.toStringAsFixed(0) ?? '0'} $kCurrency"),
                          const Divider(height: 15),
                          _buildPopupRow(Icons.event_available_rounded, "تاريخ الانتهاء", "${(ad.endDate ?? '-').split('T')[0]}"),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () {
                                Get.back();
                                Get.toNamed('/ads-view');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFA931), // Direct Orange
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text("جميع العروض", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () {
                                Get.back();
                                if (ad.targetUrl != null && ad.targetUrl!.isNotEmpty) {
                                  // logic
                                } else {
                                  Get.toNamed('/product-list', arguments: {'storeId': ad.storeId, 'categoryTitle': ad.storeName});
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFA931), // Direct Orange
                                foregroundColor: Colors.white,
                                elevation: 2,
                                shadowColor: const Color(0xFFFFA931).withOpacity(0.3),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text("زيارة المتجر", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopupRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: kPrimaryColor),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: kTextColor)),
          ],
        ),
      ],
    );
  }
}
