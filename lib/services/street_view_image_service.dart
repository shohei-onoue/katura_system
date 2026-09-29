import 'dart:async';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import '../firebase_options.dart';
import '../models/customer_model.dart';
import 'customer_service.dart';

/// 配達場所のストリートビュー画像を顧客に紐づけて保存・取得するサービス。
class StreetViewImageService {
  final CustomerService _customerService;
  StreetViewImageService({CustomerService? customerService})
      : _customerService = customerService ?? CustomerService();

  /// Static Street View API のURL（Maps APIキーが必要。現状は Firebase のAPIキーを流用）
  static String buildStaticUrl(double lat, double lng, {int size = 640, int heading = 0}) =>
      'https://maps.googleapis.com/maps/api/streetview?size=${size}x$size'
      '&location=$lat,$lng&heading=$heading&fov=90&pitch=0'
      '&key=${DefaultFirebaseOptions.currentPlatform.apiKey}';

  /// 画像をStorage(delivery_destinations/{customerId}.jpg)へ保存し、URLとパスを返す
  Future<({String url, String path})> uploadImage(String customerId, Uint8List bytes) async {
    final path = 'delivery_destinations/$customerId.jpg';
    final ref = FirebaseStorage.instance.ref().child(path);
    await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    return (url: await ref.getDownloadURL(), path: path);
  }

  /// 画像URLからバイト列を取得（失敗時null）
  Future<Uint8List?> downloadBytes(String imageUrl) async {
    try {
      final res = await http.get(Uri.parse(imageUrl)).timeout(const Duration(seconds: 10));
      return res.statusCode == 200 ? res.bodyBytes : null;
    } on TimeoutException {
      return null;
    }
  }

  /// 画像をアップロードし、顧客ドキュメントへURL/パスを保存。更新後の顧客を返す
  Future<Customer> saveForCustomer(Customer customer, Uint8List bytes) async {
    final up = await uploadImage(customer.id, bytes);
    final updated = customer.copyWith(streetViewImageUrl: up.url, streetViewImagePath: up.path);
    await _customerService.updateCustomer(updated);
    return updated;
  }

  /// 指定URL(Static Street View等)を取得して顧客へ保存。取得失敗時はnull
  Future<Customer?> saveFromUrl(Customer customer, String sourceUrl) async {
    final bytes = await downloadBytes(sourceUrl);
    if (bytes == null) return null;
    return saveForCustomer(customer, bytes);
  }

  /// 顧客に保存済みの画像URL（無ければnull）
  String? getImageUrl(Customer customer) => customer.streetViewImageUrl;
}
