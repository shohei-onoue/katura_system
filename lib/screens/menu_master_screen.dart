import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/menu_model.dart';
import '../services/menu_service.dart';

class MenuMasterScreen extends StatefulWidget {
  const MenuMasterScreen({super.key});

  @override
  State<MenuMasterScreen> createState() => _MenuMasterScreenState();
}

class _MenuMasterScreenState extends State<MenuMasterScreen> {
  final _menuService = MenuService();
  final _picker = ImagePicker();
  List<MenuModel> _menus = [];
  bool _isLoading = true;

  final List<String> _photoCollection = [
    'assets/img/a_combo.webp',
    'assets/img/b_combo.webp',
    'assets/img/c_combo.webp',
    'assets/img/hourai_beef.webp',
    'assets/img/adult_steak.jpg',
    'assets/img/special_steak.webp',
    'assets/img/a5_fillet.jpg',
    'assets/img/mikawa_fillet.webp',
    'assets/img/hors_3.jpg',
    'assets/img/hors_6.jpg',
    'assets/img/roast_beef.webp',
    'assets/img/shrimp_fry.webp',
    'assets/img/fillet_special.webp',
    'assets/img/shimofuri_hamburg.jpg',
    'assets/img/teriyaki_hamburg.webp',
    'assets/img/steak_uchimomo.webp',
    'assets/img/kids_bowl.webp',
  ];

  @override
  void initState() {
    super.initState();
    _loadMenus();
  }

  Future<void> _loadMenus() async {
    try {
      final data = await _menuService.getAllMenus();
      setState(() {
        _menus = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  ImageProvider _getImageProvider(String url) {
    if (url.isEmpty) return const AssetImage('assets/img/placeholder.png');
    if (url.startsWith('data:image')) {
      try {
        return MemoryImage(base64Decode(url.split(',').last));
      } catch (_) {
        return const AssetImage('assets/img/placeholder.png');
      }
    }
    return AssetImage(url);
  }

  void _showPhotoPicker(Function(String) onSelected) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('写真コレクション'),
        content: SizedBox(
          width: 800,
          height: 600,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: _photoCollection.length,
            itemBuilder: (context, index) {
              final path = _photoCollection[index];
              final fileName = path.split('/').last;
              return InkWell(
                onTap: () {
                  onSelected(path);
                  Navigator.pop(context);
                },
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Image.asset(
                          path,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Text('Error\n$fileName',
                                  style: const TextStyle(fontSize: 8),
                                  textAlign: TextAlign.center),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fileName,
                      style: const TextStyle(fontSize: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('閉じる')),
        ],
      ),
    );
  }

  void _showMenuDetail(MenuModel menu) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.restaurant, color: Colors.deepOrange),
            const SizedBox(width: 8),
            Expanded(child: Text(menu.name)),
            IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
          ],
        ),
        content: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (menu.imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image(
                      image: _getImageProvider(menu.imageUrl),
                      width: double.infinity,
                      height: 300,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => const SizedBox(height: 100, child: Center(child: Icon(Icons.broken_image))),
                    ),
                  ),
                const SizedBox(height: 16),
                _detailItem('カテゴリー', menu.category),
                _detailItem('価格 (税込)', '¥${menu.price}'),
                _detailItem('説明', menu.description),
                const Divider(height: 32),
                ...menu.ingredients.entries.map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, size: 16, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(entry.key),
                      const Spacer(),
                      Text(entry.value, style: const TextStyle(color: Colors.blueGrey)),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('閉じる')),
        ],
      ),
    );
  }

  void _showEditMenuDialog([MenuModel? menu]) {
    final nameController = TextEditingController(text: menu?.name ?? '');
    final categoryController = TextEditingController(text: menu?.category ?? 'お弁当');
    final priceController = TextEditingController(text: menu?.price.toString() ?? '');
    final descriptionController = TextEditingController(text: menu?.description ?? '');
    String currentImageUrl = menu?.imageUrl ?? '';
    final ingredientsController = TextEditingController(
        text: menu?.ingredients.entries.map((e) => '${e.key}:${e.value}').join(', ') ?? '');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(menu == null ? '新規登録' : '編集'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => _showPhotoPicker((path) => setDialogState(() => currentImageUrl = path)),
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: currentImageUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image(image: _getImageProvider(currentImageUrl), fit: BoxFit.cover),
                            )
                          : const Icon(Icons.add_a_photo, size: 48, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(controller: nameController, decoration: const InputDecoration(labelText: '商品名')),
                  TextField(controller: categoryController, decoration: const InputDecoration(labelText: 'カテゴリー')),
                  TextField(controller: priceController, decoration: const InputDecoration(labelText: '価格')),
                  TextField(controller: ingredientsController, decoration: const InputDecoration(labelText: '材料:分量 (カンマ区切り)')),
                  TextField(controller: descriptionController, decoration: const InputDecoration(labelText: '説明'), maxLines: 2),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('キャンセル')),
            ElevatedButton(
              onPressed: () async {
                final Map<String, String> ingredientsMap = {};
                for (var pair in ingredientsController.text.split(',')) {
                  final parts = pair.split(':');
                  if (parts.length == 2) ingredientsMap[parts[0].trim()] = parts[1].trim();
                }
                final newMenu = MenuModel(
                  id: menu?.id ?? '',
                  name: nameController.text,
                  category: categoryController.text,
                  price: int.tryParse(priceController.text) ?? 0,
                  description: descriptionController.text,
                  imageUrl: currentImageUrl,
                  ingredients: ingredientsMap,
                );
                menu == null ? await _menuService.createMenu(newMenu) : await _menuService.updateMenu(newMenu);
                if (mounted) { Navigator.pop(context); _loadMenus(); }
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _menuService.deleteMenu(menu.id);
              if (mounted) {
                Navigator.pop(context);
                _loadCustomers();
                _loadMenus();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('メニューを削除しました')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('削除する'),
          ),
        ],
      ),
    );
  }

  // 顧客管理用と競合しないよう修正
  Future<void> _loadCustomers() async {
    // 顧客一覧の更新が必要な場合のダミー（または削除）
  }

  Widget _detailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('メニューマスタ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              showDialog(context: context, builder: (_) => const Center(child: CircularProgressIndicator()));
              await _menuService.seedMenuData();
              if (mounted) Navigator.pop(context);
              _loadMenus();
            },
          ),
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
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: _menus.length,
              itemBuilder: (context, index) {
                final menu = _menus[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: Container(
                      width: 60, height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: menu.imageUrl.isNotEmpty
                            ? DecorationImage(image: _getImageProvider(menu.imageUrl), fit: BoxFit.cover)
                            : null,
                      ),
                      child: menu.imageUrl.isEmpty ? const Icon(Icons.restaurant) : null,
                    ),
                    title: Text(menu.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${menu.category} | ¥${menu.price}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.info_outline, size: 18),
                          label: const Text('詳細'),
                          onPressed: () => _showMenuDetail(menu),
                          style: TextButton.styleFrom(foregroundColor: Colors.deepOrange),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('編集'),
                          onPressed: () => _showEditMenuDialog(menu),
                          style: TextButton.styleFrom(foregroundColor: Colors.blue),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          icon: const Icon(Icons.delete_outline, size: 18),
                          label: const Text('削除'),
                          onPressed: () => _showDeleteConfirmDialog(menu),
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
