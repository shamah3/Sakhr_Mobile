class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final double oldPrice; // سعر وهمي قبل الخصم للتصميم
  final String imageUrl;
  final String brandName;
  final int stock;
  final String status;
  final String warranty;
  final String deliveryTime;
  final String storeName; // Added to link to specific stores
  final String category; // Added for precise filtering

  final double rating;
  final int buyerCount;
  final List<String> images; // Multiple images
  final List<String> threeDImages; // 360 Degree images sequence
  final List<Map<String, dynamic>>? colors; // Color variants
  final List<Map<String, dynamic>>? sizes; // Size variants

  Product({
    required this.id, required this.name, required this.description,
    required this.price, required this.oldPrice, required this.imageUrl,
    required this.brandName, required this.stock, required this.status,
    required this.warranty,
    required this.deliveryTime,

    this.storeName = "Bytore Official", // Default store
    this.category = "General", // Default category
    this.rating = 4.5,
    this.buyerCount = 100,
    this.images = const [],
    this.threeDImages = const [],
    this.colors,
    this.sizes,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    double currentPrice = double.tryParse(json['price']?.toString() ?? '0.0') ?? 0.0;
    String img = (json['image'] != null && json['image'].toString().isNotEmpty)
          ? json['image']
          : 'https://via.placeholder.com/150';

    return Product(
      id: json['id'] ?? 0,
      name: json['title']?.toString() ?? 'Unknown',
      description: json['description']?.toString() ?? '',
      price: currentPrice,
      oldPrice: currentPrice * 1.2,
      imageUrl: img,
      brandName: "General", // Default brand, will be overwritten in ApiService
      category: json['category']?.toString() ?? 'General',
      stock: (json['rating'] != null && json['rating']['count'] != null)
          ? json['rating']['count']
          : 0,
      status: ((json['rating'] != null && json['rating']['count'] != null) ? json['rating']['count'] : 0) > 0 ? 'In Stock' : 'Out of Stock',

      warranty: (json['id'] ?? 0) % 2 == 0 ? 'ضمان سنة واحدة' : 'ضمان 6 أشهر',
      deliveryTime: '${(json['id'] ?? 0) % 3 + 2} أيام توصيل',
      rating: (json['rating'] != null && json['rating']['rate'] != null) 
          ? double.tryParse(json['rating']['rate'].toString()) ?? 4.5 
          : 4.5,
      buyerCount: (json['rating'] != null && json['rating']['count'] != null)
          ? json['rating']['count']
          : 100,
      images: [img], // Default to single image
    );
  }
}
