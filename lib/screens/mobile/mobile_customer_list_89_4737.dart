import 'package:flutter/material.dart';

import '../../models/customer_model.dart';

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
    this.actions = const [],
    this.onIconTap,
  });

  final VoidCallback? onIconTap;
  final IconData icon;
  final String title;
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
  const _Chip(
    this.label, {
    this.selected = false,
    this.purple = false,
    this.onTap,
  });

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
  static const _idx = [0, 1, 3, 6, 7];

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
                      onTap: () => onNavigate?.call(_idx[i]),
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

class MobileCustomerListData {
  const MobileCustomerListData({
    required this.isLoading,
    required this.customers,
    required this.elapsedDays,
    required this.sortKey,
    required this.sortAscending,
    required this.query,
    required this.onSort,
    required this.onSearch,
    required this.onShowDetail,
    required this.onDelete,
    required this.onGenerateDummy,
    required this.colleaguesOf,
    this.onOpenMenu,
    this.onNavigate,
  });

  final bool isLoading;
  final List<Customer> customers;
  final int? Function(Customer) elapsedDays;
  final String sortKey;
  final bool sortAscending;
  final String query;
  final void Function(String) onSort;
  final void Function(String) onSearch;
  final void Function(Customer) onShowDetail;
  final Future<void> Function(Customer) onDelete;
  final VoidCallback onGenerateDummy;
  final List<Customer> Function(Customer) colleaguesOf;
  final VoidCallback? onOpenMenu;
  final void Function(int)? onNavigate;
}

class MobileCustomerList894737 extends StatelessWidget {
  const MobileCustomerList894737(this.data, {super.key});

  final MobileCustomerListData data;

  static const _orangeDays = Color(0xFFF4511E);

  Color _daysColor(int? d) {
    if (d == null || d > 365) return _grey;
    return d <= 60 ? _blue : _orangeDays;
  }

  String _arrow(String key) =>
      data.sortKey == key ? (data.sortAscending ? '▴' : '▾') : '▾';

  void _showSearch(BuildContext context) {
    final ctrl = TextEditingController(text: data.query);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          18,
          12,
          18,
          16 + MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4D7DC),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: Text('名前・企業・電話番号で検索', style: _ts(17))),
                GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F3F5),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: _ic(Icons.close, 20, _ink),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onSubmitted: (v) {
                data.onSearch(v.trim());
                Navigator.pop(ctx);
              },
              style: _ts(14, w: FontWeight.w400),
              decoration: InputDecoration(
                hintText: 'タップして詳細を入力して下さい',
                hintStyle: _ts(14, w: FontWeight.w400, c: _grey),
                filled: true,
                fillColor: const Color(0xFFF6F7F9),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 13,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _line),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _purple),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      data.onSearch('');
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFFF6D00)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'クリア',
                          style: _ts(15, c: const Color(0xFFFF6D00)),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      data.onSearch(ctrl.text.trim());
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: _purple,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text('検索', style: _ts(15, c: Colors.white)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sheetBtn(
    BuildContext ctx,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) => InkWell(
    onTap: () {
      Navigator.pop(ctx);
      onTap();
    },
    child: SizedBox(
      height: 52,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ic(icon, 20, color),
          const SizedBox(width: 8),
          Text(
            label,
            style: _ts(15, w: FontWeight.w500, c: color),
          ),
        ],
      ),
    ),
  );

  void _showActionMenu(BuildContext context, Customer c) {
    final hasCompany = c.companyName.isNotEmpty;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        '${c.name} 様',
                        style: _ts(12, w: FontWeight.w500, c: _sub),
                      ),
                    ),
                    _sheetBtn(
                      ctx,
                      Icons.info,
                      '詳細',
                      _ink,
                      () => data.onShowDetail(c),
                    ),
                    if (hasCompany)
                      _sheetBtn(
                        ctx,
                        Icons.people_outline,
                        '所属顧客',
                        _ink,
                        () => _showBelonging(context, c),
                      ),
                    _sheetBtn(
                      ctx,
                      Icons.delete_outline,
                      '削除',
                      _red,
                      () => _showDelete(context, c),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      'キャンセル',
                      style: _ts(15, w: FontWeight.w500, c: _purple),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDelete(BuildContext context, Customer c) {
    showDialog<void>(
      context: context,
      barrierColor: const Color(0x7A121218),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(26),
                ),
                child: _ic(Icons.delete_outline, 26, const Color(0xFFF44336)),
              ),
              const SizedBox(height: 14),
              Text('顧客データの削除', style: _ts(17)),
              const SizedBox(height: 12),
              Text(
                '${c.name} 様のデータを削除してもよろしいですか？',
                textAlign: TextAlign.center,
                style: _ts(13, w: FontWeight.w400),
              ),
              const SizedBox(height: 6),
              Text(
                'この操作は取り消せません。',
                style: _ts(13, w: FontWeight.w400, c: _sub),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white,
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
                      onTap: () {
                        Navigator.pop(ctx);
                        data.onDelete(c);
                      },
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF44336),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text('削除する', style: _ts(14, c: Colors.white)),
                        ),
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

  void _showBelonging(BuildContext context, Customer c) {
    final list = data.colleaguesOf(c);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.7,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4D7DC),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text('「${c.companyName}」の登録顧客', style: _ts(17)),
                const SizedBox(height: 8),
                Flexible(
                  child: list.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              '他の登録顧客はいません',
                              style: _ts(13, w: FontWeight.w400, c: _sub),
                            ),
                          ),
                        )
                      : ListView(
                          shrinkWrap: true,
                          children: [
                            for (final e in list)
                              InkWell(
                                onTap: () {
                                  Navigator.pop(ctx);
                                  data.onShowDetail(e);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 38,
                                        height: 38,
                                        decoration: BoxDecoration(
                                          color: _purpleTint,
                                          borderRadius: BorderRadius.circular(
                                            19,
                                          ),
                                        ),
                                        child: Center(
                                          child: _ic(Icons.person, 20, _purple),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('${e.name} 様', style: _ts(14)),
                                            Text(
                                              e.phoneNumber,
                                              style: _ts(
                                                11.5,
                                                w: FontWeight.w400,
                                                c: _sub,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: _line),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(child: Text('閉じる', style: _ts(15))),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rows = data.customers;
    return Scaffold(
      backgroundColor: _bg,
      bottomNavigationBar: _BottomNav(3, onNavigate: data.onNavigate),
      body: Column(
        children: [
          const _StatusBar(),
          _TopBar(
            icon: Icons.menu,
            title: '顧客管理',
            onIconTap: data.onOpenMenu,
            actions: [
              GestureDetector(
                onTap: data.onGenerateDummy,
                child: _ic(Icons.auto_awesome, 20, _ink),
              ),
              const SizedBox(width: 26),
              GestureDetector(
                onTap: () => _showSearch(context),
                child: _ic(
                  Icons.search,
                  20,
                  data.query.isEmpty ? _ink : _purple,
                ),
              ),
            ],
          ),
          Expanded(
            child: data.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                        child: Row(
                          children: [
                            _Chip(
                              '氏名順 ${_arrow('name')}',
                              selected: data.sortKey == 'name',
                              onTap: () => data.onSort('name'),
                            ),
                            const SizedBox(width: 6),
                            _Chip(
                              '企業名 ${_arrow('company')}',
                              selected: data.sortKey == 'company',
                              onTap: () => data.onSort('company'),
                            ),
                            const SizedBox(width: 6),
                            _Chip(
                              '前回経過日 ${_arrow('elapsed')}',
                              selected: data.sortKey == 'elapsed',
                              onTap: () => data.onSort('elapsed'),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(14, 10, 14, 16),
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: _cardLine),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: rows.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(32),
                                child: Center(
                                  child: Text(
                                    '顧客が見つかりません',
                                    style: _ts(13, w: FontWeight.w400, c: _sub),
                                  ),
                                ),
                              )
                            : Column(
                                children: [
                                  for (final c in rows) _row(context, c),
                                ],
                              ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, Customer c) {
    final d = data.elapsedDays(c);
    return InkWell(
      onTap: () => data.onShowDetail(c),
      child: Container(
        height: 64,
        padding: const EdgeInsets.only(left: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _purpleTint,
                borderRadius: BorderRadius.circular(19),
              ),
              child: Center(child: _ic(Icons.person, 20, _purple)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${c.name} 様',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _ts(14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    c.companyName.isEmpty ? '個人宅' : c.companyName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _ts(11.5, w: FontWeight.w400, c: _sub),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  d == null ? '—' : '$d日',
                  style: _ts(16, w: FontWeight.w900, c: _daysColor(d)),
                ),
                Text(
                  '前回から',
                  style: _ts(10, w: FontWeight.w400, c: _sub),
                ),
              ],
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _showActionMenu(context, c),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 16,
                ),
                child: _ic(Icons.more_vert, 20, _grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
