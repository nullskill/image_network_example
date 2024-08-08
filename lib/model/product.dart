class Product {
  final String id;
  final String title;
  final String description;
  final String imageUrl;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      title: json['title'],
      description: json['description'],
      imageUrl: json['image'],
    );
  }
}
