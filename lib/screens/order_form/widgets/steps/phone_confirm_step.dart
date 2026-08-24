import 'package:flutter/material.dart';
import '../../../../models/customer_model.dart';
import '../../../../widgets/k_button.dart';
import '../../../../widgets/k_responsive.dart';
import '../order_form_parts.dart';

class PhoneConfirmStep extends StatelessWidget {
  final TextEditingController phoneController;
  final bool isLoading;
  final List<Customer> candidates;
  final Customer? currentCustomer;
  final String phoneDisplay;
  final bool isCompletingPhone;
  final TextEditingController phonePrefixController;
  final VoidCallback onNext;
  final Function(Customer) onSelectCustomer;

  const PhoneConfirmStep({
    super.key,
    required this.phoneController,
    required this.isLoading,
    required this.candidates,
    required this.currentCustomer,
    required this.phoneDisplay,
    this.isCompletingPhone = false,
    required this.phonePrefixController,
    required this.onNext,
    required this.onSelectCustomer,
  });

  @override
  Widget build(BuildContext context) {
    return OrderFormCard(
      title: isCompletingPhone ? '電話番号の完成' : '電話番号の確認',
      icon: Icons.phone_callback,
      child: Column(
        children: [
          if (isCompletingPhone)
            _buildCompletingPhoneUI(context)
          else
            TextField(
              controller: phoneController,
              textAlign: TextAlign.center,
              readOnly: true,
              style: TextStyle(fontSize: rf(context, 80), fontWeight: FontWeight.bold, color: Colors.deepOrange, letterSpacing: rs(context, 10)),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '0000',
                hintStyle: TextStyle(color: Colors.grey.shade300),
              ),
              keyboardType: TextInputType.none,
            ),
          if (isLoading)
            Padding(padding: EdgeInsets.symmetric(vertical: rs(context, 20)), child: const CircularProgressIndicator()),
          if (candidates.isNotEmpty && currentCustomer == null && !isCompletingPhone)
            _buildCandidateList(context),
          SizedBox(height: rs(context, 48)),
          if (phoneController.text.isNotEmpty || isCompletingPhone)
            KButton(
              label: isCompletingPhone ? '確定して次へ' : (currentCustomer != null ? '顧客確認へ進む' : '新規登録として受注フォームへ'),
              onPressed: onNext,
              color: isCompletingPhone ? Colors.deepOrange : Colors.deepPurple,
            )
          else
            Text('下４桁を入力してください', style: TextStyle(color: Colors.grey, fontSize: rf(context, 16), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCompletingPhoneUI(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: rs(context, 320),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.deepOrange, width: 2),
            borderRadius: BorderRadius.circular(12),
            color: Colors.deepOrange.withValues(alpha: 0.05),
          ),
          alignment: Alignment.center,
          child: Text(
            phonePrefixController.text.isEmpty ? '市外局番から入力' : phonePrefixController.text,
            style: TextStyle(
              fontSize: rf(context, 48), 
              fontWeight: FontWeight.bold, 
              color: phonePrefixController.text.isEmpty ? Colors.grey.shade400 : Colors.deepOrange
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16), 
          child: Text('-', style: TextStyle(fontSize: rf(context, 48), color: Colors.grey))
        ),
        Container(
          width: rs(context, 150),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300), 
            borderRadius: BorderRadius.circular(12), 
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

  Widget _buildCandidateList(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: rs(context, 20)),
      padding: EdgeInsets.all(rs(context, 16)),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('該当する候補', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey, fontSize: rf(context, 14))),
          SizedBox(height: rs(context, 12)),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: candidates.length,
            itemBuilder: (context, index) {
              final customer = candidates[index];
              return Card(
                margin: EdgeInsets.only(bottom: rs(context, 8)),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(rs(context, 8)),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: ListTile(
                  title: Text(customer.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: rf(context, 14))),
                  subtitle: Text('${customer.companyName} / ${customer.phoneNumber}', style: TextStyle(fontSize: rf(context, 12))),
                  trailing: Icon(Icons.check_circle_outline, color: Colors.deepPurple, size: rs(context, 24)),
                  onTap: () => onSelectCustomer(customer),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
