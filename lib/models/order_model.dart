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
  final String deliveryDateStr; // 配達日文字列 (yyyy-MM-dd)
  final String deliveryTime;    // 配達時間
  final String deliveryType;
  final List<Map<String, dynamic>> items;
  final int totalCount;
  final int totalPrice; 
  
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

  // 事前連絡
  final String preConfirmationMethod; // SNS, 電話
  final String preConfirmationPhoneType; // この電話番号, 指定番号へ連絡 (電話時)
  final String preConfirmationPhoneNumber; // 指定電話番号 (電話時)
  final DateTime? preConfirmationDateTime; // 連絡希望日時 (電話時)
  final String preConfirmationSnsTime; // SNS送信時間 (例: "09:00")
  final DateTime? scheduledSnsDateTime; // 送信予定日時
  final bool snsSent; // 送信済みフラグ

  final String paymentMethod;
  final String status;
  final String branchName; // 店舗名
  final String remarks;    // 備考（音声・手書き対応）
  final String? deliveryDestinationImageUrl; // 配達先画像（ストリートビューなど）
  final double? latitude;
  final double? longitude;

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
    this.preConfirmationMethod = 'SNS',
    this.preConfirmationPhoneType = 'この電話番号',
    this.preConfirmationPhoneNumber = '',
    this.preConfirmationDateTime,
    this.preConfirmationSnsTime = '09:00',
    this.scheduledSnsDateTime,
    this.snsSent = false,
    required this.paymentMethod,
    this.status = '受注済み',
    this.branchName = '岡崎本店',
    this.remarks = '',
    this.deliveryDestinationImageUrl,
    this.latitude,
    this.longitude,
    String? deliveryDateStrParam,
    int? totalPriceParam,
  }) : deliveryDateStr = deliveryDateStrParam ?? deliveryDate.toIso8601String().split('T')[0],
       totalPrice = totalPriceParam ?? items.fold(0, (sum, item) {
          final price = (item['price'] is num) ? (item['price'] as num).toInt() : 0;
          final quantity = (item['quantity'] is num) ? (item['quantity'] as num).toInt() : 0;
          return sum + (price * quantity);
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
      'deliveryDateStr': deliveryDateStr,
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
      'preConfirmationSnsTime': preConfirmationSnsTime,
      'scheduledSnsDateTime': scheduledSnsDateTime?.toUtc().toIso8601String(),
      'snsSent': snsSent,
      'paymentMethod': paymentMethod,
      'status': status,
      'branchName': branchName,
      'remarks': remarks,
      'deliveryDestinationImageUrl': deliveryDestinationImageUrl,
      'latitude': latitude,
      'longitude': longitude,
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
      deliveryDateStrParam: map['deliveryDateStr'] ?? DateTime.parse(map['deliveryDate']).toIso8601String().split('T')[0],
      totalPriceParam: (map['totalPrice'] as num?)?.toInt(),
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
      preConfirmationMethod: map['preConfirmationMethod'] ?? 'SNS',
      preConfirmationPhoneType: map['preConfirmationPhoneType'] ?? 'この電話番号',
      preConfirmationPhoneNumber: map['preConfirmationPhoneNumber'] ?? '',
      preConfirmationDateTime: map['preConfirmationDateTime'] != null 
          ? DateTime.parse(map['preConfirmationDateTime']) 
          : null,
      preConfirmationSnsTime: map['preConfirmationSnsTime'] ?? '09:00',
      scheduledSnsDateTime: map['scheduledSnsDateTime'] != null 
          ? DateTime.parse(map['scheduledSnsDateTime']) 
          : null,
      snsSent: map['snsSent'] ?? false,
      paymentMethod: map['paymentMethod'] ?? '',
      status: map['status'] ?? '受注済み',
      branchName: map['branchName'] ?? '岡崎本店',
      remarks: map['remarks'] ?? '',
      deliveryDestinationImageUrl: map['deliveryDestinationImageUrl'],
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
    );
  }

}
