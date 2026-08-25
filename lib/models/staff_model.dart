class Staff {
  final String id;
  final String name;
  final String role;
  final bool isActive;
  /// PINのSHA-256ハッシュ値（未設定の場合は空文字。初回ログイン時に登録する）
  final String pinHash;

  Staff({
    required this.id,
    required this.name,
    this.role = '',
    this.isActive = true,
    this.pinHash = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'isActive': isActive,
      'pinHash': pinHash,
    };
  }

  factory Staff.fromMap(Map<String, dynamic> map) {
    return Staff(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? '',
      isActive: map['isActive'] ?? true,
      pinHash: map['pinHash'] ?? '',
    );
  }
}
