class Customer {
  final String id;
  final String name;
  final String furigana;
  final String companyName;
  final String phoneNumber;
  final String address;
  final double? latitude;
  final double? longitude;
  final String email;
  final List<String> orderHistory;
  final List<String> deliveryAddresses;
  final Map<String, List<String>> facilityReceivers; // 新規追加: 施設ごとの既知の受取人
  final String? streetViewImageUrl; // 配達場所ストリートビュー画像URL（null可）
  final String? streetViewImagePath; // Storage上のパス（null可）

  Customer({
    required this.id,
    required this.name,
    this.furigana = '',
    this.companyName = '',
    required this.phoneNumber,
    required this.address,
    this.latitude,
    this.longitude,
    this.email = '',
    this.orderHistory = const [],
    this.deliveryAddresses = const [],
    this.facilityReceivers = const {},
    this.streetViewImageUrl,
    this.streetViewImagePath,
  });

  factory Customer.empty() => Customer(
        id: '',
        name: '',
        furigana: '',
        phoneNumber: '',
        address: '',
      );

  Customer copyWith({
    String? id,
    String? name,
    String? furigana,
    String? companyName,
    String? phoneNumber,
    String? address,
    double? latitude,
    double? longitude,
    String? email,
    List<String>? orderHistory,
    List<String>? deliveryAddresses,
    Map<String, List<String>>? facilityReceivers,
    String? streetViewImageUrl,
    String? streetViewImagePath,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      furigana: furigana ?? this.furigana,
      companyName: companyName ?? this.companyName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      email: email ?? this.email,
      orderHistory: orderHistory ?? this.orderHistory,
      deliveryAddresses: deliveryAddresses ?? this.deliveryAddresses,
      facilityReceivers: facilityReceivers ?? this.facilityReceivers,
      streetViewImageUrl: streetViewImageUrl ?? this.streetViewImageUrl,
      streetViewImagePath: streetViewImagePath ?? this.streetViewImagePath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'furigana': furigana,
      'companyName': companyName,
      'phoneNumber': phoneNumber,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'email': email,
      'orderHistory': orderHistory,
      'deliveryAddresses': deliveryAddresses,
      'facilityReceivers': facilityReceivers,
      'streetViewImageUrl': streetViewImageUrl,
      'streetViewImagePath': streetViewImagePath,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] ?? '',
      // ふりがなのみで登録された顧客は、ふりがなを顧客名として扱う
      name: (map['name'] ?? '').toString().trim().isEmpty ? (map['furigana'] ?? '') : map['name'],
      furigana: map['furigana'] ?? '',
      companyName: map['companyName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      address: map['address'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      email: map['email'] ?? '',
      orderHistory: List<String>.from(map['orderHistory'] ?? []),
      deliveryAddresses: List<String>.from(map['deliveryAddresses'] ?? []),
      facilityReceivers: (map['facilityReceivers'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, List<String>.from(v)),
          ) ??
          {},
      streetViewImageUrl: map['streetViewImageUrl'] as String?,
      streetViewImagePath: map['streetViewImagePath'] as String?,
    );
  }
}
