import 'package:flutter/material.dart';
import 'k_responsive.dart';
import 'k_numeric_dial_pad.dart';
import 'k_button.dart';
import 'package:katura_system/utils/app_colors.dart';

/// 数字入力用の共通ダイヤログ（電話番号入力・数量直接入力などで共有）。
/// 入力はローカル状態で保持し、「確定」でのみ [onConfirmed] を呼ぶ。
class KNumericInputDialog extends StatefulWidget {
  final String title;
  final String initialValue;
  final int maxLength;
  final String emptyHint;
  final Color themeColor;
  final ValueChanged<String> onConfirmed;
  /// true の場合、maxLength に達した後の入力は左詰めシフトで上書きする（例：HHMM の時刻入力）
  final bool overwrite;
  /// true の場合、HHMM の時刻入力として「○○:○○」で表示する。
  /// 数字をタップするとそこにカーソルが付き、ダイヤルで1桁ずつ上書きして編集できる。確定値は4桁（例: 1430）。
  final bool timeFormat;
  /// 数量・金額などの単位（例：個、台、円）。指定すると「0個」のように単位付きで表示する（空のときは「0」）
  final String unit;

  const KNumericInputDialog({
    super.key,
    required this.title,
    required this.onConfirmed,
    this.initialValue = '',
    this.maxLength = 20,
    this.emptyHint = '番号を入力してください',
    this.themeColor = AppColors.accentPurple,
    this.overwrite = false,
    this.timeFormat = false,
    this.unit = '',
  });

  @override
  State<KNumericInputDialog> createState() => _KNumericInputDialogState();
}

class _KNumericInputDialogState extends State<KNumericInputDialog> {
  late String _text;
  // timeFormat 用：4桁の数字とカーソル位置（0〜3）
  List<String> _t = ['0', '0', '0', '0'];
  int _cursor = 0;

  @override
  void initState() {
    super.initState();
    _text = widget.initialValue;
    if (widget.timeFormat) {
      final d = widget.initialValue.replaceAll(RegExp(r'[^0-9]'), '').padLeft(4, '0');
      _t = d.substring(d.length - 4).split('');
    }
  }

  /// 時刻表示：数字4つ（タップでカーソル）を「○○:○○」の形に並べる。
  Widget _buildTimeDisplay(BuildContext context) {
    Widget digit(int i) {
      final selected = i == _cursor;
      return GestureDetector(
        onTap: () => setState(() => _cursor = i),
        child: Container(
          width: rs(context, 40),
          padding: EdgeInsets.symmetric(vertical: rs(context, 4)),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? widget.themeColor : Colors.transparent,
                width: rs(context, 3),
              ),
            ),
          ),
          child: Text(
            _t[i],
            style: TextStyle(fontSize: rf(context, 32), fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        digit(0),
        digit(1),
        Text(':', style: TextStyle(fontSize: rf(context, 32), fontWeight: FontWeight.bold, color: Colors.black87)),
        digit(2),
        digit(3),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.popupBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(context, 16))),
      child: Container(
        width: rs(context, 400),
        padding: EdgeInsets.all(rs(context, 24)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.title, style: TextStyle(fontSize: rf(context, 18), fontWeight: FontWeight.bold)),
              SizedBox(height: rs(context, 20)),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: rs(context, 16)),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(rs(context, 12)),
                  border: Border.all(color: Colors.grey.shade300, width: rs(context, 2)),
                ),
                child: widget.timeFormat
                    ? _buildTimeDisplay(context)
                    : Text(
                        widget.unit.isNotEmpty
                            ? '${_text.isEmpty ? '0' : _text}${widget.unit}'
                            : (_text.isEmpty ? widget.emptyHint : _text),
                        style: TextStyle(
                          fontSize: rf(context, 24),
                          fontWeight: FontWeight.bold,
                          color: _text.isEmpty && widget.unit.isEmpty ? Colors.grey : Colors.black87,
                        ),
                      ),
              ),
              SizedBox(height: rs(context, 24)),
              KNumericDialPad(
                onInput: (digit) {
                  if (widget.timeFormat) {
                    // カーソル位置の数字を上書きして、次の桁へ進む
                    setState(() {
                      _t[_cursor] = digit;
                      if (_cursor < 3) _cursor++;
                    });
                    return;
                  }
                  setState(() {
                    if (_text.length < widget.maxLength) {
                      _text += digit;
                    } else if (widget.overwrite && widget.maxLength > 0) {
                      _text = _text.substring(1) + digit;
                    }
                  });
                },
                onClear: () => setState(() {
                  _text = '';
                  _t = ['0', '0', '0', '0'];
                  _cursor = 0;
                }),
                onBackspace: () {
                  if (widget.timeFormat) {
                    // カーソル位置の数字を 0 に戻して、1つ前の桁へ
                    setState(() {
                      _t[_cursor] = '0';
                      if (_cursor > 0) _cursor--;
                    });
                    return;
                  }
                  if (_text.isNotEmpty) {
                    setState(() => _text = _text.substring(0, _text.length - 1));
                  }
                },
              ),
              SizedBox(height: rs(context, 24)),
              SizedBox(
                width: double.infinity,
                child: KButton(
                  label: '確定',
                  onPressed: () {
                    widget.onConfirmed(widget.timeFormat ? _t.join() : _text);
                    Navigator.pop(context);
                  },
                  color: widget.themeColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
