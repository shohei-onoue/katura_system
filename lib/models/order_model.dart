class OrderModel {
  final String id;
  final String customerName;
  final String facilityName;
  final String phoneNumber;
  final String address;
  final DateTime receptionDate; // 受注日
  final DateTime deliveryDate;  // 配達日
  final String deliveryTime;    // 配達時間
  final String deliveryType;
  final List<Map<String, dynamic>> items;
  final int totalCount;
  final String packagingType;
  final String paymentMethod;
  final String status;
  final String branchName; // 追加: 店舗名

  OrderModel({
    required this.id,
    required this.customerName,
    this.facilityName = '',
    required this.phoneNumber,
    required this.address,
    required this.receptionDate,
    required this.deliveryDate,
    required this.deliveryTime,
    required this.deliveryType,
    required this.items,
    required this.totalCount,
    required this.packagingType,
    required this.paymentMethod,
    this.status = '受注済み',
    this.branchName = '岡崎本店',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerName': customerName,
      'facilityName': facilityName,
      'phoneNumber': phoneNumber,
      'address': address,
      'receptionDate': receptionDate.toIso8601String(),
      'deliveryDate': deliveryDate.toIso8601String(),
      'deliveryTime': deliveryTime,
      'deliveryType': deliveryType,
      'items': items,
      'totalCount': totalCount,
      'packagingType': packagingType,
      'paymentMethod': paymentMethod,
      'status': status,
      'branchName': branchName,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] ?? '',
      customerName: map['customerName'] ?? '',
      facilityName: map['facilityName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      address: map['address'] ?? '',
      receptionDate: map['receptionDate'] != null 
          ? DateTime.parse(map['receptionDate']) 
          : DateTime.now(),
      deliveryDate: DateTime.parse(map['deliveryDate']),
      deliveryTime: map['deliveryTime'] ?? '',
      deliveryType: map['deliveryType'] ?? '',
      items: List<Map<String, dynamic>>.from(map['items'] ?? []),
      totalCount: map['totalCount'] ?? 0,
      packagingType: map['packagingType'] ?? '',
      paymentMethod: map['paymentMethod'] ?? '',
      status: map['status'] ?? '受注済み',
      branchName: map['branchName'] ?? '岡崎本店',
    );
  }
}
