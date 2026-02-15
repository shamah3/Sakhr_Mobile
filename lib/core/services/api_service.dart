import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bytore/features/product/models/product_model.dart';

class ApiService {
  static const String baseUrl = 'https://fakestoreapi.com';

  Future<List<Product>> fetchProducts({String? categorySlug}) async {
    String url = '$baseUrl/products';
    if (categorySlug != null && categorySlug != "all") {
      url = '$baseUrl/products/category/$categorySlug';
    }

    try {
      // 1. Try fetching from network
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 5),
      );

      if (response.statusCode == 200) {
        final String jsonString = utf8.decode(response.bodyBytes);
        
        // Save to cache
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('cached_products_$categorySlug', jsonString);
          await prefs.setInt('cached_products_time', DateTime.now().millisecondsSinceEpoch);
        } catch (e) {
          debugPrint("Failed to cache data: $e");
        }

        return _parseProducts(jsonString);
      } else {
        return await _loadFromCache(categorySlug) ?? _getMockProducts();
      }
    } catch (e) {
      debugPrint("Network error or timeout: $e. Loading from cache...");
      return await _loadFromCache(categorySlug) ?? _getMockProducts();
    }
  }

  Future<List<Product>?> _loadFromCache(String? categorySlug) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cachedString = prefs.getString('cached_products_$categorySlug');
      
      if (cachedString != null && cachedString.isNotEmpty) {
        debugPrint("Loaded products from cache");
        return _parseProducts(cachedString);
      }
    } catch (e) {
      debugPrint("Failed to load from cache: $e");
    }
    return null;
  }

  List<Product> _parseProducts(String jsonString) {
    final List<dynamic> productListJson = json.decode(jsonString);
    List<Product> products = productListJson.map((item) {
      Product p = Product.fromJson(item);
      
      // List of stores from StoresView
      final List<String> storeNames = [
        'عالم التقنية', 'آفاق الكمبيوتر', 'مركز الحلول', 
        'المتجر الذكي', 'كمبيوتك', 'متجر النخبة'
      ];
      final String assignedStore = storeNames[p.id % storeNames.length];

      // Augment with mock variants for testing
      return Product(
        id: p.id,
        name: p.name,
        description: p.description,
        price: p.price,
        oldPrice: p.oldPrice,
        imageUrl: p.imageUrl,
        brandName: p.brandName,
        stock: p.stock,
        status: p.status,
        warranty: p.warranty,
        deliveryTime: p.deliveryTime,
        storeName: assignedStore, // Link to real store
        rating: p.rating,
        buyerCount: p.buyerCount,
        images: [p.imageUrl, "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=500", "https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=500"],
        colors: [
          {'name': 'Black', 'colorCode': 0xFF000000, 'price': p.price, 'image': p.imageUrl},
          {'name': 'Blue', 'colorCode': 0xFF2196F3, 'price': p.price + 10, 'image': "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=500"},
        ],
        sizes: [
          {'name': 'S', 'price': p.price},
          {'name': 'M', 'price': p.price + 5},
          {'name': 'L', 'price': p.price + 10},
        ],
      );
    }).toList();
    
    // --- إضافة منتجات تجريبية للاختبار ---
    products.add(Product(
      id: 8883, 
      name: "سماعات Earbuds Pro - 360° View", 
      description: "سماعات لاسلكية متطورة مع عزل ضوضاء فعال وتجربة دوران 360 درجة ناعمة جداً.", 
      price: 299.0, 
      oldPrice: 350.0,
      imageUrl: "https://scaleflex.cloudimg.io/v7/demo/earbuds/1.jpg", 
      brandName: "Bytore Audio", 
      stock: 25, 
      status: "Available",
      warranty: "سنة واحدة",
      deliveryTime: "وصول خلال يومين",
      rating: 4.8,
      buyerCount: 250,
      images: [
        "https://scaleflex.cloudimg.io/v7/demo/earbuds/1.jpg",
        "https://scaleflex.cloudimg.io/v7/demo/earbuds/18.jpg",
      ],
      threeDImages: List.generate(36, (index) => "https://scaleflex.cloudimg.io/v7/demo/earbuds/${index + 1}.jpg"),
    ));
    
    // Adding Unavailable and On Shipment test products for wishlist verification
    products.add(Product(
      id: 9991, 
      name: "منتج تجريبي - غير متوفر", 
      description: "هذا المنتج غير متوفر حالياً للاختبار.", 
      price: 1500.0, 
      oldPrice: 1800.0,
      imageUrl: "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=500", 
      brandName: "Bytore Test", 
      stock: 0, 
      status: "Out of Stock",
      warranty: "بدون ضمان",
      deliveryTime: "N/A",
      rating: 0.0,
      buyerCount: 0,
    ));
    products.add(Product(
      id: 9992, 
      name: "منتج تجريبي - قيد الشحن", 
      description: "هذا المنتج في طريقه للمخازن حالياً.", 
      price: 2500.0, 
      oldPrice: 2800.0,
      imageUrl: "https://images.unsplash.com/photo-1525547719571-a2d4ac8945e2?w=500", 
      brandName: "Bytore Test", 
      stock: 5, 
      status: "On Shipment",
      warranty: "سنة واحدة",
      deliveryTime: "10 أيام",
      rating: 3.5,
      buyerCount: 20,
    ));
    // ----------------------------------------------------

    return products;
  }

  // بيانات تجريبية (Mock Data) لضمان عمل التطبيق في أي وقت
  List<Product> _getMockProducts() {
    return [
      Product(
        id: 1,
        name: "لابتوب احترافي - عرض خاص",
        description: "لابتوب حديث بكافة المواصفات التي تحتاجها.",
        price: 999.99,
        oldPrice: 1200.0,
        imageUrl: "https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=500",
        brandName: "Electronic",
        stock: 10,
        status: "في المخزن",
        warranty: "سنة واحدة",
        deliveryTime: "وصول خلال 2 يوم",
        storeName: "عالم التقنية", // Registered store
        rating: 4.8,
        buyerCount: 150,
        images: ["https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=500", "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=500"],
        colors: [
           {'name': 'Black', 'colorCode': 0xFF000000, 'price': 999.99, 'image': "https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=500"},
           {'name': 'Grey', 'colorCode': 0xFF808080, 'price': 1050.0, 'image': "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=500"},
        ],
        sizes: [
          {'name': '13"', 'price': 999.99},
          {'name': '15"', 'price': 1199.99},
        ],
      ),
      Product(
        id: 2,
        name: "سماعات رأس لاسلكية",
        description: "صوت نقي وتصميم مريح.",
        price: 199.99,
        oldPrice: 250.0,
        imageUrl: "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500",
        brandName: "Audio",
        stock: 50,
        status: "في المخزن",
        warranty: "6 أشهر",
        deliveryTime: "وصول خلال 3 أيام",
        storeName: "مركز الحلول", // Registered store
        rating: 4.2,
        buyerCount: 320,
        images: ["https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500"],
      ),
      Product(
          id: 9991, 
          name: "منتج غير متوفر (تست)", 
          description: "منتج للتجربة - غير متوفر", 
          price: 1500.0, 
          oldPrice: 1800.0,
          imageUrl: "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=500", 
          brandName: "Test Brand", 
          stock: 0, // غير متوفر
          status: "Out of Stock",
          warranty: "N/A",
          deliveryTime: "N/A",
          rating: 0.0,
          buyerCount: 0,
        ),
        Product(
          id: 9992, 
          name: "منتج قيد الشحن (تست)", 
          description: "منتج للتجربة - قيد الشحن", 
          price: 2500.0, 
          oldPrice: 2800.0,
          imageUrl: "https://images.unsplash.com/photo-1525547719571-a2d4ac8945e2?w=500", 
          brandName: "Test Brand", 
          stock: 5, 
          status: "On Shipment", // قيد الشحن
          warranty: "1 Year",
          deliveryTime: "10 Days",
          rating: 3.5,
          buyerCount: 20,
        ),
    ];
  }
}
