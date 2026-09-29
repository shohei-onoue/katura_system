class BranchModel {
  final String id;
  final String name;
  final String companyName; // 社名（フランチャイズのため店舗ごとに異なる。領収書の発行者名に使用）
  final String address;
  final String phone;
  final double latitude;
  final double longitude;
  final String imageUrl;
  final int deliveryVehicleCount; // 配送車両数（未設定は0）

  const BranchModel({
    required this.id,
    required this.name,
    this.companyName = '',
    required this.address,
    required this.phone,
    required this.latitude,
    required this.longitude,
    this.imageUrl = '',
    this.deliveryVehicleCount = 0,
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
      deliveryVehicleCount: (map['deliveryVehicleCount'] as num?)?.toInt() ?? 0,
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
      'deliveryVehicleCount': deliveryVehicleCount,
    };
  }

  BranchModel copyWith({String? name, String? companyName, String? address, String? phone, double? latitude, double? longitude, String? imageUrl, int? deliveryVehicleCount}) {
    return BranchModel(
      id: id,
      name: name ?? this.name,
      companyName: companyName ?? this.companyName,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrl: imageUrl ?? this.imageUrl,
      deliveryVehicleCount: deliveryVehicleCount ?? this.deliveryVehicleCount,
    );
  }
}
