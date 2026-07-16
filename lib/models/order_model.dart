class OrderModel {
  final String id;
  final String customerName; // 注文者
  final String receiverName; // 受取人
  final String facilityName;
  final String address;
  final String deliveryLocation; // お渡し場所
  final String phoneNumber;
  final DateTime receptionDate; // 受注日
  final DateTime deliveryDate;  // 配達日
  final String deliveryTime;    // 配達時間
  final String deliveryType;
  final List<Map<String, dynamic>> items;
  final int totalCount;
  final String packagingType;
  final bool collectContainer; // 容器回収
  final String paymentMethod;
  final String status;
  final String branchName; // 追加: 店舗名

  OrderModel({
    required this.id,
    required this.customerName,
    this.receiverName = '',
    this.facilityName = '',
    required this.address,
    this.deliveryLocation = '',
    required this.phoneNumber,
    required this.receptionDate,
    required this.deliveryDate,
    required this.deliveryTime,
    required this.deliveryType,
    required this.items,
    required this.totalCount,
    required this.packagingType,
    this.collectContainer = false,
    required this.paymentMethod,
    this.status = '受注済み',
    this.branchName = '岡崎本店',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerName': customerName,
      'receiverName': receiverName,
      'facilityName': facilityName,
      'address': address,
      'deliveryLocation': deliveryLocation,
      'phoneNumber': phoneNumber,
      'receptionDate': receptionDate.toIso8601String(),
      'deliveryDate': deliveryDate.toIso8601String(),
      'deliveryTime': deliveryTime,
      'deliveryType': deliveryType,
      'items': items,
      'totalCount': totalCount,
      'packagingType': packagingType,
      'collectContainer': collectContainer,
      'paymentMethod': paymentMethod,
      'status': status,
      'branchName': branchName,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] ?? '',
      customerName: map['customerName'] ?? '',
      receiverName: map['receiverName'] ?? '',
      facilityName: map['facilityName'] ?? '',
      address: map['address'] ?? '',
      deliveryLocation: map['deliveryLocation'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      receptionDate: map['receptionDate'] != null 
          ? DateTime.parse(map['receptionDate']) 
          : DateTime.now(),
      deliveryDate: DateTime.parse(map['deliveryDate']),
      deliveryTime: map['deliveryTime'] ?? '',
      deliveryType: map['deliveryType'] ?? '',
      items: List<Map<String, dynamic>>.from(map['items'] ?? []),
      totalCount: map['totalCount'] ?? 0,
      packagingType: map['packagingType'] ?? '',
      collectContainer: map['collectContainer'] ?? false,
      paymentMethod: map['paymentMethod'] ?? '',
      status: map['status'] ?? '受注済み',
      branchName: map['branchName'] ?? '岡崎本店',
    );
  }
}
