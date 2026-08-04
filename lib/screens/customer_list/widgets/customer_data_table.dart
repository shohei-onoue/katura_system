import 'package:flutter/material.dart';
import '../../../models/customer_model.dart';
import '../../../widgets/k_responsive.dart';

class CustomerDataTable extends StatelessWidget {
  final List<Customer> customers;
  final Function(Customer) onShowDetail;
  final Function(Customer) onEdit;
  final Function(Customer) onDelete;

  const CustomerDataTable({
    super.key,
    required this.customers,
    required this.onShowDetail,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // 列幅の定義 (レスポンシブ)
    final double nameWidth = rs(context, 160);
    final double companyWidth = rs(context, 200);
    final double phoneWidth = rs(context, 150);
    final double actionWidth = rs(context, 60);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: nameWidth,
                    child: Text('氏名', style: _headerStyle(context)),
                  ),
                  SizedBox(
                    width: companyWidth,
                    child: Text('企業名', style: _headerStyle(context)),
                  ),
                  SizedBox(
                    width: phoneWidth,
                    child: Text('電話番号', style: _headerStyle(context)),
                  ),
                  Expanded(
                    child: Text('住所', style: _headerStyle(context)),
                  ),
                  SizedBox(
                    width: actionWidth,
                    child: Center(child: Text('操作', style: _headerStyle(context))),
                  ),
                ],
              ),
            ),
            // スクロール可能なボディ (縦スクロールのみ)
            Expanded(
              child: ListView.separated(
                itemCount: customers.length,
                separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[100]),
                itemBuilder: (context, index) {
                  final customer = customers[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 氏名列
                        SizedBox(
                          width: nameWidth,
                          child: Text(
                            customer.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: rf(context, 14),
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        // 企業名
                        SizedBox(
                          width: companyWidth,
                          child: Text(
                            customer.companyName.isEmpty ? '-' : customer.companyName,
                            style: TextStyle(fontSize: rf(context, 14)),
                          ),
                        ),
                        // 電話番号
                        SizedBox(
                          width: phoneWidth,
                          child: Text(
                            customer.phoneNumber,
                            style: TextStyle(fontSize: rf(context, 14)),
                          ),
                        ),
                        // 住所 (自動改行)
                        Expanded(
                          child: Text(
                            customer.address,
                            style: TextStyle(fontSize: rf(context, 14), color: Colors.blueGrey[700]),
                            softWrap: true,
                          ),
                        ),
                        // 操作 (PopupMenu)
                        SizedBox(
                          width: actionWidth,
                          child: Center(
                            child: PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, color: Colors.grey),
                              onSelected: (value) {
                                if (value == 'detail') onShowDetail(customer);
                                if (value == 'edit') onEdit(customer);
                                if (value == 'delete') onDelete(customer);
                              },
                              itemBuilder: (context) => [
                                _buildPopupItem('detail', Icons.info_outline, '詳細確認', Colors.deepOrange),
                                _buildPopupItem('edit', Icons.edit, '編集', Colors.blue),
                                _buildPopupItem('delete', Icons.delete_outline, '削除', Colors.red),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _headerStyle(BuildContext context) {
    return TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: rf(context, 14),
      color: Colors.blueGrey[800],
    );
  }

  PopupMenuItem<String> _buildPopupItem(String value, IconData icon, String label, Color color) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
