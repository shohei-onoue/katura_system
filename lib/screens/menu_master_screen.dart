import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/menu_model.dart';
import '../models/ingredient_model.dart';
import '../services/menu_service.dart';
import '../services/ingredient_service.dart';
import '../../widgets/k_responsive.dart';

class MenuMasterScreen extends StatefulWidget {
  const MenuMasterScreen({super.key});

  @override
  State<MenuMasterScreen> createState() => _MenuMasterScreenState();
}

class _MenuMasterScreenState extends State<MenuMasterScreen> {
  final _menuService = MenuService();
  final _ingredientService = IngredientService();
  final _imagePicker = ImagePicker();
  List<MenuModel> _menus = [];
  List<IngredientModel> _ingredients = [];
  bool _isLoading = true;
  String _selectedCategory = 'すべて';
  MenuModel? _selectedMenu;

  final List<String> _categoryPresets = ['すべて', '厳選牛ステーキ弁当', '高級弁当', 'オードブル', '丼もの', 'ギフト', 'ドリンク・サイドメニュー'];

  @override
  void initState() {
    super.initState();
    _loadMenus();
  }

  Future<void> _loadMenus() async {
    try {
      await _menuService.migrateCategories();
      final data = await _menuService.getAllMenus();
      final ingredients = await _ingredientService.getAll();
      if (!mounted) return;
      setState(() {
        _menus = data;
        _ingredients = ingredients;
        _isLoading = false;
        if (_menus.isNotEmpty && _selectedMenu == null) {
          _selectedMenu = _menus.first;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('メニューの取得に失敗しました: $e')),
      );
    }
  }

  ImageProvider _getImageProvider(String url) {
    if (url.isEmpty) {
      return const AssetImage('assets/img/placeholder.png');
    }
    if (url.startsWith('http')) {
      return NetworkImage(url);
    }
    if (url.startsWith('assets/')) {
      return AssetImage(url);
    }
    return const AssetImage('assets/img/placeholder.png');
  }

  void _showEditMenuDialog([MenuModel? menu]) {
    final List<String> dropdownCategories = _categoryPresets.where((c) => c != 'すべて').toList();
    final nameController = TextEditingController(text: menu?.name ?? '');
    String category = menu?.category ?? dropdownCategories.first;
    final priceController = TextEditingController(text: menu?.price.toString() ?? '');
    final descriptionController = TextEditingController(text: menu?.description ?? '');
    String currentImageUrl = menu?.imageUrl ?? '';
    Uint8List? pendingImageBytes;
    
    final List<_MenuIngredientRow> ingredientRows = [];
    menu?.ingredients.forEach((name, value) {
      final master = _findIngredient(name);
      final numMatch = RegExp(r'^\d+(?:\.\d+)?').firstMatch(value.trim());
      final amount = numMatch?.group(0) ?? '';
      final unit = master?.unit ??
          value.trim().replaceFirst(RegExp(r'^\d+(?:\.\d+)?\s*'), '');
      ingredientRows.add(_MenuIngredientRow(name: name, unit: unit, amount: amount));
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          title: Text(menu == null ? '新規メニュー登録' : 'メニュー編集'),
          content: SizedBox(
            width: rs(context, 500),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () async {
                      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        final bytes = await image.readAsBytes();
                        setDialogState(() {
                          pendingImageBytes = bytes;
                          currentImageUrl = "";
                        });
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: rs(context, 200),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(rs(context, 12)),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: pendingImageBytes != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(rs(context, 12)),
                              child: Image.memory(pendingImageBytes!, fit: BoxFit.cover),
                            )
                          : currentImageUrl.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(rs(context, 12)),
                                  child: Image(image: _getImageProvider(currentImageUrl), fit: BoxFit.cover),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo, size: rs(context, 48), color: Colors.grey),
                                    SizedBox(height: rs(context, 8)),
                                    Text('写真をアップロード', style: TextStyle(color: Colors.grey)),
                                  ],
                                ),
                    ),
                  ),
                  SizedBox(height: rs(context, 16)),
                  TextField(controller: nameController, textAlignVertical: TextAlignVertical.center, decoration: const InputDecoration(labelText: '商品名', hintText: '例：特製ステーキ弁当')),
                  SizedBox(height: rs(context, 16)),
                  DropdownButtonFormField<String>(
                    value: dropdownCategories.contains(category) ? category : null,
                    decoration: const InputDecoration(labelText: 'カテゴリー'),
                    items: dropdownCategories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        category = val;
                      }
                    },
                  ),
                  SizedBox(height: rs(context, 16)),
                  TextField(controller: priceController, textAlignVertical: TextAlignVertical.center, decoration: const InputDecoration(labelText: '価格 (税込)', hintText: '例：1800'), keyboardType: TextInputType.number),
                  _buildIngredientEditor(context, setDialogState, ingredientRows),
                  TextField(controller: descriptionController, textAlignVertical: TextAlignVertical.center, decoration: const InputDecoration(labelText: '説明', hintText: '商品の詳細説明を入力してください'), maxLines: 2),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('キャンセル')),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty || priceController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('商品名と価格を入力してください')));
                  return;
                }
                showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
                try {
                  final Map<String, String> ingredientsMap = {};
                  for (final row in ingredientRows) {
                    final amount = row.amountController.text.trim();
                    final value = amount.isEmpty ? row.unit : '$amount${row.unit}';
                    if (value.isNotEmpty) ingredientsMap[row.name] = value;
                  }
                  final newMenu = MenuModel(
                    id: menu?.id ?? '',
                    name: nameController.text,
                    category: category,
                    price: int.tryParse(priceController.text) ?? 0,
                    description: descriptionController.text,
                    imageUrl: currentImageUrl,
                    ingredients: ingredientsMap,
                  );
                  if (menu == null) {
                    await _menuService.createMenu(newMenu, imageBytes: pendingImageBytes);
                  } else {
                    await _menuService.updateMenu(newMenu, imageBytes: pendingImageBytes);
                  }
                  if (!mounted) return;
                  Navigator.pop(context); // Close progress
                  Navigator.pop(context); // Close dialog
                  _loadMenus();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('メニューを保存しました')));
                } catch (e) {
                  if (!mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('保存に失敗しました: $e'), backgroundColor: Colors.red));
                }
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(MenuModel menu) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('メニューの削除'),
        content: Text('${menu.name} を削除してもよろしいですか？\nこの操作は取り消せません。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('キャンセル')),
          ElevatedButton(
            onPressed: () async {
              await _menuService.deleteMenu(menu.id);
              if (!mounted) return;
              Navigator.pop(context);
              _loadMenus();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('メニューを削除しました')));
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
    final filteredMenus = _selectedCategory == 'すべて'
        ? _menus
        : _menus.where((m) => m.category == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('メニューマスタ', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          ElevatedButton.icon(
            onPressed: () => _showEditMenuDialog(),
            icon: const Icon(Icons.add),
            label: const Text('新規登録'),
          ),
          SizedBox(width: rs(context, 16)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _menus.isEmpty 
              ? _buildEmptyState()
              : Row(
                  children: [
                    // 左側: リストとタブ
                    Expanded(
                      flex: 6,
                      child: Column(
                        children: [
                          _buildCategoryTabs(),
                          Expanded(
                            child: ListView.builder(
                              padding: EdgeInsets.all(rs(context, 24)),
                              itemCount: filteredMenus.length,
                              itemBuilder: (context, index) {
                                final menu = filteredMenus[index];
                                final isSelected = _selectedMenu?.id == menu.id;
                                return Card(
                                  elevation: isSelected ? 4 : 1,
                                  color: isSelected ? Colors.deepPurple.shade50 : Colors.white,
                                  margin: EdgeInsets.only(bottom: rs(context, 12)),
                                  child: ListTile(
                                    selected: isSelected,
                                    leading: Container(
                                      width: rs(context, 50), height: rs(context, 50),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(rs(context, 8)),
                                        image: DecorationImage(image: _getImageProvider(menu.imageUrl), fit: BoxFit.cover),
                                      ),
                                    ),
                                    title: Text(menu.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text('${menu.category} | ¥${menu.price}'),
                                    onTap: () => setState(() => _selectedMenu = menu),
                                    trailing: PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_vert, color: Colors.grey),
                                      onSelected: (value) {
                                        if (value == 'edit') _showEditMenuDialog(menu);
                                        if (value == 'delete') _showDeleteConfirmDialog(menu);
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
                                              Icon(Icons.delete_outline, size: rs(context, 20), color: Colors.red),
                                              SizedBox(width: rs(context, 12)),
                                              Text('削除', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.red)),
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
                    ),
                    // 右側: 詳細サイドバー
                    Container(
                      width: rs(context, 350),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(left: BorderSide(color: Colors.grey.shade200)),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                      ),
                      child: _selectedMenu == null
                          ? const Center(child: Text('メニューを選択してください'))
                          : _buildDetailSidebar(_selectedMenu!),
                    ),
                  ],
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu, size: rs(context, 80), color: Colors.grey.shade300),
          SizedBox(height: rs(context, 24)),
          Text('メニューが登録されていません', 
            style: TextStyle(fontSize: rf(context, 20), fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          SizedBox(height: rs(context, 12)),
          const Text('データベースを切り替えたか、初期状態です。\n以下のボタンから初期メニューを登録できます。', 
            textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          SizedBox(height: rs(context, 32)),
          ElevatedButton.icon(
            onPressed: () async {
              setState(() => _isLoading = true);
              try {
                await _menuService.seedMenuData();
                if (!mounted) return;
                await _loadMenus();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('初期データを登録しました')));
              } catch (e) {
                if (!mounted) return;
                setState(() => _isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('登録に失敗しました: $e')));
              }
            },
            icon: const Icon(Icons.download),
            label: const Text('初期データを登録する'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: rs(context, 32), vertical: rs(context, 16)),
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
          children: _categoryPresets.map((cat) {
            final isSelected = _selectedCategory == cat;
            return Padding(
              padding: EdgeInsets.only(right: rs(context, 8)),
              child: ChoiceChip(
                label: Text(cat, style: const TextStyle(fontWeight: FontWeight.bold)),
                selected: isSelected,
                onSelected: (val) => setState(() => _selectedCategory = cat),
                selectedColor: Colors.deepPurple,
                labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                showCheckmark: false, // チェックマークを非表示に
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDetailSidebar(MenuModel menu) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(rs(context, 24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(rs(context, 12)),
            child: Image(image: _getImageProvider(menu.imageUrl), width: double.infinity, height: rs(context, 200), fit: BoxFit.cover),
          ),
          SizedBox(height: rs(context, 24)),
          Text(menu.name, style: TextStyle(fontSize: rf(context, 22), fontWeight: FontWeight.bold)),
          SizedBox(height: rs(context, 8)),
          Text('¥${menu.price}', style: TextStyle(fontSize: rf(context, 20), fontWeight: FontWeight.bold, color: Colors.deepOrange)),
          SizedBox(height: rs(context, 16)),
          _detailItem('カテゴリー', menu.category),
          Divider(height: rs(context, 32)),
          Text('商品説明', style: TextStyle(fontWeight: FontWeight.bold, fontSize: rf(context, 16))),
          SizedBox(height: rs(context, 8)),
          Text(menu.description.isEmpty ? '説明はありません' : menu.description, style: const TextStyle(color: Colors.blueGrey)),
          SizedBox(height: rs(context, 24)),
          Text('材料・分量', style: TextStyle(fontWeight: FontWeight.bold, fontSize: rf(context, 16))),
          SizedBox(height: rs(context, 8)),
          ...menu.ingredients.entries.map((e) => Padding(
            padding: EdgeInsets.symmetric(vertical: rs(context, 4)),
            child: Row(
              children: [
                Icon(Icons.check_circle, size: rs(context, 16), color: Colors.orange),
                SizedBox(width: rs(context, 8)),
                Text(e.key),
                const Spacer(),
                Text(e.value, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          )),
          SizedBox(height: rs(context, 40)),
          Row(
            children: [
              Expanded(child: OutlinedButton.icon(onPressed: () => _showEditMenuDialog(menu), icon: const Icon(Icons.edit), label: const Text('編集'))),
              SizedBox(width: rs(context, 12)),
              Expanded(child: ElevatedButton.icon(onPressed: () => _showDeleteConfirmDialog(menu), icon: const Icon(Icons.delete_outline), label: const Text('削除'), style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade50, foregroundColor: Colors.red, elevation: 0))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailItem(String label, String value) {
    return Row(
      children: [
        Text('$label: ', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  IngredientModel? _findIngredient(String name) {
    for (final i in _ingredients) {
      if (i.name == name) return i;
    }
    return null;
  }

  Future<IngredientModel?> _pickIngredient(Set<String> exclude) {
    final available = _ingredients.where((i) => !exclude.contains(i.name)).toList();
    return showDialog<IngredientModel>(
      context: context,
      builder: (context) => SimpleDialog(
        backgroundColor: Colors.white,
        title: const Text('材料を選択'),
        children: available.isEmpty
            ? [
                Padding(
                  padding: EdgeInsets.all(rs(context, 16)),
                  child: const Text('選択できる材料がありません。\n材料マスタに登録してください。'),
                )
              ]
            : available
                .map((i) => SimpleDialogOption(
                      onPressed: () => Navigator.pop(context, i),
                      child: Text('${i.name}（${i.unit}）'),
                    ))
                .toList(),
      ),
    );
  }

  Widget _buildIngredientEditor(
      BuildContext context, StateSetter setDialogState, List<_MenuIngredientRow> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: rs(context, 16)),
        Align(
          alignment: Alignment.centerLeft,
          child: Text('材料・使用量',
              style: TextStyle(fontSize: rf(context, 12), color: Colors.grey.shade600)),
        ),
        ...rows.map((row) => Padding(
              padding: EdgeInsets.symmetric(vertical: rs(context, 4)),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(row.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                  ),
                  SizedBox(width: rs(context, 8)),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: row.amountController,
                      textAlignVertical: TextAlignVertical.center,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(isDense: true, hintText: '使用量'),
                    ),
                  ),
                  SizedBox(width: rs(context, 6)),
                  SizedBox(
                    width: rs(context, 36),
                    child: Text(row.unit, style: TextStyle(color: Colors.grey.shade600)),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: rs(context, 18), color: Colors.grey),
                    onPressed: () => setDialogState(() => rows.remove(row)),
                  ),
                ],
              ),
            )),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () async {
              final selected = await _pickIngredient(rows.map((r) => r.name).toSet());
              if (selected != null) {
                setDialogState(() => rows.add(
                    _MenuIngredientRow(name: selected.name, unit: selected.unit, amount: '')));
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('材料を追加'),
          ),
        ),
      ],
    );
  }
}

class _MenuIngredientRow {
  final String name;
  final String unit;
  final TextEditingController amountController;

  _MenuIngredientRow({required this.name, required this.unit, required String amount})
      : amountController = TextEditingController(text: amount);
}
