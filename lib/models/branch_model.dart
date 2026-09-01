class BranchModel {
  final String id;
  final String name;
  final String companyName; // 社名（フランチャイズのため店舗ごとに異なる。領収書の発行者名に使用）
  final String address;
  final String phone;
  final double latitude;
  final double longitude;
  final String imageUrl;

  const BranchModel({
    required this.id,
    required this.name,
    this.companyName = '',
    required this.address,
    required this.phone,
    required this.latitude,
    required this.longitude,
    this.imageUrl = '',
  });

  factory BranchModel.fromMap(String id, Map<String, dynamic> map) {
    return BranchModel(
      id: id,
      name: map['name'] ?? '',
      companyName: map['companyName'] ?? '',
      address: map['address'] ?? '',
      phone: map['phone'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'companyName': companyName,
      'address': address,
      'phone': phone,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrl': imageUrl,
    };
  }

  BranchModel copyWith({String? name, String? companyName, String? address, String? phone, double? latitude, double? longitude, String? imageUrl}) {
    return BranchModel(
      id: id,
      name: name ?? this.name,
      companyName: companyName ?? this.companyName,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
