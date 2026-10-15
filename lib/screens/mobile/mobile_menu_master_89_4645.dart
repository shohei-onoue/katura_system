import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../models/menu_model.dart';

const _bg = Color(0xFFF3F7F6);
const _ink = Color(0xFF1D1B20);
const _sub = Color(0xFF6B6F76);
const _purple = Color(0xFF673AB7);
const _purpleTint = Color(0xFFEDE7F6);
const _line = Color(0xFFE4E7EB);
const _cardLine = Color(0xFFEDF0F2);
const _lime = Color(0xFFDAFFAF);
const _limeLine = Color(0xFFB9EA80);
const _limeText = Color(0xFF1D3B00);
const _grey = Color(0xFF9AA0A6);
const _red = Color(0xFFE53935);
const _blue = Color(0xFF1E88E5);

TextStyle _ts(
  double size, {
  FontWeight w = FontWeight.w700,
  Color c = _ink,
  double? ls,
}) => TextStyle(
  fontSize: size,
  fontWeight: w,
  color: c,
  letterSpacing: ls,
  height: 1.3,
  decoration: TextDecoration.none,
);

Icon _ic(IconData d, double s, Color c) => Icon(d, size: s, color: c);

class _StatusBar extends StatelessWidget {
  const _StatusBar();

  @override
  Widget build(BuildContext context) => Container(
    height: 44,
    color: Colors.white,
    padding: const EdgeInsets.only(left: 30, right: 26),
    child: Row(
      children: [
        Text('9:41', style: _ts(15)),
        const Spacer(),
        _ic(Icons.signal_cellular_alt, 17, _ink),
        const SizedBox(width: 5),
        _ic(Icons.wifi, 17, _ink),
        const SizedBox(width: 5),
        _ic(Icons.battery_full, 17, _ink),
      ],
    ),
  );
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.icon,
    required this.title,
    this.onIconTap,
    this.actions = const [],
  });

  final IconData icon;
  final String title;
  final VoidCallback? onIconTap;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => Container(
    height: 52,
    color: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onIconTap,
          child: _ic(icon, 20, _ink),
        ),
        const SizedBox(width: 16),
        Text(title, style: _ts(18)),
        const Spacer(),
        ...actions,
      ],
    ),
  );
}

class _Chip extends StatelessWidget {
  const _Chip(this.label, {this.selected = false, this.purple = false, this.onTap});

  final VoidCallback? onTap;

  final String label;
  final bool selected;
  final bool purple;

  @override
  Widget build(BuildContext context) {
    final Color bg = selected ? (purple ? _purple : _lime) : Colors.white;
    final Color border = selected ? (purple ? _purple : _limeLine) : _line;
    final Color fg = selected ? (purple ? Colors.white : _limeText) : _ink;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        widthFactor: 1,
        child: Text(label, style: _ts(13, c: fg)),
      ),
    ),
    );
  }
}

class _HomeBar extends StatelessWidget {
  const _HomeBar();

  @override
  Widget build(BuildContext context) => Container(
    width: 134,
    height: 5,
    decoration: BoxDecoration(
      color: const Color(0xFF111111),
      borderRadius: BorderRadius.circular(2.5),
    ),
  );
}

class _BottomNav extends StatelessWidget {
  const _BottomNav(this.selected, {this.onNavigate});

  final int selected;
  final void Function(int)? onNavigate;
  static const _targets = [0, 1, 3, 6, 7];

  static const _icons = [
    Icons.post_add,
    Icons.list_alt,
    Icons.local_shipping,
    Icons.people,
    Icons.apps,
  ];
  static const _labels = ['受注入力', '受注一覧', '配送予定', '顧客', 'メニュー'];

  @override
  Widget build(BuildContext context) => Container(
    height: 82,
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: _line)),
    ),
    child: Stack(
      children: [
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 6, 4, 0),
            child: Row(
              children: [
                for (int i = 0; i < 5; i++)
                  Expanded(
                    child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onNavigate?.call(_targets[i]),
                    child: Column(
                      children: [
                        Container(
                          width: 56,
                          height: 30,
                          decoration: i == selected
                              ? BoxDecoration(
                                  color: _purpleTint,
                                  borderRadius: BorderRadius.circular(15),
                                )
                              : null,
                          child: Center(
                            child: _ic(
                              _icons[i],
                              20,
                              i == selected ? _purple : _sub,
                            ),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _labels[i],
                          style: _ts(
                            10.5,
                            w: i == selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            c: i == selected ? _purple : _sub,
                          ),
                        ),
                      ],
                    ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const Positioned(
          left: 0,
          right: 0,
          bottom: 8,
          child: Center(child: _HomeBar()),
        ),
      ],
    ),
  );
}


typedef MobileNumberInput = Future<String?> Function(
  String title,
  String initial,
  String unit,
);

/// 食材行（編集シート用）
class MobileMenuIngredientRow {
  MobileMenuIngredientRow({
    required this.name,
    required this.unit,
    this.amount = '',
  });
  final String name;
  final String unit;
  String amount;
}

/// 編集シートの保存内容
class MobileMenuEditResult {
  const MobileMenuEditResult({
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.imageBytes,
    required this.rows,
  });
  final String name;
  final String category;
  final String price;
  final String description;
  final String imageUrl;
  final Uint8List? imageBytes;
  final List<MobileMenuIngredientRow> rows;
}

class MobileMenuMasterData {
  const MobileMenuMasterData({
    required this.isLoading,
    required this.menus,
    required this.categories,
    required this.selectedCategory,
    required this.selectedMenuId,
    required this.imageBuilder,
    required this.onSelectCategory,
    required this.onSelectMenu,
    required this.onNew,
    required this.onEdit,
    required this.onDelete,
    required this.onSeed,
    this.onOpenMenu,
    this.onNavigate,
  });

  final bool isLoading;
  final List<MenuModel> menus; // カテゴリで絞り込み済み
  final List<String> categories; // 「すべて」を含む
  final String selectedCategory;
  final String? selectedMenuId;
  final Widget Function(String url, double size) imageBuilder;
  final void Function(String) onSelectCategory;
  final void Function(MenuModel) onSelectMenu;
  final VoidCallback onNew;
  final void Function(MenuModel) onEdit;
  final void Function(MenuModel) onDelete;
  final VoidCallback onSeed;
  final VoidCallback? onOpenMenu;
  final void Function(int)? onNavigate;
}

/// メニュー編集・新規登録の下からシート
class MobileMenuEditSheet extends StatefulWidget {
  const MobileMenuEditSheet({
    super.key,
    required this.title,
    required this.categories,
    required this.initialName,
    required this.initialCategory,
    required this.initialPrice,
    required this.initialDescription,
    required this.initialImageUrl,
    required this.initialRows,
    required this.imageBuilder,
    required this.pickImage,
    required this.pickIngredient,
    required this.inputNumber,
    required this.onSave,
  });

  final String title;
  final List<String> categories;
  final String initialName;
  final String initialCategory;
  final String initialPrice;
  final String initialDescription;
  final String initialImageUrl;
  final List<MobileMenuIngredientRow> initialRows;
  final Widget Function(String url, double size) imageBuilder;
  final Future<Uint8List?> Function() pickImage;
  final Future<MobileMenuIngredientRow?> Function(Set<String> exclude)
  pickIngredient;
  final MobileNumberInput inputNumber;

  /// 戻り値: エラー文言(成功時null)
  final Future<String?> Function(MobileMenuEditResult) onSave;

  @override
  State<MobileMenuEditSheet> createState() => _MobileMenuEditSheetState();
}

class _MobileMenuEditSheetState extends State<MobileMenuEditSheet> {
  late final TextEditingController _name = TextEditingController(
    text: widget.initialName,
  );
  late final TextEditingController _desc = TextEditingController(
    text: widget.initialDescription,
  );
  late String _category = widget.categories.contains(widget.initialCategory)
      ? widget.initialCategory
      : widget.categories.first;
  late String _price = widget.initialPrice;
  late String _imageUrl = widget.initialImageUrl;
  late final List<MobileMenuIngredientRow> _rows = [...widget.initialRows];
  Uint8List? _bytes;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    super.dispose();
  }

  Widget _label(String s) => Padding(
    padding: const EdgeInsets.only(top: 11, bottom: 5),
    child: Text(s, style: _ts(11.5, c: _sub)),
  );

  BoxDecoration get _fieldDeco => BoxDecoration(
    color: const Color(0xFFF6F7F9),
    border: Border.all(color: _line),
    borderRadius: BorderRadius.circular(10),
  );

  Widget _tapField(String text, {bool hint = false, Widget? trailing, VoidCallback? onTap}) =>
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 13),
          decoration: _fieldDeco,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  overflow: TextOverflow.ellipsis,
                  style: _ts(14, w: FontWeight.w400, c: hint ? _grey : _ink),
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      );

  Widget _textField(TextEditingController c, {String? hint, int maxLines = 1}) =>
      Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 13),
        decoration: _fieldDeco,
        child: TextField(
          controller: c,
          maxLines: maxLines,
          minLines: 1,
          style: _ts(14, w: FontWeight.w400),
          decoration: InputDecoration(
            border: InputBorder.none,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 13),
            hintText: hint,
            hintStyle: _ts(14, w: FontWeight.w400, c: _grey),
          ),
        ),
      );

  Future<void> _pickCategory() async {
    final v = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final c in widget.categories)
              ListTile(
                title: Text(c, style: _ts(14)),
                trailing: c == _category ? _ic(Icons.check, 20, _purple) : null,
                onTap: () => Navigator.pop(ctx, c),
              ),
          ],
        ),
      ),
    );
    if (v != null) setState(() => _category = v);
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty || _price.isEmpty) {
      setState(() => _error = '商品名と価格を入力してください');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final err = await widget.onSave(
      MobileMenuEditResult(
        name: _name.text,
        category: _category,
        price: _price,
        description: _desc.text,
        imageUrl: _imageUrl,
        imageBytes: _bytes,
        rows: _rows,
      ),
    );
    if (!mounted) return;
    if (err == null) {
      Navigator.pop(context);
    } else {
      setState(() {
        _saving = false;
        _error = err;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(top: 44, bottom: bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFD4D7DC),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 8, 10, 6),
              child: Row(
                children: [
                  Text(widget.title, style: _ts(17)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F3F5),
                        shape: BoxShape.circle,
                      ),
                      child: Center(child: _ic(Icons.close, 20, _ink)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 16),
                children: [
                  GestureDetector(
                    onTap: () async {
                      final b = await widget.pickImage();
                      if (b != null) {
                        setState(() {
                          _bytes = b;
                          _imageUrl = '';
                        });
                      }
                    },
                    child: Container(
                      height: 150,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF0F2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: _bytes != null
                          ? Image.memory(_bytes!, fit: BoxFit.cover, width: double.infinity)
                          : _imageUrl.isNotEmpty
                          ? SizedBox.expand(child: widget.imageBuilder(_imageUrl, 150))
                          : Center(
                              child: _ic(Icons.restaurant, 34, const Color(0xFFB5BAC0)),
                            ),
                    ),
                  ),
                  _label('商品名'),
                  _textField(_name),
                  _label('カテゴリー'),
                  _tapField(
                    _category,
                    trailing: _ic(Icons.arrow_drop_down, 18, _sub),
                    onTap: _pickCategory,
                  ),
                  _label('価格（税込）'),
                  _tapField(
                    _price.isEmpty ? '例：1800' : '¥$_price',
                    hint: _price.isEmpty,
                    onTap: () async {
                      final v = await widget.inputNumber('価格の入力', _price, '円');
                      if (v != null) setState(() => _price = v);
                    },
                  ),
                  _label('食材・使用量'),
                  for (final row in _rows)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Container(
                              height: 44,
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.symmetric(horizontal: 13),
                              decoration: _fieldDeco,
                              child: Text(
                                row.name,
                                overflow: TextOverflow.ellipsis,
                                style: _ts(14, w: FontWeight.w400),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 3,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () async {
                                final v = await widget.inputNumber(
                                  '${row.name}の使用量',
                                  row.amount,
                                  row.unit,
                                );
                                if (v != null) setState(() => row.amount = v);
                              },
                              child: Container(
                                height: 44,
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: _fieldDeco,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        row.amount.isEmpty ? '使用量' : row.amount,
                                        overflow: TextOverflow.ellipsis,
                                        style: _ts(
                                          14,
                                          w: FontWeight.w400,
                                          c: row.amount.isEmpty ? _grey : _ink,
                                        ),
                                      ),
                                    ),
                                    Text(row.unit, style: _ts(14, w: FontWeight.w400, c: _sub)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => setState(() => _rows.remove(row)),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: _ic(Icons.close, 20, _grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () async {
                      final r = await widget.pickIngredient(
                        _rows.map((e) => e.name).toSet(),
                      );
                      if (r != null) setState(() => _rows.add(r));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          _ic(Icons.add, 18, _purple),
                          const SizedBox(width: 4),
                          Text('食材を追加', style: _ts(13, c: _purple)),
                        ],
                      ),
                    ),
                  ),
                  _label('説明'),
                  _textField(_desc, hint: '商品の説明を入力してください', maxLines: 4),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(_error!, style: _ts(12, c: _red)),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(18, 11, 18, 22),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: _line)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _saving ? null : () => Navigator.pop(context),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: _line),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(child: Text('キャンセル', style: _ts(15))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: _saving ? null : _save,
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: _purple,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: _saving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : Text('保存', style: _ts(15, c: Colors.white)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 削除確認ダイアログ（Figma 89:2057）
Future<bool> showMobileMenuDeleteDialog(BuildContext context, String name) async {
  final r = await showDialog<bool>(
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
              decoration: const BoxDecoration(
                color: Color(0xFFFFEBEE),
                shape: BoxShape.circle,
              ),
              child: Center(child: _ic(Icons.delete_outline, 28, _red)),
            ),
            const SizedBox(height: 12),
            Text('メニューの削除', style: _ts(17)),
            const SizedBox(height: 10),
            Text(
              '$nameを削除してもよろしいですか？\nこの操作は取り消せません。',
              textAlign: TextAlign.center,
              style: _ts(13, w: FontWeight.w400, c: _sub),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(ctx, false),
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        border: Border.all(color: _line),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(child: Text('キャンセル', style: _ts(14))),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(ctx, true),
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF44336),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(child: Text('削除する', style: _ts(14, c: Colors.white))),
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
  return r == true;
}

String _yen(int v) => '¥${v.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')}';

class MobileMenuMaster894645 extends StatelessWidget {
  const MobileMenuMaster894645(this.data, {super.key});

  final MobileMenuMasterData data;

  Widget _list() {
    if (data.menus.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ic(Icons.restaurant_menu, 56, const Color(0xFFB5BAC0)),
            const SizedBox(height: 12),
            Text('メニューがありません', style: _ts(14, c: _sub)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: data.onSeed,
              child: Text('初期データを登録する', style: _ts(13, c: _purple)),
            ),
          ],
        ),
      );
    }
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(14, 10, 14, 16),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: _cardLine),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              for (final m in data.menus)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => data.onSelectMenu(m),
                  child: Container(
                    height: 77,
                    color: m.id == data.selectedMenuId
                        ? const Color(0xFFF6F0FF)
                        : Colors.white,
                    padding: const EdgeInsets.only(left: 14, right: 4),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 52,
                            height: 52,
                            child: data.imageBuilder(m.imageUrl, 52),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                m.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: _ts(
                                  14,
                                  c: m.id == data.selectedMenuId
                                      ? const Color(0xFFFF6D00)
                                      : _ink,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '${m.category} ・ ',
                                      style: _ts(11.5, w: FontWeight.w400, c: _sub),
                                    ),
                                    TextSpan(
                                      text: _yen(m.price),
                                      style: _ts(11.5, c: const Color(0xFFF44336)),
                                    ),
                                  ],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          color: Colors.white,
                          icon: _ic(Icons.more_vert, 20, _grey),
                          onSelected: (v) {
                            if (v == 'edit') data.onEdit(m);
                            if (v == 'delete') data.onDelete(m);
                          },
                          itemBuilder: (_) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  _ic(Icons.edit, 18, _blue),
                                  const SizedBox(width: 10),
                                  Text('編集', style: _ts(13)),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  _ic(Icons.delete_outline, 18, _red),
                                  const SizedBox(width: 10),
                                  Text('削除', style: _ts(13, c: _red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _bg,
    bottomNavigationBar: _BottomNav(4, onNavigate: data.onNavigate),
    body: Column(
      children: [
        const _StatusBar(),
        _TopBar(
          icon: Icons.menu,
          onIconTap: data.onOpenMenu,
          title: 'メニューマスタ',
          actions: [_ic(Icons.search, 20, _ink)],
        ),
        Container(
          height: 50,
          color: Colors.white,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
            children: [
              for (final c in data.categories) ...[
                _Chip(
                  c,
                  selected: c == data.selectedCategory,
                  purple: c == 'すべて',
                  onTap: () => data.onSelectCategory(c),
                ),
                const SizedBox(width: 6),
              ],
            ],
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              data.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _list(),
              Positioned(
                right: 16,
                bottom: 16,
                child: GestureDetector(
                  onTap: data.onNew,
                  child: Container(
                    width: 118,
                    height: 52,
                    decoration: BoxDecoration(
                      color: _purple,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ic(Icons.add, 20, Colors.white),
                        const SizedBox(width: 6),
                        Text('新規登録', style: _ts(14, c: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
