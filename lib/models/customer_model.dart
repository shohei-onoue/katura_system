class Customer {
  final String id;
  final String name;
  final String companyName;
  final String phoneNumber;
  final String address;
  final String email;
  final List<String> orderHistory;
  final List<String> deliveryAddresses;

  Customer({
    required this.id,
    required this.name,
    this.companyName = '',
    required this.phoneNumber,
    required this.address,
    this.email = '',
    this.orderHistory = const [],
    this.deliveryAddresses = const [],
  });

  factory Customer.empty() => Customer(
        id: '',
        name: '',
        phoneNumber: '',
        address: '',
      );

  Customer copyWith({
    String? id,
    String? name,
    String? companyName,
    String? phoneNumber,
    String? address,
    String? email,
    List<String>? orderHistory,
    List<String>? deliveryAddresses,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      companyName: companyName ?? this.companyName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      email: email ?? this.email,
      orderHistory: orderHistory ?? this.orderHistory,
      deliveryAddresses: deliveryAddresses ?? this.deliveryAddresses,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'companyName': companyName,
      'phoneNumber': phoneNumber,
      'address': address,
      'email': email,
      'orderHistory': orderHistory,
      'deliveryAddresses': deliveryAddresses,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      companyName: map['companyName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      address: map['address'] ?? '',
      email: map['email'] ?? '',
      orderHistory: List<String>.from(map['orderHistory'] ?? []),
      deliveryAddresses: List<String>.from(map['deliveryAddresses'] ?? []),
    );
  }
}
