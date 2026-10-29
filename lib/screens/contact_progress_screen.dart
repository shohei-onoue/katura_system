import 'dart:async';
import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/customer_service.dart';
import '../services/order_service.dart';
import '../services/pre_contact_settings_service.dart';
import '../widgets/k_responsive.dart' show KR;
import 'package:katura_system/utils/app_colors.dart';
import 'package:katura_system/utils/name_format.dart';
import 'package:katura_system/utils/facility_icon.dart';
import 'package:intl/intl.dart';
import 'phone/landscape/landscape_style.dart';
import 'phone/phone_common.dart';

// スマホ幅は実寸、それ以外は従来の比率拡大
double _rf(BuildContext c, double v) => isPhoneWidth(c) ? v : KR.rf(c, v);
double _rs(BuildContext c, double v) => isPhoneWidth(c) ? v : KR.rs(c, v);

/// 明日ご予約分の事前連絡の進捗（明日分のみ）
class ContactProgressScreen extends StatefulWidget {
  final bool asPage; // true＝別画面として開く（戻るボタンを出す）
  const ContactProgressScreen({super.key, this.asPage = false});

  @override
  State<ContactProgressScreen> createState() => _ContactProgressScreenState();
}

class _ContactProgressScreenState extends State<ContactProgressScreen> {
  final _orderService = OrderService();
  final _customerService = CustomerService();
  Map<String, String> _displayNames = {};
  List<OrderModel> _orders = [];
  bool _isLoading = true;
  StreamSubscription<List<OrderModel>>? _sub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && isPhoneWidth(context)) PreContactSettingsService.load();
    });
    _load();
    _sub = _orderService.watchOrders().skip(1).listen((_) => _load(refresh: false));
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _load({bool refresh = true}) async {
    final list = await _orderService.getAllOrders(forceRefresh: refresh);
    final names = await _customerService.resolveOrderNames(list);
    OrderService.preContactPending.value = OrderService.preContactPendingCount(list, DateTime.now());
    if (!mounted) return;
    setState(() {
      _displayNames = names;
      // 明日分のみ（事前連絡は前日に行う）。電話、またはSMSが未送信・返信待ち・承認以外の返信あり
      _orders = OrderService.preContactTargets(list, DateTime.now()).toList();
      _isLoading = false;
    });
  }

  Widget _buildLandscape(BuildContext context) {
    final pages = (_orders.length + 1) ~/ 2;
    return Scaffold(
      backgroundColor: LS.bg,
      body: SafeArea(
        left: false,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(
            height: LS.headerH,
            padding: const EdgeInsets.symmetric(horizontal: LS.pad),
            child: Row(children: [
              if (widget.asPage) ...[
                InkWell(onTap: () => Navigator.of(context).pop(), child: const Icon(Icons.close, size: 28, color: LS.text)),
                const SizedBox(width: LS.gap),
              ],
              const Flexible(
                child: Text('事前連絡',
                    maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: LS.text)),
              ),
              const SizedBox(width: LS.gap),
              ValueListenableBuilder<int>(
                valueListenable: OrderService.preContactPending,
                builder: (_, n, _) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                  decoration: BoxDecoration(color: LS.red, borderRadius: BorderRadius.circular(14)),
                  child: Text('未連絡 $n件', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const Spacer(),
              IconButton(icon: const Icon(Icons.refresh, size: 28, color: LS.text), onPressed: _load),
            ]),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _orders.isEmpty
                    ? const Center(child: Text('明日の連絡待ちはありません', style: TextStyle(fontSize: 18, color: LS.textSub)))
                    : PageView.builder(
                        itemCount: pages,
                        itemBuilder: (_, i) {
                          final a = _orders[i * 2];
                          final b = i * 2 + 1 < _orders.length ? _orders[i * 2 + 1] : null;
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(LS.pad, 0, LS.pad, LS.gap),
                            child: Row(children: [
                              Expanded(child: _landscapeCard(a)),
                              const SizedBox(width: LS.gap),
                              Expanded(child: b == null ? const SizedBox() : _landscapeCard(b)),
                            ]),
                          );
                        },
                      ),
          ),
        ]),
      ),
    );
  }

  Widget _landscapeCard(OrderModel o) {
    final isPhone = o.preConfirmationMethod == '電話';
    final phone = o.preConfirmationPhoneType == '指定番号へ連絡' && o.preConfirmationPhoneNumber.isNotEmpty ? o.preConfirmationPhoneNumber : o.phoneNumber;
    final reaction = !isPhone && o.smsReply.isNotEmpty && o.smsReply != '承認';
    final done = !isPhone && o.smsSent && o.smsReply == '承認';
    final badge = isPhone ? '電話待ち' : reaction ? '返信あり' : done ? '確認済み' : (o.smsSent ? '送信待ち' : '未送信');
    final name = withHonorific(_displayNames[o.id] ?? o.customerName);
    final date = '${DateFormat('M/d(E)', 'ja_JP').format(o.deliveryDate)} ${o.deliveryTime}';
    Widget row(IconData icon, String t) => Row(children: [
          Icon(icon, size: 24, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(child: Text(t, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))),
        ]);
    Widget btn(IconData icon, String label, Color bg, Color fg, VoidCallback onTap) => Expanded(
          child: SizedBox(
            height: LS.btnH,
            child: FilledButton.icon(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                backgroundColor: bg,
                foregroundColor: fg,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(LS.btnRadius)),
              ),
              icon: Icon(icon, size: 24),
              label: Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            ),
          ),
        );
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: LS.primary, borderRadius: BorderRadius.circular(LS.panelRadius)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(color: LS.amberText, borderRadius: BorderRadius.circular(12)),
            child: Text(badge, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: LS.badgeOrangeText)),
          ),
        ]),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: LS.primary2, borderRadius: BorderRadius.circular(12)),
          child: Column(children: [row(Icons.schedule_rounded, date), const SizedBox(height: 4), row(Icons.call_rounded, phone)]),
        ),
        const Spacer(),
        if (!done)
          Row(children: [
            if (!isPhone) ...[
              btn(Icons.sms_rounded, o.smsSent ? '再送' : 'SMS', Colors.white, LS.primary, () => _sendSms(o, phone)),
              const SizedBox(width: 8),
            ],
            btn(Icons.call_rounded, '電話', LS.orange, Colors.white, () => callPhone(phone)),
          ])
        else
          const Text('お客様が了承しました', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isPhoneLandscape(context)) return _buildLandscape(context);
    final onPhone = isPhoneWidth(context);
    final barFg = onPhone ? Colors.white : AppColors.primaryText;
    return Scaffold(
      backgroundColor: onPhone ? const Color(0xFFF4F1FA) : Colors.grey[100],
      appBar: AppBar(
        backgroundColor: onPhone ? AppColors.acceptButton : AppColors.mainBackground,
        foregroundColor: barFg,
        automaticallyImplyLeading: false,
        leading: widget.asPage ? IconButton(icon: const Icon(Icons.close), tooltip: '閉じる', onPressed: () => Navigator.of(context).pop()) : null,
        title: Text(onPhone ? '事前連絡' : '明日ご予約分事前連絡 ${_orders.length}件', style: TextStyle(fontSize: _rf(context, 16), fontWeight: FontWeight.bold, color: barFg)),
        actions: [
          if (onPhone) Center(child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(color: AppColors.cancelButton, borderRadius: BorderRadius.circular(99)),
            child: Text('未連絡 ${OrderService.preContactPending.value}件', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
          )),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? const Center(child: Text('明日の連絡待ちはありません'))
              : ListView(padding: EdgeInsets.all(_rs(context, 8)), children: _orders.map(_buildCard).toList()),
    );
  }

  Future<void> _sendSms(OrderModel o, String phone) async {
    final token = await OrderService.ensureReplyToken(o);
    if (!mounted) return;
    await sendSms(phone, preContactSmsBody(o, withHonorific(_displayNames[o.id] ?? o.customerName), link: replyUrl(o, token)));
    if (!o.smsSent) { await _orderService.markSmsSent(o.id); _load(refresh: false); }
  }

  Widget _pill(BuildContext context, {required Widget child, double alpha = 0.22}) => Container(
        padding: EdgeInsets.symmetric(horizontal: _rs(context, 10), vertical: _rs(context, 4)),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: alpha), borderRadius: BorderRadius.circular(99)),
        child: child,
      );

  Widget _actionButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap, required bool primary}) => Expanded(
        child: Material(
          color: primary ? Colors.white : Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(icon, size: 18, color: primary ? AppColors.primary[800] : Colors.white),
                const SizedBox(width: 8),
                Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primary ? AppColors.primary[800] : Colors.white)),
              ]),
            ),
          ),
        ),
      );

  Widget _buildCard(OrderModel o) {
    final isPhone = o.preConfirmationMethod == '電話';
    final phone = o.preConfirmationPhoneType == '指定番号へ連絡' && o.preConfirmationPhoneNumber.isNotEmpty ? o.preConfirmationPhoneNumber : o.phoneNumber;
    final reaction = !isPhone && o.smsReply.isNotEmpty && o.smsReply != '承認';
    final status = isPhone ? '電話連絡待ち' : reaction ? 'お客様の返信：${o.smsReply}' : (o.smsSent ? (o.smsReply == '承認' ? '確認済み' : '返信待ち') : 'SMS未送信');
    final done = !isPhone && o.smsSent && o.smsReply == '承認';
    final waiting = !isPhone && o.smsSent && !done && !reaction;
    final dot = done ? AppColors.heatmapGreen : (waiting || isPhone) ? AppColors.snackbarYellow : AppColors.accentOrange;
    final facility = o.facilityName.trim().isEmpty ? '個人宅' : o.facilityName.trim();
    final name = withHonorific(_displayNames[o.id] ?? o.customerName);
    final onPhone = isPhoneWidth(context);
    final colors = reaction
        ? [Colors.red.shade700, AppColors.cancelButton]
        : [AppColors.primary.shade800, AppColors.primary.shade500, AppColors.primary.shade200];
    return Container(
      margin: EdgeInsets.symmetric(vertical: _rs(context, 6), horizontal: _rs(context, 2)),
      padding: EdgeInsets.all(_rs(context, 16)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors),
        boxShadow: [BoxShadow(color: AppColors.primary.shade800.withValues(alpha: 0.3), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name, style: TextStyle(fontSize: _rf(context, 18), fontWeight: FontWeight.bold, color: AppColors.whiteText)),
                SizedBox(height: _rs(context, 3)),
                Row(children: [
                  Icon(orderIcon(deliveryType: o.deliveryType, facilityName: o.facilityName), size: _rs(context, 14), color: Colors.white70),
                  SizedBox(width: _rs(context, 5)),
                  Flexible(child: Text(facility, style: TextStyle(fontSize: _rf(context, 12), color: Colors.white70))),
                ]),
              ]),
            ),
            SizedBox(width: _rs(context, 8)),
            _pill(context, child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
              SizedBox(width: _rs(context, 6)),
              Text(status, style: TextStyle(fontSize: _rf(context, 12), fontWeight: FontWeight.bold, color: AppColors.whiteText)),
            ])),
          ]),
          SizedBox(height: _rs(context, 14)),
          Container(
            padding: EdgeInsets.symmetric(horizontal: _rs(context, 14), vertical: _rs(context, 10)),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              Icon(Icons.phone_outlined, size: _rs(context, 16), color: Colors.white70),
              SizedBox(width: _rs(context, 8)),
              Expanded(child: Text(phone, style: TextStyle(fontSize: _rf(context, 16), fontWeight: FontWeight.w500, color: AppColors.whiteText))),
              _pill(context, child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(isPhone ? Icons.phone : Icons.sms_outlined, size: _rs(context, 13), color: AppColors.whiteText),
                SizedBox(width: _rs(context, 5)),
                Text(isPhone ? '電話' : 'SMS', style: TextStyle(fontSize: _rf(context, 11), fontWeight: FontWeight.bold, color: AppColors.whiteText)),
              ])),
            ]),
          ),
          if (onPhone && !done) ...[
            if (waiting) Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text('返信がない場合は、電話で連絡できます', style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.85))),
            ),
            const SizedBox(height: 12),
            Row(children: [
              if (isPhone)
                _actionButton(context, icon: Icons.phone, label: '電話をかける', primary: true, onTap: () => callPhone(phone))
              else if (waiting || reaction) ...[
                _actionButton(context, icon: Icons.sms_outlined, label: 'SMSを再送', primary: false, onTap: () => _sendSms(o, phone)),
                const SizedBox(width: 8),
                _actionButton(context, icon: Icons.phone, label: '電話する', primary: true, onTap: () => callPhone(phone)),
              ] else
                _actionButton(context, icon: Icons.sms_outlined, label: 'SMSを作成', primary: true, onTap: () => _sendSms(o, phone)),
            ]),
          ],
          if (done) Padding(
            padding: EdgeInsets.only(top: _rs(context, 12)),
            child: Row(children: [
              Icon(Icons.check_circle, size: _rs(context, 18), color: AppColors.heatmapGreen),
              SizedBox(width: _rs(context, 6)),
              Text('お客様が了承しました', style: TextStyle(fontSize: _rf(context, 13), fontWeight: FontWeight.bold, color: AppColors.whiteText)),
            ]),
          ),
        ],
      ),
    );
  }
}
