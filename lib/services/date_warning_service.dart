import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/customer_model.dart';
import '../models/order_model.dart';
import 'delivery_schedule_service.dart';
import 'order_service.dart';

/// 日付ごとの警告（受注の重複・配達の移動時間不足）を返す共通ロジック（画面に依存しない）。
/// 戻り値のキーは時刻を除いた日付（DateTime(y, m, d)）。警告が無い日はキーに含まれない。
class DateWarningService {
  static DateTime dayOf(DateTime d) => DateTime(d.year, d.month, d.day);
  static String _digits(String v) => v.replaceAll(RegExp(r'[^0-9]'), '');
  static String _norm(String v) => v.replaceAll(RegExp(r'\s+'), '');

  static bool _inRange(DateTime d, DateTime? from, DateTime? to) {
    final day = dayOf(d);
    if (from != null && day.isBefore(dayOf(from))) return false;
    if (to != null && day.isAfter(dayOf(to))) return false;
    return true;
  }

  /// 号車の表示（全角数字。例: １号車）
  static String vehicleLabel(int n) {
    final zen = n.toString().split('').map((c) => String.fromCharCode(c.codeUnitAt(0) - 0x30 + 0xFF10)).join();
    return '$zen号車';
  }

  // ---------------- (a) 受注の重複・同一配達先 ----------------

  /// 顧客 [customer] の注文として、[orders] の中から関連注文（同一顧客の今日以降の有効注文、
  /// 同企業・同配達先の過去1週間以内の注文）を返す。[excludeOrderId] は編集中の注文ID。
  static List<OrderModel> relatedOrders({
    required List<OrderModel> orders,
    required Customer customer,
    String destName = '',
    String destAddress = '',
    String? excludeOrderId,
    DateTime? now,
  }) {
    final phone = _digits(customer.phoneNumber);
    final name = _norm(customer.name);
    final company = _norm(customer.companyName);
    final dName = _norm(destName);
    final dAddr = _norm(destAddress);
    final n = now ?? DateTime.now();
    final today = dayOf(n);
    final oldest = today.subtract(const Duration(days: 7));
    return orders.where((o) {
      if (excludeOrderId != null && o.id == excludeOrderId) return false;
      final sameCustomer = (o.customerId.isNotEmpty && o.customerId == customer.id) ||
          (_digits(o.phoneNumber) == phone && _norm(o.customerName) == name);
      if (sameCustomer) return OrderService.isActive(o) && !o.deliveryDate.isBefore(today);
      if (o.deliveryDate.isBefore(oldest)) return false;
      final sameCompany = company.isNotEmpty && _norm(o.facilityName) == company;
      final sameDest = (dName.isNotEmpty && _norm(o.facilityName) == dName) ||
          (dAddr.isNotEmpty && _norm(o.address) == dAddr);
      return sameCompany || sameDest;
    }).toList();
  }

  /// 関連注文ごとの「重複の内容」（どこが同じか）。キーは注文ID。
  static Map<String, String> relatedReasons({
    required List<OrderModel> related,
    required Customer customer,
    String destName = '',
    String destAddress = '',
  }) {
    final company = _norm(customer.companyName);
    final dName = _norm(destName);
    final dAddr = _norm(destAddress);
    final map = <String, String>{};
    for (final o in related) {
      final r = <String>[];
      if ((o.customerId.isNotEmpty && o.customerId == customer.id) ||
          (_digits(o.phoneNumber) == _digits(customer.phoneNumber) && _norm(o.customerName) == _norm(customer.name))) {
        r.add('同じお客様がこの日に注文済み');
      }
      if (company.isNotEmpty && _norm(o.facilityName) == company) r.add('同じ会社名（${o.facilityName}）');
      if (dName.isNotEmpty && _norm(o.facilityName) == dName) r.add('同じ届け先名（${o.facilityName}）');
      if (dAddr.isNotEmpty && _norm(o.address) == dAddr) r.add('同じ住所（${o.address}）');
      map[o.id] = r.join(' / ');
    }
    return map;
  }

  /// 受注入力の配達先確定時用。[customer]・配達先から、日付ごとの重複警告文を返す。
  static Map<DateTime, List<String>> orderConflictsForCustomer({
    required List<OrderModel> orders,
    required Customer customer,
    String destName = '',
    String destAddress = '',
    String? excludeOrderId,
    DateTime? from,
    DateTime? to,
  }) {
    final related = relatedOrders(
      orders: orders,
      customer: customer,
      destName: destName,
      destAddress: destAddress,
      excludeOrderId: excludeOrderId,
    ).where((o) => _inRange(o.deliveryDate, from, to)).toList();
    final reasons = relatedReasons(related: related, customer: customer, destName: destName, destAddress: destAddress);
    final out = <DateTime, List<String>>{};
    for (final o in related) {
      (out[dayOf(o.deliveryDate)] ??= []).add('${o.customerName}：${reasons[o.id] ?? ''}');
    }
    return out;
  }

  /// 受注一覧カレンダー用。有効な注文のうち、同じ日に「同じ顧客の複数注文」または
  /// 「別顧客なのに同じ配達先（施設名/住所）」がある日の警告文を返す。範囲は [from]〜[to]（省略可）。
  static Map<DateTime, List<String>> orderConflictsByDate(
    List<OrderModel> orders, {
    DateTime? from,
    DateTime? to,
  }) {
    final byDay = <DateTime, List<OrderModel>>{};
    for (final o in orders) {
      if (!OrderService.isActive(o) || !_inRange(o.deliveryDate, from, to)) continue;
      (byDay[dayOf(o.deliveryDate)] ??= []).add(o);
    }
    String custKey(OrderModel o) => o.customerId.isNotEmpty ? o.customerId : '${_digits(o.phoneNumber)}|${_norm(o.customerName)}';
    final out = <DateTime, List<String>>{};
    byDay.forEach((day, list) {
      final texts = <String>[];
      final seenDest = <String, OrderModel>{};
      final seenCust = <String, OrderModel>{};
      for (final o in list) {
        final ck = custKey(o);
        if (seenCust.containsKey(ck)) {
          texts.add('${o.customerName}：同じお客様がこの日に複数注文');
        }
        seenCust[ck] = o;
        for (final dk in [
          if (_norm(o.facilityName).isNotEmpty) 'n:${_norm(o.facilityName)}',
          if (_norm(o.address).isNotEmpty) 'a:${_norm(o.address)}',
        ]) {
          final prev = seenDest[dk];
          if (prev != null && custKey(prev) != ck) {
            final isName = dk.startsWith('n:');
            texts.add('${o.customerName}：${isName ? '同じ届け先名（${o.facilityName}）' : '同じ住所（${o.address}）'}が他のお客様の注文と重複');
          }
          seenDest[dk] = o;
        }
      }
      if (texts.isNotEmpty) out[day] = texts.toSet().toList();
    });
    return out;
  }

  // ---------------- (b) 配達予定の移動時間不足 ----------------

  /// 配達予定カレンダー用。[orders] を日付・店舗ごとに時間順に並べ、号車ごとに
  /// 前の配達から次の配達までの移動時間が足りない箇所の警告文を返す。
  /// [branchPositions] は店舗名→店舗の位置（無ければ1件目の移動時間は判定しない）。
  /// 範囲は [from]〜[to]。単日なら同じ日を両方に渡す。
  static Future<Map<DateTime, List<String>>> travelShortagesByDate({
    required List<OrderModel> orders,
    required DeliveryScheduleService service,
    Map<String, LatLng?> branchPositions = const {},
    DateTime? from,
    DateTime? to,
    int cardMinutes = 30,
  }) async {
    final groups = <String, List<OrderModel>>{}; // 日付+店舗
    for (final o in orders) {
      if (!OrderService.isActive(o) ||
          !_inRange(o.deliveryDate, from, to) ||
          DeliveryScheduleService.minutesOf(o.deliveryTime) == null) {
        continue;
      }
      final d = dayOf(o.deliveryDate);
      (groups['${d.toIso8601String()}|${o.branchName}'] ??= []).add(o);
    }
    final out = <DateTime, List<String>>{};
    for (final entry in groups.entries) {
      final dayOrders = entry.value
        ..sort((a, b) => DeliveryScheduleService.minutesOf(a.deliveryTime)!
            .compareTo(DeliveryScheduleService.minutesOf(b.deliveryTime)!));
      final lanes = assignLanes(dayOrders, cardMinutes: cardMinutes);
      final laneCount = lanes.values.fold<int>(0, (m, l) => l + 1 > m ? l + 1 : m);
      final pos = branchPositions[dayOrders.first.branchName];
      final stops = <String, DeliveryStop>{};
      for (int lane = 0; lane < laneCount; lane++) {
        final group = dayOrders.where((o) => lanes[o.id] == lane).toList();
        if (group.isEmpty) continue;
        for (final s in await service.buildStops(group, pos)) {
          stops[s.order.id] = s;
        }
      }
      final texts = shortageTexts(dayOrders: dayOrders, lanes: lanes, laneCount: laneCount, stops: stops);
      if (texts.isNotEmpty) {
        final day = dayOf(dayOrders.first.deliveryDate);
        (out[day] ??= []).addAll(texts);
      }
    }
    return out;
  }

  /// 注文ID→号車の列番号（0始まり）。号車指定済みはその列、未指定は時間が重ならない最初の列。
  /// [dayOrders] は時間順に並べ済みの1日・1店舗分。
  static Map<String, int> assignLanes(List<OrderModel> dayOrders, {int cardMinutes = 30}) {
    final lanes = <String, int>{};
    final laneEnds = <int>[];
    for (final o in dayOrders) {
      if (o.vehicleNumber > 0) {
        lanes[o.id] = o.vehicleNumber - 1;
        continue;
      }
      final m = DeliveryScheduleService.minutesOf(o.deliveryTime)!;
      int lane = laneEnds.indexWhere((end) => end <= m - cardMinutes);
      if (lane == -1) {
        laneEnds.add(m);
        lane = laneEnds.length - 1;
      } else {
        laneEnds[lane] = m;
      }
      lanes[o.id] = lane;
    }
    return lanes;
  }

  /// 号車ごとに、前の配達から次の配達までの移動時間が足りない箇所を文にする。
  /// [stops] は注文ID→移動時間（DeliveryScheduleService.buildStops の結果）。
  static List<String> shortageTexts({
    required List<OrderModel> dayOrders,
    required Map<String, int> lanes,
    required int laneCount,
    required Map<String, DeliveryStop> stops,
  }) {
    final list = <String>[];
    for (int lane = 0; lane < laneCount; lane++) {
      final group = dayOrders.where((o) => lanes[o.id] == lane).toList();
      for (int i = 1; i < group.length; i++) {
        final sec = stops[group[i].id]?.travelSeconds;
        if (sec == null) continue;
        final spare = DeliveryScheduleService.minutesOf(group[i].deliveryTime)! -
            DeliveryScheduleService.minutesOf(group[i - 1].deliveryTime)! -
            (sec / 60).ceil();
        if (spare < 0) {
          list.add('${vehicleLabel(lane + 1)} ${group[i].deliveryTime}：移動時間が${-spare}分不足しています');
        }
      }
    }
    return list;
  }
}
