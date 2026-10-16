import 'package:flutter/material.dart';

/// スマホ用の挨拶画面。文字を左から1文字ずつフェードインで表示する。
class PhoneGreetingScreen extends StatefulWidget {
  final String text;
  final String? subText;
  const PhoneGreetingScreen({super.key, required this.text, this.subText});

  @override
  State<PhoneGreetingScreen> createState() => _PhoneGreetingScreenState();
}

class _PhoneGreetingScreenState extends State<PhoneGreetingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  static const int _perCharMs = 150; // 1文字ごとの開始ずらし時間
  static const int _fadeMs = 400; // 1文字のフェード時間

  @override
  void initState() {
    super.initState();
    final chars = widget.text.characters.length;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: _perCharMs * (chars > 0 ? chars - 1 : 0) + _fadeMs,
      ),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chars = widget.text.characters.toList();
    final total = _controller.duration!.inMilliseconds.toDouble();
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                alignment: WrapAlignment.center,
                children: [
                  for (int i = 0; i < chars.length; i++)
                    Opacity(
                      opacity: Interval(
                        (_perCharMs * i) / total,
                        ((_perCharMs * i) + _fadeMs) / total,
                        curve: Curves.easeIn,
                      ).transform(_controller.value),
                      child: Text(
                        chars[i],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              if (widget.subText != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Opacity(
                    opacity: Curves.easeIn.transform(
                      ((_controller.value - 0.8) / 0.2).clamp(0.0, 1.0),
                    ),
                    child: Text(
                      widget.subText!,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
