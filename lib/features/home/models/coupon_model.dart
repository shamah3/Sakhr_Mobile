class CouponModel {
  final int id;
  final String code;
  final String title;
  final String type; // 'ratio' or 'fixed'
  final double value;
  final double minSpend;
  final String? endDate;
  final bool isActive;

  CouponModel({
    required this.id,
    required this.code,
    required this.title,
    required this.type,
    required this.value,
    required this.minSpend,
    this.endDate,
    required this.isActive,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: int.tryParse(json['id']?.toString() ?? "0") ?? 0,
      code: json['code']?.toString() ?? "",
      title: json['title']?.toString() ?? json['name']?.toString() ?? json['description']?.toString() ?? "خصم خاص",
      type: (json['type']?.toString().contains('نسبة') ?? false) ? "ratio" : 
            (json['type']?.toString().contains('ثابتة') ?? false) ? "fixed" : 
             json['type']?.toString() ?? "ratio",
      value: double.tryParse(json['value']?.toString() ?? "0") ?? 0,
      minSpend: double.tryParse(json['min_order_amount']?.toString() ?? json['min_spend']?.toString() ?? "0") ?? 0,
      endDate: json['expiry_date']?.toString() ?? json['expire_at']?.toString() ?? json['end_date']?.toString(),
      isActive: json['status']?.toString().toLowerCase() == "active" || 
                json['is_active'] == 1 || 
                json['is_active'] == true ||
                json['status']?.toString() == "نشط" ||
                json['status'] == null, // Assume active if not specified in management list
    );
  }

  String get discountText {
    if (type == 'ratio' || type == 'percentage' || type == 'نسبة') {
      return "${value.toInt()}% OFF";
    }
    return "-${value.toInt()} ر.ي";
  }

  String get details {
    if (minSpend > 0) {
      return "للطلبات فوق ${minSpend.toInt()} ر.ي";
    }
    return "لا يوجد حد أدنى للطلب";
  }
}
