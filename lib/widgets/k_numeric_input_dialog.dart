import 'package:katura_system/utils/device_mode.dart';
import 'package:flutter/material.dart';
import 'k_responsive.dart';
import 'k_numeric_dial_pad.dart';
import 'k_button.dart';
import 'package:katura_system/utils/app_colors.dart';
import '../screens/phone/landscape/landscape_style.dart';

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

  void _onInput(String digit) {
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
  }

  void _onClear() => setState(() {
        _text = '';
        _t = ['0', '0', '0', '0'];
        _cursor = 0;
      });

  void _onBackspace() {
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
  }

  void _confirm() {
    widget.onConfirmed(widget.timeFormat ? _t.join() : _text);
    Navigator.pop(context);
  }

  /// スマホ横向き用（Figma 169:147）: 左に表示/確定/キャンセル、右に4x3キー
  Widget _buildLandscape(BuildContext context) {
    final mq = MediaQuery.of(context);
    Widget key(String d) {
      final isClear = d == 'クリア';
      final isBk = d == '⌫';
      final Color bg = isClear ? LS.chipOff : (isBk ? LS.orange : Colors.white);
      final Color border = isBk ? LS.orange : LS.borderStrong;
      return Material(
        color: bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: border, width: 2)),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => isClear ? _onClear() : (isBk ? _onBackspace() : _onInput(d)),
          child: Center(
            child: isBk
                ? const Icon(Icons.backspace_outlined, size: 32, color: Colors.white)
                : Text(d, maxLines: 1, style: TextStyle(fontSize: isClear ? 20 : 32, fontWeight: FontWeight.bold, color: LS.text)),
          ),
        ),
      );
    }

    final rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['クリア', '0', '⌫'],
    ];
    final display = widget.timeFormat
        ? FittedBox(fit: BoxFit.scaleDown, child: _buildTimeDisplay(context))
        : Text(
            widget.unit.isNotEmpty ? '${_text.isEmpty ? '0' : _text}${widget.unit}' : (_text.isEmpty ? widget.emptyHint : _text),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: _text.isEmpty && widget.unit.isEmpty ? 20 : 48, fontWeight: FontWeight.bold, color: _text.isEmpty && widget.unit.isEmpty ? LS.hint : LS.text),
          );
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8 + mq.viewInsets.bottom / 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 650),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 270,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: LS.text)),
                        const SizedBox(height: 10),
                        Container(
                          height: 64,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(color: LS.inputBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: LS.borderStrong)),
                          child: display,
                        ),
                        const SizedBox(height: 10),
                        const Spacer(),
                        SizedBox(
                          height: 64,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: widget.themeColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: _confirm,
                            icon: const Icon(Icons.check, size: 24),
                            label: const Text('確定', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 56,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: widget.themeColor,
                              side: BorderSide(color: widget.themeColor, width: 2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text('キャンセル', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      children: [
                        for (int i = 0; i < rows.length; i++) ...[
                          if (i > 0) const SizedBox(height: 8),
                          SizedBox(
                            height: 60,
                            child: Row(
                              children: [
                                for (int j = 0; j < 3; j++) ...[
                                  if (j > 0) const SizedBox(width: 8),
                                  Expanded(child: key(rows[i][j])),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
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
    if (isPhoneLandscape(context)) return _buildLandscape(context);
    // スマホ幅は縮小せず実寸で表示する（rs/rf は大画面基準で小さくなりすぎるため）
    final phone = isPhoneMode(context);
    double rs(BuildContext c, double v) => phone ? v : KR.rs(c, v);
    double rf(BuildContext c, double v) => phone ? v : KR.rf(c, v);
    return Dialog(
      backgroundColor: AppColors.popupBackground,
      insetPadding: EdgeInsets.symmetric(horizontal: phone ? 20 : 40, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(context, 16))),
      child: Container(
        width: phone ? double.infinity : rs(context, 400),
        padding: EdgeInsets.all(phone ? 18 : rs(context, 24)),
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
              SizedBox(height: rs(context, phone ? 16 : 24)),
              KNumericDialPad(
                onInput: _onInput,
                onClear: _onClear,
                onBackspace: _onBackspace,
              ),
              SizedBox(height: rs(context, phone ? 16 : 24)),
              SizedBox(
                width: double.infinity,
                child: KButton(
                  label: '確定',
                  height: phone ? 52 : null,
                  fontSize: phone ? 17 : null,
                  onPressed: _confirm,
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
