import 'package:katura_system/utils/app_colors.dart';
import 'package:flutter/material.dart';
import '../../../../models/customer_model.dart';
import '../../../../widgets/k_button.dart';
import '../../../../widgets/k_responsive.dart';
import '../order_form_parts.dart';
import 'package:katura_system/utils/name_format.dart';

class PhoneConfirmStep extends StatelessWidget {
  final TextEditingController phoneController;
  final bool isLoading;
  final Customer? currentCustomer;
  final String phoneDisplay;
  final bool isCompletingPhone;
  final TextEditingController phonePrefixController;
  final VoidCallback onNext;
  /// 指定すると、タイトル行の右端に「×」（入力をやり直す）を表示する
  final VoidCallback? onClose;
  /// 顧客選択後に「受注中止」ボタンとして表示する
  final VoidCallback? onCancelOrder;

  const PhoneConfirmStep({
    super.key,
    required this.phoneController,
    required this.isLoading,
    required this.currentCustomer,
    required this.phoneDisplay,
    this.isCompletingPhone = false,
    required this.phonePrefixController,
    required this.onNext,
    this.onClose,
    this.onCancelOrder,
  });

  /// 電話番号がフルで表示されているか（10桁以上）
  bool get _isFullPhone => phoneController.text.replaceAll(RegExp(r'[^0-9]'), '').length >= 10;

  @override
  Widget build(BuildContext context) {
    return OrderFormCard(
      title: isCompletingPhone
          ? '電話番号の完成'
          // 電話番号がフルで表示されているとき（顧客選択後など）
          : (_isFullPhone ? 'お客様電話番号' : '下４桁を入力'),
      icon: Icons.phone_callback,
      titleBarColor: AppColors.primary,
      // タイトル行の Row 内に置くので、タイトルテキストと同じく上下中央になる（高さは文字行以下に抑える）
      trailing: onClose == null
          ? null
          : Tooltip(
              message: '入力をやり直す',
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onClose,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: rav(context, 8)),
                  child: Icon(Icons.close, color: AppColors.whiteText, size: rf(context, 16)),
                ),
              ),
            ),
      child: Column(
        children: [
          if (isCompletingPhone)
            _buildCompletingPhoneUI(context)
          else
            TextField(
              controller: phoneController,
              textAlign: TextAlign.center,
              textAlignVertical: TextAlignVertical.center,
              readOnly: true,
              style: TextStyle(fontSize: rf(context, 80), fontWeight: FontWeight.bold, color: AppColors.accentOrange, letterSpacing: rs(context, 10)),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '0000',
                hintStyle: TextStyle(color: Colors.grey.shade300),
              ),
              keyboardType: TextInputType.none,
            ),
          // 入力欄の上（タイトル行との間）と同じ余白をボタンの上にも取る。
          // 読み込み中の表示は余白からはみ出して重ね、カードの高さ（=位置）が変わらないようにする
          SizedBox(
            height: rav(context, 16),
            child: isLoading
                ? OverflowBox(
                    maxHeight: rs(context, 32),
                    child: Center(child: SizedBox(width: rs(context, 32), height: rs(context, 32), child: const CircularProgressIndicator())),
                  )
                : null,
          ),
          // 番号が空でもボタン分の高さは確保し、入力前後でカードの高さが変わらないようにする
          Visibility(
            visible: phoneController.text.isNotEmpty || isCompletingPhone,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            // 電話番号がフル表示のとき（顧客選択後・日程調整から戻った後など）は「受注中止」を左に並べる
            child: (!isCompletingPhone && _isFullPhone && onCancelOrder != null)
                ? Row(
                    children: [
                      Expanded(
                        child: KButton(label: '受注中止', onPressed: onCancelOrder, color: AppColors.cancelButton),
                      ),
                      SizedBox(width: rs(context, 12)),
                      Expanded(
                        flex: 2,
                        child: KButton(label: '日程調整', onPressed: onNext, color: AppColors.accentPurple),
                      ),
                    ],
                  )
                : KButton(
                    label: isCompletingPhone ? '確定して次へ' : (currentCustomer != null ? '日程調整' : '新規登録'),
                    onPressed: onNext,
                    color: isCompletingPhone ? AppColors.accentOrange : AppColors.accentPurple,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletingPhoneUI(BuildContext context) {
    final double fieldHeight = rs(context, 88);
    final bool prefixEmpty = phonePrefixController.text.isEmpty;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: rs(context, 380),
          height: fieldHeight,
          padding: EdgeInsets.symmetric(horizontal: rs(context, 16)),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.accentOrange, width: rs(context, 2)),
            borderRadius: BorderRadius.circular(rs(context, 12)),
            color: AppColors.accentOrange.withValues(alpha: 0.05),
          ),
          alignment: Alignment.center,
          child: prefixEmpty
              ? Text(
                  'ここをタップして番号入力',
                  style: TextStyle(fontSize: rf(context, 20), fontWeight: FontWeight.bold, color: Colors.grey.shade400),
                )
              : Text(
                  phonePrefixController.text,
                  style: TextStyle(fontSize: rf(context, 48), fontWeight: FontWeight.bold, color: AppColors.accentOrange),
                ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: rs(context, 16)),
          child: Text('-', style: TextStyle(fontSize: rf(context, 48), color: Colors.grey))
        ),
        Container(
          width: rs(context, 150),
          height: fieldHeight,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(rs(context, 12)),
            color: Colors.grey.shade100
          ),
          alignment: Alignment.center,
          child: Text(
            phoneController.text,
            style: TextStyle(fontSize: rf(context, 48), fontWeight: FontWeight.bold, color: Colors.grey.shade600)
          ),
        ),
      ],
    );
  }
}

/// 下４桁入力後に該当顧客がいるとき、番号確認カードの下にアコーディオン状に展開する候補パネル。
class PhoneCandidatePanel extends StatelessWidget {
  final bool visible;
  final List<Customer> candidates;
  final Function(Customer) onSelectCustomer;
  /// 顧客ID → 前回の配達日（注文データから算出）
  final Map<String, DateTime> lastOrderDates;
  final double maxHeight;
  /// 選択中の顧客ID（そのカードの枠線を緑にする）
  final String? selectedCustomerId;
  /// 電話番号がフルで表示されているか（未選択時のラベルを切り替える）
  final bool isFullPhone;

  const PhoneCandidatePanel({
    super.key,
    required this.visible,
    required this.candidates,
    required this.onSelectCustomer,
    this.lastOrderDates = const {},
    required this.maxHeight,
    this.selectedCustomerId,
    this.isFullPhone = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedSize(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        alignment: Alignment.topCenter,
        child: visible && candidates.isNotEmpty
            ? Material(
                color: Colors.transparent,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: maxHeight),
                  child: _buildCandidateList(context),
                ),
              )
            : const SizedBox(width: double.infinity),
      ),
    );
  }

  Widget _buildLastOrderBadge(BuildContext context, Customer customer) {
    final dateRe = RegExp(r'(\d{4})-(\d{1,2})-(\d{1,2})');
    DateTime? latest;
    for (final h in customer.orderHistory) {
      final m = dateRe.firstMatch(h);
      if (m == null) continue;
      final d = DateTime(int.parse(m.group(1)!), int.parse(m.group(2)!), int.parse(m.group(3)!));
      if (latest == null || d.isAfter(latest)) latest = d;
    }
    // 注文データから求めた前回配達日を優先（orderHistory は書き込まれていないため）
    final fromOrders = lastOrderDates[customer.id];
    if (fromOrders != null && (latest == null || fromOrders.isAfter(latest))) latest = fromOrders;
    if (latest == null) return const SizedBox.shrink();
    final now = DateTime.now();
    final int days = DateTime(now.year, now.month, now.day).difference(DateTime(latest.year, latest.month, latest.day)).inDays;
    final Color c = days >= 365
        ? Colors.grey
        : days >= 180
            ? Colors.red
            : days > 90
                ? AppColors.accentOrange
                : Colors.blue;
    return SizedBox(
      height: rs(context, 40),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text.rich(
          TextSpan(
            style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: rf(context, 10), height: 1.0),
            children: [
              const TextSpan(text: '前回から'),
              TextSpan(text: '$days', style: TextStyle(fontSize: rf(context, 33))),
              const TextSpan(text: '日'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCandidateList(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: rs(context, 8)),
      padding: EdgeInsets.all(rs(context, 16)),
      decoration: BoxDecoration(
        color: AppColors.mainBackground,
        borderRadius: BorderRadius.circular(rav(context, 16)),
        boxShadow: [
          BoxShadow(color: AppColors.primaryText.withValues(alpha: 0.05), blurRadius: rav(context, 10)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(selectedCustomerId != null ? '選択中の顧客' : (isFullPhone ? '該当する顧客' : '該当する候補'), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey, fontSize: rf(context, 14))),
          SizedBox(height: rs(context, 12)),
          Flexible(
            child: ListView.builder(
            shrinkWrap: true,
            // 候補が複数のときだけ、この候補エリア内でスクロールさせる
            physics: candidates.length > 1 ? const ClampingScrollPhysics() : const NeverScrollableScrollPhysics(),
            itemCount: candidates.length,
            itemBuilder: (context, index) {
              final customer = candidates[index];
              return Card(
                margin: EdgeInsets.only(bottom: rs(context, 8)),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(rs(context, 8)),
                  // 選択中のカードは枠線なし・背景色を selectCardBackground にする
                  side: customer.id == selectedCustomerId ? BorderSide.none : BorderSide(color: Colors.grey.shade300),
                ),
                color: customer.id == selectedCustomerId ? AppColors.selectCardBackground.withValues(alpha: 0.5) : null,
                child: ListTile(
                  // 1行目：企業名 / 顧客名、2行目：電話番号（文字サイズは同じ）
                  title: Text(
                    customer.companyName.isNotEmpty
                        ? '${customer.companyName} / ${withHonorific(customer.name)}'
                        : withHonorific(customer.name),
                    style: TextStyle(fontSize: rf(context, 20), fontWeight: FontWeight.bold, color: AppColors.primaryText),
                  ),
                  subtitle: Text(
                    customer.phoneNumber,
                    style: TextStyle(fontSize: rf(context, 20), fontWeight: FontWeight.bold, color: AppColors.accentText),
                  ),
                  trailing: _buildLastOrderBadge(context, customer),
                  onTap: () => onSelectCustomer(customer),
                ),
              );
            },
          ),
          ),
        ],
      ),
    );
  }
}
