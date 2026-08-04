import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'k_responsive.dart';
import 'k_pen_input_dialog.dart';

class KMultimodalTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final IconData? icon;
  final int maxLines;

  const KMultimodalTextField({
    super.key,
    required this.label,
    required this.controller,
    this.icon,
    this.maxLines = 3,
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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label, 
            style: TextStyle(fontSize: rf(context, 13), fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          SizedBox(height: rs(context, 4)),
          TextField(
            controller: widget.controller,
            maxLines: widget.maxLines,
            decoration: InputDecoration(
              prefixIcon: widget.icon != null ? Icon(widget.icon) : null,
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(_isListening ? Icons.mic : Icons.mic_none, 
                      color: _isListening ? Colors.red : Colors.deepPurple),
                    onPressed: _listen,
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.deepPurple),
                    onPressed: _openPenInput,
                  ),
                ],
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
