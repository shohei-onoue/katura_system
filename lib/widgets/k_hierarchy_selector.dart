import 'package:flutter/material.dart';

class KHierarchySelector extends StatefulWidget {
  final String label;
  final Function(String) onSelected;

  const KHierarchySelector({
    super.key,
    required this.label,
    required this.onSelected,
  });

  @override
  State<KHierarchySelector> createState() => _KHierarchySelectorState();
}

class _KHierarchySelectorState extends State<KHierarchySelector> {
  String? _selectedCity;
  String? _selectedCategory;
  String? _selectedFacility;

  final List<String> _cities = ['岡崎市', '豊田市', '安城市', '知立市', '刈谷市'];
  final Map<String, List<String>> _categories = {
    '岡崎市': ['病院', '学校', '企業', '公共施設'],
    '豊田市': ['病院', '企業', '工場'],
  };
  final Map<String, List<String>> _facilities = {
    '病院': ['岡崎市民病院', '愛知医科大学付属', '藤田医科大学'],
    '企業': ['トヨタ自動車', 'デンソー', 'アイシン'],
  };

  void _reset() {
    setState(() {
      _selectedCity = null;
      _selectedCategory = null;
      _selectedFacility = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
            if (_selectedCity != null)
              TextButton.icon(
                onPressed: _reset,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('リセット', style: TextStyle(fontSize: 12)),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (_selectedCity == null)
          _buildGrid(_cities, (val) => setState(() => _selectedCity = val))
        else if (_selectedCategory == null)
          _buildGrid(_categories[_selectedCity] ?? [], (val) => setState(() => _selectedCategory = val))
        else
          _buildGrid(_facilities[_selectedCategory] ?? [], (val) {
            setState(() => _selectedFacility = val);
            widget.onSelected('$_selectedCity $_selectedCategory $val');
          }),
      ],
    );
  }

  Widget _buildGrid(List<String> items, Function(String) onSelect) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 2.5,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () => onSelect(items[index]),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4)],
            ),
            child: Text(items[index], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        );
      },
    );
  }
}
