class MenuModel {
  final String id;
  final String name;
  final String category;
  final int price;
  final String description;
  final String imageUrl;
  final Map<String, String> ingredients; // { "材料名": "使用量" }
  final List<String> cookingSteps; // 調理工程

  MenuModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.description = '',
    this.imageUrl = '',
    this.ingredients = const {},
    this.cookingSteps = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'ingredients': ingredients,
      'cookingSteps': cookingSteps,
    };
  }

  factory MenuModel.fromMap(Map<String, dynamic> map) {
    return MenuModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      price: map['price'] ?? 0,
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      ingredients: Map<String, String>.from(map['ingredients'] ?? {}),
      cookingSteps: List<String>.from(map['cookingSteps'] ?? []),
    );
  }

  MenuModel copyWith({
    String? id,
    String? name,
    String? category,
    int? price,
    String? description,
    String? imageUrl,
    Map<String, String>? ingredients,
    List<String>? cookingSteps,
  }) {
    return MenuModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      ingredients: ingredients ?? this.ingredients,
      cookingSteps: cookingSteps ?? this.cookingSteps,
    );
  }
}
