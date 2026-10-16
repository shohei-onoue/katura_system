import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:katura_system/utils/app_colors.dart';
import '../../models/order_model.dart';
import '../../services/pre_contact_settings_service.dart';

/// スマホ幅(600未満)かどうか
bool isPhoneWidth(BuildContext context) => MediaQuery.of(context).size.width < 600;

/// 事前連絡SMSの文面（設定済み文面の保存先が未確定のため、受注内容から仮生成）
String preContactSmsBody(OrderModel o, String name) {
  final d = o.deliveryDate;
  final t = PreContactSettingsService.cachedSmsTemplate;
  if (t.trim().isNotEmpty) {
    final items = o.items.map((e) => '${e['name'] ?? ''}（${e['quantity'] ?? 0}個）').join('\n\n');
    return PreContactSettingsService.applyTemplate(t, name: name, date: d, time: o.deliveryTime, items: items, payment: o.paymentMethod, total: '¥${NumberFormat('#,###').format(o.totalPrice)}');
  }
  return '$name 様\nご注文の事前確認です。${d.month}月${d.day}日 ${o.deliveryTime} のお届け(お引取り)で間違いございませんでしょうか。';
}

Future<void> callPhone(String phone) async {
  final p = phone.replaceAll(RegExp(r'[^0-9+]'), '');
  if (p.isEmpty) return;
  await launchUrl(Uri(scheme: 'tel', path: p));
}

Future<void> sendSms(String phone, String body) async {
  final p = phone.replaceAll(RegExp(r'[^0-9+]'), '');
  if (p.isEmpty) return;
  await launchUrl(Uri.parse('sms:$p?body=${Uri.encodeComponent(body)}'));
}

/// 住所または緯度経度でGoogleマップを開く
Future<void> openMap({double? lat, double? lng, String address = ''}) async {
  final q = (lat != null && lng != null) ? '$lat,$lng' : address;
  if (q.isEmpty) return;
  await launchUrl(
    Uri.https('www.google.com', '/maps/search/', {'api': '1', 'query': q}),
    mode: LaunchMode.externalApplication,
  );
}

/// 1ヶ月カレンダーを出して日付を選ばせる
Future<DateTime?> showPhoneCalendar(BuildContext context, DateTime initial) {
  return showDialog<DateTime>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: AppColors.popupBackground,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: TableCalendar(
          firstDay: DateTime(2020, 1, 1),
          lastDay: DateTime(2035, 12, 31),
          focusedDay: initial,
          locale: 'ja_JP',
          shouldFillViewport: false,
          headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
          selectedDayPredicate: (d) => isSameDay(d, initial),
          calendarStyle: const CalendarStyle(
            selectedDecoration: BoxDecoration(color: AppColors.selectButton, shape: BoxShape.circle),
            selectedTextStyle: TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.bold),
            todayDecoration: BoxDecoration(color: Colors.transparent, shape: BoxShape.circle, border: Border.fromBorderSide(BorderSide(color: AppColors.primary))),
            todayTextStyle: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
          ),
          onDaySelected: (d, _) => Navigator.pop(ctx, DateTime(d.year, d.month, d.day)),
        ),
      ),
    ),
  );
}

/// 上部の日付バー：左カレンダー・中央に日付と < >・右に[trailing]
class PhoneDateBar extends StatelessWidget {
  final DateTime date;
  final ValueChanged<DateTime> onChanged;
  final Widget trailing;
  const PhoneDateBar({super.key, required this.date, required this.onChanged, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.mainBackground,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      height: 52,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.calendar_month, color: AppColors.primaryText),
            onPressed: () async {
              final d = await showPhoneCalendar(context, date);
              if (d != null) onChanged(d);
            },
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => onChanged(date.subtract(const Duration(days: 1))),
                ),
                Flexible(
                  child: Text(
                    DateFormat('M/d(E)', 'ja_JP').format(date),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryText),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => onChanged(date.add(const Duration(days: 1))),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
