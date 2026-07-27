import 'package:flutter/material.dart';
import '../../../../models/customer_model.dart';
import '../../../../widgets/k_button.dart';
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
            style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold, color: Colors.deepOrange, letterSpacing: 10),
            decoration: const InputDecoration(border: InputBorder.none),
            keyboardType: TextInputType.none,
          ),
          if (isLoading)
            const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: CircularProgressIndicator()),
          if (candidates.isNotEmpty && currentCustomer == null)
            _buildCandidateList(),
          const SizedBox(height: 48),
          if (phoneController.text.isNotEmpty)
            KButton(
              label: currentCustomer != null ? '顧客確認へ進む' : '新規登録として受注フォームへ',
              onPressed: onNext,
              color: Colors.deepPurple,
            )
          else
            const Text('電話番号を入力してください', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildCandidateList() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('該当する候補', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: candidates.length,
            itemBuilder: (context, index) {
              final customer = candidates[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: ListTile(
                  title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${customer.companyName} / ${customer.phoneNumber}'),
                  trailing: const Icon(Icons.check_circle_outline, color: Colors.deepPurple),
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
