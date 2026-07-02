import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class KTimeField extends StatefulWidget {
  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onSelected;
  final IconData icon;

  const KTimeField({
    super.key,
    required this.label,
    required this.value,
    required this.onSelected,
    this.icon = Icons.access_time,
  });

  @override
  State<KTimeField> createState() => _KTimeFieldState();
}

class _KTimeFieldState extends State<KTimeField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formatTime(widget.value));
  }

  @override
  void didUpdateWidget(KTimeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _controller.text = _formatTime(widget.value);
    }
  }

  String _formatTime(DateTime dt) {
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  void _handleManualInput(String val) {
    // 数字のみ抽出
    final digits = val.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (digits.length == 4) {
      final hour = int.tryParse(digits.substring(0, 2)) ?? 0;
      final min = int.tryParse(digits.substring(2, 4)) ?? 0;
      
      if (hour < 24 && min < 60) {
        final now = DateTime.now();
        final newTime = DateTime(now.year, now.month, now.day, hour, min);
        widget.onSelected(newTime);
        _controller.text = "$hour:${min.toString().padLeft(2, '0')}";
        _controller.selection = TextSelection.fromPosition(TextPosition(offset: _controller.text.length));
      }
    }
  }

  void _showDrumPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 250,
        color: Colors.white,
        child: Column(
          children: [
            Container(
              height: 44,
              color: Colors.grey[100],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoButton(
                    child: const Text('完了', style: TextStyle(color: Colors.deepOrange)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: widget.value,
                use24hFormat: true,
                onDateTimeChanged: (DateTime newTime) {
                  widget.onSelected(newTime);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        inputFormatters: [
          LengthLimitingTextInputFormatter(5),
        ],
        onChanged: _handleManualInput,
        decoration: InputDecoration(
          labelText: widget.label,
          prefixIcon: Icon(widget.icon),
          suffixIcon: IconButton(
            icon: const Icon(Icons.keyboard_arrow_down),
            onPressed: _showDrumPicker,
          ),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          hintText: "1200",
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
