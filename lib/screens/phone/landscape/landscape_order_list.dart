import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:katura_system/models/order_model.dart';
import 'package:katura_system/utils/name_format.dart';
import '../phone_common.dart';
import 'landscape_style.dart';

/// スマホ横向きの受注一覧(Figma 168:8)。左330=日付+店舗+カード、右=詳細パネル。
class LandscapeOrderList extends StatefulWidget {
  final List<OrderModel> orders;
  final bool isLoading;
  final DateTime selectedDay;
  final Map<String, String> displayNames;
  final Set<String> warnOrderIds;
  final List<String> branches;
  final String selectedBranch;
  final VoidCallback onPrevDay;
  final VoidCallback onNextDay;
  final VoidCallback onToday;
  final ValueChanged<String> onSelectBranch;
  final Future<void> Function(OrderModel) onDelivered;
  final void Function(OrderModel, String) onEdit;
  final void Function(OrderModel) onCancel;

  const LandscapeOrderList({
    super.key,
    required this.orders,
    required this.isLoading,
    required this.selectedDay,
    required this.displayNames,
    required this.warnOrderIds,
    required this.branches,
    required this.selectedBranch,
    required this.onPrevDay,
    required this.onNextDay,
    required this.onToday,
    required this.onSelectBranch,
    required this.onDelivered,
    required this.onEdit,
    required this.onCancel,
  });

  @override
  State<LandscapeOrderList> createState() => _LandscapeOrderListState();
}

class _LandscapeOrderListState extends State<LandscapeOrderList> {
  String? _selectedId;

  static String _yen(int v) => '¥${NumberFormat('#,###').format(v)}';

  OrderModel? get _selected {
    if (widget.orders.isEmpty) return null;
    for (final o in widget.orders) {
      if (o.id == _selectedId) return o;
    }
    return widget.orders.first;
  }

  (Color, Color) _branchColors(String n) {
    if (n.contains('岐阜')) return (LS.gifuBg, LS.gifuText);
    if (n.contains('名古屋')) return (const Color(0xFFD8F0DA), LS.green);
    return (LS.blueBg, LS.blue);
  }

  String _branchLabel(String n) => n.replaceAll('店', '');

  Widget _dayButton(IconData icon, VoidCallback onTap) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(LS.btnRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(LS.btnRadius),
          onTap: onTap,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(LS.btnRadius),
              border: Border.all(color: LS.borderStrong),
            ),
            child: Icon(icon, size: 32, color: LS.text),
          ),
        ),
      );

  Widget _dateRow() {
    final d = widget.selectedDay;
    final now = DateTime.now();
    final isToday = d.year == now.year && d.month == now.month && d.day == now.day;
    final label = DateFormat('M/d(E)', 'ja_JP').format(d) + (isToday ? ' 今日' : '');
    return Row(children: [
      _dayButton(Icons.chevron_left_rounded, widget.onPrevDay),
      const SizedBox(width: 8),
      Expanded(
        child: Material(
          color: LS.primary,
          borderRadius: BorderRadius.circular(LS.btnRadius),
          child: InkWell(
            borderRadius: BorderRadius.circular(LS.btnRadius),
            onTap: widget.onToday,
            child: SizedBox(
              height: 56,
              child: Center(
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ),
        ),
      ),
      const SizedBox(width: 8),
      _dayButton(Icons.chevron_right_rounded, widget.onNextDay),
    ]);
  }

  Widget _chips() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: widget.branches.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          final b = widget.branches[i];
          final sel = b == widget.selectedBranch;
          return InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () => widget.onSelectBranch(b),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(color: sel ? LS.primary : LS.chipOff, borderRadius: BorderRadius.circular(22)),
              child: Text(b == '全店舗' ? '全店' : _branchLabel(b),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: sel ? Colors.white : LS.text)),
            ),
          );
        },
      ),
    );
  }

  Widget _card(OrderModel o, bool selected) {
    final warn = widget.warnOrderIds.contains(o.id);
    final name = withHonorific(widget.displayNames[o.id] ?? o.customerName);
    final (bBg, bFg) = _branchColors(o.branchName);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: warn ? LS.redBg : Colors.white,
        borderRadius: BorderRadius.circular(LS.cardRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(LS.cardRadius),
          onTap: () => setState(() => _selectedId = o.id),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(LS.cardRadius),
              border: selected
                  ? Border.all(color: LS.primary, width: 2)
                  : Border.all(color: warn ? LS.red : LS.border),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(children: [
                Text(o.deliveryTime, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: LS.orange)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: LS.text)),
                ),
                const SizedBox(width: 8),
                Text(_yen(o.totalPrice), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: LS.text)),
              ]),
              const SizedBox(height: 2),
              Row(children: [
                Expanded(
                  child: Text(o.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16, color: LS.textSub)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(color: bBg, borderRadius: BorderRadius.circular(12)),
                  child: Text(_branchLabel(o.branchName),
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: bFg)),
                ),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _left(OrderModel? sel) {
    return SizedBox(
      width: 330,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _dateRow(),
        const SizedBox(height: 8),
        _chips(),
        const SizedBox(height: 8),
        Expanded(
          child: widget.isLoading
              ? const Center(child: CircularProgressIndicator())
              : widget.orders.isEmpty
                  ? const Center(child: Text('この日の受注はありません', style: TextStyle(fontSize: 18, color: LS.textSub)))
                  : ListView(children: [for (final o in widget.orders) _card(o, o.id == sel?.id)]),
        ),
      ]),
    );
  }

  /// 縦(OrderListCard)と同じ「変更内容を選択」。
  Future<void> _showEditChoice(OrderModel o) async {
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('変更内容を選択'),
        children: [
          for (final name in ['配達先', '日程', '注文内容'])
            SimpleDialogOption(onPressed: () => Navigator.pop(context, name), child: Text(name)),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, '予約キャンセル'),
            child: const Text('予約キャンセル', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (choice == null) return;
    if (choice == '予約キャンセル') {
      widget.onCancel(o);
    } else {
      widget.onEdit(o, choice);
    }
  }

  Widget _detail(OrderModel? o) {
    final panel = BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(LS.panelRadius),
      border: Border.all(color: LS.border),
    );
    if (o == null) return Container(decoration: panel);
    final name = withHonorific(widget.displayNames[o.id] ?? o.customerName);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: panel,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          height: 52,
          color: LS.primary,
          padding: const EdgeInsets.only(left: 14, right: 4),
          child: Row(children: [
            Expanded(
              child: Text(name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            IconButton(
              tooltip: '変更・キャンセル',
              icon: const Icon(Icons.edit_rounded, size: 24, color: Colors.white),
              onPressed: () => _showEditChoice(o),
            ),
          ]),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(children: [
                Text(o.deliveryTime, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: LS.orange)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(_yen(o.totalPrice),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: LS.text)),
                ),
              ]),
              const SizedBox(height: 6),
              InkWell(
                onTap: () => openMap(lat: o.latitude, lng: o.longitude, address: o.address),
                child: Text(o.address,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: LS.text)),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: LS.lilac, borderRadius: BorderRadius.circular(12)),
                child: Column(children: [
                  for (final it in o.items)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 1),
                      child: Row(children: [
                        Expanded(
                          child: Text('${it['name'] ?? ''}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: LS.text)),
                        ),
                        const SizedBox(width: 8),
                        Text('×${it['quantity'] ?? ''}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: LS.primary)),
                      ]),
                    ),
                ]),
              ),
            ]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 6, 14, 12),
          child: Row(children: [
            SizedBox(
              width: 110,
              height: LS.btnH,
              child: OutlinedButton.icon(
                onPressed: o.phoneNumber.isEmpty ? null : () => callPhone(o.phoneNumber),
                style: OutlinedButton.styleFrom(
                  foregroundColor: LS.primary,
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  side: const BorderSide(color: LS.primary, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(LS.btnRadius)),
                ),
                icon: const Icon(Icons.call_rounded, size: 24),
                label: const Text('電話', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: LS.btnH,
                child: FilledButton.icon(
                  onPressed: () => widget.onDelivered(o),
                  style: FilledButton.styleFrom(
                    backgroundColor: LS.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(LS.btnRadius)),
                  ),
                  icon: const Icon(Icons.check_rounded, size: 24),
                  label: const Text('配達済み',
                      maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sel = _selected;
    return Scaffold(
      backgroundColor: LS.bg,
      body: SafeArea(
        left: false,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(
            height: LS.headerH,
            padding: const EdgeInsets.symmetric(horizontal: LS.pad),
            alignment: Alignment.centerLeft,
            child: const Text('受注一覧',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: LS.text)),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(LS.pad, 0, LS.pad, LS.gap),
              child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                _left(sel),
                const SizedBox(width: LS.gap),
                Expanded(child: _detail(sel)),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}
