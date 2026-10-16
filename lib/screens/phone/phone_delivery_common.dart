import 'package:flutter/material.dart';
import 'package:katura_system/utils/app_colors.dart';
import '../../models/order_model.dart';

/// 配達予定・データ分析(スマホ)で共通のFigma配色
class PhoneUi {
  PhoneUi._();
  static const bg = Color(0xFFF3F7F6);
  static const purple = AppColors.acceptButton; // 0xFF673AB7
  static const ink = Color(0xFF1D1B20);
  static const sub = Color(0xFF6B6F76);
  static const line = Color(0xFFE4E7EB);
  static const cardLine = Color(0xFFEDF0F2);
  static const chipFill = Color(0xFFDAFFAF);
  static const chipBorder = Color(0xFFB9EA80);
  static const chipText = Color(0xFF1D3B00);
  static const red = Color(0xFFF44336);
  static const segmentBg = Color(0xFFECEFF1);
}

/// 店舗などの選択チップ（高さ34・角丸10）
class PhoneChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  const PhoneChip({super.key, required this.label, required this.selected, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? PhoneUi.chipFill : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? PhoneUi.chipBorder : PhoneUi.line),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: selected ? PhoneUi.chipText : PhoneUi.ink),
        ),
      ),
    );
  }
}

/// チップの横並び（はみ出す場合は横スクロール）
class PhoneChipRow extends StatelessWidget {
  final List<String> labels;
  final String selected;
  final ValueChanged<String> onTap;
  const PhoneChipRow({super.key, required this.labels, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          for (int i = 0; i < labels.length; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            PhoneChip(label: labels[i], selected: labels[i] == selected, onTap: () => onTap(labels[i])),
          ],
        ],
      ),
    );
  }
}

/// 2択のセグメント（選択側が紫）
class PhoneSegmented extends StatelessWidget {
  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;
  const PhoneSegmented({super.key, required this.labels, required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: PhoneUi.segmentBg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          for (int i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(i),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == index ? PhoneUi.purple : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    labels[i],
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: i == index ? Colors.white : PhoneUi.sub),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 下から出るシート（角丸22・ハンドル・閉じる丸ボタン・下の「閉じる」ボタン）
Future<void> showPhoneSheet(BuildContext context, {required String title, required Widget child, String closeLabel = '閉じる'}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x7A121218),
    builder: (ctx) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(width: 40, height: 5, decoration: BoxDecoration(color: const Color(0xFFD4D7DC), borderRadius: BorderRadius.circular(2.5))),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 10),
              child: SizedBox(
                height: 36,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: PhoneUi.ink)),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(color: Color(0xFFF1F3F5), shape: BoxShape.circle),
                        child: const Icon(Icons.close_rounded, size: 20, color: PhoneUi.ink),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                child: child,
              ),
            ),
            Container(
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: PhoneUi.line))),
              padding: const EdgeInsets.fromLTRB(18, 11, 18, 11),
              child: SafeArea(
                top: false,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.pop(ctx),
                  child: Container(
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: PhoneUi.line),
                    ),
                    child: Text(closeLabel, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: PhoneUi.ink)),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

/// 住所から市区町村だけを取り出す（取れなければ施設名→住所）
String phoneCityOf(OrderModel o) {
  var a = o.address.replaceAll('　', ' ').trim();
  a = a.replaceFirst(RegExp(r'^〒?\s*\d{3}-?\d{4}\s*'), '');
  a = a.replaceFirst(RegExp(r'^(北海道|[^市区町村\d\s]{2,3}?[都府県])'), '');
  final m = RegExp(r'^[^\d\s]+?[市区町村]').firstMatch(a);
  if (m != null) return m.group(0)!;
  return o.facilityName.isNotEmpty ? o.facilityName : o.address;
}

/// 住所に混ざった社名・施設名を除き、「〒郵便番号 都道府県以降」にする
String phoneCleanAddress(OrderModel o) {
  var a = o.address.replaceAll('　', ' ').trim();
  final zip = RegExp(r'〒?\s*\d{3}-?\d{4}').firstMatch(a);
  var zipPrefix = '';
  if (zip != null) {
    final d = zip.group(0)!.replaceAll(RegExp(r'[^0-9]'), '');
    zipPrefix = '〒${d.substring(0, 3)}-${d.substring(3)} ';
    a = (a.substring(0, zip.start) + a.substring(zip.end)).trim();
  }
  if (o.facilityName.trim().isNotEmpty) a = a.replaceAll(o.facilityName.trim(), '');
  a = a.replaceFirst(RegExp(r'^\[[^\]]*\]'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
  final pref = RegExp(r'(北海道|東京都|大阪府|京都府|[^\s]{2,3}県)').firstMatch(a);
  if (pref != null) a = a.substring(pref.start);
  return (zipPrefix + a).trim();
}

/// 配達詳細シート（顧客名・住所・注文内容）
Future<void> showPhoneDeliveryDetail(BuildContext context, {required OrderModel order, required String name}) {
  final handover = order.deliveryType == '配送' ? '配達' : 'お渡し';
  final items = order.items
      .map((it) => '${it['name'] ?? ''} x${it['quantity'] ?? ''}')
      .where((s) => s.trim() != 'x')
      .join(' ／ ');
  Widget row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: PhoneUi.red)),
              const SizedBox(height: 4),
              Text(value.isEmpty ? '-' : value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: PhoneUi.ink)),
            ],
          ),
        ),
      );
  return showPhoneSheet(
    context,
    title: '${order.deliveryTime} $handover',
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PhoneUi.cardLine),
      ),
      child: Column(
        children: [
          row('顧客名', name),
          row('住所', phoneCleanAddress(order)),
          row('注文内容', items),
        ],
      ),
    ),
  );
}
