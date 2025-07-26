// lib/model/product_model.dart
import 'dart:convert';

Product productFromJson(String str) => Product.fromMap(json.decode(str));

String productToJson(Product data) => json.encode(data.toMap());

class Product {
  final int? id;
  final String title;
  final String description;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final String brand;
  final String category;
  final String thumbnail;
  final List<String> images;

  Product({
    this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.brand,
    required this.category,
    required this.thumbnail,
    required this.images,
  });

  factory Product.fromMap(Map<String, dynamic> json) => Product(
    id: json['id'], // Pastikan casting ke int
    title: json['title'],
    description: json['description'],
    price: (json['price'] as num).toDouble(), // Tangani num ke double
    discountPercentage:
        (json['discountPercentage'] as num).toDouble(), // Tangani num ke double
    rating: (json['rating'] as num).toDouble(), // Tangani num ke double
    stock: json['stock'],
    brand: json['brand'],
    category: json['category'],
    thumbnail: json['thumbnail'],
    images: List<String>.from(json['images']), // Casting item list ke String
  );

  Map<String, dynamic> toMap() => {
    "title": title,
    "description": description,
    "price": price,
    "discountPercentage": discountPercentage,
    "rating": rating,
    "stock": stock,
    "brand": brand,
    "category": category,
    "thumbnail": thumbnail,
    "images": List<dynamic>.from(images.map((x) => x)),
  };

  Product copyWith({
    int? id,
    String? title,
    String? description,
    double? price,
    double? discountPercentage,
    double? rating,
    int? stock,
    String? brand,
    String? category,
    String? thumbnail,
    List<String>? images,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      rating: rating ?? this.rating,
      stock: stock ?? this.stock,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      thumbnail: thumbnail ?? this.thumbnail,
      images: images ?? this.images,
    );
  }

  static fromJson(newProductJson) {}

  Object? toJson() {}
}
