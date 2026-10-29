import 'package:flutter/material.dart';
import '../../../models/customer_model.dart';
import '../../../utils/name_format.dart';
import '../phone_common.dart';
import 'landscape_style.dart';

/// 顧客（スマホ横向き, Figma 168:361）: 左=検索+並び替え+一覧(幅390) / 右=選択中顧客の詳細。
/// データ・操作は親(CustomerListScreen)が持ち、ここは表示と通知だけ行う。
class LandscapeCustomerView extends StatelessWidget {
  final List<Customer> customers;
  final int? Function(Customer) elapsedDays;
  final Customer? selected;
  final String sortKey;
  final bool sortAscending;
  final String searchText;
  final ValueChanged<String> onSort;
  final VoidCallback onSearch;
  final VoidCallback onClearSearch;
  final ValueChanged<Customer> onTap;
  final ValueChanged<Customer> onLongPress;
  final Set<String> checkedIds;
  final VoidCallback onCancelSelect;
  final VoidCallback onDeleteChecked;
  final ValueChanged<Customer> onDetail;
  final ValueChanged<Customer> onDelete;
  final VoidCallback onSelectAll;
  final VoidCallback onNewOrder;

  const LandscapeCustomerView({
    super.key,
    required this.customers,
    required this.elapsedDays,
    required this.selected,
    required this.sortKey,
    required this.sortAscending,
    required this.searchText,
    required this.onSort,
    required this.onSearch,
    required this.onClearSearch,
    required this.onTap,
    required this.onLongPress,
    required this.checkedIds,
    required this.onCancelSelect,
    required this.onDeleteChecked,
    required this.onDetail,
    required this.onDelete,
    required this.onSelectAll,
    required this.onNewOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: LS.bg,
      child: Column(
        children: [
          SizedBox(
            height: LS.headerH,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: LS.pad),
              child: Row(children: [
                const Expanded(child: Text('顧客', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: LS.text))),
                if (checkedIds.isNotEmpty) ...[
                  Text('${checkedIds.length}件選択', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: LS.text)),
                  const SizedBox(width: 8),
                  _smallBtn('全選択', LS.primary, Colors.white, onSelectAll, border: true),
                  const SizedBox(width: 8),
                  _smallBtn('解除', LS.primary, Colors.white, onCancelSelect, border: true),
                  const SizedBox(width: 8),
                  _smallBtn('削除', Colors.white, LS.red, onDeleteChecked),
                ],
              ]),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(LS.pad, 0, LS.pad, LS.gap),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(width: 390, child: _left()),
                  const SizedBox(width: LS.gap),
                  Expanded(child: _detail(context)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallBtn(String label, Color fg, Color bg, VoidCallback onTap, {bool border = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: border ? Colors.white : fg, borderRadius: BorderRadius.circular(12), border: border ? Border.all(color: LS.primary, width: 2) : null),
        child: Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: border ? LS.primary : bg)),
      ),
    );
  }

  Widget _left() {
    return Column(
      children: [
        InkWell(
          onTap: onSearch,
          borderRadius: BorderRadius.circular(LS.btnRadius),
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(LS.btnRadius), border: Border.all(color: LS.borderStrong)),
            child: Row(children: [
              const Icon(Icons.search, size: 28, color: LS.text),
              const SizedBox(width: 10),
              Expanded(child: Text(searchText.isEmpty ? '名前・電話で探す' : searchText, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 18, color: searchText.isEmpty ? LS.hint : LS.text))),
              if (searchText.isNotEmpty) GestureDetector(onTap: onClearSearch, child: const Icon(Icons.close, size: 24, color: LS.textSub)),
            ]),
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            _chip('氏名順', 'name'),
            const SizedBox(width: 6),
            _chip('企業名', 'company'),
            const SizedBox(width: 6),
            _chip('経過日', 'elapsed'),
          ]),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: customers.isEmpty
              ? const Center(child: Text('顧客が見つかりません', style: TextStyle(fontSize: 18, color: LS.hint)))
              : ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: customers.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _row(customers[i]),
                ),
        ),
      ],
    );
  }

  Widget _chip(String label, String key) {
    final active = sortKey == key;
    final arrow = active && !sortAscending ? ' ▴' : (active ? ' ▾' : '');
    return GestureDetector(
      onTap: () => onSort(key),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: active ? LS.primary : LS.chipOff, borderRadius: BorderRadius.circular(22)),
        child: Text('$label$arrow', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: active ? Colors.white : LS.text)),
      ),
    );
  }

  Widget _row(Customer c) {
    final isSel = c.id == selected?.id || checkedIds.contains(c.id);
    final days = elapsedDays(c);
    return InkWell(
      onTap: () => onTap(c),
      onLongPress: () => onLongPress(c),
      borderRadius: BorderRadius.circular(LS.cardRadius),
      child: Container(
        height: 60,
        padding: const EdgeInsets.only(left: 14, right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(LS.cardRadius),
          border: Border.all(color: isSel ? LS.primary : LS.border, width: isSel ? 3 : 1),
        ),
        child: Row(children: [
          Expanded(child: Text(c.companyName.isNotEmpty ? c.companyName : c.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: LS.text))),
          const SizedBox(width: 10),
          Text(days == null ? '—' : '$days日', maxLines: 1, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: LS.red)),
        ]),
      ),
    );
  }

  Widget _detail(BuildContext context) {
    final c = selected;
    final days = c == null ? null : elapsedDays(c);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(LS.panelRadius), border: Border.all(color: LS.border)),
      child: c == null
          ? const Center(child: Text('顧客を選んでください', style: TextStyle(fontSize: 18, color: LS.hint)))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        InkWell(
                          onTap: () => onDetail(c),
                          child: Row(children: [
                            Expanded(child: Text(withHonorific(c.name), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: LS.text))),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(color: LS.chipOff, borderRadius: BorderRadius.circular(12)),
                              child: Text(c.companyName.isEmpty ? '個人' : '法人', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: LS.text)),
                            ),
                            IconButton(
                              tooltip: '削除',
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.delete_outline, size: 24, color: LS.red),
                              onPressed: () => onDelete(c),
                            ),
                          ]),
                        ),
                        const SizedBox(height: 10),
                        Row(children: [
                          const Icon(Icons.call, size: 28, color: LS.text),
                          const SizedBox(width: 8),
                          Expanded(child: Text(c.phoneNumber.isEmpty ? '—' : c.phoneNumber, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: LS.text))),
                        ]),
                        const SizedBox(height: 10),
                        Text(c.address.isEmpty ? '住所未登録' : c.address, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: LS.text)),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(color: LS.redBg, borderRadius: BorderRadius.circular(12)),
                          child: Text(days == null ? '注文履歴なし' : '前回の注文から $days日', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: LS.red)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(children: [
                  SizedBox(
                    width: 100,
                    height: LS.btnH,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: LS.primary,
                        padding: EdgeInsets.zero,
                        side: const BorderSide(color: LS.primary, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(LS.btnRadius)),
                      ),
                      onPressed: c.phoneNumber.isEmpty ? null : () => callPhone(c.phoneNumber),
                      icon: const Icon(Icons.call, size: 24),
                      label: const Text('電話', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: LS.btnH,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: LS.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(LS.btnRadius)),
                        ),
                        onPressed: onNewOrder,
                        icon: const Icon(Icons.add, size: 24),
                        label: const Text('新規受注', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ]),
              ],
            ),
    );
  }
}
