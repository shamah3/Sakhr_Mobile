import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bytore/core/constants/constants.dart';
import 'package:bytore/core/controllers/app_controller.dart';
import 'package:bytore/features/home/controllers/home_controller.dart';
import 'package:bytore/features/home/controllers/categories_controller.dart';
import 'package:bytore/features/home/views/components/filter_widgets.dart';

class FilterBottomSheet extends StatelessWidget {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    final homeController = Get.find<HomeController>();
    final catController = Get.put(CategoriesController());

    // حساب السعر الأدنى والأقصى ديناميكياً لتأطير نطاق الأسعار
    double maxProductPrice = 10000.0;
    double minProductPrice = 0.0;
    
    if (homeController.allProducts.isNotEmpty) {
      maxProductPrice = homeController.allProducts.fold(0.0, (prev, curr) => curr.price > prev ? curr.price : prev);
      minProductPrice = homeController.allProducts.fold(maxProductPrice, (prev, curr) => curr.price < prev ? curr.price : prev);
    }

    if (maxProductPrice <= minProductPrice) maxProductPrice = minProductPrice + 100.0;
    if (minProductPrice < 0) minProductPrice = 0.0;

    // Initialize variables OUTSIDE StatefulBuilder
    var tempRange = appController.priceRange.value;

    // Clamp initial tempRange to new dynamic bounds to prevent crashes
    double clampedStart = tempRange.start;
    double clampedEnd = tempRange.end;
    
    if (clampedStart < minProductPrice) clampedStart = minProductPrice;
    if (clampedStart > maxProductPrice) clampedStart = maxProductPrice;
    
    if (clampedEnd > maxProductPrice) clampedEnd = maxProductPrice;
    if (clampedEnd < clampedStart) clampedEnd = clampedStart;

    tempRange = RangeValues(clampedStart, clampedEnd);
    var tempCategory = appController.activeCategory.value;
    var tempBrand = appController.selectedBrand.value;
    var tempAvailability = appController.selectedAvailability.value;
    var tempWarranty = appController.warrantyText.value;
    var tempRegion = appController.selectedRegion.value;

    final TextEditingController minPriceCtrl = TextEditingController(text: tempRange.start.round().toString());
    final TextEditingController maxPriceCtrl = TextEditingController(text: tempRange.end.round().toString());
    
    // استخراج الماركات والضمانات من المنتجات الفعلية ليكون الفلتر "مضبوط بالضبط"
    final List<String> availableBrands = ["الكل", ...homeController.allProducts.map((p) => p.brandName).where((b) => b.isNotEmpty).toSet().toList()..sort()];
    final List<String> availableWarranties = ["الكل", ...homeController.allProducts.map((p) => p.warranty).where((w) => w.isNotEmpty).toSet().toList()..sort()];
    final List<String> yemenGovernorates = [
      "الكل",
      "أمانة العاصمة",
      "صنعاء",
      "عدن",
      "تعز",
      "الحديدة",
      "إب",
      "أبين",
      "لحج",
      "الضالع",
      "شبوة",
      "حضرموت",
      "المهرة",
      "سقطرى",
      "مأرب",
      "الجوف",
      "صعدة",
      "حجة",
      "عمران",
      "ذمار",
      "البيضاء",
      "المحويت",
      "ريمة"
    ];

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      padding: const EdgeInsets.all(25),
      child: StatefulBuilder(
            builder: (context, setModalState) {

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
                    const Text("نطاق السعر", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 10),
                    
                    RangeSlider(
                      values: tempRange,
                      min: minProductPrice,
                      max: maxProductPrice,
                      activeColor: kPrimaryColor,
                      inactiveColor: Colors.grey.shade300,
                      labels: RangeLabels(
                        appController.getFormattedPrice(tempRange.start),
                        appController.getFormattedPrice(tempRange.end),
                      ),
                      onChanged: (RangeValues values) {
                        setModalState(() {
                          tempRange = values;
                          minPriceCtrl.text = values.start.round().toString();
                          maxPriceCtrl.text = values.end.round().toString();
                        });
                      },
                    ),
                    const SizedBox(height: 15),

                    Row(
                      children: [
                        Expanded(
                          child: FilterWidgets.buildTextField("أقل سعر", "", controller: minPriceCtrl, keyboardType: TextInputType.number, onChanged: (val) {
                             if (val.isEmpty) return;
                             double? minVal = double.tryParse(val);
                             if (minVal != null) {
                               if (minVal < minProductPrice) minVal = minProductPrice;
                               if (minVal > tempRange.end) minVal = tempRange.end;
                               setModalState(() {
                                 tempRange = RangeValues(minVal!, tempRange.end);
                               });
                             }
                          }),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: FilterWidgets.buildTextField("أعلى سعر", "", controller: maxPriceCtrl, keyboardType: TextInputType.number, onChanged: (val) {
                             if (val.isEmpty) return;
                             double? maxVal = double.tryParse(val);
                             if (maxVal != null) {
                               if (maxVal > maxProductPrice) maxVal = maxProductPrice;
                               if (maxVal < tempRange.start) maxVal = tempRange.start;
                               setModalState(() {
                                 tempRange = RangeValues(tempRange.start, maxVal!);
                               });
                             }
                          }),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    FilterWidgets.buildDropdownField(
                      tempCategory,
                      null,
                      label: "الفئة",
                      items: catController.apiCategories.map((c) => (c['name'] ?? "").toString()).toList(),
                      onChanged: (v) {
                        setModalState(() => tempCategory = v ?? tempCategory);
                      },
                    ),
                    const SizedBox(height: 20),
                    FilterWidgets.buildDropdownField(
                      tempBrand,
                      null,
                      label: "الماركة",
                      items: availableBrands,
                      onChanged: (v) {
                        setModalState(() => tempBrand = v ?? tempBrand);
                      },
                    ),

                    const SizedBox(height: 20),
                    FilterWidgets.buildDropdownField(
                      tempAvailability,
                      null,
                      label: "التوفر والحالة",
                      hint: "اختيار الحالة",
                      items: ["الكل", "متوفر"],
                      onChanged: (v) {
                        setModalState(() => tempAvailability = v ?? tempAvailability);
                      },
                    ),

                    const SizedBox(height: 20),
                    FilterWidgets.buildDropdownField(
                      tempRegion,
                      null,
                      label: "المنطقة",
                      hint: "اختيار المدينة/المحافظة",
                      items: yemenGovernorates,
                      onChanged: (v) {
                        setModalState(() => tempRegion = v ?? tempRegion);
                      },
                    ),

                    FilterWidgets.buildDropdownField(
                      tempWarranty,
                      null,
                      label: "الضمان",
                      hint: "اختيار مدة الضمان",
                      items: availableWarranties,
                      onChanged: (v) {
                        setModalState(() => tempWarranty = v ?? tempWarranty);
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
                          warranty: tempWarranty,
                          region: tempRegion,
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
    );
  }
}