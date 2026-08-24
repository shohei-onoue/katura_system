import 'package:flutter/material.dart';
import '../../../models/customer_model.dart';
import '../../../widgets/k_responsive.dart';

class CustomerDataTable extends StatelessWidget {
  final List<Customer> customers;
  final String? selectedCustomerId;
  final Function(Customer) onSelect;
  final Function(Customer) onShowDetail;
  final Function(Customer) onEdit;
  final Function(Customer) onDelete;

  const CustomerDataTable({
    super.key,
    required this.customers,
    this.selectedCustomerId,
    required this.onSelect,
    required this.onShowDetail,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // 列幅の定義 (レスポンスシブ)
    final double nameWidth = rs(context, 120);
    final double companyWidth = rs(context, 180);
    final double actionWidth = rs(context, 50);

    return Padding(
      padding: EdgeInsets.all(rs(context, 16)),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            // 固定ヘッダー
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                  Expanded(
                    child: Text('電話番号', style: _headerStyle(context)),
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
                  final isSelected = customer.id == selectedCustomerId;

                  return InkWell(
                    onTap: () => onSelect(customer),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      color: isSelected ? Colors.deepPurple.withValues(alpha: 0.05) : null,
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
                                fontSize: rf(context, 13),
                                color: isSelected ? Colors.deepPurple : Colors.black87,
                              ),
                            ),
                          ),
                          // 企業名
                          SizedBox(
                            width: companyWidth,
                            child: Text(
                              customer.companyName,
                              style: TextStyle(fontSize: rf(context, 12), color: Colors.grey[700]),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // 電話番号
                          Expanded(
                            child: Text(
                              customer.phoneNumber,
                              style: TextStyle(fontSize: rf(context, 13)),
                            ),
                          ),
                          // 操作 (PopupMenu)
                          SizedBox(
                            width: actionWidth,
                            child: Center(
                              child: PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert, color: Colors.grey, size: 20),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onSelected: (value) {
                                  if (value == 'detail') onShowDetail(customer);
                                  if (value == 'edit') onEdit(customer);
                                  if (value == 'delete') onDelete(customer);
                                },
                                itemBuilder: (context) => [
                                  _buildPopupItem('detail', Icons.info_outline, '詳細', Colors.deepOrange),
                                  _buildPopupItem('edit', Icons.edit, '編集', Colors.blue),
                                  _buildPopupItem('delete', Icons.delete_outline, '削除', Colors.red),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
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
      fontSize: rf(context, 13),
      color: Colors.blueGrey[800],
    );
  }

  PopupMenuItem<String> _buildPopupItem(String value, IconData icon, String label, Color color) {
    return PopupMenuItem(
      value: value,
      height: 36,
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
        ],
      ),
    );
  }
}
