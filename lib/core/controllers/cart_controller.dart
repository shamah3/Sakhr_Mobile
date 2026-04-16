import 'package:get/get.dart';
import 'package:bytore/features/product/models/product_model.dart';
import 'package:bytore/core/services/notification_service.dart';
import 'package:bytore/features/profile/controllers/activities_controller.dart';
import 'package:bytore/features/notifications/controllers/notification_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CartItem {
  final Product product;
  var quantity = 1.obs;

  CartItem({
    required this.product,
    int initialQuantity = 1,
  }) {
    quantity.value = initialQuantity;
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity.value,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['product']),
      initialQuantity: json['quantity'] ?? 1,
    );
  }
}

class CartController extends GetxController {
  // Reactive map of items
  final RxMap<int, CartItem> _items = <int, CartItem>{}.obs;

  // Coupon & Discount State
  final RxnString _appliedCoupon = RxnString();
  final RxDouble _discountPercentage = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCart();
    
    // Auto-save whenever items change
    ever(_items, (_) => _saveCart());
  }

  Future<void> _loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cartJson = prefs.getString('cart_items');
      if (cartJson != null) {
        final Map<String, dynamic> decoded = jsonDecode(cartJson);
        final Map<int, CartItem> loadedItems = {};
        decoded.forEach((key, value) {
          loadedItems[int.parse(key)] = CartItem.fromJson(value);
        });
        _items.assignAll(loadedItems);
      }
    } catch (e) {
      print("Error loading cart: $e");
    }
  }

  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> toSave = {};
      _items.forEach((key, value) {
        toSave[key.toString()] = value.toJson();
      });
      await prefs.setString('cart_items', jsonEncode(toSave));
    } catch (e) {
      print("Error saving cart: $e");
    }
  }

  String? get appliedCoupon => _appliedCoupon.value;
  double get discountAmount => totalAmountBeforeDiscount * _discountPercentage.value;

  Map<int, CartItem> get items => _items;

  int get itemCount => _items.length;

  double get totalAmountBeforeDiscount {
    double total = 0.0;
    _items.forEach((_, cartItem) {
      total += cartItem.product.price * cartItem.quantity.value;
    });
    return total;
  }

  double get totalAmount => totalAmountBeforeDiscount - discountAmount;

  int get totalQuantity {
    int total = 0;
    _items.forEach((_, item) {
      total += item.quantity.value;
    });
    return total;
  }

  // Cost in USD (approx 1000 YER)
  double get shippingCost => 2.0;

  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity.value++;
    } else {
      _items[product.id] = CartItem(product: product);
    }
    
    NotificationService().showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: 'السلة',
      body: 'تم إضافة ${product.name} إلى السلة',
    );
    
    // Update Notification Center
    try {
      Get.find<NotificationController>().addNotification(
        "السلة",
        "تم إضافة ${product.name} إلى السلة",
        category: "الكل"
      );
    } catch (_) {}

    // Log Activity
    try {
      Get.find<ActivitiesController>().logActivity(
        title: 'إضافة "${product.name}" للسلة',
        type: 'cart' 
      );
    } catch (e) {
      print("ActivitiesController log error: $e");
    }

  }

  void incrementItem(int productId) {
    if (_items.containsKey(productId)) {
      _items[productId]!.quantity.value++;
    }
  }

  void decrementOrRemoveItem(int productId) {
    if (!_items.containsKey(productId)) return;

    if (_items[productId]!.quantity.value > 1) {
      _items[productId]!.quantity.value--;
    } else {
      _items.remove(productId);
    }
  }

  void removeItem(int productId) {
    _items.remove(productId);
  }

  bool applyCoupon(String code) {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode == "BYTORE" || cleanCode == "YEMEN") {
      _appliedCoupon.value = cleanCode;
      _discountPercentage.value = 0.10;
      return true;
    } else if (cleanCode == "NICE") {
      _appliedCoupon.value = cleanCode;
      _discountPercentage.value = 0.20;
      return true;
    }
    return false;
  }

  void clearCoupon() {
    _appliedCoupon.value = null;
    _discountPercentage.value = 0.0;
  }

  void clearCart() {
    _items.clear();
    clearCoupon();
  }
}
