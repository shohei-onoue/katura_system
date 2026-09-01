import 'package:flutter/material.dart';
import 'k_responsive.dart';
import 'k_pen_input_dialog.dart';
import '../services/settings_service.dart';

class KMultimodalTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;
  final bool showLabel;
  final double? height;
  final String hintText;

  const KMultimodalTextField({
    super.key,
    required this.label,
    required this.controller,
    this.maxLines = 3,
    this.showLabel = true,
    this.height,
    this.hintText = 'タップして詳細を入力して下さい',
  });

  @override
  State<KMultimodalTextField> createState() => _KMultimodalTextFieldState();
}

class _KMultimodalTextFieldState extends State<KMultimodalTextField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleTextChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChange);
    super.dispose();
  }

  void _handleTextChange() {
    if (mounted) setState(() {});
  }

  void _openPenInput() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => KPenInputDialog(
        initialText: widget.controller.text,
        onTextRecognized: (text) {
          // ダイヤログ側で既存テキスト＋新規判定を結合済みのため、そのまま反映する
          setState(() {
            widget.controller.text = text;
            widget.controller.selection = TextSelection.fromPosition(
              TextPosition(offset: text.length),
            );
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool fixedHeight = widget.height != null;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: fixedHeight ? 0 : 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showLabel && widget.label.isNotEmpty) ...[
            Text(widget.label,
              style: TextStyle(fontSize: rf(context, 13), fontWeight: FontWeight.bold, color: Colors.blueGrey)),
            SizedBox(height: rs(context, 4)),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: SizedBox(
                  height: widget.height,
                  child: ValueListenableBuilder<KInputMode>(
                    valueListenable: SettingsService.inputMode,
                    builder: (context, mode, _) {
                      final bool isPenMode = mode == KInputMode.pen;
                      return TextField(
                        controller: widget.controller,
                        maxLines: fixedHeight ? null : widget.maxLines,
                        minLines: null,
                        expands: fixedHeight,
                        textAlignVertical: TextAlignVertical.center,
                        readOnly: isPenMode,
                        onTap: isPenMode ? _openPenInput : null,
                        decoration: InputDecoration(
                          hintText: widget.hintText,
                          hintStyle: TextStyle(fontSize: rf(context, 14), color: Colors.grey.shade400),
                          isDense: true,
                          isCollapsed: false,
                          contentPadding: EdgeInsets.symmetric(horizontal: rs(context, 16), vertical: 0),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(widget.height != null ? 8 : 12)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(widget.height != null ? 8 : 12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(widget.height != null ? 8 : 12),
                            borderSide: BorderSide(color: Colors.deepPurple, width: rs(context, 1.5)),
                          ),
                          filled: true,
                          fillColor: isPenMode ? Colors.grey.shade50 : Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(width: rs(context, 8)),
              SizedBox(
                height: widget.height,
                width: widget.height,
                child: IconButton(
                  padding: widget.height != null ? EdgeInsets.zero : EdgeInsets.all(rs(context, 8)),
                  constraints: widget.height != null ? const BoxConstraints() : BoxConstraints(minWidth: rs(context, 48), minHeight: rs(context, 48)),
                  icon: Icon(Icons.delete_outline,
                    color: widget.controller.text.isNotEmpty ? Colors.red.shade400 : Colors.grey.shade300,
                    size: widget.height != null ? 22 : 24),
                  onPressed: widget.controller.text.isNotEmpty ? () {
                    widget.controller.clear();
                    setState(() {});
                  } : null,
                  tooltip: '入力をクリア',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
