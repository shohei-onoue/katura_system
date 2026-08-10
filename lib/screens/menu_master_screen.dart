import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/menu_model.dart';
import '../services/menu_service.dart';
import '../../widgets/k_responsive.dart';

class MenuMasterScreen extends StatefulWidget {
  const MenuMasterScreen({super.key});

  @override
  State<MenuMasterScreen> createState() => _MenuMasterScreenState();
}

class _MenuMasterScreenState extends State<MenuMasterScreen> {
  final _menuService = MenuService();
  final _imagePicker = ImagePicker();
  List<MenuModel> _menus = [];
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
      if (mounted) {
        setState(() {
          _menus = data;
          _isLoading = false;
          if (_menus.isNotEmpty && _selectedMenu == null) {
            _selectedMenu = _menus.first;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('メニューの取得に失敗しました: $e')),
        );
      }
    }
  }

  ImageProvider _getImageProvider(String url) {
    if (url.isEmpty) return const AssetImage('assets/img/placeholder.png');
    if (url.startsWith('http')) return NetworkImage(url);
    if (url.startsWith('assets/')) return AssetImage(url);
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
    
    final ingredientsController = TextEditingController(
        text: menu?.ingredients.entries.map((e) => '${e.key}:${e.value}').join(', ') ?? '');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          title: Text(menu == null ? '新規メニュー登録' : 'メニュー編集'),
          content: SizedBox(
            width: 500,
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
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: pendingImageBytes != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(pendingImageBytes!, fit: BoxFit.cover),
                            )
                          : currentImageUrl.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image(image: _getImageProvider(currentImageUrl), fit: BoxFit.cover),
                                )
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo, size: 48, color: Colors.grey),
                                    SizedBox(height: 8),
                                    Text('写真をアップロード', style: TextStyle(color: Colors.grey)),
                                  ],
                                ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(controller: nameController, decoration: const InputDecoration(labelText: '商品名', hintText: '例：特製ステーキ弁当')),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: dropdownCategories.contains(category) ? category : null,
                    decoration: const InputDecoration(labelText: 'カテゴリー'),
                    items: dropdownCategories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                    onChanged: (val) {
                      if (val != null) category = val;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(controller: priceController, decoration: const InputDecoration(labelText: '価格 (税込)', hintText: '例：1800'), keyboardType: TextInputType.number),
                  TextField(controller: ingredientsController, decoration: const InputDecoration(labelText: '材料:分量 (カンマ区切り)', hintText: '例：牛ステーキ肉:150g, 白米:250g')),
                  TextField(controller: descriptionController, decoration: const InputDecoration(labelText: '説明', hintText: '商品の詳細説明を入力してください'), maxLines: 2),
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
                  if (ingredientsController.text.isNotEmpty) {
                    for (var pair in ingredientsController.text.split(',')) {
                      final parts = pair.split(':');
                      if (parts.length == 2) ingredientsMap[parts[0].trim()] = parts[1].trim();
                    }
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
                  if (mounted) {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    _loadMenus();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('メニューを保存しました')));
                  }
                } catch (e) {
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('保存に失敗しました: $e'), backgroundColor: Colors.red));
                  }
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
        title: const Text('メニューの削除'),
        content: Text('${menu.name} を削除してもよろしいですか？\nこの操作は取り消せません。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('キャンセル')),
          ElevatedButton(
            onPressed: () async {
              await _menuService.deleteMenu(menu.id);
              if (mounted) {
                Navigator.pop(context);
                _loadMenus();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('メニューを削除しました')));
              }
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
          const SizedBox(width: 16),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
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
                          padding: const EdgeInsets.all(24),
                          itemCount: filteredMenus.length,
                          itemBuilder: (context, index) {
                            final menu = filteredMenus[index];
                            final isSelected = _selectedMenu?.id == menu.id;
                            return Card(
                              elevation: isSelected ? 4 : 1,
                              color: isSelected ? Colors.deepPurple.shade50 : Colors.white,
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                selected: isSelected,
                                leading: Container(
                                  width: 50, height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
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
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit, size: 20, color: Colors.blue),
                                          SizedBox(width: 12),
                                          Text('編集', style: TextStyle(fontWeight: FontWeight.w500)),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete_outline, size: 20, color: Colors.red),
                                          SizedBox(width: 12),
                                          Text('削除', style: TextStyle(fontWeight: FontWeight.w500)),
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
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                  ),
                  child: _selectedMenu == null
                      ? const Center(child: Text('メニューを選択してください'))
                      : _buildDetailSidebar(_selectedMenu!),
                ),
              ],
            ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      width: double.infinity,
      color: Colors.grey.shade50,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _categoryPresets.map((cat) {
            final isSelected = _selectedCategory == cat;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
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
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image(image: _getImageProvider(menu.imageUrl), width: double.infinity, height: 200, fit: BoxFit.cover),
          ),
          const SizedBox(height: 24),
          Text(menu.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('¥${menu.price}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
          const SizedBox(height: 16),
          _detailItem('カテゴリー', menu.category),
          const Divider(height: 32),
          const Text('商品説明', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(menu.description.isEmpty ? '説明はありません' : menu.description, style: const TextStyle(color: Colors.blueGrey)),
          const SizedBox(height: 24),
          const Text('材料・分量', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          ...menu.ingredients.entries.map((e) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.check_circle, size: 16, color: Colors.orange),
                const SizedBox(width: 8),
                Text(e.key),
                const Spacer(),
                Text(e.value, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          )),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(child: OutlinedButton.icon(onPressed: () => _showEditMenuDialog(menu), icon: const Icon(Icons.edit), label: const Text('編集'))),
              const SizedBox(width: 12),
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
}
