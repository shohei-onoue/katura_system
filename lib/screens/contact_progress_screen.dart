import 'dart:async';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart' show isSameDay;
import '../models/order_model.dart';
import '../services/customer_service.dart';
import '../services/order_service.dart';
import '../services/pre_contact_settings_service.dart';
import '../widgets/k_responsive.dart' show KR;
import 'package:katura_system/utils/app_colors.dart';
import 'package:katura_system/utils/name_format.dart';
import 'phone/phone_common.dart';

// スマホ幅は実寸、それ以外は従来の比率拡大
double _rf(BuildContext c, double v) => isPhoneWidth(c) ? v : KR.rf(c, v);
double _rs(BuildContext c, double v) => isPhoneWidth(c) ? v : KR.rs(c, v);

/// 事前連絡の進捗（本日分のみ）
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
    if (!mounted) return;
    final today = DateTime.now();
    setState(() {
      _displayNames = names;
      // 本日分のみ。電話、またはSMSが未送信・返信待ち・承認以外の返信あり
      _orders = list.where(OrderService.isActive).where((o) {
        if (!isSameDay(o.deliveryDate, today) || o.preConfirmationMethod.isEmpty) return false;
        if (o.preConfirmationMethod == '電話') return true;
        return !o.smsSent || (o.smsReply.isNotEmpty && o.smsReply != '承認');
      }).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppColors.mainBackground,
        automaticallyImplyLeading: widget.asPage,
        title: Text('事前連絡の進捗（本日 ${_orders.length}件）', style: TextStyle(fontSize: _rf(context, 16), fontWeight: FontWeight.bold, color: AppColors.primaryText)),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? const Center(child: Text('本日の連絡待ちはありません'))
              : ListView(padding: EdgeInsets.all(_rs(context, 8)), children: _orders.map(_buildCard).toList()),
    );
  }

  Widget _buildCard(OrderModel o) {
    final isPhone = o.preConfirmationMethod == '電話';
    final phone = isPhone && o.preConfirmationPhoneType == '指定番号へ連絡' && o.preConfirmationPhoneNumber.isNotEmpty ? o.preConfirmationPhoneNumber : o.phoneNumber;
    final reaction = !isPhone && o.smsReply.isNotEmpty && o.smsReply != '承認';
    final status = isPhone ? '電話連絡待ち' : reaction ? 'お客様の返信：${o.smsReply}' : (o.smsSent ? '返信待ち' : 'SMS未送信');
    final fg = reaction ? AppColors.whiteText : null;
    return Card(
      color: reaction ? AppColors.cancelButton : null,
      child: Padding(
        padding: EdgeInsets.all(_rs(context, 10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(isPhone ? Icons.phone : Icons.mail, size: _rs(context, 18), color: fg),
              SizedBox(width: _rs(context, 6)),
              Expanded(child: Text(withHonorific(_displayNames[o.id] ?? o.customerName), style: TextStyle(fontSize: _rf(context, 15), fontWeight: FontWeight.bold, color: fg))),
            ]),
            if (o.facilityName.trim().isNotEmpty) Text(o.facilityName.trim(), style: TextStyle(fontSize: _rf(context, 13), color: fg)),
            if (isPhoneWidth(context))
              InkWell(
                onTap: () => isPhone ? callPhone(phone) : sendSms(phone, preContactSmsBody(o, withHonorific(_displayNames[o.id] ?? o.customerName))),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(phone, style: TextStyle(fontSize: 15, color: fg ?? AppColors.accentPurple, decoration: TextDecoration.underline)),
                ),
              )
            else
              Text(phone, style: TextStyle(fontSize: _rf(context, 13), color: fg)),
            Text(status, style: TextStyle(fontSize: _rf(context, 12), fontWeight: FontWeight.bold, color: reaction ? AppColors.whiteText : Colors.red)),
          ],
        ),
      ),
    );
  }
}
