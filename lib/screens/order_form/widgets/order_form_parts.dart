import 'package:flutter/material.dart';
import '../../../models/customer_model.dart';
import '../../../../widgets/k_responsive.dart';

class OrderFormCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  const OrderFormCard({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rav(context, 16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: rav(context, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.all(rav(context, 16)),
            child: Row(
              children: [
                Icon(icon, color: Colors.deepOrange, size: rav(context, 20)),
                SizedBox(width: rav(context, 8)),
                Text(title, style: TextStyle(fontSize: rf(context, 16), fontWeight: FontWeight.bold)),
                if (trailing != null) ...[const Spacer(), trailing!],
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(padding: EdgeInsets.all(rav(context, 16)), child: child),
        ],
      ),
    );
  }
}

class CustomerInfoBanner extends StatelessWidget {
  final Customer? customer;

  const CustomerInfoBanner({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    if (customer == null) {
      return const SizedBox.shrink();
    }
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: rav(context, 8)),
      child: Container(
        padding: EdgeInsets.all(rav(context, 16)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(rav(context, 12)),
          border: Border.all(color: Colors.blueGrey.shade100, width: 1.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 左側: 顧客名
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel(context, Icons.person, '注文者名'),
                  SizedBox(height: rav(context, 4)),
                  if (customer!.furigana.isNotEmpty)
                    Text(customer!.furigana, 
                      style: TextStyle(fontSize: rf(context, 10), color: Colors.grey, height: 1.1)),
                  Text(
                    customer!.name,
                    style: TextStyle(
                      fontSize: rf(context, 28),
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            
            // 区切り線代わりの余白
            SizedBox(width: rav(context, 24)),
            
            // 右側: 企業・施設名
            Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel(context, Icons.business, '所属企業・施設'),
                  SizedBox(height: rav(context, 4)),
                  Text(
                    customer!.companyName.isEmpty ? '個人' : customer!.companyName,
                    style: TextStyle(
                      fontSize: rf(context, 22),
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey.shade700,
                      height: 1.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(BuildContext context, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: rav(context, 14), color: Colors.blueGrey),
        SizedBox(width: rav(context, 6)),
        Text(text, style: TextStyle(fontSize: rf(context, 11), fontWeight: FontWeight.bold, color: Colors.blueGrey)),
      ],
    );
  }

  static int? calculateDaysSince(List<String> history) {
    if (history.isEmpty) {
      return null;
    }
    try {
      final dateStr = history.first.split(':').first.trim();
      final lastDate = DateTime.parse(dateStr);
      return DateTime.now().difference(lastDate).inDays;
    } catch (e) {
      return null;
    }
  }
}

class KInitialRowSelector extends StatelessWidget {
  final String selectedInitial;
  final Function(String) onSelected;

  const KInitialRowSelector({
    super.key,
    required this.selectedInitial,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> rows = ['あ', 'か', 'さ', 'た', 'な', 'は', 'ま', 'や', 'ら', 'わ', 'すべて'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: rows.map((r) {
          final isSelected = selectedInitial == r;
          return Padding(
            padding: EdgeInsets.only(right: rs(context, 4)),
            child: SizedBox(
              width: rs(context, 44),
              height: rs(context, 36),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? Colors.deepPurple : Colors.white,
                  foregroundColor: isSelected ? Colors.white : Colors.black87,
                  padding: EdgeInsets.zero,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(rs(context, 6)),
                    side: BorderSide(color: isSelected ? Colors.deepPurple : Colors.grey.shade300),
                  ),
                ),
                onPressed: () => onSelected(r),
                child: Text(r, style: TextStyle(fontSize: rf(context, 13), fontWeight: FontWeight.bold)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
