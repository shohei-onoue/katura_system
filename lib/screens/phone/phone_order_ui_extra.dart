import 'package:flutter/material.dart';
import 'phone_order_ui.dart';

/// 文字の上にアイコンを並べた切替（配達先の新規登録・顧客確認の検索タブ）
class PoIconSegment extends StatelessWidget {
  final List<String> options;
  final List<IconData> icons;
  final int index;
  final ValueChanged<int> onChanged;
  const PoIconSegment({super.key, required this.options, required this.icons, required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: PO.segBg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          for (int i = 0; i < options.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(i),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: i == index ? PO.selBg : Colors.transparent, borderRadius: BorderRadius.circular(10)),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icons[i], size: 16, color: i == index ? PO.selText : PO.sub),
                        Text(options[i], style: PO.ts(13, color: i == index ? PO.selText : PO.sub, h: 1.0)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
