import 'package:flutter/material.dart';
import 'package:bytore/core/constants/constants.dart';

class FilterWidgets {
  static Widget buildTextField(String label, String hint, {String? initialValue, Function(String)? onChanged, TextEditingController? controller, TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          initialValue: controller != null ? null : initialValue,
          onChanged: onChanged,
          textAlign: TextAlign.right,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300)
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300)
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12)
          )
        )
      ]
    );
  }

  static Widget buildDropdownField(String? value, IconData? icon, {String? hint, String? label, List<String>? items, Function(String?)? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: (items != null && value != null && items.contains(value)) ? value : null,
          decoration: InputDecoration(
            prefixIcon: icon != null ? Icon(icon, color: kPrimaryColor, size: 20) : null,
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300)
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300)
            ),
          ),
          hint: hint != null ? Text(hint) : null,
          items: (items ?? []).map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
          onChanged: onChanged,
        )
      ]
    );
  }

  static Widget buildElevatedButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed, 
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimaryColor, 
        foregroundColor: Colors.white, 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), 
        padding: const EdgeInsets.symmetric(vertical: 15)
      ), 
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold))
    );
  }

  static Widget buildOutlinedButton(String text, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed, 
      style: OutlinedButton.styleFrom(
        foregroundColor: kTextColor, 
        side: BorderSide(color: Colors.grey.shade300), 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), 
        padding: const EdgeInsets.symmetric(vertical: 15)
      ), 
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold))
    );
  }
}
