import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bytore/core/controllers/app_controller.dart';
import 'package:bytore/features/home/views/components/filter_widgets.dart';

class AddressBottomSheet extends StatelessWidget {
  const AddressBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();

    // Local state for the sheet
    String city = appController.selectedCity.value;
    String fName = appController.firstName.value;
    String lName = appController.lastName.value;
    String street = appController.streetName.value;
    String landmark = appController.landmark.value;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.vertical(top: Radius.circular(25))
      ),
      padding: const EdgeInsets.all(25),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: Text("عنوان التوصيل", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            const SizedBox(height: 30),
            FilterWidgets.buildDropdownField(
              city,
              Icons.location_on_outlined,
              label: "المحافظة*",
              items: ["أمانة العاصمة", "صنعاء", "عدن", "تعز", "الحديدة", "حضرموت", "إب", "لحج", "أبين", "المهرة", "شبوة", "الجوف", "عمران", "صعدة", "حجة", "البيضاء", "مأرب", "ذمار", "المحويت", "ريمة", "الضالع", "سقطرى"],
              onChanged: (v) => city = v ?? city,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: FilterWidgets.buildTextField("الاسم الأول*", "الرجاء إدخال الاسم", initialValue: fName, onChanged: (v) => fName = v)),
                const SizedBox(width: 15),
                Expanded(child: FilterWidgets.buildTextField("الاسم الأخير*", "الرجاء إدخال اللقب", initialValue: lName, onChanged: (v) => lName = v)),
              ],
            ),
            const SizedBox(height: 20),
            FilterWidgets.buildTextField("اسم الشارع*", "الرجاء إدخال اسم الشارع", initialValue: street, onChanged: (v) => street = v),
            const SizedBox(height: 20),
            FilterWidgets.buildTextField("أقرب معلم*", "مثال: بجانب مستشفى ..", initialValue: landmark, onChanged: (v) => landmark = v),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(child: FilterWidgets.buildOutlinedButton("إلغاء", () => Get.back())),
                const SizedBox(width: 15),
                Expanded(
                  child: FilterWidgets.buildElevatedButton("تعديل العنوان", () {
                    appController.updateAddress(
                      city: city,
                      fName: fName,
                      lName: lName,
                      street: street,
                      landmark: landmark,
                    );
                    Get.back();
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
