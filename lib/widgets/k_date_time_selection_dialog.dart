import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/order_model.dart';
import '../services/customer_service.dart';
import 'k_responsive.dart';
import 'k_button.dart';
import 'package:katura_system/utils/app_colors.dart';
import 'package:katura_system/utils/name_format.dart';

class KDateTimeSelectionDialog extends StatefulWidget {
  final DateTime initialDateTime;
  final TimeOfDay minTime;
  final TimeOfDay maxTime;
  final bool enforceTimeRange; // trueなら minTime〜maxTime の範囲外は確定できない
  final int interval;
  final String title;
  final Color themeColor;
  /// 参考として枠付きで表示する日付（例：ゴミ回収日時設定時の配達日）
  final DateTime? highlightDate;
  final String highlightLabel;

  /// カレンダー下部に「選択日の受注」を簡易カードで一覧表示する場合に渡す。
  /// 空のときは何も表示しない。
  final List<OrderModel> previewOrders;

  /// 対応中顧客の所属企業の他顧客の注文、および同じ配達先の他顧客の注文。
  /// 表示は後続のデザイン対応で実装（現状は受け口のみ）。
  final List<OrderModel> relatedOrders;
  /// 関連注文ID → 重複の内容（例: 同じ住所）
  final Map<String, String> relatedReasons;

  /// trueのときはカレンダーだけを表示し、日付をタップするとその日付(00:00)を返して閉じる。
  /// 時間は呼び出し側（配達予定ダイアログ）で決める。
  final bool calendarOnly;

  /// 選択日の丸の色（未指定なら themeColor）。指定すると丸の中の文字は黒系になる。
  final Color? selectedDayColor;

  /// trueのときはカレンダーだけを表示し、日付をタップするとすぐにその日付(00:00)を返して閉じる
  /// （関連注文カードやボタンは出さない。時間は呼び出し側で別のウィジェットで決める）。
  final bool pickDayOnly;

  /// trueのとき引取り用：予約あり・警告ありのマーク/凡例を出さず、ボタンを「時間設定」にする。
  final bool pickupMode;

  /// 受注カードに表示する受け渡し種別（'引取' なら引取りのみ、'配送' なら引取り以外）。null なら絞り込まない。
  final String? orderTypeFilter;

  /// trueのときゴミ回収用：警告マーク/凡例なし、右側にゴミ回収予定カード（選択日が回収日の注文）を出す。
  final bool trashMode;

  /// 右下ボタンの文言（未指定なら既定の文言）
  final String? nextLabel;

  const KDateTimeSelectionDialog({
    super.key,
    required this.initialDateTime,
    this.minTime = const TimeOfDay(hour: 0, minute: 0),
    this.maxTime = const TimeOfDay(hour: 23, minute: 59),
    this.enforceTimeRange = false,
    this.interval = 15,
    this.title = '配達日時',
    this.themeColor = AppColors.primary,
    this.highlightDate,
    this.highlightLabel = '配達日',
    this.previewOrders = const [],
    this.relatedOrders = const [],
    this.relatedReasons = const {},
    this.calendarOnly = false,
    this.selectedDayColor,
    this.pickDayOnly = false,
    this.pickupMode = false,
    this.orderTypeFilter,
    this.trashMode = false,
    this.nextLabel,
  });

  @override
  State<KDateTimeSelectionDialog> createState() => _KDateTimeSelectionDialogState();
}

class _KDateTimeSelectionDialogState extends State<KDateTimeSelectionDialog> {
  late DateTime _tempDate;
  bool _calendarOpen = false;
  late String _timeBuffer; // 4桁の数字保持用 (例: "1430")
  Map<String, String> _customerNames = {};
  final GlobalKey _calendarKey = GlobalKey(); // カレンダー枠の高さを測る（右側の高さを合わせる）
  double? _calendarHeight;

  String _nameOf(OrderModel o) => withHonorific(_customerNames[o.id] ?? o.customerName);

  Future<void> _loadCustomerNames() async {
    await _ensureNames(widget.relatedOrders);
  }

  /// まだ顧客名を取得していない注文だけ、顧客管理の最新の顧客名を取得して追加する。
  Future<void> _ensureNames(List<OrderModel> orders) async {
    final missing = orders.where((o) => !_customerNames.containsKey(o.id)).toList();
    if (missing.isEmpty) return;
    try {
      final names = await CustomerService().resolveOrderNames(missing);
      if (!mounted) return;
      setState(() => _customerNames = {..._customerNames, ...names});
    } catch (_) {}
  }

  /// 選択日の受注（previewOrders と relatedOrders の和集合・時間順）。
  List<OrderModel> _ordersOnSelectedDay() {
    if (widget.trashMode) {
      final byId = <String, OrderModel>{};
      for (final o in widget.previewOrders) {
        final t = o.trashPickupDateTime;
        if (o.trashPickupRequested && t != null && isSameDay(t, _tempDate)) byId[o.id] = o;
      }
      return byId.values.toList()
        ..sort((a, b) => a.trashPickupDateTime!.compareTo(b.trashPickupDateTime!));
    }
    final byId = <String, OrderModel>{};
    for (final o in [...widget.previewOrders, ...widget.relatedOrders]) {
      if (!isSameDay(o.deliveryDate, _tempDate)) continue;
      final f = widget.orderTypeFilter;
      if (f != null && (f == '引取') != (o.deliveryType == '引取')) continue;
      byId[o.id] = o;
    }
    final warnIds = widget.relatedOrders.map((o) => o.id).toSet();
    // 警告（関連注文）のカードを先頭に、その中は時間順
    return byId.values.toList()
      ..sort((a, b) {
        final wa = warnIds.contains(a.id) ? 0 : 1;
        final wb = warnIds.contains(b.id) ? 0 : 1;
        if (wa != wb) return wa.compareTo(wb);
        return a.deliveryTime.compareTo(b.deliveryTime);
      });
  }

  @override
  void initState() {
    super.initState();
    _calendarOpen = widget.calendarOnly || widget.pickDayOnly;
    _tempDate = DateTime(
      widget.initialDateTime.year,
      widget.initialDateTime.month,
      widget.initialDateTime.day,
    );
    _loadCustomerNames();
    if (widget.calendarOnly) _ensureNames(_ordersOnSelectedDay());
    // 初期時間を4桁の文字列に変換
    _timeBuffer = widget.initialDateTime.hour.toString().padLeft(2, '0') +
                  widget.initialDateTime.minute.toString().padLeft(2, '0');
  }

  String get _displayTime {
    return "${_timeBuffer.substring(0, 2)}:${_timeBuffer.substring(2, 4)}";
  }

  bool _isValidTime() {
    final hour = int.parse(_timeBuffer.substring(0, 2));
    final minute = int.parse(_timeBuffer.substring(2, 4));
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return false;
    if (!widget.enforceTimeRange) return true;
    final t = hour * 60 + minute;
    return t >= widget.minTime.hour * 60 + widget.minTime.minute && t <= widget.maxTime.hour * 60 + widget.maxTime.minute;
  }

  /// 住所文字列から市区町村部分を抜き出す（取れなければ施設名で代替）。
  String _areaLabel(OrderModel o) {
    final m = RegExp(r'([^\d\s]+?[市区町村])').firstMatch(o.address);
    if (m != null) return m.group(1)!;
    return o.facilityName.isNotEmpty ? o.facilityName : o.address;
  }

  /// カレンダー下部：選択日の受注を「市区町村＋顧客名＋時間」で簡易表示する。
  Widget _buildOrderPreview(BuildContext context) {
    final sameDay = widget.previewOrders
        .where((o) => isSameDay(o.deliveryDate, _tempDate))
        .toList()
      ..sort((a, b) => a.deliveryTime.compareTo(b.deliveryTime));

    return Padding(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${DateFormat('M/d(E)', 'ja_JP').format(_tempDate)} の受注 ${sameDay.length}件',
            style: TextStyle(fontSize: rf(context, 12), fontWeight: FontWeight.bold, color: AppColors.secondaryText),
          ),
          SizedBox(height: rs(context, 6)),
          if (sameDay.isEmpty)
            Text('受注なし', style: TextStyle(fontSize: rf(context, 12), color: Colors.grey))
          else
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: rs(context, 400)),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: sameDay.length,
                separatorBuilder: (context, index) => SizedBox(height: rs(context, 6)),
                itemBuilder: (context, i) {
                  final o = sameDay[i];
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: rs(context, 10), vertical: rs(context, 8)),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(rs(context, 8)),
                    ),
                    child: Row(
                      children: [
                        Text(o.deliveryTime,
                            style: TextStyle(fontSize: rf(context, 12), fontWeight: FontWeight.bold, color: widget.themeColor)),
                        SizedBox(width: rs(context, 8)),
                        Expanded(
                          child: Text('${_areaLabel(o)}　${_nameOf(o)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: rf(context, 12), fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  bool get _showRelated => !widget.pickDayOnly && (widget.calendarOnly || widget.relatedOrders.isNotEmpty);

  /// カレンダーの右に関連注文カード領域を並べる（7:3）。狭い画面では下に縦積み。
  Widget _withRelated(BuildContext context, Widget calendar) {
    if (!_showRelated) return calendar;
    final narrow = MediaQuery.of(context).size.width < 700;
    if (narrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          calendar,
          SizedBox(height: rs(context, 12)),
          SizedBox(height: rs(context, widget.calendarOnly ? 340 : 260), child: _buildRelatedPanel(context)),
        ],
      );
    }
    if (widget.calendarOnly) {
      // カレンダー枠の高さを測り、右側（カード＋ボタン）の下端をカレンダーの下端に合わせる
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final h = _calendarKey.currentContext?.size?.height;
        if (mounted && h != null && (_calendarHeight == null || (h - _calendarHeight!).abs() > 0.5)) {
          setState(() => _calendarHeight = h);
        }
      });
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 7, child: calendar),
        SizedBox(width: rs(context, 12)),
        Expanded(flex: 3, child: SizedBox(height: widget.calendarOnly ? (_calendarHeight ?? rs(context, 420)) : rs(context, 420), child: _buildRelatedPanel(context))),
      ],
    );
  }

  /// 選択日と同じ日に配達される関連注文があれば確認ポップアップを出す。
  /// 戻り値: true=そのまま進む / false=やめる（日付を選び直す）。
  Future<bool> _confirmDuplicate(DateTime day) async {
    final dups = widget.relatedOrders.where((o) => isSameDay(o.deliveryDate, day)).toList()
      ..sort((a, b) => a.deliveryTime.compareTo(b.deliveryTime));
    if (dups.isEmpty) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.popupBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rs(context, 28)),
          side: const BorderSide(color: AppColors.snackbarRed),
        ),
        title: const Center(
          child: Text('- 重複注意 -',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.snackbarRed, fontWeight: FontWeight.bold)),
        ),
        content: SizedBox(
          width: rs(ctx, 360),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final o in dups)
                  Padding(
                    padding: EdgeInsets.only(bottom: rs(ctx, 6)),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: rs(ctx, 10), vertical: rs(ctx, 8)),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(rs(ctx, 8)),
                      ),
                      child: Row(
                        children: [
                          Text(o.deliveryTime,
                              style: TextStyle(fontSize: rf(ctx, 12), fontWeight: FontWeight.bold, color: widget.themeColor)),
                          SizedBox(width: rs(ctx, 8)),
                          Expanded(
                            child: Text(
                                '${o.facilityName.isNotEmpty ? o.facilityName : _areaLabel(o)}　${_nameOf(o)}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: rf(ctx, 12), fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('中止'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('注文'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// calendarOnly 用：選択日の受注カードを一覧し、下の「スケジュール確認」で配達車両スケジュールへ進む。
  /// 関連注文（重複など）に当たるカードは赤系の色＋警告アイコンで通常の注文と区別する。
  Widget _buildTrashPanel(BuildContext context) {
    final list = _ordersOnSelectedDay();
    return Container(
      padding: EdgeInsets.all(rs(context, 8)),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(rs(context, 12)),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${_tempDate.day}日の回収 ${list.length}件',
              style: TextStyle(fontSize: rf(context, 12), fontWeight: FontWeight.bold, color: AppColors.secondaryText)),
          SizedBox(height: rs(context, 6)),
          Expanded(
            child: list.isEmpty
                ? Center(child: Text('回収予定なし', style: TextStyle(fontSize: rf(context, 12), color: Colors.grey)))
                : ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (context, index) => SizedBox(height: rs(context, 6)),
                    itemBuilder: (context, i) {
                      final o = list[i];
                      final t = o.trashPickupDateTime!;
                      final time = '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
                      final place = o.facilityName.isNotEmpty ? o.facilityName : _areaLabel(o);
                      final loc = o.trashPickupLocationDetail.isNotEmpty
                          ? '${o.trashPickupLocation}　${o.trashPickupLocationDetail}'
                          : o.trashPickupLocation;
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: rs(context, 8), vertical: rs(context, 6)),
                        decoration: BoxDecoration(
                          color: AppColors.mainBackground,
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(rs(context, 8)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(time,
                                style: TextStyle(fontSize: rf(context, 11), fontWeight: FontWeight.bold, color: widget.themeColor)),
                            Text('$place　${_nameOf(o)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: rf(context, 12), fontWeight: FontWeight.w600, color: AppColors.primaryText)),
                            Text(loc,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: rf(context, 11), color: AppColors.secondaryText)),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayOrdersPanel(BuildContext context) {
    if (widget.trashMode) return _buildTrashPanel(context);
    final list = _ordersOnSelectedDay();
    final warnIds = widget.relatedOrders.map((o) => o.id).toSet();
    return Container(
      padding: EdgeInsets.all(rs(context, 8)),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(rs(context, 12)),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${DateFormat('M/d(E)', 'ja_JP').format(_tempDate)} の受注 ${list.length}件',
              style: TextStyle(fontSize: rf(context, 12), fontWeight: FontWeight.bold, color: AppColors.secondaryText)),
          SizedBox(height: rs(context, 6)),
          Expanded(
            child: list.isEmpty
                ? Center(child: Text('受注なし', style: TextStyle(fontSize: rf(context, 12), color: Colors.grey)))
                : ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (context, index) => SizedBox(height: rs(context, 6)),
                    itemBuilder: (context, i) {
                      final o = list[i];
                      final isWarn = warnIds.contains(o.id);
                      final place = o.facilityName.isNotEmpty ? o.facilityName : _areaLabel(o);
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: rs(context, 8), vertical: rs(context, 6)),
                        decoration: BoxDecoration(
                          color: AppColors.mainBackground,
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(rs(context, 8)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isWarn)
                              Container(
                                margin: EdgeInsets.only(bottom: rs(context, 4)),
                                padding: EdgeInsets.all(rs(context, 4)),
                                decoration: BoxDecoration(
                                  color: AppColors.cautionCardBackground.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(rs(context, 6)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.warning_amber_rounded, color: AppColors.warningText, size: rf(context, 20)),
                                    SizedBox(width: rs(context, 6)),
                                    Expanded(
                                      child: Text(
                                          (widget.relatedReasons[o.id] ?? '').isEmpty ? '重複の可能性' : '重複の可能性: ${widget.relatedReasons[o.id]}',
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(fontSize: rf(context, 12), fontWeight: FontWeight.bold, color: AppColors.warningText)),
                                    ),
                                  ],
                                ),
                              ),
                            Text('${o.deliveryTime}  ${_areaLabel(o)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: rf(context, 11), fontWeight: FontWeight.bold, color: isWarn ? AppColors.primaryText : widget.themeColor)),
                            Text(_nameOf(o),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: rf(context, 12), fontWeight: FontWeight.w600, color: AppColors.primaryText)),
                            Text(place,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: rf(context, 11), color: isWarn ? AppColors.primaryText : AppColors.secondaryText)),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// 受注カードの枠の外（下）に置く「スケジュール確認」ボタン付きの右側エリア。
  Widget _buildDayOrdersArea(BuildContext context) {
    return Column(
      children: [
        Expanded(child: _buildDayOrdersPanel(context)),
        SizedBox(height: rs(context, 8)),
        KButton(
          label: widget.nextLabel ?? (widget.pickupMode ? '時間設定' : 'スケジュール確認'),
          color: widget.themeColor,
          onPressed: () => Navigator.of(context).pop(DateTime(_tempDate.year, _tempDate.month, _tempDate.day)),
        ),
      ],
    );
  }

  Widget _buildRelatedPanel(BuildContext context) {
    if (widget.calendarOnly) return _buildDayOrdersArea(context);
    final list = [...widget.relatedOrders]
      ..sort((a, b) => a.deliveryDate.compareTo(b.deliveryDate));
    return Container(
      padding: EdgeInsets.all(rs(context, 8)),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(rs(context, 12)),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('関連する注文 ${list.length}件',
              style: TextStyle(fontSize: rf(context, 12), fontWeight: FontWeight.bold, color: AppColors.secondaryText)),
          SizedBox(height: rs(context, 6)),
          Expanded(
            child: list.isEmpty
                ? Center(
                    child: Text('該当する注文はありません',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: rf(context, 12), color: Colors.grey)))
                : ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (context, index) => SizedBox(height: rs(context, 6)),
                    itemBuilder: (context, i) {
                      final o = list[i];
                      final place = o.facilityName.isNotEmpty ? o.facilityName : _areaLabel(o);
                      final isDup = isSameDay(o.deliveryDate, _tempDate);
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: rs(context, 8), vertical: rs(context, 6)),
                        decoration: BoxDecoration(
                          color: isDup ? AppColors.heatmapRed.withValues(alpha: 0.5) : Colors.white,
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(rs(context, 8)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${DateFormat('M/d(E)', 'ja_JP').format(o.deliveryDate)} ${o.deliveryTime}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: rf(context, 11), fontWeight: FontWeight.bold, color: widget.themeColor)),
                            Text(_nameOf(o),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: rf(context, 12), fontWeight: FontWeight.w600)),
                            Text(place,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: rf(context, 11), color: AppColors.secondaryText)),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(BuildContext context, String label,
      {Color? border, Color? fill, Color? dot, IconData? icon, Color? iconColor, Color? square}) {
    final size = rs(context, dot != null ? 8 : 14);
    final Widget mark = icon != null
        ? Icon(icon, size: rs(context, 16), color: iconColor)
        : Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: square != null ? BoxShape.rectangle : BoxShape.circle,
              borderRadius: square != null ? BorderRadius.circular(rs(context, 2)) : null,
              color: dot ?? fill,
              border: square != null
                  ? Border.all(color: square, width: rs(context, 2))
                  : (border != null ? Border.all(color: border, width: rs(context, 1.5)) : null),
            ),
          );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        SizedBox(width: rs(context, 6)),
        Text(label, style: TextStyle(fontSize: rf(context, 12))),
      ],
    );
  }

  /// カレンダーの日付文字サイズ。今日は標準より2px大きくする。
  double _dayFontSize(BuildContext context, {bool today = false}) =>
      (Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14) + (today ? 4 : 0);

  /// 日付セルのマーク（参考日の輪／予約あり・引取りあり・回収ありの印）。マークが無い日は null。
  Widget? _dayMark(BuildContext context, DateTime day, {bool today = false}) {
    final textStyle = TextStyle(
      fontSize: _dayFontSize(context, today: today),
      fontWeight: today ? FontWeight.bold : null,
      color: today ? AppColors.accentOrange : null,
    );
    Widget cell(Widget child) => Center(child: SizedBox(width: rs(context, 36), height: rs(context, 36), child: child));
    if (widget.highlightDate != null && isSameDay(day, widget.highlightDate)) {
      return cell(Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary, width: rs(context, 1.5)),
        ),
        child: Text('${day.day}', style: textStyle.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
      ));
    }
    if (widget.trashMode) {
      final has = widget.previewOrders.any((o) => o.trashPickupRequested && o.trashPickupDateTime != null && isSameDay(o.trashPickupDateTime!, day));
      if (!has) return null;
      // ゴミ箱アイコンで日付を囲む
      return Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.delete_outline, size: rs(context, 44), color: AppColors.dialogLine),
            Padding(padding: EdgeInsets.only(top: rs(context, 6)), child: Text('${day.day}', style: textStyle)),
          ],
        ),
      );
    }
    if (widget.pickupMode) {
      final has = widget.previewOrders.any((o) => o.deliveryType == '引取' && isSameDay(o.deliveryDate, day));
      if (!has) return null;
      // 日付を四角の枠で囲む
      return cell(Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(rs(context, 4)),
          border: Border.all(color: AppColors.cautionCardBackground, width: rs(context, 2)),
        ),
        child: Text('${day.day}', style: textStyle),
      ));
    }
    if (!widget.previewOrders.any((o) => isSameDay(o.deliveryDate, day))) return null;
    return cell(Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.accentOrange, width: rs(context, 1.5)),
      ),
      child: Text('${day.day}', style: textStyle),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isValid = _isValidTime();
    final String formattedDate = DateFormat('yyyy/MM/dd (E)', 'ja_JP').format(_tempDate);
    
    // タブレットなどの広い画面を想定し、横長に調整
    final double dialogWidth = rs(context, 850).clamp(0.0, screenWidth * 0.95).toDouble();

    return Dialog(
      backgroundColor: AppColors.popupBackground,
      insetPadding: EdgeInsets.symmetric(horizontal: rs(context, 16), vertical: rs(context, 16)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rav(context, 16))),
      child: Container(
        width: dialogWidth,
        padding: EdgeInsets.all(rav(context, 24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(widget.title, style: TextStyle(fontSize: rf(context, 22), fontWeight: FontWeight.bold, color: widget.themeColor)),
                if (!widget.calendarOnly && !widget.pickDayOnly) SizedBox(width: rs(context, 16)),
                if (!widget.calendarOnly && !widget.pickDayOnly) Container(
                  padding: EdgeInsets.symmetric(horizontal: rs(context, 16), vertical: rs(context, 8)),
                  decoration: BoxDecoration(
                    color: isValid ? widget.themeColor.withValues(alpha: 0.08) : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(rs(context, 20)),
                    border: Border.all(color: isValid ? widget.themeColor.withValues(alpha: 0.2) : Colors.red.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () => setState(() => _calendarOpen = !_calendarOpen),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.event, size: rs(context, 18), color: isValid ? widget.themeColor : Colors.red),
                            SizedBox(width: rs(context, 8)),
                            Text(
                              formattedDate,
                              style: TextStyle(fontSize: rf(context, 16), fontWeight: FontWeight.bold, color: isValid ? AppColors.primaryText : Colors.red),
                            ),
                            Icon(_calendarOpen ? Icons.expand_less : Icons.expand_more, size: rs(context, 18), color: isValid ? widget.themeColor : Colors.red),
                          ],
                        ),
                      ),
                      SizedBox(width: rs(context, 12)),
                      Icon(Icons.access_time, size: rs(context, 18), color: isValid ? widget.themeColor : Colors.red),
                      SizedBox(width: rs(context, 8)),
                      Text(
                        _displayTime,
                        style: TextStyle(fontSize: rf(context, 20), fontWeight: FontWeight.w900, color: isValid ? AppColors.primaryText : Colors.red, letterSpacing: 1),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            SizedBox(height: rs(context, 24)),
            
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // カレンダー: 日付タップでメニュー状に展開
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      alignment: Alignment.topCenter,
                      child: _calendarOpen
                          ? Padding(
                              padding: EdgeInsets.only(bottom: rs(context, 16)),
                              child: _withRelated(context, Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                      Container(
                      key: _calendarKey,
                      padding: EdgeInsets.all(rs(context, 12)),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(rs(context, 12)),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: TableCalendar(
                        firstDay: DateTime.now().subtract(const Duration(days: 30)),
                        lastDay: DateTime.now().add(const Duration(days: 365)),
                        focusedDay: _tempDate,
                        currentDay: DateTime.now(),
                        locale: 'ja_JP',
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          // 月表示を上に詰め、曜日との間に余白を確保する
                          headerPadding: EdgeInsets.only(bottom: rs(context, 12)),
                          leftChevronPadding: EdgeInsets.zero,
                          rightChevronPadding: EdgeInsets.zero,
                        ),
                        calendarStyle: CalendarStyle(
                          // 選択日：枠なし・テーマ色塗りつぶし・白文字（配達＝#000038 / 回収＝オレンジ）
                          selectedDecoration: BoxDecoration(color: widget.selectedDayColor ?? widget.themeColor, shape: BoxShape.circle),
                          selectedTextStyle: TextStyle(
                            color: widget.selectedDayColor != null ? AppColors.primaryText : AppColors.whiteText,
                            fontWeight: FontWeight.bold,
                          ),
                          // 今日：マークなし。文字を太字・オレンジにする
                          todayDecoration: const BoxDecoration(color: Colors.transparent, shape: BoxShape.circle),
                          todayTextStyle: TextStyle(fontSize: _dayFontSize(context, today: true), fontWeight: FontWeight.bold, color: AppColors.accentOrange),
                        ),
                        selectedDayPredicate: (day) => isSameDay(_tempDate, day),
                        onDaySelected: (selectedDay, focusedDay) async {
                          if (widget.pickDayOnly) {
                            Navigator.of(this.context).pop(DateTime(selectedDay.year, selectedDay.month, selectedDay.day));
                            return;
                          }
                          if (widget.calendarOnly) {
                            // すぐには進まず、右の受注カード一覧を選択日に切り替える（警告はカードで表示）
                            setState(() => _tempDate = selectedDay);
                            _ensureNames(_ordersOnSelectedDay());
                            return;
                          }
                          final prevDate = _tempDate;
                          setState(() => _tempDate = selectedDay);
                          final proceed = await _confirmDuplicate(selectedDay);
                          if (!mounted) return;
                          if (!proceed) {
                            setState(() => _tempDate = prevDate);
                            return;
                          }
                        },
                        rowHeight: rs(context, 50),
                        // 曜日の行を高くして日付と重ならないようにし、月によらず6週分の高さを確保する
                        daysOfWeekHeight: rs(context, 36),
                        sixWeekMonthsEnforced: true,
                        // 「関連する注文」がある日は、日付の下に赤丸を表示する
                        eventLoader: (day) => (widget.pickupMode || widget.trashMode) ? const [] : widget.relatedOrders.where((o) => isSameDay(o.deliveryDate, day)).toList(),
                        calendarBuilders: CalendarBuilders(
                          markerBuilder: (context, day, events) => events.isEmpty
                              ? null
                              : Positioned(
                                  bottom: rs(context, 1),
                                  left: 0,
                                  right: 0,
                                  child: Center(
                                    child: Icon(Icons.warning_amber_rounded, color: AppColors.warningText, size: rs(context, 14)),
                                  ),
                                ),
                          defaultBuilder: (context, day, focusedDay) => _dayMark(context, day),
                          todayBuilder: (context, day, focusedDay) => _dayMark(context, day, today: true),
                          // 選択中の日が今日のときも、他の日と同じ文字サイズにする
                          selectedBuilder: (context, day, focusedDay) {
                            if (!isSameDay(day, DateTime.now())) return null;
                            return Container(
                              margin: EdgeInsets.all(rs(context, 6)),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(color: widget.selectedDayColor ?? widget.themeColor, shape: BoxShape.circle),
                              child: Text('${day.day}',
                                  style: TextStyle(
                                    fontSize: _dayFontSize(context, today: true),
                                    fontWeight: FontWeight.bold,
                                    color: widget.selectedDayColor != null ? AppColors.primaryText : AppColors.whiteText,
                                  )),
                            );
                          },
                        ),
                      ),
                    ),
                      // マーキングの凡例
                      Padding(
                        padding: EdgeInsets.only(top: rs(context, 8)),
                        child: Wrap(
                          spacing: rs(context, 14),
                          runSpacing: rs(context, 4),
                          children: [
                            if (widget.trashMode)
                              _legendItem(context, '回収あり', icon: Icons.delete_outline, iconColor: AppColors.dialogLine)
                            else if (widget.pickupMode)
                              _legendItem(context, '引取りあり', square: AppColors.cautionCardBackground)
                            else
                              _legendItem(context, '予約あり', border: AppColors.accentOrange),
                            _legendItem(context, '選択中', fill: widget.selectedDayColor ?? widget.themeColor),
                            if (!widget.pickupMode && !widget.trashMode)
                              _legendItem(context, '警告あり', icon: Icons.warning_amber_rounded, iconColor: AppColors.warningText),
                          ],
                        ),
                      ),
                      if (widget.highlightDate != null)
                        Padding(
                          padding: EdgeInsets.only(top: rs(context, 8)),
                          child: Row(
                            children: [
                              Container(
                                width: rs(context, 14),
                                height: rs(context, 14),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.primary, width: rs(context, 1.5)),
                                ),
                              ),
                              SizedBox(width: rs(context, 6)),
                              Text('${widget.highlightLabel}: ${DateFormat('M/d(E)', 'ja_JP').format(widget.highlightDate!)}',
                                  style: TextStyle(fontSize: rf(context, 12), color: AppColors.primary, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                                ],
                              )),
                            )
                          : const SizedBox(width: double.infinity),
                    ),
                    if (!widget.calendarOnly && !widget.pickDayOnly) _buildOrderPreview(context),
                  ],
                ),
              ),
            ),
            
            if (!widget.calendarOnly && !widget.pickDayOnly) SizedBox(height: rs(context, 24)),
            
            if (!widget.calendarOnly && !widget.pickDayOnly) Row(
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
                      child: Text('キャンセル', 
                        style: TextStyle(fontSize: rf(context, 18), color: Colors.blueGrey, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                SizedBox(width: rs(context, 24)),
                Expanded(
                  child: SizedBox(
                    height: rs(context, 54),
                    child: KButton(
                      label: '設定を反映する', 
                      onPressed: isValid ? () {
                        final hour = int.parse(_timeBuffer.substring(0, 2));
                        final minute = int.parse(_timeBuffer.substring(2, 4));
                        final result = DateTime(
                          _tempDate.year,
                          _tempDate.month,
                          _tempDate.day,
                          hour,
                          minute,
                        );
                        Navigator.pop(context, result);
                      } : null,
                      color: widget.themeColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
