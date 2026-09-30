import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/order_model.dart';
import 'google_maps_service.dart';

/// 予定カード1件分の移動情報。
class DeliveryStop {
  final OrderModel order;
  final int startMinutes; // 配達時間（分。例: 10:30 → 630）
  final int? travelSeconds; // 前の地点（1件目は店舗）からの移動時間。取得できなければ null
  int? get arrivalMinutes => travelSeconds == null ? null : startMinutes + (travelSeconds! / 60).ceil();
  const DeliveryStop(this.order, this.startMinutes, this.travelSeconds);
}

/// 1日分の配達予定について、ナビ（Distance Matrix）から移動時間・到着時間を求める。
/// 区間ごとの移動時間はメモリに保持し、同じ区間は再取得しない（将来のルート最適化でも使う）。
class DeliveryScheduleService {
  final GoogleMapsService _maps;
  DeliveryScheduleService(this._maps);

  /// 区間（"緯度,経度>緯度,経度"）→ 移動秒数
  static final Map<String, int> _legCache = {}; // static＝画面を閉じても保持（アプリ終了まで）

  String _key(LatLng a, LatLng b) => '${a.latitude},${a.longitude}>${b.latitude},${b.longitude}';

  /// 2地点間の移動秒数。失敗時は null。
  Future<int?> travelSeconds(LatLng from, LatLng to) async {
    final k = _key(from, to);
    final cached = _legCache[k];
    if (cached != null) return cached;
    final sec = await _maps.getDurationSeconds(from, to);
    if (sec != null) _legCache[k] = sec;
    return sec;
  }

  static int? minutesOf(String t) {
    final m = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(t.trim());
    if (m == null) return null;
    return int.parse(m.group(1)!) * 60 + int.parse(m.group(2)!);
  }

  /// [orders] は同じ日・同じ店舗の注文。時間順に並べ、1件目は [branchPos] から、
  /// 2件目以降は前の配達先からの移動時間を求める。緯度経度が無い注文は移動時間なし（null）。
  Future<List<DeliveryStop>> buildStops(List<OrderModel> orders, LatLng? branchPos) async {
    final items = <MapEntry<int, OrderModel>>[];
    for (final o in orders) {
      final min = minutesOf(o.deliveryTime);
      if (min != null) items.add(MapEntry(min, o));
    }
    items.sort((a, b) => a.key.compareTo(b.key));

    // 区間ごとの取得を先に並べ、まとめて同時に実行する（キャッシュ済みの区間はAPIを叩かない）
    final futures = <Future<int?>>[];
    final dests = <LatLng?>[];
    LatLng? prev = branchPos;
    for (final e in items) {
      final o = e.value;
      // 緯度経度が未設定（null または 0,0）の注文は位置不明として扱う
      final hasPos = o.latitude != null && o.longitude != null && !(o.latitude == 0 && o.longitude == 0);
      final dest = hasPos ? LatLng(o.latitude!, o.longitude!) : null;
      futures.add(prev != null && dest != null ? travelSeconds(prev, dest) : Future.value(null));
      dests.add(dest);
      prev = dest; // 緯度経度が無い場合は次の区間も求められない（null）
    }
    final secs = await Future.wait(futures);
    return [for (int i = 0; i < items.length; i++) DeliveryStop(items[i].value, items[i].key, secs[i])];
  }
}
