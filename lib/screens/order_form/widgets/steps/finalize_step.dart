import 'package:flutter/material.dart';
import '../../../../widgets/k_button.dart';
import '../../../../widgets/k_choice_group.dart';
import '../../../../widgets/k_tile_selector.dart';
import '../../../../widgets/k_responsive.dart';
import '../../../../widgets/k_multimodal_text_field.dart';
import '../../../../widgets/k_shared_quantity_input.dart';
import '../../../../widgets/k_date_time_display.dart';
import '../../../../widgets/k_date_time_selection_dialog.dart';
import '../../../../widgets/k_time_selection_dialog.dart';
import '../../../../widgets/k_numeric_dial_pad.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../order_form_parts.dart';

class FinalizeStep extends StatelessWidget {
  final String branchName;
  final String paymentMethod;
  final String packagingType;
  final int packagingSmallQty;
  final TextEditingController packagingOtherController;
  final String preConfirmationMethod; // 事前連絡方法
  final String preConfirmationPhoneType;
  final String preConfirmationPhoneNumber;
  final TextEditingController preConfirmationPhoneController;
  final DateTime? preConfirmationDateTime;
  final String preConfirmationSmsTime;
  final DateTime? scheduledSmsDateTime; // 送信予定日時
  final String phoneDisplay; // 受電番号
  final String customerName;
  final String receiverName;
  final String deliveryType;
  final DateTime deliveryDate;
  final String deliveryTime;
  final String address;
  final List<Map<String, dynamic>> items;
  final int totalPrice;
  final DateTime? trashPickupDateTime;
  final String trashPickupLocationDetail;

  final Function(String) onPackagingTypeChanged;
  final Function(int) onPackagingSmallQtyChanged;
  final Function(String) onBranchChanged;
  final Function(String) onPaymentChanged;
  final Function(String) onPreConfirmationMethodChanged;
  final Function(String) onPreConfirmationPhoneTypeChanged;
  final Function(String) onPreConfirmationPhoneNumberChanged;
  final Function(DateTime) onPreConfirmationDateTimeChanged;
  final Function(String) onPreConfirmationSmsTimeChanged;
  final Function(DateTime) onScheduledSmsDateTimeChanged; // 追加
  final VoidCallback onSave;

  const FinalizeStep({
    super.key,
    required this.branchName,
    required this.paymentMethod,
    required this.packagingType,
    required this.packagingSmallQty,
    required this.packagingOtherController,
    required this.preConfirmationMethod,
    required this.preConfirmationPhoneType,
    required this.preConfirmationPhoneNumber,
    required this.preConfirmationPhoneController,
    this.preConfirmationDateTime,
    required this.preConfirmationSmsTime,
    this.scheduledSmsDateTime, // 追加
    required this.phoneDisplay,
    required this.customerName,
    required this.receiverName,
    required this.deliveryType,
    required this.deliveryDate,
    required this.deliveryTime,
    required this.address,
    required this.items,
    required this.totalPrice,
    this.trashPickupDateTime,
    required this.trashPickupLocationDetail,
    required this.onPackagingTypeChanged,
    required this.onPackagingSmallQtyChanged,
    required this.onBranchChanged,
    required this.onPaymentChanged,
    required this.onPreConfirmationMethodChanged,
    required this.onPreConfirmationPhoneTypeChanged,
    required this.onPreConfirmationPhoneNumberChanged,
    required this.onPreConfirmationDateTimeChanged,
    required this.onPreConfirmationSmsTimeChanged,
    required this.onScheduledSmsDateTimeChanged, // 追加
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return OrderFormCard(
      title: '梱包・支払・確認設定',
      icon: Icons.check_circle,
      trailing: Text('受電: $phoneDisplay',
        style: TextStyle(fontSize: rf(context, 20), fontWeight: FontWeight.bold, color: Colors.white)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 梱包
          _buildPackagingArea(context),

          SizedBox(height: rs(context, 12)),
          Divider(height: rs(context, 1)),
          SizedBox(height: rs(context, 12)),

          // 2. 事前連絡
          _buildAdvanceNotificationSection(context),

          SizedBox(height: rs(context, 12)),
          Divider(height: rs(context, 1)),
          SizedBox(height: rs(context, 12)),

          // 3. 店舗
          _buildFormRow(
            context: context, 
            label: '担当店舗', 
            buttons: KTileSelector(
              label: '', 
              selectedValue: branchName, 
              items: [
                KTileItem(label: '岡崎本店', value: '岡崎本店'), 
                KTileItem(label: '名古屋店', value: '名古屋店'), 
                KTileItem(label: '岐阜店', value: '岐阜店')
              ], 
              onSelected: onBranchChanged
            ),
          ),

          SizedBox(height: rs(context, 12)),
          Divider(height: rs(context, 1)),
          SizedBox(height: rs(context, 12)),

          // 4. 支払
          _buildFormRow(
            context: context, 
            label: '支払方法', 
            buttons: KTileSelector(
              label: '', 
              selectedValue: paymentMethod, 
              items: [
                KTileItem(label: '現金', value: '現金'), 
                KTileItem(label: 'カード', value: 'カード'), 
                KTileItem(label: '請求書', value: '請求')
              ], 
              onSelected: onPaymentChanged
            ),
          ),
          
          SizedBox(height: rs(context, 24)),
          KButton(label: '受注を確定して保存する', color: Colors.deepOrange, onPressed: onSave),
        ],
      ),
    );
  }

  Widget _buildFormRow({
    required BuildContext context,
    required String label,
    required Widget buttons,
    Widget? details,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle(context)),
        SizedBox(height: rs(context, 12)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 50,
              child: Align(
                alignment: Alignment.centerLeft,
                child: buttons,
              ),
            ),
            SizedBox(width: rs(context, 16)),
            Expanded(
              flex: 50,
              child: details ?? const SizedBox.shrink(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPackagingArea(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('梱包方法', style: _labelStyle(context)),
        SizedBox(height: rs(context, 12)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: KChoiceGroup<String>(
                label: '',
                selectedValue: packagingType,
                items: [
                  KChoiceItem(label: '紙袋', value: '紙袋'),
                  KChoiceItem(label: '段ボール', value: '段ボール'),
                  KChoiceItem(label: '小分け', value: '小分け'),
                  KChoiceItem(label: 'その他', value: 'その他'),
                ],
                onSelected: onPackagingTypeChanged,
                showLabel: false,
                selectedColor: Colors.deepPurple,
              ),
            ),
            SizedBox(width: rs(context, 12)),
            Expanded(
              flex: 6,
              child: _buildPackagingDetailArea(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPackagingDetailArea(BuildContext context) {
    if (packagingType == '小分け') {
      return Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('数量:', style: TextStyle(fontSize: rf(context, 13), fontWeight: FontWeight.bold, color: Colors.blueGrey)),
            SizedBox(width: rs(context, 4)),
            KSharedQuantityInput(
              value: packagingSmallQty,
              onChanged: onPackagingSmallQtyChanged,
              title: '小分け数量',
              width: rs(context, 60),
              height: rs(context, 36),
            ),
            SizedBox(width: rs(context, 4)),
            Text('個ずつ', style: TextStyle(fontSize: rf(context, 12))),
          ],
        ),
      );
    }
    if (packagingType == 'その他') {
      return SizedBox(
        width: double.infinity,
        child: KMultimodalTextField(
          label: '',
          hintText: '梱包方法（詳細）',
          showLabel: false,
          controller: packagingOtherController,
          height: kFieldHeight(context),
          maxLines: 1,
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildAdvanceNotificationSection(BuildContext context) {
    final bool isSms = preConfirmationMethod == 'SMS';
    final bool isPhoneSelf = preConfirmationMethod == '電話' && preConfirmationPhoneType == 'この電話番号';
    final bool isPhoneOther = preConfirmationMethod == '電話' && preConfirmationPhoneType == '指定番号へ連絡';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('事前連絡', style: _labelStyle(context)),
        SizedBox(height: rs(context, 12)),
        _notificationCard(
          context: context,
          isSelected: isSms,
          title: 'SMS送信',
          onTap: () => onPreConfirmationMethodChanged('SMS'),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: rs(context, 16), color: Colors.blue),
              SizedBox(width: rs(context, 8)),
              Expanded(
                child: Text(
                  scheduledSmsDateTime != null 
                    ? '${scheduledSmsDateTime!.month}月${scheduledSmsDateTime!.day}日 ${scheduledSmsDateTime!.hour}:${scheduledSmsDateTime!.minute.toString().padLeft(2, '0')} に送信予約'
                    : '前日 $preConfirmationSmsTime に自動送信されます', 
                  style: TextStyle(fontSize: rf(context, 12), color: Colors.blue.shade800, fontWeight: FontWeight.bold)),
              ),
              SizedBox(width: rs(context, 8)),
              ElevatedButton.icon(
                icon: Icon(Icons.send, size: rs(context, 14)),
                label: Text('今すぐ送信', style: TextStyle(fontSize: rf(context, 11))),
                onPressed: () {
                  _sendActualSms(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: rs(context, 12), vertical: 0),
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  elevation: 2,
                ),
              ),
              SizedBox(width: rs(context, 8)),
              IconButton(
                icon: Icon(Icons.settings, size: rs(context, 20), color: Colors.blue),
                onPressed: () => _showSmsScheduleDialog(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
        SizedBox(height: rs(context, 8)),
        _notificationCard(
          context: context,
          isSelected: isPhoneSelf,
          title: '受電番号へ連絡',
          onTap: () {
            onPreConfirmationMethodChanged('電話');
            onPreConfirmationPhoneTypeChanged('この電話番号');
          },
          child: _buildDateTimeRow(context),
        ),
        SizedBox(height: rs(context, 8)),
        _notificationCard(
          context: context,
          isSelected: isPhoneOther,
          title: '指定番号へ連絡',
          onTap: () {
            onPreConfirmationMethodChanged('電話');
            onPreConfirmationPhoneTypeChanged('指定番号へ連絡');
          },
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: InkWell(
                  onTap: () => _showPhoneDialDialog(context),
                  child: Container(
                    height: rs(context, 36),
                    padding: EdgeInsets.symmetric(horizontal: rs(context, 12)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(rs(context, 8)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          preConfirmationPhoneNumber.isEmpty ? '電話番号を入力' : preConfirmationPhoneNumber,
                          style: TextStyle(
                            fontSize: rf(context, 13), 
                            color: preConfirmationPhoneNumber.isEmpty ? Colors.grey.shade400 : Colors.black87,
                            fontWeight: preConfirmationPhoneNumber.isEmpty ? FontWeight.normal : FontWeight.bold,
                          ),
                        ),
                        Icon(Icons.phone_android, size: rs(context, 16), color: Colors.blueGrey),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: rs(context, 12)),
              Expanded(
                flex: 6,
                child: _buildDateTimeRow(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _notificationCard({
    required BuildContext context,
    required bool isSelected,
    required String title,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(rs(context, 12)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: rs(context, 12), vertical: rs(context, 8)),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(rs(context, 12)),
          border: Border.all(
            color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              size: rs(context, 20),
              color: isSelected ? Colors.deepPurple : Colors.grey,
            ),
            SizedBox(width: rs(context, 8)),
            SizedBox(
              width: rs(context, 130),
              child: Text(title, 
                style: TextStyle(
                  fontSize: rf(context, 14), 
                  fontWeight: FontWeight.bold, 
                  color: isSelected ? Colors.deepPurple.shade900 : Colors.black87
                )),
            ),
            SizedBox(width: rs(context, 12)),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeRow(BuildContext context) {
    return Row(
      children: [
        Text('連絡希望日時:', style: TextStyle(fontSize: rf(context, 12), fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        SizedBox(width: rs(context, 12)),
        Expanded(
          child: KDateTimeDisplay(
            label: '',
            dateTime: preConfirmationDateTime,
            onTap: () async {
              final result = await showDialog<DateTime>(
                context: context,
                builder: (context) => KDateTimeSelectionDialog(
                  initialDateTime: preConfirmationDateTime ?? DateTime.now().add(const Duration(days: 1)),
                  title: '電話連絡日時の設定',
                ),
              );
              if (result != null) {
                onPreConfirmationDateTimeChanged(result);
              }
            },
            isCompact: true,
          ),
        ),
      ],
    );
  }

  String _buildSmsMessage() {
    final String dateStr = "${deliveryDate.month}月${deliveryDate.day}日";
    final List<String> weekDays = ["日", "月", "火", "水", "木", "金", "土"];
    final String weekDay = weekDays[deliveryDate.weekday % 7];
    
    String itemsText = "";
    for (int i = 0; i < items.length; i++) {
      itemsText += "${i + 1}.${items[i]['name']} x${items[i]['quantity']}\n";
    }

    String trashInfo = "なし";
    if (trashPickupDateTime != null) {
      trashInfo = "${trashPickupDateTime!.hour}:${trashPickupDateTime!.minute.toString().padLeft(2, '0')}";
    }

    final isPickup = deliveryType == '引取' || deliveryType == '店頭引取';
    final actionText = isPickup ? "お待ちしております" : "お届けいたします";

    final Map<String, String> branchPhones = {
      '岡崎本店': '0564-23-8861',
      '名古屋店': '050-1748-2670',
      '岐阜店': '050-1748-2670',
    };
    final storePhone = branchPhones[branchName] ?? '';

    return "「肉弁当専門店かつらです」\n"
        "$customerName様\n"
        "この度はご注文ありがとうございます。\n"
        "下記内容にて明日$dateStr$weekDay曜日 $deliveryTimeに$actionText。\n\n"
        "受取人：$receiverName様\n"
        "${isPickup ? '引取店舗' : '配達先住所'}：$address\n"
        "連絡先：$phoneDisplay\n\n"
        "ー注文内容ー\n"
        "$itemsText\n"
        "ーお支払い金額ー\n"
        "$totalPrice円（税込）\n\n"
        "容器回収日時：$trashInfo\n"
        "回収場所：${trashPickupLocationDetail.isEmpty ? '配達場所と同じ' : trashPickupLocationDetail}\n\n"
        "内容に不備がある場合お気軽にお電話ください\n"
        "$storePhone";
  }

  Future<void> _sendActualSms(BuildContext context) async {
    const String apiKey = '14caff28';
    const String apiSecret = 'FumC5ojafuwOcWXK';
    const String senderId = 'Katura';

    if (phoneDisplay.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('送信先の電話番号が見つかりません'), backgroundColor: Colors.orange),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('SMS自動送信を開始します...'), duration: Duration(seconds: 1)),
    );

    String cleanPhone = phoneDisplay.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanPhone.startsWith('0')) {
      cleanPhone = '81${cleanPhone.substring(1)}';
    }

    final String message = _buildSmsMessage();

    try {
      final Uri url = Uri.parse('https://rest.nexmo.com/sms/json');

      final response = await http.post(
        url,
        body: {
          'api_key': apiKey,
          'api_secret': apiSecret,
          'from': senderId,
          'to': cleanPhone,
          'text': message,
          'type': 'unicode',
        },
      ).timeout(const Duration(seconds: 15));

      if (context.mounted) {
        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final status = data['messages'][0]['status'];
          
          if (status == '0') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.green.shade600,
                content: Text('$phoneDisplay への送信に成功しました！'),
              ),
            );
          } else {
            final errorText = data['messages'][0]['error-text'] ?? 'Unknown error';
            throw 'Vonageエラー: $errorText (code: $status)';
          }
        } else {
          throw '通信エラー: ステータスコード ${response.statusCode}';
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade800,
            content: Text('送信失敗: $e'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _showSmsScheduleDialog(BuildContext context) async {
    // 現在の送信時間（例: "09:00"）を DateTime に変換して初期値にする
    final timeParts = preConfirmationSmsTime.split(':');
    final initial = DateTime(2024, 1, 1, int.parse(timeParts[0]), int.parse(timeParts[1]));

    final result = await showDialog<DateTime>(
      context: context,
      builder: (context) => KTimeSelectionDialog(
        initialDateTime: initial,
        title: '店舗全体のSMS送信時間設定',
      ),
    );

    if (result != null) {
      final newTime = "${result.hour.toString().padLeft(2, '0')}:${result.minute.toString().padLeft(2, '0')}";
      onPreConfirmationSmsTimeChanged(newTime);
    }
  }

  void _showPhoneDialDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(context, 16))),
        child: Container(
          width: rs(context, 400),
          padding: EdgeInsets.all(rs(context, 24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('電話番号の入力', style: TextStyle(fontSize: rf(context, 18), fontWeight: FontWeight.bold)),
              SizedBox(height: rs(context, 20)),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: rs(context, 16)),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(rs(context, 12)),
                  border: Border.all(color: Colors.grey.shade300, width: rs(context, 2)),
                ),
                child: Text(
                  preConfirmationPhoneController.text.isEmpty ? "番号を入力してください" : preConfirmationPhoneController.text,
                  style: TextStyle(
                    fontSize: rf(context, 24), 
                    fontWeight: FontWeight.bold, 
                    color: preConfirmationPhoneController.text.isEmpty ? Colors.grey : Colors.black87
                  ),
                ),
              ),
              SizedBox(height: rs(context, 24)),
              KNumericDialPad(
                onInput: (digit) {
                  onPreConfirmationPhoneNumberChanged(preConfirmationPhoneController.text + digit);
                },
                onClear: () => onPreConfirmationPhoneNumberChanged(""),
                onBackspace: () {
                  if (preConfirmationPhoneController.text.isNotEmpty) {
                    onPreConfirmationPhoneNumberChanged(
                      preConfirmationPhoneController.text.substring(0, preConfirmationPhoneController.text.length - 1)
                    );
                  }
                },
              ),
              SizedBox(height: rs(context, 24)),
              SizedBox(
                width: double.infinity,
                child: KButton(
                  label: '確定', 
                  onPressed: () => Navigator.pop(context),
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle _labelStyle(BuildContext context) {
    return TextStyle(fontSize: rf(context, 14), fontWeight: FontWeight.bold, color: Colors.blueGrey.shade700);
  }
}
