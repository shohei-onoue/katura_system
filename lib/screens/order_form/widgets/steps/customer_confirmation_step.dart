import 'package:flutter/material.dart';
import '../../../../models/customer_model.dart';
import '../../../../widgets/k_button.dart';
import '../../../../widgets/k_responsive.dart';
import '../order_form_parts.dart';

class CustomerConfirmationStep extends StatelessWidget {
  final TextEditingController phoneController;
  final Customer? currentCustomer;
  final String phoneDisplay; // 受電番号
  final VoidCallback onNext;
  final VoidCallback onBack;

  const CustomerConfirmationStep({
    super.key,
    required this.phoneController,
    required this.currentCustomer,
    required this.phoneDisplay,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final daysSince = currentCustomer != null 
        ? CustomerInfoBanner.calculateDaysSince(currentCustomer!.orderHistory) 
        : null;

    return OrderFormCard(
      title: '受注者（本人）の確認',
      icon: Icons.person_search,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (daysSince != null) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: rs(context, 12), vertical: rs(context, 6)),
              decoration: BoxDecoration(
                color: (daysSince > 90) ? Colors.red.shade50 : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(rs(context, 20)),
                border: Border.all(color: (daysSince > 90) ? Colors.red.shade200 : Colors.blue.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history, size: rs(context, 14), color: (daysSince > 90) ? Colors.red : Colors.blue),
                  SizedBox(width: rs(context, 6)),
                  Text(
                    '前回から $daysSince 日',
                    style: TextStyle(
                      fontSize: rf(context, 13),
                      fontWeight: FontWeight.bold,
                      color: (daysSince > 90) ? Colors.red : Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: rs(context, 16)),
          ],
          Text('受電: $phoneDisplay', 
            style: TextStyle(fontSize: rf(context, 20), fontWeight: FontWeight.bold, color: Colors.deepOrange)),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: phoneController,
            textAlign: TextAlign.center,
            readOnly: true,
            style: TextStyle(fontSize: rf(context, 80), fontWeight: FontWeight.bold, color: Colors.deepOrange, letterSpacing: rs(context, 10)),
            decoration: const InputDecoration(border: InputBorder.none),
            keyboardType: TextInputType.none,
          ),
          SizedBox(height: rs(context, 24)),
          CustomerInfoBanner(customer: currentCustomer),
          SizedBox(height: rs(context, 48)),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: rs(context, 50),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(context, 12))),
                    ),
                    onPressed: onBack,
                    child: Text('選び直す', style: TextStyle(fontSize: rf(context, 18), color: Colors.blueGrey, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              SizedBox(width: rs(context, 16)),
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
