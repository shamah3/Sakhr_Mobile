import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bytore/core/constants/constants.dart';
import '../controllers/checkout_controller.dart';
import 'payment_page.dart';
import 'map_picker_page.dart';

class AddressPage extends GetView<CheckoutController> {
  const AddressPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CheckoutController>()) {
      Get.put(CheckoutController());
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          // زر الرجوع من نظام التلفون → السلة
          Get.offAllNamed('/cart');
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text("عنوان التوصيل", style: TextStyle(color: kTextColor, fontWeight: FontWeight.bold, fontSize: 18)),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: kTextColor, size: 20),
            // سهم AppBar → تسجيل الدخول
            onPressed: () => Get.offAllNamed('/login'),
          ),
        ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          _buildModernProgress(),
          const SizedBox(height: 30),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const Text(
                  "طريقة التوصيل",
                  style: TextStyle(fontWeight: FontWeight.w900, color: kTextColor, fontSize: 16),
                ),
                const SizedBox(height: 15),
                _buildMapPickerButton(context),

                const SizedBox(height: 30),

                const Text(
                  "عناوينك المحفوظة",
                  style: TextStyle(fontWeight: FontWeight.w900, color: kTextColor, fontSize: 16),
                ),
                const SizedBox(height: 15),
                Obx(() => Column(
                  children: List.generate(
                    controller.addresses.length,
                    (index) => _buildAddressCard(index)
                  ),
                )),

                const SizedBox(height: 20),
                _buildAddManualButton(context),
                const SizedBox(height: 30),
              ],
            ),
          ),

          _buildBottomAction(),
        ],
      ),
    ),
    );
  }

  Widget _buildModernProgress() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _stepNode(Icons.location_on_rounded, "العنوان", true),
          _stepLine(false),
          _stepNode(Icons.payment_rounded, "الدفع", false),
          _stepLine(false),
          _stepNode(Icons.check_circle_rounded, "التأكيد", false),
        ],
      ),
    );
  }

  Widget _stepNode(IconData icon, String label, bool isActive) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isActive ? kPrimaryColor : kBgColor,
            shape: BoxShape.circle,
            border: Border.all(color: isActive ? kPrimaryColor : Colors.grey.shade200),
          ),
          child: Icon(icon, color: isActive ? Colors.white : Colors.grey.shade400, size: 18),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: isActive ? kTextColor : Colors.grey, fontSize: 11, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  Widget _stepLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 22, left: 10, right: 10),
        decoration: BoxDecoration(
          color: isActive ? kPrimaryColor : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }

  Widget _buildMapPickerButton(BuildContext context) {
    return InkWell(
      onTap: () async {
        final result = await Get.to(() => const MapPickerPage());

        if (result != null && result is Map<String, dynamic>) {
          controller.addAddress({
            'title': 'موقع من الخريطة',
            'name': 'محمد الكبسي',
            'phone': '777xxxxxx',
            'address': result['address'],
            'city': 'إحداثيات: ${result['lat'].toStringAsFixed(4)}, ${result['lng'].toStringAsFixed(4)}',
          });
          Get.snackbar("نجاح", "تم إضافة الموقع بنجاح", backgroundColor: Colors.green, colorText: Colors.white);
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: kSecondaryColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kSecondaryColor.withOpacity(0.1)),
        ),
        child: const Row(
          children: [
            CircleAvatar(
              backgroundColor: kSecondaryColor,
              child: Icon(Icons.my_location_rounded, color: Colors.white, size: 20),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("تحديد عبر الخريطة", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kTextColor)),
                  Text("تحديد موقعك الحالي بدقة عبر GPS", style: TextStyle(fontSize: 12, color: kTextLightColor)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: kSecondaryColor, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(int index) {
    final address = controller.addresses[index];
    return Obx(() {
      final isSelected = controller.selectedAddressIndex.value == index;
      return GestureDetector(
        onTap: () => controller.selectAddress(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : kBgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: isSelected ? kPrimaryColor : Colors.transparent,
                width: 1.5
            ),
            boxShadow: isSelected ? [
              BoxShadow(
                  color: kPrimaryColor.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 8)
              )
            ] : [],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: isSelected ? kPrimaryColor : Colors.grey.shade300, width: 2),
                  color: isSelected ? kPrimaryColor : Colors.transparent,
                ),
                child: Icon(Icons.check, size: 12, color: isSelected ? Colors.white : Colors.transparent),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(address['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kTextColor)),
                        if (isSelected) const Icon(Icons.home_work_rounded, color: kPrimaryColor, size: 18),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text("${address['address']} - ${address['city']}", style: const TextStyle(color: kTextLightColor, fontSize: 13, height: 1.4)),
                    const SizedBox(height: 10),
                    Text(address['phone']!, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: kTextColor)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showManualAddressDialog(BuildContext context) {
    final titleController = TextEditingController();
    final addressController = TextEditingController();
    final cityController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text("إضافة عنوان يدوي", textAlign: TextAlign.right),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, textAlign: TextAlign.right, decoration: const InputDecoration(labelText: "عنوان (مثلاً: المنزل)")),
            TextField(controller: addressController, textAlign: TextAlign.right, decoration: const InputDecoration(labelText: "الشارع / التفاصيل")),
            TextField(controller: cityController, textAlign: TextAlign.right, decoration: const InputDecoration(labelText: "المدينة")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("إلغاء")),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty && addressController.text.isNotEmpty) {
                 controller.addAddress({
                   'title': titleController.text,
                   'name': 'محمد الكبسي',
                   'phone': '777xxxxxx',
                   'address': addressController.text,
                   'city': cityController.text,
                 });
                 Get.back();
              }
            },
            child: const Text("إضافة"),
          ),
        ],
      ),
    );
  }

  Widget _buildAddManualButton(BuildContext context) {
    return TextButton.icon(
      onPressed: () => _showManualAddressDialog(context),
      icon: const Icon(Icons.add_location_alt_rounded, size: 20),
      label: const Text("أضف عنواناً جديداً"),
      style: TextButton.styleFrom(
        foregroundColor: kPrimaryColor,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: const BorderSide(color: kPrimaryColor, width: 1)
        ),
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("العنوان المختار", style: TextStyle(color: kTextLightColor, fontWeight: FontWeight.bold)),
              Obx(() => Text(
                controller.addresses[controller.selectedAddressIndex.value]['title']!, 
                style: const TextStyle(fontWeight: FontWeight.w900, color: kSecondaryColor, fontSize: 16)
              )),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 55,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: kPrimaryColor.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => Get.to(() => const PaymentPage()),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 0,
              ),
              child: const Text("الاستمرار للدفع", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 40), // Increased from 20 to 40
        ],
      ),
    );
  }
}
