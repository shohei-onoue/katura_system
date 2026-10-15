// Figma node 89:4943 (データ分析 グラフ) を実データに接続したスマホ版。
import 'package:flutter/material.dart';
import 'mobile_delivery_common.dart';

class MobileMenuBarRow {
  final String menu;
  final int total;
  final Map<String, int> byBranch;
  const MobileMenuBarRow(this.menu, this.total, this.byBranch);
}

class MobileMonthTop {
  final String monthKey; // yyyy-MM
  final List<MapEntry<String, int>> top;
  const MobileMonthTop(this.monthKey, this.top);
}

class MobileAnalysisData {
  final bool isLoading;
  final int view; // 0: ヒートマップ, 1: グラフ
  final void Function(int) onView;
  final Widget heatmapView; // 既存のヒートマップ表示（地図）
  final List<String> branchTabs;
  final String graphBranch;
  final void Function(String) onBranch;
  final List<String> branchesInData;
  final Color Function(String) branchColor;
  final List<MobileMenuBarRow> rows;
  final List<MobileMonthTop> months;
  final String? Function(String) menuImage;
  final void Function(MobileMenuBarRow row) onRowTap;
  final void Function(MobileMonthTop m) onMonthTap;
  final VoidCallback? onOpenMenu;
  final void Function(int)? onNavigate;

  const MobileAnalysisData({
    required this.isLoading,
    required this.view,
    required this.onView,
    required this.heatmapView,
    required this.branchTabs,
    required this.graphBranch,
    required this.onBranch,
    required this.branchesInData,
    required this.branchColor,
    required this.rows,
    required this.months,
    required this.menuImage,
    required this.onRowTap,
    required this.onMonthTap,
    this.onOpenMenu,
    this.onNavigate,
  });
}

class MobileDataAnalysisGraph894943 extends StatelessWidget {
  const MobileDataAnalysisGraph894943(this.d, {super.key});

  final MobileAnalysisData d;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mdBg,
      bottomNavigationBar: MdBottomNav(-1, onNavigate: d.onNavigate),
      body: Column(
        children: [
          const MdStatusBar(),
          MdTopBar(title: 'データ分析', onIconTap: d.onOpenMenu),
          Padding(padding: const EdgeInsets.fromLTRB(14, 10, 14, 8), child: _viewTabs()),
          Expanded(
            child: d.view == 0
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                    child: d.heatmapView,
                  )
                : (d.isLoading ? const Center(child: CircularProgressIndicator()) : _graph()),
          ),
        ],
      ),
    );
  }

  Widget _viewTabs() {
    Widget tab(String label, int i) {
      final sel = d.view == i;
      return Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => d.onView(i),
          child: Container(
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: sel ? mdPurple : null, borderRadius: BorderRadius.circular(10)),
            child: Text(label, style: mdTs(13, c: sel ? Colors.white : mdSub)),
          ),
        ),
      );
    }

    return Container(
      height: 42,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: const Color(0xFFECEFF1), borderRadius: BorderRadius.circular(12)),
      child: Row(children: [tab('ヒートマップ', 0), tab('グラフ', 1)]),
    );
  }

  Widget _card(String title, Widget child, {Widget? trailing}) => Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: mdCardLine),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Text(title, style: mdTs(14)), const Spacer(), if (trailing != null) trailing]),
            const SizedBox(height: 10),
            child,
          ],
        ),
      );

  Widget _graph() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final b in d.branchTabs) ...[
                MdChip(b, selected: b == d.graphBranch, onTap: () => d.onBranch(b)),
                const SizedBox(width: 6),
              ],
            ],
          ),
        ),
        const SizedBox(height: 10),
        _card('店舗別 メニュー注文数', _bars(), trailing: Text('多い順', style: mdTs(11.5, w: FontWeight.w400, c: mdSub))),
        const SizedBox(height: 12),
        _card('月別 人気メニュー', _monthly()),
      ],
    );
  }

  Widget _empty() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(child: Text('データがありません', style: mdTs(12, w: FontWeight.w400, c: mdSub))),
      );

  Widget _bars() {
    if (d.rows.isEmpty) return _empty();
    final maxTotal = d.rows.map((r) => r.total).fold<int>(1, (a, b) => a > b ? a : b);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: [
            for (final b in d.branchesInData)
              Row(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: d.branchColor(b), shape: BoxShape.circle),
                ),
                const SizedBox(width: 4),
                Text(b, style: mdTs(11, w: FontWeight.w400, c: mdSub)),
              ]),
          ],
        ),
        const SizedBox(height: 10),
        for (final r in d.rows)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => d.onRowTap(r),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 104,
                    child: Text(r.menu, maxLines: 1, overflow: TextOverflow.ellipsis, style: mdTs(12)),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, c) => Row(
                        children: [
                          for (final b in d.branchesInData)
                            if ((r.byBranch[b] ?? 0) > 0)
                              Container(
                                width: c.maxWidth * (r.byBranch[b]! / maxTotal) * 0.85,
                                height: 14,
                                color: d.branchColor(b),
                              ),
                          const SizedBox(width: 6),
                          Text('${r.total}', style: mdTs(11, c: mdSub)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _monthly() {
    if (d.months.isEmpty) return _empty();
    return Column(
      children: [
        for (final m in d.months)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => d.onMonthTap(m),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 36,
                    child: Text('${int.parse(m.monthKey.split('-')[1])}月', style: mdTs(11.5, w: FontWeight.w400, c: mdSub)),
                  ),
                  if (m.top.isNotEmpty) ...[
                    _thumb(m.top[0].key),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('1位', style: mdTs(11.5, w: FontWeight.w400, c: mdSub)),
                          Text(m.top[0].key, maxLines: 2, overflow: TextOverflow.ellipsis, style: mdTs(14)),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 104,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (int i = 1; i < m.top.length; i++)
                          Text('${i + 1}位 ${m.top[i].key}',
                              maxLines: 1, overflow: TextOverflow.ellipsis, style: mdTs(11.5, w: FontWeight.w400)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _thumb(String menu) {
    final img = d.menuImage(menu);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 44,
        height: 44,
        child: img == null
            ? Container(
                color: const Color(0xFFEEF0F2),
                child: const Icon(Icons.restaurant, size: 20, color: Color(0xFFB5BAC0)),
              )
            : Image.network(img,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: const Color(0xFFEEF0F2))),
      ),
    );
  }
}
