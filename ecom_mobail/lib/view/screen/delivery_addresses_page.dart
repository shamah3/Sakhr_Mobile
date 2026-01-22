
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nice/controller/address_controller.dart';
// import 'address_controller.dart';

class AddEditAddressScreen extends StatelessWidget {
AddEditAddressScreen({Key? key}) : super(key: key);

// استدعاء الكنترولر
final AddressController controller = Get.put(AddressController());

static const Color primaryColor = Color(0xFF015C92);
static const Color secondaryColor = Color(0xFFFFA931);

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text(
'إضافة عنوان جديد',
style: TextStyle(
color: Colors.white,
fontWeight: FontWeight.bold,
),
),
backgroundColor: primaryColor,
iconTheme: const IconThemeData(color: Colors.white),
centerTitle: true,
),
body: Directionality(
textDirection: TextDirection.rtl,
child: Form(
key: controller.formKey,
child: ListView(
padding: const EdgeInsets.all(24),
children: [
TextFormField(
controller: controller.titleController,
decoration: const InputDecoration(
labelText: 'اسم العنوان (مثال: المنزل)',
),
validator: (value) => value == null || value.trim().isEmpty
? 'الرجاء إدخال اسم للعنوان'
    : null,
),
const SizedBox(height: 20),

// استخدام Obx لمراقبة تغيير المنطقة في الـ Dropdown
Obx(() => DropdownButtonFormField<String>(
value: controller.selectedArea.value,
decoration: const InputDecoration(labelText: 'المنطقة'),
hint: const Text('اختر المنطقة'),
items: controller.sanaaAreas
    .map(
(area) => DropdownMenuItem<String>(
value: area,
child: Text(area),
),
)
    .toList(),
onChanged: (value) => controller.updateArea(value),
validator: (value) =>
value == null ? 'الرجاء اختيار منطقة' : null,
)),

const SizedBox(height: 20),
TextFormField(
controller: controller.streetController,
decoration: const InputDecoration(labelText: 'الشارع'),
validator: (value) => value == null || value.trim().isEmpty
? 'الرجاء إدخال اسم الشارع'
    : null,
),
const SizedBox(height: 20),
TextFormField(
controller: controller.buildingController,
decoration: const InputDecoration(labelText: 'المبنى'),
validator: (value) => value == null || value.trim().isEmpty
? 'الرجاء إدخال اسم أو رقم المبنى'
    : null,
),
const SizedBox(height: 20),
TextFormField(
controller: controller.apartmentController,
decoration: const InputDecoration(labelText: 'رقم الشقة (اختياري)'),
),
const SizedBox(height: 40),
ElevatedButton(
onPressed: () => controller.saveAddress(),
style: ElevatedButton.styleFrom(
backgroundColor: primaryColor,
padding: const EdgeInsets.symmetric(vertical: 16),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(12),
),
),
child: const Text(


'حفظ العنوان',
style: TextStyle(
fontSize: 18,
color: Colors.white,
fontWeight: FontWeight.bold,
),
),
),
],
),
),
),
);
}
}