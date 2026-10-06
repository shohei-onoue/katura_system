import 'package:flutter/material.dart';
import '../../../models/customer_model.dart';
import '../../../services/customer_service.dart';
import '../../../widgets/k_responsive.dart';
import '../../../widgets/k_multimodal_text_field.dart';
import '../../../widgets/k_numeric_input_dialog.dart';
import 'package:katura_system/utils/app_colors.dart';

class CustomerEditDialog extends StatefulWidget {
  final Customer customer;
  final CustomerService customerService;
  final VoidCallback onSaved;

  const CustomerEditDialog({
    super.key,
    required this.customer,
    required this.customerService,
    required this.onSaved,
  });

  @override
  State<CustomerEditDialog> createState() => _CustomerEditDialogState();
}

class _CustomerEditDialogState extends State<CustomerEditDialog> {
  late TextEditingController nameController;
  late TextEditingController companyController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController addressController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.customer.name);
    companyController = TextEditingController(text: widget.customer.companyName);
    phoneController = TextEditingController(text: _formatPhone(widget.customer.phoneNumber));
    emailController = TextEditingController(text: widget.customer.email);
    addressController = TextEditingController(text: widget.customer.address);
  }

  String _formatPhone(String phone) {
    final clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.length == 11) {
      return '${clean.substring(0, 3)}-${clean.substring(3, 7)}-${clean.substring(7)}';
    } else if (clean.length == 10) {
      if (clean.startsWith('03') || clean.startsWith('06')) {
        return '${clean.substring(0, 2)}-${clean.substring(2, 6)}-${clean.substring(6)}';
      } else if (clean.startsWith('0564')) {
        return '${clean.substring(0, 4)}-${clean.substring(4, 6)}-${clean.substring(6)}';
      } else if (clean.startsWith('0120') || clean.startsWith('0800')) {
        return '${clean.substring(0, 4)}-${clean.substring(4, 7)}-${clean.substring(7)}';
      } else {
        return '${clean.substring(0, 3)}-${clean.substring(3, 6)}-${clean.substring(6)}';
      }
    }
    return clean;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('顧客情報の編集'),
      content: SizedBox(
        width: rs(context, 500),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              KMultimodalTextField(label: '氏名', controller: nameController, maxLines: 1),
              KMultimodalTextField(label: '企業名', controller: companyController, maxLines: 1),
              Padding(
                padding: EdgeInsets.symmetric(vertical: rs(context, 8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('電話番号', style: TextStyle(fontSize: rf(context, 13), fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                    SizedBox(height: rs(context, 4)),
                    InkWell(
                      onTap: () => showDialog(
                        context: context,
                        builder: (_) => KNumericInputDialog(
                          title: '電話番号の入力',
                          initialValue: phoneController.text.replaceAll(RegExp(r'[^0-9]'), ''),
                          emptyHint: '番号を入力してください',
                          maxLength: 11,
                          onConfirmed: (v) => setState(() => phoneController.text = _formatPhone(v)),
                        ),
                      ),
                      child: InputDecorator(
                        decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                        child: Text(phoneController.text.isEmpty ? 'タップして入力' : phoneController.text),
                      ),
                    ),
                  ],
                ),
              ),
              KMultimodalTextField(label: 'メールアドレス', controller: emailController, maxLines: 1),
              KMultimodalTextField(label: '住所', controller: addressController, maxLines: 2),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: () async {
            final updatedCustomer = widget.customer.copyWith(
              name: nameController.text,
              companyName: companyController.text,
              phoneNumber: phoneController.text,
              email: emailController.text,
              address: addressController.text,
            );
            final navigator = Navigator.of(context);
            await widget.customerService.updateCustomer(updatedCustomer);
            if (!mounted) return;
            navigator.pop();
            widget.onSaved();
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentOrange, foregroundColor: AppColors.mainBackground),
          child: const Text('保存'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    companyController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    super.dispose();
  }
}
