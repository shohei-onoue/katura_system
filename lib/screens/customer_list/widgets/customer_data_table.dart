import 'package:flutter/material.dart';
import '../../../models/customer_model.dart';

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
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            clipBehavior: Clip.antiAlias,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey[200]!),
            ),
            child: SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Scrollbar(
                    thumbVisibility: true,
                    notificationPredicate: (n) => n.depth == 1,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: constraints.maxWidth - 48,
                        ),
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
                          dataRowMaxHeight: 60,
                          columnSpacing: 24,
                          columns: const [
                            DataColumn(label: Text('氏名', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('企業名', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('電話番号', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('住所', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Center(child: Text('操作', style: TextStyle(fontWeight: FontWeight.bold)))),
                          ],
                          rows: customers.map((customer) {
                            return DataRow(cells: [
                              DataCell(
                                Text(
                                  customer.name,
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                  softWrap: false,
                                ),
                              ),
                              DataCell(Text(customer.companyName, softWrap: false)),
                              DataCell(Text(customer.phoneNumber, softWrap: false)),
                              DataCell(Text(customer.address, softWrap: false)),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextButton.icon(
                                      icon: const Icon(Icons.info_outline, size: 18),
                                      label: const Text('詳細'),
                                      onPressed: () => onShowDetail(customer),
                                      style: TextButton.styleFrom(foregroundColor: Colors.deepOrange),
                                    ),
                                    const SizedBox(width: 8),
                                    TextButton.icon(
                                      icon: const Icon(Icons.edit, size: 18),
                                      label: const Text('編集'),
                                      onPressed: () => onEdit(customer),
                                      style: TextButton.styleFrom(foregroundColor: Colors.blue),
                                    ),
                                    const SizedBox(width: 8),
                                    TextButton.icon(
                                      icon: const Icon(Icons.delete_outline, size: 18),
                                      label: const Text('削除'),
                                      onPressed: () => onDelete(customer),
                                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
