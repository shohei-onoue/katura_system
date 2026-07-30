import 'package:flutter/material.dart';
import '../../../../widgets/k_responsive.dart';

class SidebarSearchResults extends StatelessWidget {
  final List<Map<String, dynamic>> results;
  final VoidCallback onClose;
  final Function(Map<String, dynamic>) onSelect;
  final VoidCallback? onForceApiSearch;

  const SidebarSearchResults({
    super.key,
    required this.results,
    required this.onClose,
    required this.onSelect,
    this.onForceApiSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(rs(context, 20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, 
            children: [
              _SectionTitle('施設検索結果', Icons.business_center), 
              IconButton(icon: Icon(Icons.close, size: rs(context, 18)), onPressed: onClose)
            ]
          ),
          SizedBox(height: rs(context, 12)),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: results.length,
            itemBuilder: (context, i) => Card(
              margin: EdgeInsets.only(bottom: rs(context, 8)), 
              elevation: 0, 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(context, 8)), side: BorderSide(color: Colors.grey.shade200)), 
              child: ListTile(
                dense: true, 
                title: Text(results[i]['name'] ?? '名称なし', style: TextStyle(fontWeight: FontWeight.bold, fontSize: rf(context, 14))), 
                subtitle: Text(results[i]['address'] ?? '', style: TextStyle(fontSize: rf(context, 12))), 
                trailing: Icon(Icons.chevron_right, size: rs(context, 16)), 
                onTap: () => onSelect(results[i])
              )
            ),
          ),
          if (onForceApiSearch != null) ...[
            SizedBox(height: rs(context, 24)),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: Icon(Icons.travel_explore, size: rs(context, 18)),
                label: Text('該当なし？Googleマップで再検索', style: TextStyle(fontWeight: FontWeight.bold, fontSize: rf(context, 14))),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: rs(context, 16)),
                  foregroundColor: Colors.deepPurple,
                  side: const BorderSide(color: Colors.deepPurple),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs(context, 12))),
                ),
                onPressed: onForceApiSearch,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionTitle(this.title, this.icon);
  @override
  Widget build(BuildContext context) {
    return Row(children: [Icon(icon, size: rs(context, 18), color: Colors.blueGrey), SizedBox(width: rs(context, 8)), Text(title, style: TextStyle(fontSize: rf(context, 15), fontWeight: FontWeight.bold, color: Colors.blueGrey))]);
  }
}
