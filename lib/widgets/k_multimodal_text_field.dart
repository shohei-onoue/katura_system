import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'k_responsive.dart';
import 'k_pen_input_dialog.dart';

class KMultimodalTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final IconData? icon;
  final int maxLines;
  final bool showLabel;
  final double? height;
  final String? prefixText;

  const KMultimodalTextField({
    super.key,
    required this.label,
    required this.controller,
    this.icon,
    this.maxLines = 3,
    this.showLabel = true,
    this.height,
    this.prefixText,
  });

  @override
  State<KMultimodalTextField> createState() => _KMultimodalTextFieldState();
}

class _KMultimodalTextFieldState extends State<KMultimodalTextField> {
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => debugPrint('onStatus: $val'),
        onError: (val) => debugPrint('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            if (val.hasConfidenceRating && val.confidence > 0) {
              widget.controller.text = val.recognizedWords;
            }
          }),
          listenOptions: stt.SpeechListenOptions(localeId: 'ja_JP'),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _openPenInput() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => KPenInputDialog(
        onTextRecognized: (text) {
          setState(() {
            final String currentText = widget.controller.text;
            if (currentText.isEmpty) {
              widget.controller.text = text;
            } else {
              widget.controller.text = "$currentText $text";
            }
            // カーソルを末尾へ移動
            widget.controller.selection = TextSelection.fromPosition(
              TextPosition(offset: widget.controller.text.length)
            );
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: widget.height != null ? 0 : 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showLabel && widget.label.isNotEmpty) ...[
            Text(widget.label, 
              style: TextStyle(fontSize: rf(context, 13), fontWeight: FontWeight.bold, color: Colors.blueGrey)),
            SizedBox(height: rs(context, 4)),
          ],
          SizedBox(
            height: widget.height,
            child: TextField(
              controller: widget.controller,
              maxLines: widget.maxLines,
              textAlignVertical: widget.height != null ? TextAlignVertical.center : null,
              decoration: InputDecoration(
                isDense: widget.height != null,
                contentPadding: widget.height != null 
                    ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8) 
                    : null,
                prefixIcon: widget.icon != null ? Icon(widget.icon, size: widget.height != null ? 18 : null) : null,
                prefix: widget.prefixText != null 
                  ? Text(
                      widget.prefixText!,
                      style: TextStyle(
                        fontSize: rf(context, 14),
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    )
                  : null,
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(_isListening ? Icons.mic : Icons.mic_none, 
                        color: _isListening ? Colors.red : Colors.deepPurple,
                        size: widget.height != null ? 18 : null),
                      onPressed: _listen,
                      padding: EdgeInsets.zero,
                      constraints: widget.height != null ? const BoxConstraints() : null,
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, 
                        color: Colors.deepPurple,
                        size: widget.height != null ? 18 : null),
                      onPressed: _openPenInput,
                      padding: EdgeInsets.zero,
                      constraints: widget.height != null ? const BoxConstraints() : null,
                    ),
                    if (widget.height != null) const SizedBox(width: 8),
                  ],
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(widget.height != null ? 8 : 12)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
