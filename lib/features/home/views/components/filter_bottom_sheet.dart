import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bytore/core/constants/constants.dart';
import 'package:bytore/core/controllers/app_controller.dart';
import 'package:bytore/features/home/controllers/home_controller.dart';
import 'package:bytore/data/category_data.dart';
import 'package:bytore/features/home/views/components/filter_widgets.dart';

class FilterBottomSheet extends StatelessWidget {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    final homeController = Get.find<HomeController>();

    // حساب السعر الأقصى ديناميكياً مع وضع حماية لتجنب خطأ الـ Assertion
    double maxProductPrice = 10000.0;
    if (homeController.allProducts.isNotEmpty) {
      maxProductPrice = homeController.allProducts.fold(0.0, (prev, curr) => curr.price > prev ? curr.price : prev);
    }

    // تأمين القيمة لئلا تكون صفر أو أصغر من القيم المختارة حالياً لمنع الشاشة الحمراء
    if (maxProductPrice <= 0) maxProductPrice = 1000.0;
    if (maxProductPrice < appController.priceRange.value.end) {
      maxProductPrice = appController.priceRange.value.end + 100.0;
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      padding: const EdgeInsets.all(25),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(
            builder: (context, setModalState) {
              // استخدام القيم الحالية كبداية للحالة المحلية داخل الـ Sheet
              var tempRange = appController.priceRange.value;
              var tempCategory = appController.activeCategory.value;
              var tempBrand = appController.selectedBrand.value;
              var tempAvailability = appController.selectedAvailability.value;

              // التأكد من توافق النطاق مع الحد الأقصى قبل الرسم لتجنب أخطاء Assertion
              if (tempRange.end > maxProductPrice) {
                tempRange = RangeValues(tempRange.start, maxProductPrice);
              }

              final TextEditingController maxPriceCtrl = TextEditingController(
                  text: tempRange.end.round().toString()
              );

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                        child: Container(
                            width: 50, height: 5,
                            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))
                        )
                    ),
                    const SizedBox(height: 20),
                    const Center(child: Text("فلترة المنتجات", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),

                    const SizedBox(height: 30),
                    const Text("السعر", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 10),

                    FilterWidgets.buildTextField("حدد السعر", "", controller: maxPriceCtrl, onChanged: (val) {
                      double? maxVal = double.tryParse(val);
                      if (maxVal != null) {
                        if (maxVal > maxProductPrice) maxVal = maxProductPrice;
                        if (maxVal < tempRange.start) maxVal = tempRange.start;

                        setModalState(() {
                          tempRange = RangeValues(tempRange.start, maxVal!);
                          appController.priceRange.value = tempRange;
                        });
                      }
                    }),

                    RangeSlider(
                      values: tempRange,
                      min: 0,
                      max: maxProductPrice,
                      divisions: 100,
                      labels: RangeLabels(
                          tempRange.start.round().toString(),
                          tempRange.end.round().toString()
                      ),
                      onChanged: (RangeValues values) {
                        setModalState(() {
                          tempRange = values;
                          appController.priceRange.value = values;
                          maxPriceCtrl.text = values.end.round().toString();
                        });
                      },
                      activeColor: kPrimaryColor,
                      inactiveColor: kPrimaryColor.withOpacity(0.2),
                    ),

                    const SizedBox(height: 20),
                    FilterWidgets.buildDropdownField(
                      tempCategory,
                      null,
                      label: "الفئة",
                      items: CategoryData.categories.map((c) => c['name'] as String).toList(),
                      onChanged: (v) {
                        setModalState(() => tempCategory = v ?? tempCategory);
                        appController.activeCategory.value = tempCategory;
                      },
                    ),
                    const SizedBox(height: 20),
                    FilterWidgets.buildDropdownField(
                      tempBrand,
                      null,
                      label: "الماركة",
                      items: ["الكل", "HP", "Apple", "Dell", "Canon", "Logitech", "Samsung"],
                      onChanged: (v) {
                        setModalState(() => tempBrand = v ?? tempBrand);
                        appController.selectedBrand.value = tempBrand;
                      },
                    ),

                    const SizedBox(height: 20),
                    FilterWidgets.buildDropdownField(
                      tempAvailability,
                      null,
                      label: "التوفر والحالة",
                      hint: "اختيار الحالة",
                      items: ["الكل", "متوفر", "غير متوفر", "قيد الشحن"],
                      onChanged: (v) {
                        setModalState(() => tempAvailability = v ?? tempAvailability);
                        appController.selectedAvailability.value = tempAvailability;
                      },
                    ),

                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () {
                        appController.updateFilters(
                          range: tempRange,
                          category: tempCategory,
                          brand: tempBrand,
                          availability: tempAvailability,
                        );
                        homeController.applyFilters();
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text(
                        "تطبيق",
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            }
        ),
      ),
    );
  }
}