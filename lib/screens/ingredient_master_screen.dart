import 'package:flutter/material.dart';
import '../models/ingredient_model.dart';
import '../services/ingredient_service.dart';
import '../../widgets/k_responsive.dart';
import '../../widgets/k_multimodal_text_field.dart';

class IngredientMasterScreen extends StatefulWidget {
  const IngredientMasterScreen({super.key});

  @override
  State<IngredientMasterScreen> createState() => _IngredientMasterScreenState();
}

class _IngredientMasterScreenState extends State<IngredientMasterScreen> {
  final _ingredientService = IngredientService();
  List<IngredientModel> _ingredients = [];
  bool _isLoading = true;
  String _selectedCategory = 'すべて';

  List<String> get _categoryTabs => ['すべて', ...IngredientService.categoryPresets];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await _ingredientService.getAll(forceRefresh: true);
      if (!mounted) return;
      setState(() {
        _ingredients = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('食材の取得に失敗しました: $e')),
      );
    }
  }

  static const List<String> _unitPresets = [
    'g', 'kg', 'ml', 'L', '大さじ', '小さじ', '個', '枚', '本', '束', '適量'
  ];

  void _showEditDialog([IngredientModel? ingredient]) {
    final nameController = TextEditingController(text: ingredient?.name ?? '');
    final noteController = TextEditingController(text: ingredient?.note ?? '');
    String category = ingredient?.category ?? IngredientService.categoryPresets.first;
    String selectedUnit = ingredient?.unit ?? 'g';
    final List<String> unitOptions = [
      ..._unitPresets,
      if (selectedUnit.isNotEmpty && !_unitPresets.contains(selectedUnit)) selectedUnit,
    ];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          title: Text(ingredient == null ? '新規食材登録' : '食材編集'),
          content: SizedBox(
            width: rs(context, 420),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  KMultimodalTextField(
                    label: '食材名',
                    controller: nameController,
                    maxLines: 1,
                    hintText: '例：牛肩ロース',
                  ),
                  SizedBox(height: rs(context, 16)),
                  DropdownButtonFormField<String>(
                    value: unitOptions.contains(selectedUnit) ? selectedUnit : null,
                    decoration: const InputDecoration(labelText: '単位'),
                    items: unitOptions
                        .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedUnit = val);
                    },
                  ),
                  SizedBox(height: rs(context, 16)),
                  DropdownButtonFormField<String>(
                    value: IngredientService.categoryPresets.contains(category) ? category : null,
                    decoration: const InputDecoration(labelText: 'カテゴリ'),
                    items: IngredientService.categoryPresets
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => category = val);
                    },
                  ),
                  SizedBox(height: rs(context, 16)),
                  KMultimodalTextField(
                    label: '備考',
                    controller: noteController,
                    maxLines: 2,
                    hintText: '例：米は季節で使用量が変動',
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('キャンセル')),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('食材名を入力してください')));
                  return;
                }
                final unit = selectedUnit.trim().isEmpty ? '適量' : selectedUnit.trim();
                try {
                  if (ingredient == null) {
                    await _ingredientService.add(
                      name: nameController.text.trim(),
                      unit: unit,
                      category: category,
                      note: noteController.text.trim(),
                    );
                  } else {
                    await _ingredientService.update(ingredient.copyWith(
                      name: nameController.text.trim(),
                      unit: unit,
                      category: category,
                      note: noteController.text.trim(),
                    ));
                  }
                  if (!mounted) return;
                  Navigator.pop(context);
                  _load();
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('食材を保存しました')));
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('保存に失敗しました: $e'), backgroundColor: Colors.red),
                  );
                }
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(IngredientModel ingredient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('食材の削除'),
        content: Text('${ingredient.name} を削除してもよろしいですか？\nこの操作は取り消せません。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('キャンセル')),
          ElevatedButton(
            onPressed: () async {
              await _ingredientService.delete(ingredient.id);
              if (!mounted) return;
              Navigator.pop(context);
              _load();
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('食材を削除しました')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('削除する'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedCategory == 'すべて'
        ? _ingredients
        : _ingredients.where((i) => i.category == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('食材マスタ', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          ElevatedButton.icon(
            onPressed: () => _showEditDialog(),
            icon: const Icon(Icons.add),
            label: const Text('新規登録'),
          ),
          SizedBox(width: rs(context, 16)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _ingredients.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    _buildCategoryTabs(),
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.all(rs(context, 24)),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final ing = filtered[index];
                          return Card(
                            elevation: 1,
                            color: Colors.white,
                            margin: EdgeInsets.only(bottom: rs(context, 12)),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.deepPurple.shade50,
                                child: Icon(Icons.egg_alt_outlined,
                                    color: Colors.deepPurple, size: rs(context, 20)),
                              ),
                              title: Text(ing.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                '${ing.category} | 単位: ${ing.unit}'
                                '${ing.note.isEmpty ? '' : ' | ${ing.note}'}',
                              ),
                              trailing: PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert, color: Colors.grey),
                                onSelected: (value) {
                                  if (value == 'edit') _showEditDialog(ing);
                                  if (value == 'delete') _showDeleteConfirmDialog(ing);
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, size: rs(context, 20), color: Colors.blue),
                                        SizedBox(width: rs(context, 12)),
                                        Text('編集', style: TextStyle(fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete_outline,
                                            size: rs(context, 20), color: Colors.red),
                                        SizedBox(width: rs(context, 12)),
                                        Text('削除',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500, color: Colors.red)),
                                      ],
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
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      width: double.infinity,
      color: Colors.grey.shade50,
      padding: EdgeInsets.symmetric(vertical: rs(context, 8), horizontal: rs(context, 16)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _categoryTabs.map((cat) {
            final isSelected = _selectedCategory == cat;
            return Padding(
              padding: EdgeInsets.only(right: rs(context, 8)),
              child: ChoiceChip(
                label: Text(cat, style: const TextStyle(fontWeight: FontWeight.bold)),
                selected: isSelected,
                onSelected: (val) => setState(() => _selectedCategory = cat),
                selectedColor: Colors.deepPurple,
                labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                showCheckmark: false,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.egg_alt_outlined, size: rs(context, 80), color: Colors.grey.shade300),
          SizedBox(height: rs(context, 24)),
          Text('食材が登録されていません',
              style: TextStyle(
                  fontSize: rf(context, 20),
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey)),
          SizedBox(height: rs(context, 12)),
          const Text('「新規登録」から食材を登録してください。',
              textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          SizedBox(height: rs(context, 32)),
          ElevatedButton.icon(
            onPressed: () => _showEditDialog(),
            icon: const Icon(Icons.add),
            label: const Text('新規登録する'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: rs(context, 32), vertical: rs(context, 16)),
            ),
          ),
        ],
      ),
    );
  }
}
