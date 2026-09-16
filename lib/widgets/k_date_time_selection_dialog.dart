import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/order_model.dart';
import 'k_responsive.dart';
import 'k_button.dart';
import 'k_numeric_dial_pad.dart';
import 'package:katura_system/utils/app_colors.dart';

class KDateTimeSelectionDialog extends StatefulWidget {
  final DateTime initialDateTime;
  final TimeOfDay minTime;
  final TimeOfDay maxTime;
  final int interval;
  final String title;
  final Color themeColor;
  /// 参考として枠付きで表示する日付（例：ゴミ回収日時設定時の配達日）
  final DateTime? highlightDate;
  final String highlightLabel;

  /// カレンダー下部に「選択日の受注」を簡易カードで一覧表示する場合に渡す。
  /// 空のときは何も表示しない。
  final List<OrderModel> previewOrders;

  const KDateTimeSelectionDialog({
    super.key,
    required this.initialDateTime,
    this.minTime = const TimeOfDay(hour: 0, minute: 0),
    this.maxTime = const TimeOfDay(hour: 23, minute: 59),
    this.interval = 15,
    this.title = '配達日時の設定',
    this.themeColor = Colors.deepPurple,
    this.highlightDate,
    this.highlightLabel = '配達日',
    this.previewOrders = const [],
  });

  @override
  State<KDateTimeSelectionDialog> createState() => _KDateTimeSelectionDialogState();
}

class _KDateTimeSelectionDialogState extends State<KDateTimeSelectionDialog> {
  late DateTime _tempDate;
  late String _timeBuffer; // 4桁の数字保持用 (例: "1430")

  @override
  void initState() {
    super.initState();
    _tempDate = DateTime(
      widget.initialDateTime.year,
      widget.initialDateTime.month,
      widget.initialDateTime.day,
    );
    // 初期時間を4桁の文字列に変換
    _timeBuffer = widget.initialDateTime.hour.toString().padLeft(2, '0') +
                  widget.initialDateTime.minute.toString().padLeft(2, '0');
  }

  void _onInput(String digit) {
    setState(() {
      _timeBuffer = (_timeBuffer + digit);
      if (_timeBuffer.length > 4) {
        _timeBuffer = _timeBuffer.substring(_timeBuffer.length - 4);
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (_timeBuffer.isNotEmpty) {
        _timeBuffer = '0${_timeBuffer.substring(0, _timeBuffer.length - 1)}';
      }
    });
  }

  void _onClear() {
    setState(() {
      _timeBuffer = "0000";
    });
  }

  String get _displayTime {
    return "${_timeBuffer.substring(0, 2)}:${_timeBuffer.substring(2, 4)}";
  }

  bool _isValidTime() {
    final hour = int.parse(_timeBuffer.substring(0, 2));
    final minute = int.parse(_timeBuffer.substring(2, 4));
    return hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59;
  }

  /// 住所文字列から市区町村部分を抜き出す（取れなければ施設名で代替）。
  String _areaLabel(OrderModel o) {
    final m = RegExp(r'([^\d\s]+?[市区町村])').firstMatch(o.address);
    if (m != null) return m.group(1)!;
    return o.facilityName.isNotEmpty ? o.facilityName : o.address;
  }

  /// カレンダー下部：選択日の受注を「市区町村＋顧客名＋時間」で簡易表示する。
  Widget _buildOrderPreview(BuildContext context) {
    if (widget.previewOrders.isEmpty) return const SizedBox.shrink();
    final sameDay = widget.previewOrders
        .where((o) => isSameDay(o.deliveryDate, _tempDate))
        .toList()
      ..sort((a, b) => a.deliveryTime.compareTo(b.deliveryTime));

    return Padding(
      padding: EdgeInsets.only(top: rs(context, 10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${DateFormat('M/d(E)', 'ja_JP').format(_tempDate)} の受注 ${sameDay.length}件',
            style: TextStyle(fontSize: rf(context, 12), fontWeight: FontWeight.bold, color: Colors.blueGrey.shade700),
          ),
          SizedBox(height: rs(context, 6)),
          if (sameDay.isEmpty)
            Text('受注なし', style: TextStyle(fontSize: rf(context, 12), color: Colors.grey))
          else
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: rs(context, 160)),
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
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: rs(context, 16), vertical: rs(context, 8)),
                  decoration: BoxDecoration(
                    color: isValid ? widget.themeColor.withValues(alpha: 0.08) : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(rs(context, 20)),
                    border: Border.all(color: isValid ? widget.themeColor.withValues(alpha: 0.2) : Colors.red.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.event, size: rs(context, 18), color: isValid ? widget.themeColor : Colors.red),
                      SizedBox(width: rs(context, 8)),
                      Text(
                        "$formattedDate  ",
                        style: TextStyle(fontSize: rf(context, 16), fontWeight: FontWeight.bold, color: isValid ? Colors.black87 : Colors.red),
                      ),
                      Icon(Icons.access_time, size: rs(context, 18), color: isValid ? widget.themeColor : Colors.red),
                      SizedBox(width: rs(context, 8)),
                      Text(
                        _displayTime,
                        style: TextStyle(fontSize: rf(context, 20), fontWeight: FontWeight.w900, color: isValid ? Colors.black87 : Colors.red, letterSpacing: 1),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: rs(context, 8)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            SizedBox(height: rs(context, 24)),
            
            Flexible(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 左側: カレンダーエリア
                  Expanded(
                    flex: 55,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
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
                          selectedTextStyle: const TextStyle(color: AppColors.background, fontWeight: FontWeight.bold),
                          // 今日：丸枠のみ・塗りつぶしなし
                          todayDecoration: BoxDecoration(
                            color: Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(color: widget.themeColor, width: rs(context, 1.5)),
                          ),
                          todayTextStyle: TextStyle(color: widget.themeColor, fontWeight: FontWeight.bold),
                        ),
                        selectedDayPredicate: (day) => isSameDay(_tempDate, day),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() => _tempDate = selectedDay);
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
                                    border: Border.all(color: const Color(0xFF000038), width: rs(context, 1.5)),
                                  ),
                                  child: Text('${day.day}',
                                      style: const TextStyle(color: Color(0xFF000038), fontWeight: FontWeight.bold)),
                                ),
                              );
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                      _buildOrderPreview(context),
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
                                  border: Border.all(color: const Color(0xFF000038), width: rs(context, 1.5)),
                                ),
                              ),
                              SizedBox(width: rs(context, 6)),
                              Text('${widget.highlightLabel}: ${DateFormat('M/d(E)', 'ja_JP').format(widget.highlightDate!)}',
                                  style: TextStyle(fontSize: rf(context, 12), color: const Color(0xFF000038), fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                    ],
                  )),

                  SizedBox(width: rs(context, 24)),
                  VerticalDivider(width: rs(context, 1)),
                  SizedBox(width: rs(context, 24)),
                  
                  // 右側: 時間入力エリア (テンキーのみ)
                  Expanded(
                    flex: 45,
                    child: Center(
                      child: KNumericDialPad(
                        onInput: _onInput,
                        onBackspace: _onBackspace,
                        onClear: _onClear,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: rs(context, 24)),
            
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
