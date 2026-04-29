class Product {
  final int id;
  final String name;
  final String? description;
  final double price; // FCFA
  final int categoryId;
  final String? categoryName;
  final String? imageUrl;

  const Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.categoryId,
    this.categoryName,
    this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as int,
        name: json['name'] as String,
        description: json['description'] as String?,
        price: (json['price'] as num).toDouble(),
        categoryId: json['category_id'] as int,
        categoryName: json['category']?['name'] as String?,
        imageUrl: json['image_url'] as String?,
      );
}
