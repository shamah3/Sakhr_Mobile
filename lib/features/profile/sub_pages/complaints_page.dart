import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:bytore/features/profile/controllers/complaints_controller.dart';
import 'package:bytore/core/components/custom_app_bar.dart';


class ComplaintsPage extends StatelessWidget {
  ComplaintsPage({Key? key}) : super(key: key);

  // استدعاء الكنترولر
  final ComplaintsController controller = Get.put(ComplaintsController());

  static const Color primaryBlue = Color(0xFF015C92);
  static const Color secondaryOrange = Color(0xFFFFA931);
  static const Color bgCanvas = Color(0xFFF0F4F8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgCanvas,
      appBar: const CustomAppBar(title: 'مركز الدعم والشكاوى'),
      body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('لماذا تتواصل معنا؟'),
                    _buildDropdownField(),
                    const SizedBox(height: 20),
                    _buildLabel('رقم الطلب'),
                    _buildInputField(hint: 'أدخل الرقم هنا...', icon: Icons.confirmation_number_outlined, controller: controller.orderIdController),
                    const SizedBox(height: 20),
                    _buildLabel('ما المشكلة بالتفصيل؟'),
                    _buildInputField(hint: 'اكتب رسالتك هنا...', icon: Icons.message_outlined, maxLines: 2, controller: controller.messageController),
                    const SizedBox(height: 25),
                    _buildLabel('إثبات الحالة (صور)'),
                    _buildUploadBox(),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              _buildModernSubmitBtn(),
              const SizedBox(height: 30),
              _buildComplaintsList(),
            ],
          ),
        ),
    );
  }

  Widget _buildComplaintsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text("شكاواك السابقة", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        Obx(() {
          if (controller.isFetching.value) return const Center(child: CircularProgressIndicator());
          if (controller.complaints.isEmpty) return Center(child: Text("لا توجد شكاوى سابقة", style: GoogleFonts.cairo(color: Colors.grey)));
          
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.complaints.length,
            itemBuilder: (context, index) {
              final complaint = controller.complaints[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: ListTile(
                  title: Text(complaint.type, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                  subtitle: Text(complaint.message, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.cairo(fontSize: 12)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: complaint.statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(complaint.statusText, style: GoogleFonts.cairo(color: complaint.statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  // --- دوال البناء بنفس تصميمك بالضبط ---

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, right: 5),
      child: Text(text, style: GoogleFonts.cairo(fontWeight: FontWeight.w800, color: Colors.black, fontSize: 14)),
    );
  }

  Widget _buildDropdownField() {
    return Obx(() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: bgCanvas.withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: controller.selectedType.value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: secondaryOrange),
          hint: Text('اختر الشكاوى ', style: GoogleFonts.cairo(fontSize: 13)),
          items: controller.complaintTypes.map((String val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Text(val, style: GoogleFonts.cairo(color: Colors.black, fontSize: 14)),
            );
          }).toList(),
          onChanged: (v) => controller.updateSelectedType(v),
        ),
      ),
    ));
  }


  Widget _buildInputField({required String hint, required IconData icon, int maxLines = 1, TextEditingController? controller}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: primaryBlue, size: 20),
        filled: true,
        fillColor: bgCanvas.withOpacity(0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildUploadBox() {
    return Obx(() => InkWell(
      onTap: () => controller.pickImage(),
      child: Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: primaryBlue.withOpacity(0.2), width: 2, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(15),
          color: controller.fileName.value != null ? Colors.green.withOpacity(0.05) : Colors.transparent,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(controller.fileName.value != null ? Icons.check_circle : Icons.camera_alt_outlined,
                color: controller.fileName.value != null ? const Color(0xFFFFA931) : secondaryOrange),
            Text(controller.fileName.value ?? 'ارفع صورك هنا',
                style: GoogleFonts.cairo(fontSize: 12, color: controller.fileName.value != null ? const Color(0xFFFFA931) : Colors.grey)),
          ],
        ),
      ),
    ));
  }

  Widget _buildModernSubmitBtn() {
    return Obx(() => Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: primaryBlue.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: ElevatedButton(
        onPressed: controller.isLoading.value ? null : () => controller.submitForm(),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: controller.isLoading.value
            ? const CircularProgressIndicator(color: Colors.white)
            : Text('إرسال الآن', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
      ),
    ));
  }
}
