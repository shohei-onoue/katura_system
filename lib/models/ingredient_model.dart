class IngredientModel {
  final String id;
  final String name;
  final String unit;
  final String category;
  final String note;

  const IngredientModel({
    required this.id,
    required this.name,
    this.unit = 'g',
    this.category = 'その他',
    this.note = '',
  });

  factory IngredientModel.fromMap(String id, Map<String, dynamic> map) {
    return IngredientModel(
      id: id,
      name: map['name'] ?? '',
      unit: map['unit'] ?? 'g',
      category: map['category'] ?? 'その他',
      note: map['note'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'unit': unit,
      'category': category,
      'note': note,
    };
  }

  IngredientModel copyWith({String? name, String? unit, String? category, String? note}) {
    return IngredientModel(
      id: id,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      note: note ?? this.note,
    );
  }
}
