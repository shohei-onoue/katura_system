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
  final VoidCallback onNext;
  final Function(Customer) onSelectCustomer;

  const PhoneConfirmStep({
    super.key,
    required this.phoneController,
    required this.isLoading,
    required this.candidates,
    required this.currentCustomer,
    required this.onNext,
    required this.onSelectCustomer,
  });

  @override
  Widget build(BuildContext context) {
    return OrderFormCard(
      title: '電話番号の確認',
      icon: Icons.phone_callback,
      child: Column(
        children: [
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
          if (candidates.isNotEmpty && currentCustomer == null)
            _buildCandidateList(context),
          SizedBox(height: rs(context, 48)),
          if (phoneController.text.isNotEmpty)
            KButton(
              label: currentCustomer != null ? '顧客確認へ進む' : '新規登録として受注フォームへ',
              onPressed: onNext,
              color: Colors.deepPurple,
            )
          else
            Text('下４桁を入力してください', style: TextStyle(color: Colors.grey, fontSize: rf(context, 16), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCandidateList(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: rs(context, 20)),
      padding: EdgeInsets.all(rs(context, 16)),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(rs(context, 12)),
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
