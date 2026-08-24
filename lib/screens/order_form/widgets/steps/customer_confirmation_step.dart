import 'package:flutter/material.dart';
import '../../../../models/customer_model.dart';
import '../../../../widgets/k_button.dart';
import '../../../../widgets/k_responsive.dart';
import '../../../../widgets/k_multimodal_text_field.dart';
import '../order_form_parts.dart';

/// 顧客確認および新規登録ステップ
/// [評価] 高齢者配慮のペン入力統合、右手操作用のボタン配置を徹底。
class CustomerConfirmationStep extends StatefulWidget {
  final TextEditingController phoneController;
  final TextEditingController nameController;
  final TextEditingController companyController;
  final Customer? currentCustomer;
  final String phoneDisplay;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const CustomerConfirmationStep({
    super.key,
    required this.phoneController,
    required this.nameController,
    required this.companyController,
    required this.currentCustomer,
    required this.phoneDisplay,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<CustomerConfirmationStep> createState() => _CustomerConfirmationStepState();
}

class _CustomerConfirmationStepState extends State<CustomerConfirmationStep> {
  @override
  Widget build(BuildContext context) {
    final bool isNewCustomer = widget.currentCustomer == null;
    
    return OrderFormCard(
      title: isNewCustomer ? '新規顧客の登録' : '受注者（本人）の確認',
      icon: isNewCustomer ? Icons.person_add_alt_1_rounded : Icons.person_search_rounded,
      child: Column(
        children: [
          // 受電番号を大きく、美しく中央に。
          Container(
            padding: EdgeInsets.symmetric(vertical: rs(context, 16)),
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.deepOrange.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.phoneController.text,
              style: TextStyle(
                fontSize: rf(context, 64), 
                fontWeight: FontWeight.w900, 
                color: Colors.deepOrange, 
                letterSpacing: 4
              ),
            ),
          ),
          
          const SizedBox(height: 32),

          if (!isNewCustomer) ...[
            // 既存顧客の場合：詳細情報を表示
            CustomerInfoBanner(customer: widget.currentCustomer),
          ] else ...[
            // 新規顧客の場合：整列された入力フォームを表示（ペン入力対応）
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: KMultimodalTextField(
                    label: '顧客名（必須）', 
                    controller: widget.nameController,
                    hintText: 'お名前を書いてください',
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: KMultimodalTextField(
                    label: '企業・施設名', 
                    controller: widget.companyController,
                    hintText: '会社名などを書いてください',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('※右側のペンアイコンをタップして手書き入力が可能です。', 
              style: TextStyle(fontSize: rf(context, 11), color: Colors.grey)),
          ],

          SizedBox(height: rs(context, 64)),

          // 右手で押しやすい操作ボタン（大きく、整列）
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: rs(context, 200),
                height: rs(context, 54),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: widget.onBack,
                  child: Text('番号を打ち直す', 
                    style: TextStyle(fontSize: rf(context, 16), color: Colors.blueGrey, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 24),
              SizedBox(
                width: rs(context, 320),
                height: rs(context, 54),
                child: KButton(
                  label: isNewCustomer ? '新規登録して次へ進む' : 'この顧客で受注する', 
                  onPressed: () {
                    if (isNewCustomer && widget.nameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('お名前を入力してください'), backgroundColor: Colors.redAccent)
                      );
                      return;
                    }
                    widget.onNext();
                  }, 
                  color: Colors.deepPurple
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
