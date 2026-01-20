class Product {
  final int id;
  final String name;
  final String sku;
  final String category;
  final double price;
  int stock;

  Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.price,
    required this.stock,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'],
      sku: json['sku'] ?? '',
      category: json['category'] ?? '',
      price: json['price'] is double ? json['price'] : double.parse(json['price'].toString()),
      stock: json['stock'] is int ? json['stock'] : int.parse(json['stock'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'category': category,
      'price': price,
      'stock': stock,
    };
  }
}
