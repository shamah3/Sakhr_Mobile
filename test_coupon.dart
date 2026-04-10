import "dart:convert";
class CouponModel {
  final int id;
  final String code;
  final String title;
  final String type; // ratio or fixed
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
      id: int.tryParse(json["id"]?.toString() ?? "0") ?? 0,
      code: json["code"]?.toString() ?? "",
      title: json["title"]?.toString() ?? json["name"]?.toString() ?? json["description"]?.toString() ?? "Œ’„ Œ«’",
      type: (json["type"]?.toString().contains("‰”»…") ?? false) ? "ratio" : 
            (json["type"]?.toString().contains("À«» …") ?? false) ? "fixed" : 
             json["type"]?.toString() ?? "ratio",
      value: double.tryParse(json["value"]?.toString() ?? "0") ?? 0,
      minSpend: double.tryParse(json["min_order_amount"]?.toString() ?? json["min_spend"]?.toString() ?? "0") ?? 0,
      endDate: json["expiry_date"]?.toString() ?? json["expire_at"]?.toString() ?? json["end_date"]?.toString(),
      isActive: json["status"]?.toString().toLowerCase() == "active" || 
                json["is_active"] == 1 || 
                json["is_active"] == true ||
                json["status"]?.toString() == "1" ||
                json["status"] == 1 ||
                json["status"]?.toString() == "‰‘ÿ" ||
                json["status"] == null, 
    );
  }
}

void main() {
  String jsonStr = """{"status":true,"message":" „","data":[{"id":6,"store_id":2,"title":"Œ’„ «·«›  «Õ","description":null,"code":"SILICON10","type":"percentage","value":"10.00","min_order_amount":"0.00","max_discount_amount":null,"start_date":"2026-04-09T00:00:00.000000Z","end_date":"2026-05-09T00:00:00.000000Z","usage_limit":100,"used_count":0,"status":"active","applicable_products":null,"created_at":"2026-04-09T19:06:05.000000Z","updated_at":"2026-04-09T19:06:05.000000Z"},{"id":9,"store_id":null,"title":"ﬂÊ»Ê‰: SAVE10","description":" „ ‰ﬁ·Â „‰ ‰Ÿ«„ «·ﬂÊ»Ê‰«  «·ﬁœÌ„","code":"SAVE10","type":"percentage","value":"10.00","min_order_amount":"1000.00","max_discount_amount":null,"start_date":"2026-04-10T00:00:00.000000Z","end_date":"2026-12-31T00:00:00.000000Z","usage_limit":null,"used_count":0,"status":"active","applicable_products":null,"created_at":"2026-04-10T20:33:17.000000Z","updated_at":"2026-04-10T20:33:17.000000Z"}]}""";
  
  final decoded = jsonDecode(jsonStr);
  List<dynamic> rawList = decoded["data"];
  List<CouponModel> parsedCoupons = [];
  
  for (var item in rawList) {
    try {
      parsedCoupons.add(CouponModel.fromJson(Map<String, dynamic>.from(item)));
    } catch (e) {
      print("Failed parsing: \$e");
    }
  }
  print("Successfully parsed: \${parsedCoupons.length}");
}
