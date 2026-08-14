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
  
  // 梱包設定
  final String packagingType; // 紙袋, 段ボール, 小分け, その他
  final int packagingSmallQty; // 小分け数量
  final String packagingOther; // 梱包その他

  // 受注区分
  final String orderSource; // 直取, 結膳, デリカ, その他
  final String orderSourceOther;

  // ゴミ回収設定
  final bool trashPickupRequested;
  final DateTime? trashPickupDateTime;
  final String trashPickupLocation; // 引渡し場所, 指定場所
  final String trashPickupLocationDetail;

  // お茶設定
  final String teaOption; // 込み, 別, なし, 特典
  final int teaQuantity; // 特典本数

  // 事前確認
  final String preConfirmationMethod; // SMS, 電話
  final String preConfirmationPhoneType; // この電話番号, 指定番号へ連絡 (電話時)
  final String preConfirmationPhoneNumber; // 指定電話番号 (電話時)
  final DateTime? preConfirmationDateTime; // 連絡希望日時 (電話時)
  final String preConfirmationSmsTime; // SMS送信時間 (例: "09:00")

  final String paymentMethod;
  final String status;
  final String branchName; // 店舗名
  final String remarks;    // 備考（音声・手書き対応）
  final String? deliveryDestinationImageUrl; // 配達先画像（ストリートビューなど）

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
    this.packagingType = '紙袋',
    this.packagingSmallQty = 0,
    this.packagingOther = '',
    this.orderSource = '直取',
    this.orderSourceOther = '',
    this.trashPickupRequested = false,
    this.trashPickupDateTime,
    this.trashPickupLocation = '引渡し場所',
    this.trashPickupLocationDetail = '',
    this.teaOption = 'なし',
    this.teaQuantity = 0,
    this.preConfirmationMethod = 'SMS',
    this.preConfirmationPhoneType = 'この電話番号',
    this.preConfirmationPhoneNumber = '',
    this.preConfirmationDateTime,
    this.preConfirmationSmsTime = '09:00',
    required this.paymentMethod,
    this.status = '受注済み',
    this.branchName = '岡崎本店',
    this.remarks = '',
    this.deliveryDestinationImageUrl,
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
      'packagingSmallQty': packagingSmallQty,
      'packagingOther': packagingOther,
      'orderSource': orderSource,
      'orderSourceOther': orderSourceOther,
      'trashPickupRequested': trashPickupRequested,
      'trashPickupDateTime': trashPickupDateTime?.toIso8601String(),
      'trashPickupLocation': trashPickupLocation,
      'trashPickupLocationDetail': trashPickupLocationDetail,
      'teaOption': teaOption,
      'teaQuantity': teaQuantity,
      'preConfirmationMethod': preConfirmationMethod,
      'preConfirmationPhoneType': preConfirmationPhoneType,
      'preConfirmationPhoneNumber': preConfirmationPhoneNumber,
      'preConfirmationDateTime': preConfirmationDateTime?.toIso8601String(),
      'preConfirmationSmsTime': preConfirmationSmsTime,
      'paymentMethod': paymentMethod,
      'status': status,
      'branchName': branchName,
      'remarks': remarks,
      'deliveryDestinationImageUrl': deliveryDestinationImageUrl,
    };
  }

  factory OrderModel.empty() {
    return OrderModel(
      id: '',
      customerName: '',
      address: '',
      phoneNumber: '',
      receptionDate: DateTime.now(),
      deliveryDate: DateTime.now(),
      deliveryTime: '',
      deliveryType: '',
      items: [],
      totalCount: 0,
      packagingType: '紙袋',
      paymentMethod: '',
      remarks: '',
      deliveryDestinationImageUrl: null,
    );
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
      packagingType: map['packagingType'] ?? '紙袋',
      packagingSmallQty: map['packagingSmallQty'] ?? 0,
      packagingOther: map['packagingOther'] ?? '',
      orderSource: map['orderSource'] ?? '直取',
      orderSourceOther: map['orderSourceOther'] ?? '',
      trashPickupRequested: map['trashPickupRequested'] ?? false,
      trashPickupDateTime: map['trashPickupDateTime'] != null 
          ? DateTime.parse(map['trashPickupDateTime']) 
          : null,
      trashPickupLocation: map['trashPickupLocation'] ?? '引渡し場所',
      trashPickupLocationDetail: map['trashPickupLocationDetail'] ?? '',
      teaOption: map['teaOption'] ?? 'なし',
      teaQuantity: map['teaQuantity'] ?? 0,
      preConfirmationMethod: map['preConfirmationMethod'] ?? 'SMS',
      preConfirmationPhoneType: map['preConfirmationPhoneType'] ?? 'この電話番号',
      preConfirmationPhoneNumber: map['preConfirmationPhoneNumber'] ?? '',
      preConfirmationDateTime: map['preConfirmationDateTime'] != null 
          ? DateTime.parse(map['preConfirmationDateTime']) 
          : null,
      preConfirmationSmsTime: map['preConfirmationSmsTime'] ?? '09:00',
      paymentMethod: map['paymentMethod'] ?? '',
      status: map['status'] ?? '受注済み',
      branchName: map['branchName'] ?? '岡崎本店',
      remarks: map['remarks'] ?? '',
      deliveryDestinationImageUrl: map['deliveryDestinationImageUrl'],
    );
  }
}
