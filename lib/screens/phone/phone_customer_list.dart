import 'package:flutter/material.dart';
import '../../models/customer_model.dart';
import '../../widgets/k_pen_input_dialog.dart';
import '../../utils/name_format.dart';
import 'phone_common.dart';
import 'phone_customer_style.dart';

/// 顧客管理（スマホ版）の一覧。並び替えチップ＋カード一覧。
/// 実データ・並び替え・検索は親（CustomerListScreen）が持ち、ここは表示と操作の通知だけを行う。
class PhoneCustomerList extends StatelessWidget {
  final List<Customer> customers;
  final int? Function(Customer) elapsedDays;
  final String? selectedId;
  final String sortKey; // 'name' | 'company' | 'elapsed'
  final bool sortAscending;
  final String searchText;
  final ValueChanged<String> onSort;
  final VoidCallback onSearch;
  final VoidCallback onClearSearch;
  final VoidCallback onGenerateDummy;
  final ValueChanged<Customer> onTap;
  final ValueChanged<Customer> onMenu;

  const PhoneCustomerList({
    super.key,
    required this.customers,
    required this.elapsedDays,
    required this.selectedId,
    required this.sortKey,
    required this.sortAscending,
    required this.searchText,
    required this.onSort,
    required this.onSearch,
    required this.onClearSearch,
    required this.onGenerateDummy,
    required this.onTap,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: PcColors.bg,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
            child: Row(
              children: [
                _chip('氏名順', 'name'),
                const SizedBox(width: 6),
                _chip('企業名', 'company'),
                const SizedBox(width: 7),
                _chip('前回経過日', 'elapsed'),
                const Spacer(),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.auto_awesome, size: 20, color: PcColors.text),
                  tooltip: 'ダミーデータを生成',
                  onPressed: onGenerateDummy,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
            child: InkWell(
              onTap: onSearch,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: PcColors.line),
                ),
                child: Row(children: [
                  const Icon(Icons.search, size: 18, color: PcColors.sub),
                  const SizedBox(width: 8),
                  Expanded(child: Text(searchText.isEmpty ? '顧客名・電話番号で検索' : searchText, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: searchText.isEmpty ? PcColors.sub : PcColors.text))),
                ]),
              ),
            ),
          ),
          if (searchText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 16, color: PcColors.sub),
                  const SizedBox(width: 4),
                  Expanded(child: Text('「$searchText」で検索中', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: PcColors.sub))),
                  GestureDetector(onTap: onClearSearch, child: const Icon(Icons.close, size: 16, color: PcColors.sub)),
                ],
              ),
            ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(14, 0, 14, 0),
              child: customers.isEmpty
                  ? const Center(child: Text('顧客が見つかりません', style: TextStyle(color: PcColors.hint)))
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 4, bottom: 12),
                      itemCount: customers.length,
                      itemBuilder: (_, i) => _row(customers[i]),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, String key) {
    final active = sortKey == key;
    final arrow = active && !sortAscending ? '▴' : '▾';
    return GestureDetector(
      onTap: () => onSort(key),
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? PcColors.purple : Colors.white,
          border: Border.all(color: active ? PcColors.purple : PcColors.line),
          borderRadius: BorderRadius.circular(17),
        ),
        child: Text('$label $arrow', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: active ? Colors.white : PcColors.text)),
      ),
    );
  }

  Widget _row(Customer c) {
    final selected = c.id == selectedId;
    final days = elapsedDays(c);
    final Color dayColor = days == null ? PcColors.hint : (days <= 60 ? PcColors.blue : (days <= 365 ? PcColors.redOrange : PcColors.hint));
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: selected ? PcColors.purpleRow : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x1F1B1B2F), blurRadius: 14, offset: Offset(0, 4))],
      ),
      child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onTap(c),
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              const SizedBox(width: 14),
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(color: PcColors.purpleSoft, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(c.name.trim().isEmpty ? '?' : c.name.trim().substring(0, 1), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: PcColors.purple)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(withHonorific(c.name), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: selected ? PcColors.purple : PcColors.text)),
                    const SizedBox(height: 2),
                    Text(c.companyName.isEmpty ? '個人宅' : c.companyName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5, color: PcColors.sub)),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: PcColors.chipOff, borderRadius: BorderRadius.circular(6)),
                child: Text(c.companyName.isEmpty ? '個人' : '法人', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: PcColors.text)),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(days == null ? '—' : '$days日', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: dayColor)),
                  const Text('前回から', style: TextStyle(fontSize: 10, color: PcColors.sub)),
                ],
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onMenu(c),
                child: const Padding(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16), child: Icon(Icons.more_vert, size: 20, color: PcColors.hint)),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

/// 最近の検索語（アプリ起動中のみ保持。新しい順に3件）
final List<String> _recentSearches = [];

/// 「名前・企業・電話番号で検索」シート。確定した語を返す（クリア→空文字、閉じる→null）。
Future<String?> showPhoneCustomerSearchSheet(BuildContext context, String current) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SearchSheet(current: current),
  );
}

class _SearchSheet extends StatefulWidget {
  final String current;
  const _SearchSheet({required this.current});
  @override
  State<_SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends State<_SearchSheet> {
  late final TextEditingController _c = TextEditingController(text: widget.current);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _submit() {
    final t = _c.text.trim();
    if (t.isNotEmpty) {
      _recentSearches.remove(t);
      _recentSearches.insert(0, t);
      if (_recentSearches.length > 3) _recentSearches.removeLast();
    }
    Navigator.pop(context, t);
  }

  Future<void> _pen() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => KPenInputDialog(initialText: _c.text, onTextRecognized: (t) => setState(() => _c.text = t.trim())),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: PcSheet(
        title: '名前・企業・電話番号で検索',
        footer: Row(
          children: [
            Expanded(child: PcOutlineButton(label: 'クリア', color: PcColors.orange, border: PcColors.orange, onTap: () => Navigator.pop(context, ''))),
            const SizedBox(width: 10),
            Expanded(child: PcButton(label: '検索', onTap: _submit)),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 44,
                padding: const EdgeInsets.only(left: 13, right: 4),
                decoration: BoxDecoration(color: PcColors.field, border: Border.all(color: PcColors.line), borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _c,
                        autofocus: false,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => _submit(),
                        style: const TextStyle(fontSize: 14, color: PcColors.text),
                        decoration: const InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          hintText: 'タップして詳細を入力して下さい',
                          hintStyle: TextStyle(fontSize: 14, color: PcColors.hint),
                        ),
                      ),
                    ),
                    IconButton(visualDensity: VisualDensity.compact, icon: const Icon(Icons.draw, size: 18, color: PcColors.sub), onPressed: _pen),
                  ],
                ),
              ),
              if (_recentSearches.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  children: [
                    const Icon(Icons.history, size: 14, color: PcColors.sub),
                    const Text('最近の検索：', style: TextStyle(fontSize: 11.5, color: PcColors.sub)),
                    for (var i = 0; i < _recentSearches.length; i++) ...[
                      GestureDetector(
                        onTap: () => setState(() => _c.text = _recentSearches[i]),
                        child: Text(_recentSearches[i], style: const TextStyle(fontSize: 11.5, color: PcColors.sub)),
                      ),
                      if (i != _recentSearches.length - 1) const Text('／', style: TextStyle(fontSize: 11.5, color: PcColors.sub)),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// カードの「︙」メニュー。'detail' / 'delete' / null(キャンセル)
Future<String?> showPhoneCustomerMenu(BuildContext context, Customer c) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: [
                  Text(withHonorific(c.name), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: PcColors.sub)),
                  const SizedBox(height: 8),
                  _menuRow(ctx, Icons.info, '詳細', PcColors.text, 'detail'),
                  _menuRow(ctx, Icons.delete_outline, '削除', PcColors.red, 'delete'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Navigator.pop(ctx),
                child: const SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: Center(child: Text('キャンセル', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: PcColors.purple))),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _menuRow(BuildContext ctx, IconData icon, String label, Color color, String value) {
  return InkWell(
    onTap: () => Navigator.pop(ctx, value),
    child: SizedBox(
      height: 52,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: color)),
        ],
      ),
    ),
  );
}

/// 「顧客データの削除」確認。削除する→true
Future<bool> showPhoneDeleteCustomerDialog(BuildContext context, Customer c) async {
  final r = await showDialog<bool>(
    context: context,
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
              decoration: const BoxDecoration(color: Color(0xFFFFEBEE), shape: BoxShape.circle),
              child: const Icon(Icons.delete_outline, size: 28, color: PcColors.red),
            ),
            const SizedBox(height: 14),
            const Text('顧客データの削除', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: PcColors.text)),
            const SizedBox(height: 10),
            Text('${withHonorific(c.name)}のデータを削除してもよろしいですか？', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: PcColors.sub)),
            const SizedBox(height: 14),
            const Text('この操作は取り消せません。', style: TextStyle(fontSize: 13, color: PcColors.sub)),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(child: PcOutlineButton(label: 'キャンセル', onTap: () => Navigator.pop(ctx, false))),
                const SizedBox(width: 10),
                Expanded(child: PcButton(label: '削除する', fill: PcColors.red, onTap: () => Navigator.pop(ctx, true))),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  return r == true;
}

/// 「所属顧客一覧」シート。行をタップ→その顧客を返す。電話アイコンで発信。
Future<Customer?> showPhoneColleaguesSheet(BuildContext context, String companyName, List<Customer> colleagues) {
  return showModalBottomSheet<Customer>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.7),
      child: PcSheet(
        title: '「$companyName」の登録顧客',
        footer: PcOutlineButton(label: '閉じる', onTap: () => Navigator.pop(ctx)),
        child: colleagues.isEmpty
            ? const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('他の登録顧客はいません', style: TextStyle(color: PcColors.hint))))
            : Container(
                margin: const EdgeInsets.fromLTRB(18, 4, 18, 12),
                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: PcColors.line2), borderRadius: BorderRadius.circular(14)),
                clipBehavior: Clip.antiAlias,
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: colleagues.length,
                  itemBuilder: (_, i) {
                    final c = colleagues[i];
                    return InkWell(
                      onTap: () => Navigator.pop(ctx, c),
                      child: SizedBox(
                        height: 63,
                        child: Row(
                          children: [
                            const SizedBox(width: 14),
                            Container(
                              width: 38,
                              height: 38,
                              decoration: const BoxDecoration(color: PcColors.purpleSoft, shape: BoxShape.circle),
                              child: const Icon(Icons.person, size: 20, color: PcColors.purple),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(withHonorific(c.name), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: PcColors.text)),
                                  const SizedBox(height: 2),
                                  Text(c.phoneNumber, style: const TextStyle(fontSize: 11.5, color: PcColors.sub)),
                                ],
                              ),
                            ),
                            IconButton(icon: const Icon(Icons.call, size: 20, color: PcColors.purple), onPressed: () => callPhone(c.phoneNumber)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    ),
  );
}
