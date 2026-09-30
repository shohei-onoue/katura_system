import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/order_model.dart';
import 'k_responsive.dart';
import 'k_button.dart';
import 'package:katura_system/utils/app_colors.dart';

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

  /// trueのときはカレンダーだけを表示し、日付をタップするとその日付(00:00)を返して閉じる。
  /// 時間は呼び出し側（配達予定ダイアログ）で決める。
  final bool calendarOnly;

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
    this.calendarOnly = false,
  });

  @override
  State<KDateTimeSelectionDialog> createState() => _KDateTimeSelectionDialogState();
}

class _KDateTimeSelectionDialogState extends State<KDateTimeSelectionDialog> {
  late DateTime _tempDate;
  bool _calendarOpen = false;
  late String _timeBuffer; // 4桁の数字保持用 (例: "1430")

  @override
  void initState() {
    super.initState();
    _calendarOpen = widget.calendarOnly;
    _tempDate = DateTime(
      widget.initialDateTime.year,
      widget.initialDateTime.month,
      widget.initialDateTime.day,
    );
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
                          child: Text('${_areaLabel(o)}　${o.customerName}',
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

  bool get _showRelated => widget.calendarOnly || widget.relatedOrders.isNotEmpty;

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
          SizedBox(height: rs(context, 260), child: _buildRelatedPanel(context)),
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 7, child: calendar),
        SizedBox(width: rs(context, 12)),
        Expanded(flex: 3, child: SizedBox(height: rs(context, 420), child: _buildRelatedPanel(context))),
      ],
    );
  }

  /// 選択日と同じ日に配達される関連注文があれば確認ポップアップを出す。
  /// 戻り値: true=そのまま進む / false=やめる（日付を選び直す）。
  Future<bool> _confirmDuplicate(DateTime day) async {
    final count = widget.relatedOrders.where((o) => isSameDay(o.deliveryDate, day)).length;
    if (count == 0) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text('同日に他の注文が$count件あります',
            style: const TextStyle(color: AppColors.snackbarRed, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('やめる（日付を選び直す）'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('それでも注文する'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Widget _buildRelatedPanel(BuildContext context) {
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
                            Text(o.customerName,
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

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isValid = _isValidTime();
    final String formattedDate = DateFormat('yyyy/MM/dd (E)', 'ja_JP').format(_tempDate);
    
    // タブレットなどの広い画面を想定し、横長に調整
    final double dialogWidth = screenWidth < 900 ? screenWidth * 0.95 : 850;

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
                if (!widget.calendarOnly) SizedBox(width: rs(context, 16)),
                if (!widget.calendarOnly) Container(
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
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                        ),
                        calendarStyle: CalendarStyle(
                          // 選択日：枠なし・テーマ色塗りつぶし・白文字（配達＝#000038 / 回収＝オレンジ）
                          selectedDecoration: BoxDecoration(color: widget.themeColor, shape: BoxShape.circle),
                          selectedTextStyle: const TextStyle(color: AppColors.whiteText, fontWeight: FontWeight.bold),
                          // 今日：丸枠のみ・塗りつぶしなし
                          todayDecoration: BoxDecoration(
                            color: Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(color: widget.themeColor, width: rs(context, 1.5)),
                          ),
                          todayTextStyle: TextStyle(color: widget.themeColor, fontWeight: FontWeight.bold),
                        ),
                        selectedDayPredicate: (day) => isSameDay(_tempDate, day),
                        onDaySelected: (selectedDay, focusedDay) async {
                          final prevDate = _tempDate;
                          setState(() => _tempDate = selectedDay);
                          final proceed = await _confirmDuplicate(selectedDay);
                          if (!mounted) return;
                          if (!proceed) {
                            setState(() => _tempDate = prevDate);
                            return;
                          }
                          if (widget.calendarOnly) {
                            Navigator.of(this.context).pop(DateTime(selectedDay.year, selectedDay.month, selectedDay.day));
                          }
                        },
                        rowHeight: rs(context, 50),
                        calendarBuilders: CalendarBuilders(
                          defaultBuilder: (context, day, focusedDay) {
                            if (widget.highlightDate != null && isSameDay(day, widget.highlightDate)) {
                              return Center(
                                child: Container(
                                  width: rs(context, 36),
                                  height: rs(context, 36),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.primary, width: rs(context, 1.5)),
                                  ),
                                  child: Text('${day.day}',
                                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                                ),
                              );
                            }
                            if (widget.previewOrders.any((o) => isSameDay(o.deliveryDate, day))) {
                              return Center(
                                child: Container(
                                  width: rs(context, 36),
                                  height: rs(context, 36),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.accentOrange, width: rs(context, 1.5)),
                                  ),
                                  child: Text('${day.day}'),
                                ),
                              );
                            }
                            return null;
                          },
                        ),
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
                    if (!widget.calendarOnly) _buildOrderPreview(context),
                  ],
                ),
              ),
            ),
            
            if (!widget.calendarOnly) SizedBox(height: rs(context, 24)),
            
            if (!widget.calendarOnly) Row(
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
