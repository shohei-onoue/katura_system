class Staff {
  final String id;
  final String name;
  final String role;
  final bool isActive;

  Staff({
    required this.id,
    required this.name,
    this.role = '',
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'isActive': isActive,
    };
  }

  factory Staff.fromMap(Map<String, dynamic> map) {
    return Staff(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? '',
      isActive: map['isActive'] ?? true,
    );
  }
}
