import 'package:flutter/material.dart';
import '../../../models/customer_model.dart';

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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(icon, color: Colors.deepOrange, size: 20),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                if (trailing != null) ...[const Spacer(), trailing!],
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(padding: const EdgeInsets.all(20), child: child),
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
    if (customer == null) return const SizedBox.shrink();
    
    final daysSince = _calculateDaysSince(customer!.orderHistory);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: _InfoCardWrapper(
            label: '注文者',
            icon: Icons.person,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Text(customer!.name, 
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, height: 1.0),
                  overflow: TextOverflow.ellipsis),
                if (customer!.furigana.isNotEmpty)
                  Transform.translate(
                    offset: const Offset(0, -20),
                    child: Text(customer!.furigana, 
                      style: const TextStyle(fontSize: 11, color: Colors.grey, height: 1.0)),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 4,
          child: _InfoCardWrapper(
            label: '企業・施設',
            icon: Icons.business,
            child: Text(
              customer!.companyName.isEmpty ? '個人' : customer!.companyName,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, height: 1.0),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: _InfoCardWrapper(
            label: '最終注文から',
            icon: Icons.update,
            isAlert: (daysSince ?? 0) > 90,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(daysSince != null ? '$daysSince' : '-', 
                  style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold, height: 1.0, color: (daysSince ?? 0) > 90 ? Colors.red : Colors.blue)),
                const SizedBox(width: 2),
                Text('日', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: (daysSince ?? 0) > 90 ? Colors.red : Colors.blue)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  int? _calculateDaysSince(List<String> history) {
    if (history.isEmpty) return null;
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
            padding: const EdgeInsets.only(right: 4),
            child: SizedBox(
              width: 44,
              height: 36,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? Colors.deepPurple : Colors.white,
                  foregroundColor: isSelected ? Colors.white : Colors.black87,
                  padding: EdgeInsets.zero,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: BorderSide(color: isSelected ? Colors.deepPurple : Colors.grey.shade300),
                  ),
                ),
                onPressed: () => onSelected(r),
                child: Text(r, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _InfoCardWrapper extends StatelessWidget {
  final String label;
  final IconData icon;
  final Widget child;
  final bool isAlert;

  const _InfoCardWrapper({
    required this.label,
    required this.icon,
    required this.child,
    this.isAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 24,
          child: Row(
            children: [
              const SizedBox(width: 4),
              Icon(icon, size: 14, color: Colors.blueGrey),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 90, 
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isAlert ? Colors.red.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isAlert ? Colors.red.shade100 : Colors.blueGrey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: child,
        ),
      ],
    );
  }
}
