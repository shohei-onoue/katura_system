import 'package:flutter/material.dart';
import '../../../models/customer_model.dart';
import '../../../widgets/k_responsive.dart';

class CustomerDetailDialog extends StatelessWidget {
  final Customer customer;

  const CustomerDetailDialog({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.person, color: Colors.deepOrange),
          SizedBox(width: rs(context, 8)),
          Text('${customer.name} 様 詳細'),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      content: SizedBox(
        width: rs(context, 700),
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
                        _detailItem(context, '顧客氏名', customer.name),
                        _detailItem(context, 'ふりがな', customer.furigana),
                        _detailItem(context, '所属企業', customer.companyName),
                        _detailItem(context, '電話番号', customer.phoneNumber),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _detailItem(context, '代表住所', customer.address),
                        _detailItem(context, '位置座標', '${customer.latitude ?? "-"}, ${customer.longitude ?? "-"}'),
                        _detailItem(context, 'メール', customer.email),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(height: rs(context, 48), thickness: 1),
              Text('【 配達先マスター・履歴 】', style: TextStyle(fontWeight: FontWeight.bold, fontSize: rf(context, 18), color: Colors.blueGrey)),
              SizedBox(height: rs(context, 16)),
              ...customer.deliveryAddresses.map((addr) {
                final parts = addr.split(': ');
                final facilityName = parts.length > 1 ? parts[0] : '名称なし';
                final addressWithCoord = parts.length > 1 ? parts[1] : addr;
                
                return Container(
                  margin: EdgeInsets.only(bottom: rs(context, 12)),
                  padding: EdgeInsets.all(rs(context, 16)),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(rs(context, 8)),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.business, size: rs(context, 18), color: Colors.deepOrange),
                          SizedBox(width: rs(context, 8)),
                          Expanded(
                            child: Text(facilityName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: rf(context, 16))),
                          ),
                        ],
                      ),
                      SizedBox(height: rs(context, 8)),
                      Padding(
                        padding: EdgeInsets.only(left: rs(context, 26)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('住所: ${addressWithCoord.split(' (')[0]}', style: const TextStyle(color: Colors.black87)),
                            if (addressWithCoord.contains('('))
                              Text(
                                '座標: ${addressWithCoord.substring(addressWithCoord.indexOf('('))}',
                                style: TextStyle(color: Colors.blueGrey, fontSize: rf(context, 13), fontWeight: FontWeight.bold),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
              Divider(height: rs(context, 48), thickness: 1),
              Text('【 注文履歴（施設別サマリー） 】', style: TextStyle(fontWeight: FontWeight.bold, fontSize: rf(context, 18), color: Colors.blueGrey)),
              SizedBox(height: rs(context, 16)),
              if (customer.orderHistory.isEmpty)
                const Text('履歴なし', style: TextStyle(color: Colors.grey))
              else
                ...customer.orderHistory.map((history) => Padding(
                      padding: EdgeInsets.symmetric(vertical: rs(context, 6)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.history, size: rs(context, 16), color: Colors.grey),
                          SizedBox(width: rs(context, 8)),
                          Expanded(
                            child: Text(
                              history,
                              style: TextStyle(fontSize: rf(context, 15), fontFamily: 'monospace'),
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

  Widget _detailItem(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: rs(context, 8.0)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: rs(context, 120),
            child: Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value, style: TextStyle(fontSize: rf(context, 16)))),
        ],
      ),
    );
  }
}
