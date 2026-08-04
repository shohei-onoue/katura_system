import 'dart:convert';
import 'dart:typed_data';
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
  final _imagePicker = ImagePicker();
  List<MenuModel> _menus = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMenus();
  }

  Future<void> _loadMenus() async {
    try {
      final data = await _menuService.getAllMenus();
      if (mounted) {
        setState(() {
          _menus = data;
          _isLoading = false;
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
    if (url.startsWith('data:image')) {
      try {
        return MemoryImage(base64Decode(url.split(',').last));
      } catch (_) {
        return const AssetImage('assets/img/placeholder.png');
      }
    }
    return const AssetImage('assets/img/placeholder.png');
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
                if (menu.ingredients.isNotEmpty) ...[
                  const Text('材料・分量', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
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
    Uint8List? pendingImageBytes;
    
    final ingredientsController = TextEditingController(
        text: menu?.ingredients.entries.map((e) => '${e.key}:${e.value}').join(', ') ?? '');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
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
                          currentImageUrl = ""; // ローカル表示優先
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
                  TextField(controller: categoryController, decoration: const InputDecoration(labelText: 'カテゴリー', hintText: '例：お弁当、高級弁当')),
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

                debugPrint('MenuMasterScreen: Save button pressed.');
                // インジケータを表示
                showDialog(
                  context: context, 
                  barrierDismissible: false, 
                  builder: (_) => const Center(child: CircularProgressIndicator())
                );
                
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
                    category: categoryController.text,
                    price: int.tryParse(priceController.text) ?? 0,
                    description: descriptionController.text,
                    imageUrl: currentImageUrl,
                    ingredients: ingredientsMap,
                  );

                  debugPrint('MenuMasterScreen: Calling MenuService...');
                  if (menu == null) {
                    await _menuService.createMenu(newMenu, imageBytes: pendingImageBytes);
                  } else {
                    await _menuService.updateMenu(newMenu, imageBytes: pendingImageBytes);
                  }
                  debugPrint('MenuMasterScreen: MenuService returned successfully.');

                  if (mounted) {
                    Navigator.of(context).pop(); // インジケータを閉じる
                    Navigator.of(context).pop(); // ダイアログを閉じる
                    _loadMenus();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('メニューを保存しました')),
                    );
                  }
                } catch (e, stack) {
                  debugPrint('MenuMasterScreen Error during save: $e');
                  debugPrint('Stack trace: $stack');
                  if (mounted) {
                    Navigator.of(context).pop(); // インジケータを閉じる
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('保存失敗', style: TextStyle(color: Colors.red)),
                        content: Text('エラーが発生しました：\n$e\n\nネットワーク接続や権限を確認してください。'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('了解')),
                        ],
                      ),
                    );
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _menuService.deleteMenu(menu.id);
              if (mounted) {
                Navigator.pop(context);
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

  void _showResetConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('初期データでリセット'),
        content: const Text('現在のメニューデータをすべて削除し、初期データで上書きします。よろしいですか？\n※自分で登録したメニューも消去されます。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('キャンセル')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
              try {
                await _menuService.seedMenuData();
                if (mounted) {
                  Navigator.pop(context);
                  _loadMenus();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('メニューマスタをリセットしました')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('リセットに失敗しました: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
            child: const Text('リセット実行'),
          ),
        ],
      ),
    );
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
        title: const Text('メニューマスタ', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _showResetConfirmDialog,
            tooltip: '初期データでリセット',
          ),
          const SizedBox(width: 8),
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
