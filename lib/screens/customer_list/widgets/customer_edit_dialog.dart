import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/customer_model.dart';
import '../../../services/customer_service.dart';

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
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: '氏名'),
              ),
              TextField(
                controller: companyController,
                decoration: const InputDecoration(labelText: '企業名'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: '電話番号'),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
                  _PhoneFormatter(_formatPhone),
                ],
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'メールアドレス'),
              ),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: '住所'),
                maxLines: 2,
              ),
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
            await widget.customerService.updateCustomer(updatedCustomer);
            if (mounted) {
              Navigator.pop(context);
              widget.onSaved();
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, foregroundColor: Colors.white),
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

class _PhoneFormatter extends TextInputFormatter {
  final String Function(String) formatFunc;
  _PhoneFormatter(this.formatFunc);

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final formatted = formatFunc(newValue.text);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
      composing: TextRange.empty,
    );
  }
}
