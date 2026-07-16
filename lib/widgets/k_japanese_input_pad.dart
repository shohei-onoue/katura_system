import 'dart:async';
import 'package:flutter/material.dart';

enum KInputMode { kana, alpha, numeric }

class KJapaneseInputPad extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback? onCompleted;
  final Function(String)? onRowTap;

  const KJapaneseInputPad({
    super.key,
    required this.controller,
    this.onCompleted,
    this.onRowTap,
  });

  @override
  State<KJapaneseInputPad> createState() => _KJapaneseInputPadState();
}

class _KJapaneseInputPadState extends State<KJapaneseInputPad> {
  KInputMode _mode = KInputMode.kana;
  bool _isUpperCase = false;

  final Map<String, List<String>> _kanaMap = {
    'あ': ['あ', 'い', 'う', 'え', 'お'],
    'か': ['か', 'き', 'く', 'け', 'こ'],
    'さ': ['さ', 'し', 'す', 'せ', 'そ'],
    'た': ['た', 'ち', 'つ', 'て', 'と'],
    'な': ['な', 'に', 'ぬ', 'ね', 'の'],
    'は': ['は', 'ひ', 'ふ', 'へ', 'ほ'],
    'ま': ['ま', 'み', 'む', 'め', 'も'],
    'や': ['や', 'ゆ', 'よ'],
    'ら': ['ら', 'り', 'る', 'れ', 'ろ'],
    'わ': ['わ', 'を', 'ん', 'ー'],
  };

  final Map<String, List<String>> _alphaMap = {
    '1': ['@', '#', '/', '&', '_'],
    '2': ['a', 'b', 'c'],
    '3': ['d', 'e', 'f'],
    '4': ['g', 'h', 'i'],
    '5': ['j', 'k', 'l'],
    '6': ['m', 'n', 'o'],
    '7': ['p', 'q', 'r', 's'],
    '8': ['t', 'u', 'v'],
    '9': ['w', 'x', 'y', 'z'],
    '0': ["'", '"', '(', ')'],
  };

  final Map<String, String> _alphaLabelMap = {
    '1': '@#/_',
    '2': 'abc',
    '3': 'def',
    '4': 'ghi',
    '5': 'jkl',
    '6': 'mno',
    '7': 'pqrs',
    '8': 'tuv',
    '9': 'wxyz',
    '0': '\'"()',
  };

  String? _lastTappedKey;
  int _tapCount = 0;
  Timer? _timer;

  void _handleKeyTap(String key) {
    widget.onRowTap?.call(key);

    setState(() {
      if (_lastTappedKey == key && _mode != KInputMode.numeric) {
        _tapCount++;
        final text = widget.controller.text;
        if (text.isNotEmpty) {
          widget.controller.text = text.substring(0, text.length - 1);
        }
      } else {
        _finalizeLastChar();
        _lastTappedKey = key;
        _tapCount = 0;
      }

      if (_mode == KInputMode.kana) {
        final chars = _kanaMap[key]!;
        widget.controller.text += chars[_tapCount % chars.length];
      } else if (_mode == KInputMode.alpha) {
        final chars = _alphaMap[key]!;
        String char = chars[_tapCount % chars.length];
        if (_isUpperCase) {
          char = char.toUpperCase();
        }
        widget.controller.text += char;
      } else {
        widget.controller.text += key;
      }
    });
    _resetTimer();
  }

  void _finalizeLastChar() {
    _timer?.cancel();
    _lastTappedKey = null;
    _tapCount = 0;
  }

  void _resetTimer() {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 1200), () => _finalizeLastChar());
  }

  void _handleModifier() {
    if (_mode != KInputMode.kana) return;
    final text = widget.controller.text;
    if (text.isEmpty) return;
    final lastChar = text.substring(text.length - 1);
    final converted = _convertModifier(lastChar);
    if (converted != lastChar) {
      widget.controller.text = text.substring(0, text.length - 1) + converted;
    }
  }

  String _convertModifier(String char) {
    const map = {
      'は': 'ば', 'ば': 'ぱ', 'ぱ': 'は',
      'ひ': 'び', 'び': 'ぴ', 'ぴ': 'ひ',
      'ふ': 'ぶ', 'ぶ': 'ぷ', 'ぷ': 'ふ',
      'へ': 'べ', 'べ': 'ぺ', 'ぺ': 'へ',
      'ほ': 'ぼ', 'ぼ': 'ぽ', 'ぽ': 'ほ',
      'か': 'が', 'が': 'か', 'き': 'ぎ', 'ぎ': 'き', 'く': 'ぐ', 'ぐ': 'く', 'け': 'げ', 'げ': 'け', 'こ': 'ご', 'ご': 'こ',
      'さ': 'ざ', 'ざ': 'さ', 'し': 'じ', 'じ': 'し', 'す': 'ず', 'ず': 'す', 'せ': 'ぜ', 'ぜ': 'せ', 'そ': 'ぞ', 'ぞ': 'そ',
      'た': 'だ', 'だ': 'た', 'ち': 'ぢ', 'ぢ': 'ち', 'つ': 'づ', 'づ': 'っ', 'っ': 'つ', 'て': 'で', 'で': 'て', 'と': 'ど', 'ど': 'と',
      'あ': 'ぁ', 'ぁ': 'あ', 'い': 'ぃ', 'ぃ': 'い', 'う': 'ぅ', 'ぅ': 'う', 'え': 'ぇ', 'ぇ': 'え', 'お': 'ぉ', 'ぉ': 'お',
      'や': 'ゃ', 'ゃ': 'や', 'ゆ': 'ゅ', 'ゅ': 'ゆ', 'よ': 'ょ', 'ょ': 'よ',
    };
    return map[char] ?? char;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 380,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _modeButton('かな', KInputMode.kana),
              const SizedBox(width: 8),
              _modeButton('ABC', KInputMode.alpha),
              const SizedBox(width: 8),
              _modeButton('123', KInputMode.numeric),
            ],
          ),
          const SizedBox(height: 12),
          _buildKeyGrid(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _actionButton('送る', Colors.orange.shade800, _finalizeLastChar)),
              const SizedBox(width: 12),
              Expanded(child: _actionButton('確定', Colors.deepPurple, () { _finalizeLastChar(); widget.onCompleted?.call(); })),
            ],
          ),
        ],
      ),
    );
  }

  Widget _modeButton(String label, KInputMode mode) {
    final isSelected = _mode == mode;
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.deepPurple : Colors.white,
          foregroundColor: isSelected ? Colors.white : Colors.black87,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.shade300)),
          padding: EdgeInsets.zero,
        ),
        onPressed: () => setState(() { _finalizeLastChar(); _mode = mode; }),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildKeyGrid() {
    if (_mode == KInputMode.kana) {
      final List<String> keys = ['あ', 'か', 'さ', 'た', 'な', 'は', 'ま', 'や', 'ら'];
      return GridView.count(
        shrinkWrap: true,
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.4,
        children: [
          ...keys.map((k) => _buildKey(k)),
          _buildSpecialKey('濁/小', _handleModifier, Colors.blueGrey.shade300),
          _buildKey('わ'),
          _buildDeleteKey(),
        ],
      );
    } else if (_mode == KInputMode.alpha) {
      final List<String> keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9'];
      return GridView.count(
        shrinkWrap: true,
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.4,
        children: [
          ...keys.map((k) => _buildKey(k)),
          _buildSpecialKey(_isUpperCase ? 'A→a' : 'a→A', () => setState(() => _isUpperCase = !_isUpperCase), Colors.blueGrey.shade300),
          _buildKey('0'),
          _buildDeleteKey(),
        ],
      );
    } else {
      final List<String> keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];
      return GridView.count(
        shrinkWrap: true,
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.4,
        children: [
          ...keys.take(9).map((k) => _buildKey(k)),
          const SizedBox.shrink(),
          _buildKey('0'),
          _buildDeleteKey(),
        ],
      );
    }
  }

  Widget _buildKey(String label) {
    String displayLabel = label;
    if (_mode == KInputMode.alpha && _alphaLabelMap.containsKey(label)) {
      displayLabel = _alphaLabelMap[label]!;
      if (_isUpperCase) {
        displayLabel = displayLabel.toUpperCase();
      }
    }

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.zero,
      ),
      onPressed: () => _handleKeyTap(label),
      child: Text(
        displayLabel,
        style: const TextStyle(
          fontSize: 20, // フォントサイズを20に統一
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDeleteKey() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey.shade600,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.zero,
      ),
      onPressed: () {
        _finalizeLastChar();
        if (widget.controller.text.isNotEmpty) {
          widget.controller.text = widget.controller.text.substring(0, widget.controller.text.length - 1);
        }
      },
      child: const Icon(Icons.backspace, size: 32),
    );
  }

  Widget _buildSpecialKey(String label, VoidCallback onPressed, Color color) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      onPressed: onPressed,
      child: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _actionButton(String label, Color color, VoidCallback onPressed) {
    return SizedBox(height: 54, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: onPressed, child: Text(label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))));
  }
}
