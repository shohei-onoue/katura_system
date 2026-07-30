import 'package:flutter/material.dart';
import '../../../models/customer_model.dart';

class CustomerDetailDialog extends StatelessWidget {
  final Customer customer;

  const CustomerDetailDialog({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.person, color: Colors.deepOrange),
          const SizedBox(width: 8),
          Text('${customer.name} 様 詳細'),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      content: SizedBox(
        width: 700,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _detailItem('顧客氏名', customer.name),
                        _detailItem('ふりがな', customer.furigana),
                        _detailItem('所属企業', customer.companyName),
                        _detailItem('電話番号', customer.phoneNumber),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _detailItem('代表住所', customer.address),
                        _detailItem('位置座標', '${customer.latitude ?? "-"}, ${customer.longitude ?? "-"}'),
                        _detailItem('メール', customer.email),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 48, thickness: 1),
              const Text('【 配達先マスター・履歴 】', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blueGrey)),
              const SizedBox(height: 16),
              ...customer.deliveryAddresses.map((addr) {
                final parts = addr.split(': ');
                final facilityName = parts.length > 1 ? parts[0] : '名称なし';
                final addressWithCoord = parts.length > 1 ? parts[1] : addr;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.business, size: 18, color: Colors.deepOrange),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(facilityName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 26),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('住所: ${addressWithCoord.split(' (')[0]}', style: const TextStyle(color: Colors.black87)),
                            if (addressWithCoord.contains('('))
                              Text(
                                '座標: ${addressWithCoord.substring(addressWithCoord.indexOf('('))}',
                                style: const TextStyle(color: Colors.blueGrey, fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const Divider(height: 48, thickness: 1),
              const Text('【 注文履歴（施設別サマリー） 】', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blueGrey)),
              const SizedBox(height: 16),
              if (customer.orderHistory.isEmpty)
                const Text('履歴なし', style: TextStyle(color: Colors.grey))
              else
                ...customer.orderHistory.map((history) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.history, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              history,
                              style: const TextStyle(fontSize: 15, fontFamily: 'monospace'),
                            ),
                          ),
                        ],
                      ),
                    )),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('閉じる'),
        ),
      ],
    );
  }

  Widget _detailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
