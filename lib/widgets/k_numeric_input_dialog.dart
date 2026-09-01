import 'package:flutter/material.dart';
import 'k_responsive.dart';
import 'k_numeric_dial_pad.dart';
import 'k_button.dart';

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

  const KNumericInputDialog({
    super.key,
    required this.title,
    required this.onConfirmed,
    this.initialValue = '',
    this.maxLength = 20,
    this.emptyHint = '番号を入力してください',
    this.themeColor = Colors.deepPurple,
    this.overwrite = false,
  });

  @override
  State<KNumericInputDialog> createState() => _KNumericInputDialogState();
}

class _KNumericInputDialogState extends State<KNumericInputDialog> {
  late String _text;

  @override
  void initState() {
    super.initState();
    _text = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
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
                child: Text(
                  _text.isEmpty ? widget.emptyHint : _text,
                  style: TextStyle(
                    fontSize: rf(context, 24),
                    fontWeight: FontWeight.bold,
                    color: _text.isEmpty ? Colors.grey : Colors.black87,
                  ),
                ),
              ),
              SizedBox(height: rs(context, 24)),
              KNumericDialPad(
                onInput: (digit) {
                  setState(() {
                    if (_text.length < widget.maxLength) {
                      _text += digit;
                    } else if (widget.overwrite && widget.maxLength > 0) {
                      _text = _text.substring(1) + digit;
                    }
                  });
                },
                onClear: () => setState(() => _text = ''),
                onBackspace: () {
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
                    widget.onConfirmed(_text);
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
