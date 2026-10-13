import 'package:flutter/material.dart';
import 'k_responsive.dart';
import 'package:katura_system/utils/app_colors.dart';

/// メール/パスワード欄用のオンスクリーンキーボード。
/// OS標準キーボードを使わず、独自のキー配列で入力する。
/// 見た目はFigma「ログインキーボード（KEmailKeyboardPad）」(I10 Plus 1280x800 基準) に合わせる。
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
  bool _isUpperCase = false;
  final FocusNode _previewFocus = FocusNode();

  @override
  void dispose() {
    _previewFocus.dispose();
    super.dispose();
  }

  static const List<String> _defaultDomains = [
    '@gmail.com',
    '@yahoo.co.jp',
    '@outlook.com',
    '@icloud.com',
  ];

  // 通常キー1つ分の幅(flex)と、右端の特殊キー(削除/ENTER/シフト)の幅
  static const int _keyFlex = 80;
  static const int _backspaceFlex = 172;
  static const int _shiftFlex = 174;

  static const List<String> _row1 = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-'];
  static const List<String> _row2 = ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '@'];
  static const List<String> _row3 = ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', ':'];
  static const List<String> _row4 = ['z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/', '_'];

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
    _insert(_isUpperCase ? key.toUpperCase() : key);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildPreview(context),
        if (widget.isEmailMode) ...[
          SizedBox(height: rs(context, 13)),
          _buildDomainRow(context),
          SizedBox(height: rs(context, 14)),
        ] else
          SizedBox(height: rs(context, 12)),
        _buildKeyArea(context),
      ],
    );
  }

  /// 入力中の文字を表示する欄（中央揃え）
  Widget _buildPreview(BuildContext context) {
    return SizedBox(
      height: rs(context, 72),
      child: TextField(
        controller: widget.controller,
        focusNode: _previewFocus,
        readOnly: true,
        showCursor: true,
        autofocus: true,
        expands: true,
        maxLines: null,
        minLines: null,
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.center,
        style: TextStyle(fontSize: rf(context, 32), fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.mainBackground,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: rs(context, 12)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(rs(context, 8))),
        ),
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
        separatorBuilder: (_, _) => SizedBox(width: rs(context, 8)),
        itemBuilder: (context, index) {
          final domain = domains[index];
          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mainBackground,
              foregroundColor: Colors.black87,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(rs(context, 8)),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              padding: EdgeInsets.symmetric(horizontal: rs(context, 12)),
            ),
            onPressed: () => _insert(domain),
            child: Text(domain, style: TextStyle(fontSize: rf(context, 20), fontWeight: FontWeight.bold)),
          );
        },
      ),
    );
  }

  /// 灰色の枠の中のキー全体
  Widget _buildKeyArea(BuildContext context) {
    final gap = SizedBox(height: rs(context, 10));
    return Container(
      padding: EdgeInsets.fromLTRB(rs(context, 12), rs(context, 26), rs(context, 12), rs(context, 20)),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(rs(context, 16)),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1段目：数字・「-」・削除
          Row(children: [
            ..._keys(context, _row1),
            _cell(_backspaceFlex, _buildBackspace(context)),
          ]),
          gap,
          // 2・3段目：英字・記号と、2段分の高さのENTER
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: _keyFlex * 11,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(children: _keys(context, _row2)),
                      gap,
                      Row(children: _keys(context, _row3)),
                    ],
                  ),
                ),
                _cell(_backspaceFlex, _buildEnter(context), vertical: rs(context, 5)),
              ],
            ),
          ),
          gap,
          // 4段目：英字・記号・シフト
          Row(children: [
            ..._keys(context, _row4),
            _cell(_shiftFlex, _buildShift(context)),
          ]),
          SizedBox(height: rs(context, 27)),
          _buildSpace(context),
        ],
      ),
    );
  }

  Widget _cell(int flex, Widget child, {double vertical = 0}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: rs(context, 2), vertical: vertical),
        child: child,
      ),
    );
  }

  List<Widget> _keys(BuildContext context, List<String> keys) =>
      keys.map((k) => _cell(_keyFlex, _buildKey(context, k))).toList();

  ButtonStyle _keyStyle(BuildContext context, {Color? background, Color? foreground, BorderSide? side}) {
    return ElevatedButton.styleFrom(
      backgroundColor: background ?? AppColors.mainBackground,
      foregroundColor: foreground ?? Colors.black87,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(rs(context, 10)),
        side: side ?? BorderSide.none,
      ),
      padding: EdgeInsets.zero,
    );
  }

  Widget _buildKey(BuildContext context, String key) {
    final isLetter = RegExp(r'^[a-z]$').hasMatch(key);
    final label = (_isUpperCase && isLetter) ? key.toUpperCase() : key;
    return SizedBox(
      height: rs(context, 70),
      child: ElevatedButton(
        style: _keyStyle(context),
        onPressed: () => _handleKeyTap(key),
        child: Text(label, style: TextStyle(fontSize: rf(context, 40), fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildBackspace(BuildContext context) {
    return SizedBox(
      height: rs(context, 70),
      child: ElevatedButton(
        style: _keyStyle(context, background: Colors.grey.shade600, foreground: AppColors.mainBackground),
        onPressed: _backspace,
        child: Icon(Icons.backspace, size: rs(context, 40)),
      ),
    );
  }

  Widget _buildShift(BuildContext context) {
    return SizedBox(
      height: rs(context, 70),
      child: ElevatedButton(
        style: _keyStyle(
          context,
          background: _isUpperCase ? AppColors.accentPurple : null,
          foreground: _isUpperCase ? AppColors.mainBackground : null,
        ),
        onPressed: () => setState(() => _isUpperCase = !_isUpperCase),
        child: Icon(Icons.arrow_upward, size: rs(context, 40)),
      ),
    );
  }

  Widget _buildEnter(BuildContext context) {
    return ElevatedButton(
      style: _keyStyle(context, background: AppColors.accentPurple, foreground: AppColors.mainBackground),
      onPressed: widget.onCompleted,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('ENTER', style: TextStyle(fontSize: rf(context, 24), fontWeight: FontWeight.bold)),
          Icon(Icons.keyboard_return, size: rs(context, 36)),
        ],
      ),
    );
  }

  Widget _buildSpace(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: rs(context, 82),
      child: ElevatedButton(
        style: _keyStyle(context, side: BorderSide(color: Colors.grey.shade300)),
        onPressed: () => _insert(' '),
        child: Text('space', style: TextStyle(fontSize: rf(context, 32), fontWeight: FontWeight.bold)),
      ),
    );
  }
}
