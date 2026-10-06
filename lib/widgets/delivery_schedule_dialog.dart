import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:katura_system/utils/app_colors.dart';
import '../models/order_model.dart';
import '../services/delivery_schedule_service.dart';
import '../services/customer_service.dart';
import '../services/order_service.dart';
import '../services/reservation_service.dart';
import 'k_button.dart';
import 'k_numeric_input_dialog.dart';
import 'k_route_map_dialog.dart';
import 'k_responsive.dart';
import 'package:katura_system/utils/name_format.dart';

/// 配達予定ダイアログ。縦の時間軸（9:00〜20:00）に、その日の配達予定カードを号車ごとの列に並べ、
/// 空いている時間帯をタップして配達時間を決める。決定すると日時（DateTime）を返す。
/// カードの下端が配達時間のライン。同じ号車のカード間は点線の矢印でつなぎ、移動時間を表示する。
/// 将来「配達ルート最適化機能」の内容をここに表示する予定。
/// 配達予定ダイアログで決めた「号車・日時」。
class DeliverySlot {
  final DateTime dateTime;
  final int vehicleNumber; // 1始まり
  const DeliverySlot(this.dateTime, this.vehicleNumber);
}

class DeliveryScheduleDialog extends StatefulWidget {
  final DateTime date;
  final List<OrderModel> orders; // 自店舗の注文（日付での絞り込みはこちらで行う）
  final LatLng? branchPos; // 1件目の出発地点（店舗の位置）
  final int vehicleCount; // 店舗の配送車両数（号車の列数の下限。0以下は1列）
  final DeliveryScheduleService service;
  final List<ReservationSlot> reservations; // 他の注文入力で確保中の予約枠
  final int initialVehicle; // すでに決まっている号車（0＝なし）
  final TimeOfDay? initialTime; // すでに決まっている時間（あれば予約枠として最初から表示する）
  final bool allowTimePick; // false＝空白タップで時間入力をしない（閲覧のみ）
  final String handoverLabel; // タイトルなどに使う受け渡し方法の呼び名（'配達' / '引取り'）

  const DeliveryScheduleDialog({
    super.key,
    required this.date,
    required this.orders,
    required this.branchPos,
    required this.service,
    this.vehicleCount = 1,
    this.reservations = const [],
    this.initialVehicle = 0,
    this.initialTime,
    this.allowTimePick = true,
    this.handoverLabel = '配達',
  });

  @override
  State<DeliveryScheduleDialog> createState() => _DeliveryScheduleDialogState();
}

class _DeliveryScheduleDialogState extends State<DeliveryScheduleDialog> {
  static const int _startHour = 9;
  static const int _endHour = 20;
  static const int _cardMinutes = 30; // カードの長さ（分）。配達時間の30分前から配達時間まで

  late final List<OrderModel> _dayOrders;
  final Map<String, int> _lanes = {}; // 注文ID → 号車の列番号（0始まり）
  int _laneCount = 1;
  Map<String, DeliveryStop> _stops = {}; // 注文ID → 移動情報
  Map<String, String> _names = {}; // 注文ID → 顧客管理の最新の顧客名
  final OrderService _orderService = OrderService();
  final GlobalKey<ScaffoldMessengerState> _messengerKey = GlobalKey<ScaffoldMessengerState>();
  final Set<String> _lateIds = {}; // 移動時間で間に合わない予定カードのID（赤色で表示）
  ({int lane, int minutes})? _pending; // 今回決めた予約枠（列番号は0始まり）

  @override
  void initState() {
    super.initState();
    _dayOrders = widget.orders
        .where((o) =>
            o.deliveryDate.year == widget.date.year &&
            o.deliveryDate.month == widget.date.month &&
            o.deliveryDate.day == widget.date.day &&
            DeliveryScheduleService.minutesOf(o.deliveryTime) != null)
        .toList()
      ..sort((a, b) => DeliveryScheduleService.minutesOf(a.deliveryTime)!.compareTo(DeliveryScheduleService.minutesOf(b.deliveryTime)!));

    // 号車が決まっている注文はその列へ。未割り当ての注文は、時間が重ならない最初の列へ
    // （カードは [m-30分, m] の範囲を使う）
    final laneEnds = <int>[];
    int maxAssigned = 0;
    for (final o in _dayOrders) {
      if (o.vehicleNumber > 0) {
        _lanes[o.id] = o.vehicleNumber - 1;
        maxAssigned = math.max(maxAssigned, o.vehicleNumber);
        continue;
      }
      final m = DeliveryScheduleService.minutesOf(o.deliveryTime)!;
      int lane = laneEnds.indexWhere((end) => end <= m - _cardMinutes);
      if (lane == -1) {
        laneEnds.add(m);
        lane = laneEnds.length - 1;
      } else {
        laneEnds[lane] = m;
      }
      _lanes[o.id] = lane;
    }
    for (final r in widget.reservations) {
      maxAssigned = math.max(maxAssigned, r.vehicleNumber);
    }
    _laneCount = math.max(math.max(math.max(laneEnds.length, maxAssigned), widget.vehicleCount), 1);
    if (widget.initialVehicle > _laneCount) _laneCount = widget.initialVehicle;

    final t = widget.initialTime;
    if (t != null && widget.initialVehicle > 0) {
      final m = t.hour * 60 + t.minute;
      if (m >= _startHour * 60 && m <= _endHour * 60) _pending = (lane: widget.initialVehicle - 1, minutes: m);
    }
    _loadStops();
    _loadNames();
  }

  /// 顧客名は受注に保存された名前ではなく、顧客管理の最新の名前（ふりがなのみの顧客も含む）を使う。
  Future<void> _loadNames() async {
    try {
      final names = await CustomerService().resolveOrderNames(_dayOrders);
      if (mounted) setState(() => _names = names);
    } catch (e) {
      debugPrint('delivery names error: $e');
    }
  }

  /// 号車ごとに、1件目は店舗から・2件目以降は前の配達先からの移動時間を取得する。
  Future<void> _loadStops() async {
    try {
      final result = <String, DeliveryStop>{};
      for (int lane = 0; lane < _laneCount; lane++) {
        final group = _dayOrders.where((o) => _lanes[o.id] == lane).toList();
        if (group.isEmpty) continue;
        final stops = await widget.service.buildStops(group, widget.branchPos);
        for (final s in stops) {
          result[s.order.id] = s;
        }
      }
      if (!mounted) return;
      setState(() => _stops = result);
    } catch (e) {
      debugPrint('delivery stops error: $e');
    }
  }

  Color _branchColor(String branch) {
    switch (branch) {
      case '名古屋店':
        return Colors.green;
      case '岐阜店':
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }

  /// 住所に混ざった社名・施設名を取り除き、（郵便番号）＋都道府県以降だけにする。
  String _cleanAddress(OrderModel o) {
    var a = o.address.replaceAll('　', ' ').trim();
    final zip = RegExp(r'〒?\s*\d{3}-?\d{4}').firstMatch(a);
    var zipPrefix = '';
    if (zip != null) {
      final d = zip.group(0)!.replaceAll(RegExp(r'[^0-9]'), '');
      zipPrefix = '〒${d.substring(0, 3)}-${d.substring(3)} ';
      a = (a.substring(0, zip.start) + a.substring(zip.end)).trim();
    }
    if (o.facilityName.trim().isNotEmpty) a = a.replaceAll(o.facilityName.trim(), '');
    a = a.replaceFirst(RegExp(r'^\[[^\]]*\]'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
    final pref = RegExp(r'(北海道|東京都|大阪府|京都府|[^\s]{2,3}県)').firstMatch(a);
    if (pref != null) a = a.substring(pref.start); // 都道府県より前は社名として捨てる
    return (zipPrefix + a).trim();
  }

  /// 住所から市区町村のみを取り出す（都道府県は除く。取れなければ空文字）
  String _cityOf(OrderModel o) {
    final noZip = _cleanAddress(o).replaceFirst(RegExp(r'^\s*〒\s*\d{3}-?\d{4}\s*'), '');
    final rest = noZip.replaceFirst(RegExp(r'^(北海道|[^市区町村\d]{2,3}?[都府県])'), '');
    final m = RegExp(r'^[^\d\s]+?[市区町村]').firstMatch(rest);
    return m?.group(0) ?? '';
  }

  /// カードの上を空ける量。隣り合うカードの間にも必ず移動時間の表示場所ができる。
  double _cardInset(BuildContext context) => rs(context, 32);

  /// 号車の表示（全角数字。例: １号車）
  String _vehicleLabel(int n) {
    final zen = n.toString().split('').map((c) => String.fromCharCode(c.codeUnitAt(0) - 0x30 + 0xFF10)).join();
    return '$zen号車';
  }

  String _hm(int minutes) {
    final h = (minutes ~/ 60) % 24;
    return '${h.toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}';
  }

  /// 同じ号車の前のカードの下端から次のカードの上端まで、点線の矢印と車アイコン・移動時間を描く。
  List<Widget> _connector(BuildContext context, OrderModel prev, OrderModel next, double colX, double colW, double Function(int) yOf, double cardH) {
    final pm = DeliveryScheduleService.minutesOf(prev.deliveryTime)!;
    final nm = DeliveryScheduleService.minutesOf(next.deliveryTime)!;
    final double y1 = yOf(pm); // 前のカードの下端
    final double y2 = yOf(nm - _cardMinutes) + _cardInset(context); // 次のカードの上端
    if (y2 - y1 < rs(context, 16)) return const []; // すき間が狭いときは描かない
    final double cx = colX + colW / 2;
    final double mid = (y1 + y2) / 2;
    final travel = _stops[next.id]?.travelSeconds;
    final travelMin = travel == null ? null : (travel / 60).ceil();
    // 余裕時間＝前の配達時間から次の配達時間までの間隔 − 移動時間（マイナスなら間に合わない）
    final spare = travelMin == null ? null : nm - pm - travelMin;
    return [
      Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: _DashedArrowPainter(cx, y1, y2)))),
      // 矢印の縦方向中央に、車アイコンとナビの移動時間（矢印の真ん中に重ねる）
      Positioned(
        left: cx - colW / 2,
        width: colW,
        top: mid - rs(context, 12),
        height: rs(context, 24),
        child: IgnorePointer(
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: rs(context, 6)),
              decoration: BoxDecoration(color: AppColors.popupBackground, borderRadius: BorderRadius.circular(rs(context, 12))),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.directions_car, size: rs(context, 20), color: AppColors.primary),
                    SizedBox(width: rs(context, 4)),
                    Text(travelMin == null ? '移動--分' : '移動$travelMin分',
                        style: TextStyle(fontSize: rf(context, 14), fontWeight: FontWeight.bold, color: AppColors.primary)),
                    if (spare != null) ...[
                      SizedBox(width: rs(context, 6)),
                      Text(spare >= 0 ? '余裕$spare分' : '不足${-spare}分',
                          style: TextStyle(fontSize: rf(context, 14), fontWeight: FontWeight.bold, color: spare >= 0 ? AppColors.secondaryText : Colors.red)),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ];
  }

  /// 号車の見出しをタップ → 画面中央の時間入力（HHMM）→ その号車の時間軸に予約枠を置く。
  Future<void> _pickTime(int lane) async {
    final current = _pending?.lane == lane ? _pending!.minutes : null;
    final initial = current == null ? '' : _hm(current).replaceAll(':', '');
    String? entered;
    await showDialog<void>(
      context: context,
      builder: (_) => KNumericInputDialog(
        title: '- ${lane + 1}号車 -',
        timeFormat: true,
        initialValue: initial,
        emptyHint: '',
        maxLength: 4,
        overwrite: true,
        themeColor: AppColors.primary,
        onConfirmed: (v) => entered = v,
      ),
    );
    if (entered == null || !mounted) return;
    final digits = entered!.replaceAll(RegExp(r'[^0-9]'), '').padLeft(4, '0');
    final h = int.parse(digits.substring(0, 2));
    final m = int.parse(digits.substring(2, 4));
    final minutes = h * 60 + m;
    if (m % 10 != 0 || minutes < _startHour * 60 || minutes > _endHour * 60) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('$_startHour:00〜$_endHour:00の間で、10分単位（00・10・20・30・40・50）で入力してください'),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('閉じる'))],
        ),
      );
      return;
    }
    setState(() => _pending = (lane: lane, minutes: minutes));
  }

  /// 号車の見出しタップ → 確認ポップアップ（API節約のため）→ Googleマップでナビを開く。
  /// 出発地は店舗、最後の配達先が目的地、それ以外の配達先は経由地。
  Future<void> _confirmRoute(int lane) async {
    final group = _dayOrders.where((o) => _lanes[o.id] == lane).toList();
    if (group.isEmpty || widget.branchPos == null) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(group.isEmpty ? 'この号車には配達予定がありません' : '店舗の位置が取得できないため、ルートを表示できません'),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('閉じる'))],
        ),
      );
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        ButtonStyle btn(Color c) => ElevatedButton.styleFrom(
              backgroundColor: c,
              foregroundColor: Colors.white,
              fixedSize: Size(rs(context, 120), rs(context, 40)),
            );
        return AlertDialog(
          elevation: 12,
          shadowColor: Colors.black,
          backgroundColor: AppColors.dialogBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(context, 12))),
          title: Text('${lane + 1}号車のルートを表示しますか？', textAlign: TextAlign.center),
          titleTextStyle: TextStyle(fontSize: rf(context, 18), fontWeight: FontWeight.bold, color: AppColors.primaryText),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(style: btn(AppColors.cancelButton), onPressed: () => Navigator.pop(ctx, false), child: const Text('キャンセル')),
            ElevatedButton(style: btn(AppColors.acceptButton), onPressed: () => Navigator.pop(ctx, true), child: const Text('表示する')),
          ],
        );
      },
    );
    if (ok != true || !mounted) return;
    Object point(OrderModel o) => (o.latitude != null && o.longitude != null) ? LatLng(o.latitude!, o.longitude!) : _cleanAddress(o);
    await showDialog<void>(
      context: context,
      builder: (_) => KRouteMapDialog(
        title: '- ${lane + 1}号車 -　配送ルート',
        origin: widget.branchPos!,
        stops: [
          for (final o in group)
            KRouteStop(location: point(o), time: o.deliveryTime, place: _cityOf(o), color: _branchColor(o.branchName)),
        ],
      ),
    );
  }

  /// [o] を [lane] の列へ移せるか（同じ列の他の予定・予約枠と30分以内で重ならない）。
  bool _canDrop(OrderModel o, int lane) {
    if (_lanes[o.id] == lane) return false;
    final m = DeliveryScheduleService.minutesOf(o.deliveryTime)!;
    bool clash(int other) => (other - m).abs() < _cardMinutes;
    for (final x in _dayOrders) {
      if (x.id != o.id && _lanes[x.id] == lane && clash(DeliveryScheduleService.minutesOf(x.deliveryTime)!)) return false;
    }
    for (final r in widget.reservations) {
      final rm = DeliveryScheduleService.minutesOf(r.time);
      if (r.vehicleNumber - 1 == lane && rm != null && clash(rm)) return false;
    }
    if (_pending != null && _pending!.lane == lane && clash(_pending!.minutes)) return false;
    return true;
  }

  /// カードを別の号車の列へ移す（保存に失敗したら元に戻す）。
  Future<void> _moveToLane(OrderModel o, int lane) async {
    final before = _lanes[o.id]!;
    setState(() {
      _lanes[o.id] = lane;
      _lateIds.remove(o.id);
    });
    try {
      await _orderService.updateVehicleNumber(o.id, lane + 1);
      await _loadStops();
      if (!mounted) return;
      final shortage = _shortageAfterMove(o, lane);
      if (shortage > 0) {
        setState(() => _lateIds.add(o.id));
        _showNotice('移動時間が足りません（$shortage分不足）');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _lanes[o.id] = before);
      _showNotice('号車の変更を保存できませんでした');
    }
  }

  /// 移した [o] の前後の区間で、移動時間が間隔を超える最大の不足分（分）。間に合うなら0。
  int _shortageAfterMove(OrderModel o, int lane) {
    final group = _dayOrders.where((x) => _lanes[x.id] == lane).toList();
    final i = group.indexWhere((x) => x.id == o.id);
    int shortage = 0;
    int gap(OrderModel from, OrderModel to) {
      final sec = _stops[to.id]?.travelSeconds;
      if (sec == null) return 0;
      final spare = DeliveryScheduleService.minutesOf(to.deliveryTime)! - DeliveryScheduleService.minutesOf(from.deliveryTime)! - (sec / 60).ceil();
      return spare < 0 ? -spare : 0;
    }
    if (i > 0) shortage = math.max(shortage, gap(group[i - 1], o));
    if (i >= 0 && i + 1 < group.length) shortage = math.max(shortage, gap(o, group[i + 1]));
    return shortage;
  }

  /// ダイアログ下部にスナックバーを出す。
  void _showNotice(String text) {
    _messengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 4)));
  }

  /// 予約枠カード（背景は heatmapGreen）。
  Widget _reservationCard(BuildContext context, String time) {
    final style = TextStyle(fontSize: rf(context, 14), fontWeight: FontWeight.bold, color: AppColors.primaryText);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: rs(context, 10), vertical: rs(context, 6)),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(color: AppColors.heatmapGreen, borderRadius: BorderRadius.circular(rs(context, 8))),
      child: Row(
        children: [
          Text(time, style: style),
          SizedBox(width: rs(context, 12)),
          Text('予約枠', style: style),
        ],
      ),
    );
  }

  /// 予定カード。「|」・配達時間・市区町村を上下中央に並べる。タップで詳細ダイアログ。
  Widget _buildCard(BuildContext context, OrderModel o, double cardH) {
    final white = TextStyle(fontSize: rf(context, 14), fontWeight: FontWeight.bold, color: Colors.white);
    final card = GestureDetector(
      onTap: () => _showDetail(context, o),
      child: Container(
        height: cardH,
        padding: EdgeInsets.symmetric(horizontal: rs(context, 10)),
        decoration: BoxDecoration(
          color: _lateIds.contains(o.id) ? Colors.red : _branchColor(o.branchName),
          borderRadius: BorderRadius.circular(rs(context, 8)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('|', style: white),
            SizedBox(width: rs(context, 8)),
            Text(o.deliveryTime, style: white),
            SizedBox(width: rs(context, 12)),
            Expanded(child: Text(_cityOf(o), maxLines: 1, overflow: TextOverflow.ellipsis, style: white)),
          ],
        ),
      ),
    );
    // 長押ししてドラッグすると、別の号車の列へ移せる（ふつうのタップは詳細表示のまま）
    return LongPressDraggable<OrderModel>(
      data: o,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(width: rs(context, 176), child: Opacity(opacity: 0.85, child: card)),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: card),
      child: card,
    );
  }

  /// 予定カードの詳細（顧客名・住所・注文内容）を配達予定ダイアログの中央に表示。
  void _showDetail(BuildContext context, OrderModel o) {
    final small = TextStyle(fontSize: rf(context, 14), fontWeight: FontWeight.w500, color: AppColors.dialogText);
    final label = TextStyle(fontSize: rf(context, 12), fontWeight: FontWeight.bold, color: AppColors.dialogLabel);
    Widget row(String title, String body) => Padding(
          padding: EdgeInsets.only(top: rs(context, 10)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text(title, style: label), Text(body.isEmpty ? '－' : body, style: small)],
          ),
        );
    final items = o.items.map((m) {
      final special = m['specialOrder']?.toString() ?? '';
      return '${m['name']} x${m['quantity']}${special.isEmpty ? '' : ' ($special)'}';
    }).join('\n');
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.dialogBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rs(context, 12)),
          side: BorderSide(color: AppColors.dialogLine, width: 2),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: rs(context, 420)),
          child: Padding(
            padding: EdgeInsets.all(rs(context, 20)),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(o.deliveryType == '引取' ? '引取り時間' : '配達時間', style: label),
                            Text(o.deliveryTime, style: TextStyle(fontSize: rf(context, 18), fontWeight: FontWeight.bold, color: AppColors.dialogText)),
                          ],
                        ),
                      ),
                      IconButton(icon: const Icon(Icons.close, color: AppColors.dialogText), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  row('顧客名', withHonorific(_names[o.id] ?? o.customerName)),
                  row('住所', _cleanAddress(o).replaceFirstMapped(RegExp(r'^(〒\d{3}-\d{4}) '), (m) => '${m[1]}\n')),
                  row('注文内容', items),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final double dialogWidth = screen.width < 900 ? screen.width * 0.95 : 850;
    final double hourH = rs(context, 160); // 10分＝約27（カードを10分単位で置けるよう間隔を広く）
    final double labelW = rs(context, 64);
    final double slotH = _cardMinutes / 60 * hourH;
    final double cardH = slotH - _cardInset(context); // 見えるカードの高さ（上を空けて移動時間の場所を作る）
    final double baseTop = rs(context, 8) + slotH; // 10:00のライン（その上にカードが乗る余白を確保）
    final double totalH = hourH * (_endHour - _startHour) + baseTop;
    double yOf(int minutes) => baseTop + (minutes - _startHour * 60) / 60 * hourH;
    final double colW = rs(context, 176); // 号車1列の幅（カードは配達時間と市区町村だけなので細くする）
    final double stackH = totalH + rs(context, 16);
    final double colGap = rs(context, 12);
    double colX(int lane) => labelW + rs(context, 24) + lane * (colW + colGap);

    return Dialog(
      backgroundColor: AppColors.popupBackground,
      insetPadding: EdgeInsets.symmetric(horizontal: rs(context, 16), vertical: rs(context, 16)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rav(context, 16))),
      child: SizedBox(
        width: dialogWidth,
        height: screen.height * 0.9,
        // スナックバーをダイアログ下部に出すため、ダイアログ専用の Scaffold を置く
        child: ScaffoldMessenger(
          key: _messengerKey,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Container(
        padding: EdgeInsets.all(rav(context, 24)),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  '${widget.handoverLabel}予定  ${DateFormat('M/d(E)', 'ja_JP').format(widget.date)}　${_dayOrders.length}件',
                  style: TextStyle(fontSize: rf(context, 22), fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            SizedBox(height: rs(context, 8)),
            SizedBox(height: rs(context, 12)),
            // 号車の見出し（縦スクロールしても動かない固定）
            Padding(
              padding: EdgeInsets.only(left: rs(context, 33.67), top: rs(context, 13.02)),
              child: SizedBox(
                height: rs(context, 42),
                child: Stack(
                  children: [
                    for (int lane = 0; lane < _laneCount; lane++)
                      Positioned(
                        top: 0,
                        left: colX(lane),
                        width: colW,
                        height: rs(context, 42),
                        child: GestureDetector(
                          onTap: () => _confirmRoute(lane),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: AppColors.secondaryText, borderRadius: BorderRadius.circular(rs(context, 8))),
                            child: Text(_vehicleLabel(lane + 1), style: TextStyle(fontSize: rf(context, 14), fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: rs(context, 8)),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(left: rs(context, 33.67)),
                  child: SizedBox(
                    height: stackH,
                    child: Stack(
                      children: [
                        // 時間の横線（ラベルの行の中央に線）
                        IgnorePointer(
                          child: Stack(
                            children: [
                              for (int h = _startHour; h <= _endHour; h++)
                                Positioned(
                                  top: baseTop + (h - _startHour) * hourH,
                                  left: 0,
                                  right: 0,
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: labelW,
                                        child: Text('$h:00', style: TextStyle(fontSize: rf(context, 13), color: AppColors.secondaryText)),
                                      ),
                                      Expanded(child: Divider(height: 1, color: Colors.grey.shade300)),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // 号車の空白部分タップで時間入力（カードは上のレイヤーなので、カードのタップは今まで通り）
                        for (int lane = 0; lane < _laneCount; lane++)
                          Positioned(
                            top: 0,
                            bottom: 0,
                            left: colX(lane),
                            width: colW,
                            child: DragTarget<OrderModel>(
                              onWillAcceptWithDetails: (d) => _canDrop(d.data, lane),
                              onAcceptWithDetails: (d) => _moveToLane(d.data, lane),
                              builder: (context, candidate, _) => GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: widget.allowTimePick ? () => _pickTime(lane) : null,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: candidate.isEmpty ? null : AppColors.primary.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(rs(context, 8)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        // 号車ごとのカード間の点線矢印（カードより下のレイヤー）
                        for (int lane = 0; lane < _laneCount; lane++)
                          ...() {
                            final group = _dayOrders.where((o) => _lanes[o.id] == lane).toList();
                            return [
                              for (int i = 0; i + 1 < group.length; i++)
                                ..._connector(context, group[i], group[i + 1], colX(lane), colW, yOf, cardH),
                            ];
                          }(),
                        // 予定カード（下端＝配達時間のライン。タップで上に広げて詳細を表示。広げたカードは手前）
                        // 予約枠（他の注文入力中のもの＋今回決めたもの）
                        for (final r in widget.reservations)
                          if (DeliveryScheduleService.minutesOf(r.time) != null)
                            Positioned(
                              top: yOf(DeliveryScheduleService.minutesOf(r.time)! - _cardMinutes) + _cardInset(context),
                              left: colX(r.vehicleNumber - 1),
                              width: colW,
                              height: cardH,
                              child: _reservationCard(context, r.time),
                            ),
                        if (_pending != null)
                          Positioned(
                            top: yOf(_pending!.minutes - _cardMinutes) + _cardInset(context),
                            left: colX(_pending!.lane),
                            width: colW,
                            height: cardH,
                            child: _reservationCard(context, _hm(_pending!.minutes)),
                          ),
                        for (final o in _dayOrders)
                          Positioned(
                            top: yOf(DeliveryScheduleService.minutesOf(o.deliveryTime)! - _cardMinutes) + _cardInset(context),
                            left: colX(_lanes[o.id]!),
                            width: colW,
                            child: _buildCard(context, o, cardH),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: rs(context, 16)),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: rs(context, 54),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey, width: rs(context, 2)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(context, 12))),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text('戻る', style: TextStyle(fontSize: rf(context, 18), color: Colors.blueGrey, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                SizedBox(width: rs(context, 24)),
                Expanded(
                  child: SizedBox(
                    height: rs(context, 54),
                    child: KButton(
                      label: _pending == null ? '号車の空白部分をタップして時間を入力' : '${_vehicleLabel(_pending!.lane + 1)} ${_hm(_pending!.minutes)} で決定',
                      onPressed: _pending == null
                          ? null
                          : () {
                              final p = _pending!;
                              Navigator.pop(
                                context,
                                DeliverySlot(
                                  DateTime(widget.date.year, widget.date.month, widget.date.day, p.minutes ~/ 60, p.minutes % 60),
                                  p.lane + 1,
                                ),
                              );
                            },
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 縦の破線（太さ3・破線5.58/5.58）。
class _DashedArrowPainter extends CustomPainter {
  final double x;
  final double y1; // 始点（上）
  final double y2; // 矢印の先端（下）
  _DashedArrowPainter(this.x, this.y1, this.y2);

  @override
  void paint(Canvas canvas, Size size) {
    const dash = 5.5833;
    const period = 11.1667;
    const thick = 3.0;
    final len = y2 - y1;
    final paint = Paint()..color = Colors.black;
    // 先頭は半分の長さの点線から始まる
    for (double s = -dash / 2; s < len; s += period) {
      final a = math.max(s, 0.0);
      final b = math.min(s + dash, len);
      if (b > a) canvas.drawRect(Rect.fromLTRB(x - thick / 2, y1 + a, x + thick / 2, y1 + b), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DashedArrowPainter old) => old.x != x || old.y1 != y1 || old.y2 != y2;
}
