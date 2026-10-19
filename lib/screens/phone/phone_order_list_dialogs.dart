import 'package:flutter/material.dart';
import 'phone_order_list_style.dart';

/// スマホ版の確認ダイアログ共通部品（Figma: 編集の中止 / 予約キャンセル / 当日キャンセル / 注文入力の中止 / 注文の中止 / ルート表示の確認）
/// 左ボタン=false、右ボタン=true を返す（枠外タップは null）。
Future<bool?> showPhoneFigmaConfirm(
  BuildContext context, {
  required IconData icon,
  required Color iconColor,
  required Color iconBg,
  required String title,
  String? message,
  required String cancelLabel,
  required String confirmLabel,
  Color confirmColor = PL.red,
  Color? cancelFill, // 左ボタンを塗りつぶす場合の色（nullなら白＋枠線）
}) {
  Widget btn(String label, VoidCallback onTap, {Color? fill, Color fg = PL.ink, bool outlined = false}) {
    return Expanded(
      child: SizedBox(
        height: 46,
        child: Material(
          color: fill ?? Colors.white,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Container(
              alignment: Alignment.center,
              decoration: outlined ? BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: PL.border)) : null,
              child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: fg)),
            ),
          ),
        ),
      ),
    );
  }

  return showDialog<bool>(
    context: context,
    barrierColor: PL.scrim,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, size: 28, color: iconColor),
            ),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: PL.ink)),
            if (message != null) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, height: 1.5, color: PL.grey)),
              ),
            ],
            const SizedBox(height: 18),
            Row(children: [
              btn(cancelLabel, () => Navigator.pop(ctx, false), fill: cancelFill, fg: cancelFill == null ? PL.ink : Colors.white, outlined: cancelFill == null),
              const SizedBox(width: 10),
              btn(confirmLabel, () => Navigator.pop(ctx, true), fill: confirmColor, fg: Colors.white),
            ]),
          ],
        ),
      ),
    ),
  );
}

/// 予約キャンセルの確認（受注一覧）
Future<bool?> showPhoneReservationCancelConfirm(BuildContext context, String nameWithHonorific) => showPhoneFigmaConfirm(
      context,
      icon: Icons.event_busy_rounded,
      iconColor: PL.red,
      iconBg: PL.redSoft,
      title: '予約キャンセルの確認',
      message: '$nameWithHonorificの予約をキャンセルし、登録内容を削除します。元に戻せません。よろしいですか？',
      cancelLabel: 'いいえ',
      confirmLabel: 'キャンセルする',
    );

/// 当日キャンセルの確認（受注一覧）
Future<bool?> showPhoneSameDayCancelConfirm(BuildContext context, String nameWithHonorific) => showPhoneFigmaConfirm(
      context,
      icon: Icons.warning_amber_rounded,
      iconColor: PL.orange,
      iconBg: PL.orangeSoft,
      title: '当日キャンセルの確認',
      message: '$nameWithHonorificの予約は当日のため、キャンセル料は100%になります。よろしいですか？',
      cancelLabel: '戻る',
      confirmLabel: '了承',
    );

/// ルート表示の確認（配達予定の号車）
Future<bool?> showPhoneRouteConfirm(BuildContext context, int lane) => showPhoneFigmaConfirm(
      context,
      icon: Icons.route_rounded,
      iconColor: PL.purple,
      iconBg: PL.purpleSoft,
      title: '$lane号車のルートを表示しますか？',
      cancelLabel: 'キャンセル',
      confirmLabel: '表示する',
      confirmColor: PL.purple,
      cancelFill: PL.red,
    );
