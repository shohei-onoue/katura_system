import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:katura_system/utils/app_colors.dart';
import '../../models/menu_model.dart';
import '../../models/ingredient_model.dart';
import '../../services/menu_service.dart';
import 'package:katura_system/widgets/k_numeric_input_dialog.dart';

// Figma(スマホ版メニューマスタ)の色
const Color _bg = Color(0xFFF3F7F6);
const Color _ink = Color(0xFF1D1B20);
const Color _sub = Color(0xFF6B6F76);
const Color _hint = Color(0xFF9AA0A6);
const Color _line = Color(0xFFE4E7EB);
const Color _fieldBg = Color(0xFFF6F7F9);
const Color _thumbBg = Color(0xFFEEF0F2);
const Color _thumbIcon = Color(0xFFB5BAC0);
const Color _purple = Color(0xFF673AB7);
const Color _red = Color(0xFFF44336);
const Color _orange = Color(0xFFFF6D00);

String _yen(int v) {
  final s = v.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
  return '¥$s';
}

Widget _menuThumb(String url, double size) {
  final fallback = Container(
    width: size,
    height: size,
    color: _thumbBg,
    alignment: Alignment.center,
    child: Icon(Icons.restaurant, size: 20, color: _thumbIcon),
  );
  if (!url.startsWith('http') && !url.startsWith('assets/')) return fallback;
  final ImageProvider p = url.startsWith('http')
      ? NetworkImage(url, webHtmlElementStrategy: WebHtmlElementStrategy.fallback)
      : AssetImage(url);
  return Image(image: p, width: size, height: size, fit: BoxFit.cover, errorBuilder: (_, _, _) => fallback);
}

/// メニューマスタ(スマホ)の本体: カテゴリ絞り込み + 一覧カード + 新規登録ボタン
class PhoneMenuMasterBody extends StatelessWidget {
  final List<MenuModel> menus;
  final List<String> categories;
  final String selectedCategory;
  final MenuModel? selectedMenu;
  final ValueChanged<String> onCategory;
  final ValueChanged<MenuModel> onSelect;
  final ValueChanged<MenuModel> onEdit;
  final ValueChanged<MenuModel> onDelete;
  final VoidCallback onAdd;

  const PhoneMenuMasterBody({
    super.key,
    required this.menus,
    required this.categories,
    required this.selectedCategory,
    required this.selectedMenu,
    required this.onCategory,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final list = selectedCategory == 'すべて' ? menus : menus.where((m) => m.category == selectedCategory).toList();
    return Container(
      color: _bg,
      child: Stack(
        children: [
          Column(
            children: [
              Container(
                color: Colors.white,
                height: 50,
                width: double.infinity,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  itemCount: categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 6),
                  itemBuilder: (_, i) {
                    final c = categories[i];
                    final sel = c == selectedCategory;
                    return GestureDetector(
                      onTap: () => onCategory(c),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: sel ? _purple : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: sel ? _purple : _line),
                        ),
                        child: Text(c,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: sel ? Colors.white : _ink)),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                    border: Border.all(color: const Color(0xFFEDF0F2)),
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 90),
                    itemCount: list.length,
                    itemBuilder: (_, i) {
                      final m = list[i];
                      final sel = selectedMenu?.id == m.id;
                      return InkWell(
                        onTap: () => onSelect(m),
                        child: Container(
                          height: 77,
                          color: sel ? const Color(0xFFF6F0FF) : Colors.white,
                          padding: const EdgeInsets.only(left: 14, right: 4),
                          child: Row(
                            children: [
                              ClipRRect(borderRadius: BorderRadius.circular(10), child: _menuThumb(m.imageUrl, 52)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(m.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 14, fontWeight: FontWeight.bold, color: sel ? _orange : _ink)),
                                    const SizedBox(height: 4),
                                    Text.rich(
                                      TextSpan(children: [
                                        TextSpan(text: '${m.category} ・', style: const TextStyle(color: _sub)),
                                        TextSpan(
                                            text: ' ${_yen(m.price)}',
                                            style: const TextStyle(color: _red, fontWeight: FontWeight.bold)),
                                      ]),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 11.5),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert, size: 20, color: _hint),
                                color: Colors.white,
                                onSelected: (v) {
                                  if (v == 'edit') onEdit(m);
                                  if (v == 'delete') onDelete(m);
                                },
                                itemBuilder: (_) => const [
                                  PopupMenuItem(value: 'edit', child: Text('編集')),
                                  PopupMenuItem(value: 'delete', child: Text('削除', style: TextStyle(color: _red))),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            right: 16,
            bottom: 24,
            child: Material(
              color: _purple,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: onAdd,
                child: const SizedBox(
                  width: 118,
                  height: 52,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, size: 20, color: Colors.white),
                      SizedBox(width: 6),
                      Text('新規登録', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---- 共通部品(ボトムシート用) ----

Widget _sheetHeader(BuildContext context, String title) {
  return Column(
    children: [
      const SizedBox(height: 8),
      Container(
        width: 40,
        height: 5,
        decoration: BoxDecoration(color: const Color(0xFFD4D7DC), borderRadius: BorderRadius.circular(2.5)),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(30, 8, 10, 8),
        child: Row(
          children: [
            Expanded(child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: _ink))),
            InkWell(
              onTap: () => Navigator.pop(context),
              customBorder: const CircleBorder(),
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(color: Color(0xFFF1F3F5), shape: BoxShape.circle),
                child: const Icon(Icons.close, size: 20, color: _ink),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _label(String t) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(t, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: _sub)),
    );

InputDecoration _fieldDeco(String hint, {Widget? suffix}) => InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 14, color: _hint),
      filled: true,
      fillColor: _fieldBg,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 14),
      suffixIcon: suffix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _line)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _line)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _purple)),
    );

Widget _fakeField({required Widget child, VoidCallback? onTap, double? width}) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 44,
        width: width ?? double.infinity,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 13),
        decoration: BoxDecoration(
          color: _fieldBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _line),
        ),
        child: child,
      ),
    );

Widget _footer(BuildContext context, String okLabel, VoidCallback onOk) {
  return Container(
    decoration: const BoxDecoration(border: Border(top: BorderSide(color: _line))),
    padding: const EdgeInsets.fromLTRB(18, 11, 18, 18),
    child: Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: _line),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('キャンセル', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _ink)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: onOk,
              style: ElevatedButton.styleFrom(
                backgroundColor: _purple,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(okLabel, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ),
      ],
    ),
  );
}

Future<T?> _showSheet<T>(BuildContext context, Widget child, {double? heightFactor}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    barrierColor: const Color(0x7A121218),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (_) => child,
  );
}

// ---- メニュー編集 / 新規メニュー登録 ----

/// 保存したら true を返す。[menu]が null なら新規登録。
Future<bool?> showPhoneMenuEditSheet(
  BuildContext context, {
  MenuModel? menu,
  required List<String> categories,
  required List<IngredientModel> ingredients,
  required MenuService menuService,
}) {
  return _showSheet<bool>(
    context,
    _PhoneMenuEditSheet(menu: menu, categories: categories, ingredients: ingredients, menuService: menuService),
  );
}

class _IngRow {
  final String name;
  final String unit;
  final TextEditingController amount;
  _IngRow(this.name, this.unit, String a) : amount = TextEditingController(text: a);
}

class _PhoneMenuEditSheet extends StatefulWidget {
  final MenuModel? menu;
  final List<String> categories;
  final List<IngredientModel> ingredients;
  final MenuService menuService;
  const _PhoneMenuEditSheet({
    required this.menu,
    required this.categories,
    required this.ingredients,
    required this.menuService,
  });

  @override
  State<_PhoneMenuEditSheet> createState() => _PhoneMenuEditSheetState();
}

class _PhoneMenuEditSheetState extends State<_PhoneMenuEditSheet> {
  final _picker = ImagePicker();
  late final TextEditingController _name = TextEditingController(text: widget.menu?.name ?? '');
  late final TextEditingController _desc = TextEditingController(text: widget.menu?.description ?? '');
  late String _price = widget.menu?.price.toString() ?? '';
  late String _category = widget.menu != null && widget.categories.contains(widget.menu!.category)
      ? widget.menu!.category
      : widget.categories.first;
  late String _imageUrl = widget.menu?.imageUrl ?? '';
  Uint8List? _pendingBytes;
  final List<_IngRow> _rows = [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    widget.menu?.ingredients.forEach((name, value) {
      IngredientModel? master;
      for (final i in widget.ingredients) {
        if (i.name == name) master = i;
      }
      final m = RegExp(r'^\d+(?:\.\d+)?').firstMatch(value.trim());
      final unit = master?.unit ?? value.trim().replaceFirst(RegExp(r'^\d+(?:\.\d+)?\s*'), '');
      _rows.add(_IngRow(name, unit, m?.group(0) ?? ''));
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    for (final r in _rows) {
      r.amount.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    final bytes = await image.readAsBytes();
    setState(() {
      _pendingBytes = bytes;
      _imageUrl = '';
    });
  }

  Future<void> _addIngredient() async {
    final used = _rows.map((r) => r.name).toSet();
    final avail = widget.ingredients.where((i) => !used.contains(i.name)).toList();
    final sel = await showDialog<IngredientModel>(
      context: context,
      builder: (ctx) => SimpleDialog(
        backgroundColor: AppColors.popupBackground,
        title: const Text('食材を選択'),
        children: avail.isEmpty
            ? [const Padding(padding: EdgeInsets.all(16), child: Text('選択できる食材がありません。\n食材マスタに登録してください。'))]
            : avail
                .map((i) => SimpleDialogOption(onPressed: () => Navigator.pop(ctx, i), child: Text('${i.name}（${i.unit}）')))
                .toList(),
      ),
    );
    if (sel != null) setState(() => _rows.add(_IngRow(sel.name, sel.unit, '')));
  }

  Future<void> _save() async {
    if (_name.text.isEmpty || _price.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('商品名と価格を入力してください')));
      return;
    }
    if (_saving) return;
    setState(() => _saving = true);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final map = <String, String>{};
      for (final r in _rows) {
        final a = r.amount.text.trim();
        final v = a.isEmpty ? r.unit : '$a${r.unit}';
        if (v.isNotEmpty) map[r.name] = v;
      }
      final m = MenuModel(
        id: widget.menu?.id ?? '',
        name: _name.text,
        category: _category,
        price: int.tryParse(_price) ?? 0,
        description: _desc.text,
        imageUrl: _imageUrl,
        ingredients: map,
      );
      if (widget.menu == null) {
        await widget.menuService.createMenu(m, imageBytes: _pendingBytes);
      } else {
        await widget.menuService.updateMenu(m, imageBytes: _pendingBytes);
      }
      if (!mounted) return;
      navigator.pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text('保存に失敗しました: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.menu == null;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            _sheetHeader(context, isNew ? '新規メニュー登録' : 'メニュー編集'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: _pickImage,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(color: _thumbBg, borderRadius: BorderRadius.circular(10)),
                        child: _pendingBytes != null
                            ? Image.memory(_pendingBytes!, fit: BoxFit.cover)
                            : _imageUrl.isNotEmpty
                                ? _menuThumbFill(_imageUrl)
                                : const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_a_photo, size: 34, color: _thumbIcon),
                                      SizedBox(height: 30),
                                      Text('写真をアップロード', style: TextStyle(fontSize: 11.5, color: _thumbIcon)),
                                    ],
                                  ),
                      ),
                    ),
                    const SizedBox(height: 11),
                    _label('商品名'),
                    TextField(
                      controller: _name,
                      style: const TextStyle(fontSize: 14, color: _ink),
                      decoration: _fieldDeco('例：特製ステーキ弁当', suffix: const Icon(Icons.draw, size: 18, color: _sub)),
                    ),
                    const SizedBox(height: 11),
                    _label('カテゴリー'),
                    Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 13),
                      decoration: BoxDecoration(
                        color: _fieldBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _line),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _category,
                          isExpanded: true,
                          dropdownColor: Colors.white,
                          icon: const Icon(Icons.arrow_drop_down, size: 18, color: _sub),
                          style: const TextStyle(fontSize: 14, color: _ink),
                          items: widget.categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _category = v);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 11),
                    _label('価格（税込）'),
                    _fakeField(
                      onTap: () => showDialog(
                        context: context,
                        builder: (_) => KNumericInputDialog(
                          title: '価格の入力',
                          initialValue: _price,
                          emptyHint: '価格を入力してください',
                          unit: '円',
                          onConfirmed: (v) => setState(() => _price = v),
                        ),
                      ),
                      child: Text(
                        _price.isEmpty ? '例：1800' : _yen(int.tryParse(_price) ?? 0),
                        style: TextStyle(fontSize: 14, color: _price.isEmpty ? _hint : _ink),
                      ),
                    ),
                    const SizedBox(height: 11),
                    _label('食材・使用量'),
                    ..._rows.map((r) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 228,
                                child: _fakeField(
                                  child: Text(r.name,
                                      maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, color: _ink)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 90,
                                child: _fakeField(
                                  onTap: () => showDialog(
                                    context: context,
                                    builder: (_) => KNumericInputDialog(
                                      title: '${r.name}の使用量',
                                      initialValue: r.amount.text,
                                      unit: r.unit,
                                      maxLength: 6,
                                      onConfirmed: (v) => setState(() => r.amount.text = v),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: Text(r.amount.text.isEmpty ? '使用量' : r.amount.text,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(fontSize: 14, color: r.amount.text.isEmpty ? _hint : _ink)),
                                      ),
                                      if (r.amount.text.isNotEmpty) ...[
                                        const SizedBox(width: 6),
                                        Text(r.unit, style: const TextStyle(fontSize: 14, color: _sub)),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () => setState(() => _rows.remove(r)),
                                child: const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Icon(Icons.close, size: 20, color: _hint),
                                ),
                              ),
                            ],
                          ),
                        )),
                    InkWell(
                      onTap: _addIngredient,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add, size: 16, color: _orange),
                            SizedBox(width: 2),
                            Text('食材を追加', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _orange)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 11),
                    _label('説明'),
                    TextField(
                      controller: _desc,
                      maxLines: 3,
                      minLines: 1,
                      style: const TextStyle(fontSize: 14, color: _ink),
                      decoration: _fieldDeco('商品の説明を入力してください'),
                    ),
                  ],
                ),
              ),
            ),
            _footer(context, '保存', _save),
          ],
        ),
      ),
    );
  }

  Widget _menuThumbFill(String url) {
    final fallback = const Center(child: Icon(Icons.restaurant, size: 34, color: _thumbIcon));
    if (!url.startsWith('http') && !url.startsWith('assets/')) return fallback;
    final ImageProvider p = url.startsWith('http')
        ? NetworkImage(url, webHtmlElementStrategy: WebHtmlElementStrategy.fallback)
        : AssetImage(url);
    return Image(image: p, fit: BoxFit.cover, width: double.infinity, errorBuilder: (_, _, _) => fallback);
  }
}

// ---- メニュー削除ダイアログ ----

/// 「削除する」を押したら true
Future<bool?> showPhoneMenuDeleteDialog(BuildContext context, String menuName) {
  return showDialog<bool>(
    context: context,
    barrierColor: const Color(0x7A121218),
    builder: (ctx) => Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(color: Color(0xFFFFEBEE), shape: BoxShape.circle),
              child: const Icon(Icons.delete_outline, size: 28, color: _red),
            ),
            const SizedBox(height: 12),
            const Text('メニューの削除', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: _ink)),
            const SizedBox(height: 8),
            Text('$menuName を削除してもよろしいですか？\nこの操作は取り消せません。',
                textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, height: 1.6, color: _sub)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: _line),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('キャンセル', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _ink)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _red,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('削除する', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
