import 'package:flutter/material.dart';
import 'k_responsive.dart';
import 'package:katura_system/utils/app_colors.dart';

enum KEmailKeyboardMode { letters, symbols }

/// メール/パスワード欄用のオンスクリーンキーボード。
/// OS標準キーボードを使わず、独自のキー配列で入力する。
class KEmailKeyboardPad extends StatefulWidget {
  final TextEditingController controller;
  final bool isEmailMode;
  final VoidCallback? onCompleted;
  final List<String>? emailDomains;

  const KEmailKeyboardPad({
    super.key,
    required this.controller,
    this.isEmailMode = true,
    this.onCompleted,
    this.emailDomains,
  });

  @override
  State<KEmailKeyboardPad> createState() => _KEmailKeyboardPadState();
}

class _KEmailKeyboardPadState extends State<KEmailKeyboardPad> {
  KEmailKeyboardMode _mode = KEmailKeyboardMode.letters;
  bool _isUpperCase = false;

  static const List<String> _defaultDomains = [
    '@gmail.com',
    '@yahoo.co.jp',
    '@outlook.com',
    '@icloud.com',
  ];

  final List<List<String>> _letterRows = const [
    ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'],
    ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'],
    ['z', 'x', 'c', 'v', 'b', 'n', 'm'],
  ];

  final List<List<String>> _symbolRows = const [
    ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
    ['@', '.', '-', '_', '+', '/'],
    ['#', '&', '%', '(', ')', '*'],
  ];

  void _insert(String text) {
    final controller = widget.controller;
    final value = controller.text;
    final selection = controller.selection;
    final start = selection.start >= 0 ? selection.start : value.length;
    final end = selection.end >= 0 ? selection.end : value.length;
    final newText = value.replaceRange(start, end, text);
    controller.text = newText;
    final offset = start + text.length;
    controller.selection = TextSelection.collapsed(offset: offset);
    setState(() {});
  }

  void _backspace() {
    final controller = widget.controller;
    final value = controller.text;
    final selection = controller.selection;
    if (value.isEmpty) return;
    if (selection.start != selection.end && selection.start >= 0) {
      final newText = value.replaceRange(selection.start, selection.end, '');
      controller.text = newText;
      controller.selection = TextSelection.collapsed(offset: selection.start);
    } else {
      final cursor = selection.end >= 0 ? selection.end : value.length;
      if (cursor <= 0) return;
      final newText = value.substring(0, cursor - 1) + value.substring(cursor);
      controller.text = newText;
      controller.selection = TextSelection.collapsed(offset: cursor - 1);
    }
    setState(() {});
  }

  void _handleKeyTap(String key) {
    String char = key;
    if (_mode == KEmailKeyboardMode.letters && _isUpperCase) {
      char = char.toUpperCase();
    }
    _insert(char);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(rs(context, 12)),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(rs(context, 16)),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: rs(context, 10))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.isEmailMode) ...[
            _buildDomainRow(context),
            SizedBox(height: rs(context, 12)),
          ],
          Row(
            children: [
              _modeButton(context, 'ABC', KEmailKeyboardMode.letters),
              SizedBox(width: rs(context, 8)),
              _modeButton(context, '123#', KEmailKeyboardMode.symbols),
            ],
          ),
          SizedBox(height: rs(context, 12)),
          ..._buildKeyRows(context),
          SizedBox(height: rs(context, 4)),
          _buildBottomRow(context),
        ],
      ),
    );
  }

  Widget _buildDomainRow(BuildContext context) {
    final domains = widget.emailDomains ?? _defaultDomains;
    return SizedBox(
      height: rs(context, 40),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: domains.length,
        separatorBuilder: (_, __) => SizedBox(width: rs(context, 8)),
        itemBuilder: (context, index) {
          final domain = domains[index];
          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.background,
              foregroundColor: Colors.black87,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(rs(context, 8)),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              padding: EdgeInsets.symmetric(horizontal: rs(context, 12)),
            ),
            onPressed: () => _insert(domain),
            child: Text(domain, style: TextStyle(fontSize: rf(context, 13), fontWeight: FontWeight.bold)),
          );
        },
      ),
    );
  }

  Widget _modeButton(BuildContext context, String label, KEmailKeyboardMode mode) {
    final isSelected = _mode == mode;
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.deepPurple : AppColors.background,
          foregroundColor: isSelected ? AppColors.background : Colors.black87,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(context, 8)), side: BorderSide(color: Colors.grey.shade300)),
          padding: EdgeInsets.zero,
          minimumSize: Size(0, rs(context, 44)),
        ),
        onPressed: () => setState(() => _mode = mode),
        child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: rf(context, 14))),
      ),
    );
  }

  List<Widget> _buildKeyRows(BuildContext context) {
    final rows = _mode == KEmailKeyboardMode.letters ? _letterRows : _symbolRows;
    return rows.map((row) {
      return Padding(
        padding: EdgeInsets.only(bottom: rs(context, 8)),
        child: Row(
          children: row.map((key) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: rs(context, 2)),
                child: _buildKey(context, key),
              ),
            );
          }).toList(),
        ),
      );
    }).toList();
  }

  Widget _buildKey(BuildContext context, String key) {
    String label = key;
    if (_mode == KEmailKeyboardMode.letters && _isUpperCase) {
      label = label.toUpperCase();
    }
    return SizedBox(
      height: rs(context, 44),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.background,
          foregroundColor: Colors.black87,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(context, 10))),
          padding: EdgeInsets.zero,
        ),
        onPressed: () => _handleKeyTap(key),
        child: Text(label, style: TextStyle(fontSize: rf(context, 16), fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildBottomRow(BuildContext context) {
    return Row(
      children: [
        if (_mode == KEmailKeyboardMode.letters)
          SizedBox(
            width: rs(context, 56),
            height: rs(context, 48),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isUpperCase ? Colors.deepPurple : Colors.blueGrey.shade300,
                foregroundColor: AppColors.background,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(context, 10))),
                padding: EdgeInsets.zero,
              ),
              onPressed: () => setState(() => _isUpperCase = !_isUpperCase),
              child: Icon(Icons.arrow_upward, size: rs(context, 22)),
            ),
          ),
        if (_mode == KEmailKeyboardMode.letters) SizedBox(width: rs(context, 8)),
        Expanded(
          child: SizedBox(
            height: rs(context, 48),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.background,
                foregroundColor: Colors.black87,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(context, 10)), side: BorderSide(color: Colors.grey.shade300)),
              ),
              onPressed: () => _insert(' '),
              child: Text('space', style: TextStyle(fontSize: rf(context, 14), fontWeight: FontWeight.bold)),
            ),
          ),
        ),
        SizedBox(width: rs(context, 8)),
        SizedBox(
          width: rs(context, 56),
          height: rs(context, 48),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade600,
              foregroundColor: AppColors.background,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(context, 10))),
              padding: EdgeInsets.zero,
            ),
            onPressed: _backspace,
            child: Icon(Icons.backspace, size: rs(context, 22)),
          ),
        ),
        SizedBox(width: rs(context, 8)),
        SizedBox(
          width: rs(context, 72),
          height: rs(context, 48),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade800,
              foregroundColor: AppColors.background,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(context, 10))),
              padding: EdgeInsets.zero,
            ),
            onPressed: widget.onCompleted,
            child: Text('完了', style: TextStyle(fontSize: rf(context, 14), fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}
