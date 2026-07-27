import 'package:flutter/material.dart';
import '../../../../models/customer_model.dart';
import '../../../../widgets/k_button.dart';
import '../order_form_parts.dart';

class CustomerConfirmationStep extends StatelessWidget {
  final TextEditingController phoneController;
  final Customer? currentCustomer;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const CustomerConfirmationStep({
    super.key,
    required this.phoneController,
    required this.currentCustomer,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return OrderFormCard(
      title: '受注者（本人）の確認',
      icon: Icons.person_search,
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
          const SizedBox(height: 24),
          CustomerInfoBanner(customer: currentCustomer),
          const SizedBox(height: 48),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: onBack,
                  child: const Text('選び直す', style: TextStyle(fontSize: 18, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: KButton(label: 'この顧客で受注する', onPressed: onNext, color: Colors.deepPurple),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
