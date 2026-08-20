import 'package:flutter/material.dart';
import '../../../../widgets/k_responsive.dart';

class SidebarDestinationInfo extends StatelessWidget {
  final String facilityName;
  final String address;
  final String deliveryLocation;
  final String receiverName;

  const SidebarDestinationInfo({
    super.key,
    required this.facilityName,
    required this.address,
    required this.deliveryLocation,
    required this.receiverName,
  });

  @override
  Widget build(BuildContext context) {
    if (facilityName.isEmpty && address.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(rs(context, 16)),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border(bottom: BorderSide(color: Colors.blue.shade100)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, size: rs(context, 18), color: Colors.blue.shade700),
              SizedBox(width: rs(context, 8)),
              Text(
                '確定した配達先',
                style: TextStyle(
                  fontSize: rf(context, 15),
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
            ],
          ),
          SizedBox(height: rs(context, 12)),
          _InfoRow(
            label: '施設・会社名',
            value: facilityName.isEmpty ? '(一般住宅・個人)' : facilityName,
            isBold: true,
          ),
          _InfoRow(label: '住所', value: address),
          if (deliveryLocation.isNotEmpty)
            _ImportantRow(label: '★ お渡し場所', value: deliveryLocation),
          if (receiverName.isNotEmpty)
            _InfoRow(label: '受取人', value: receiverName),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  final bool isBold;
  const _InfoRow({required this.label, required this.value, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: rs(context, 4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: rf(context, 11), color: Colors.blue.shade700)),
          Text(
            value,
            style: TextStyle(
              fontSize: rf(context, 14),
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImportantRow extends StatelessWidget {
  final String label, value;
  const _ImportantRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: rs(context, 4)),
      padding: EdgeInsets.all(rs(context, 8)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rs(context, 4)),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: rf(context, 11), color: Colors.orange.shade900, fontWeight: FontWeight.bold)),
          Text(
            value,
            style: TextStyle(
              fontSize: rf(context, 16),
              fontWeight: FontWeight.w900,
              color: Colors.orange.shade900,
            ),
          ),
        ],
      ),
    );
  }
}
