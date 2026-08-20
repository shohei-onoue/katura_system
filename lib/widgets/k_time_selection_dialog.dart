import 'package:flutter/material.dart';
import 'k_responsive.dart';
import 'k_button.dart';
import 'k_numeric_dial_pad.dart';

class KTimeSelectionDialog extends StatefulWidget {
  final DateTime initialDateTime;
  final TimeOfDay minTime;
  final TimeOfDay maxTime;
  final int interval;
  final String title;
  final Color themeColor;

  const KTimeSelectionDialog({
    super.key,
    required this.initialDateTime,
    this.minTime = const TimeOfDay(hour: 0, minute: 0),
    this.maxTime = const TimeOfDay(hour: 23, minute: 59),
    this.interval = 15,
    this.title = '時間の設定',
    this.themeColor = Colors.deepPurple,
  });

  @override
  State<KTimeSelectionDialog> createState() => _KTimeSelectionDialogState();
}

class _KTimeSelectionDialogState extends State<KTimeSelectionDialog> {
  // 時間の4桁を保持する文字列 (例: "1430" -> 14:30)
  late String _timeBuffer;

  @override
  void initState() {
    super.initState();
    // 初期値を4桁の文字列に変換 (例: 14:30 -> "1430")
    _timeBuffer = widget.initialDateTime.hour.toString().padLeft(2, '0') +
                  widget.initialDateTime.minute.toString().padLeft(2, '0');
  }

  void _onInput(String digit) {
    setState(() {
      // 常に右側に数字を追加し、5桁になったら左端を捨てる（1桁ずつ左にシフトする上書き方式）
      _timeBuffer = (_timeBuffer + digit);
      if (_timeBuffer.length > 4) {
        _timeBuffer = _timeBuffer.substring(_timeBuffer.length - 4);
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (_timeBuffer.isNotEmpty) {
        // バックスペース時は左に0を詰めて4桁を維持する
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
    if (_timeBuffer.length < 4) return _timeBuffer.padLeft(4, '0');
    return "${_timeBuffer.substring(0, 2)}:${_timeBuffer.substring(2, 4)}";
  }

  bool _isValidTime() {
    if (_timeBuffer.length != 4) return false;
    final hour = int.parse(_timeBuffer.substring(0, 2));
    final minute = int.parse(_timeBuffer.substring(2, 4));
    return hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59;
  }

  @override
  Widget build(BuildContext context) {
    final bool isValid = _isValidTime();

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rav(context, 16))),
      child: Container(
        width: rs(context, 400),
        padding: EdgeInsets.all(rav(context, 24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.title, style: TextStyle(fontSize: rf(context, 18), fontWeight: FontWeight.bold)),
            SizedBox(height: rav(context, 24)),
            
            // 時間表示エリア
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: rav(context, 16)),
              decoration: BoxDecoration(
                color: isValid ? Colors.grey.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(rs(context, 12)),
                border: Border.all(
                  color: isValid ? widget.themeColor.withValues(alpha: 0.3) : Colors.red.shade200, 
                  width: 2
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                _displayTime,
                style: TextStyle(
                  fontSize: rf(context, 48), 
                  fontWeight: FontWeight.bold, 
                  color: isValid ? Colors.black87 : Colors.red,
                  letterSpacing: 4,
                ),
              ),
            ),
            
            if (!isValid)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text('無効な時間です', style: TextStyle(color: Colors.red, fontSize: rf(context, 12))),
              ),

            SizedBox(height: rav(context, 24)),
            
            // ダイヤルパッド
            KNumericDialPad(
              onInput: _onInput,
              onBackspace: _onBackspace,
              onClear: _onClear,
            ),
            
            SizedBox(height: rav(context, 32)),
            
            Row(
              children: [
                Expanded(
                  child: KButton(
                    label: 'キャンセル', 
                    onPressed: () => Navigator.pop(context),
                    isSecondary: true,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(width: rav(context, 16)),
                Expanded(
                  child: KButton(
                    label: '確定', 
                    onPressed: isValid ? () {
                      final hour = int.parse(_timeBuffer.substring(0, 2));
                      final minute = int.parse(_timeBuffer.substring(2, 4));
                      final result = DateTime(
                        widget.initialDateTime.year,
                        widget.initialDateTime.month,
                        widget.initialDateTime.day,
                        hour,
                        minute,
                      );
                      Navigator.pop(context, result);
                    } : null,
                    color: widget.themeColor,
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
