import "dart:convert";
import "dart:io";

class CouponModel {
  final int id;
  final String title;

  CouponModel({required this.id, required this.title});

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: int.tryParse(json["id"]?.toString() ?? "0") ?? 0,
      title: json["title"]?.toString() ?? "Œ’„",
    );
  }
}

void main() async {
  String url = "http://192.168.8.196:8000/api/v1/discounts";
  
  var request = await HttpClient().getUrl(Uri.parse(url));
  request.headers.add("Accept", "application/json");
  var response = await request.close();
  var responseBody = await response.transform(utf8.decoder).join();
  
  print("Status: \${response.statusCode}");
  
  try {
    final decoded = jsonDecode(responseBody);
    List<dynamic> rawList = [];

    if (decoded is List) {
      rawList = decoded;
    } else if (decoded is Map) {
      void collectFromValue(dynamic value) {
        if (value is List) {
          rawList.addAll(value);
        } else if (value is Map) {
          if (value.containsKey("data")) collectFromValue(value["data"]);
          else if (value.containsKey("discounts")) collectFromValue(value["discounts"]);
          else if (value.containsKey("coupons")) collectFromValue(value["coupons"]);
        }
      }
      collectFromValue(decoded);
    }
    
    print("Raw list size: \${rawList.length}");
    
    int successCount = 0;
    for (var item in rawList) {
      if (item is Map) {
        try {
          var x = CouponModel.fromJson(Map<String, dynamic>.from(item));
          successCount++;
        } catch (e) {
          print("Error parsing: \$e");
        }
      }
    }
    print("Successfully parsed: \$successCount");
  } catch (e) {
    print("JSON decode error: \$e");
  }
}
