// スマホ版 受注入力（Figma: mobile_order_input_* / mobile_order_entry_* を既存ロジックにつないだもの）
import 'package:flutter/material.dart';

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
const _red = Color(0xFFF44336);
const _blue = Color(0xFF1E88E5);
const _orange = Color(0xFFFF6D00);
const _green = Color(0xFF4CAF50);
const _key = Color(0xFF2E3440);
const _keySub = Color(0xFF6C737E);

TextStyle _ts(double size, {FontWeight w = FontWeight.w700, Color c = _ink, double? ls}) => TextStyle(
      fontSize: size,
      fontWeight: w,
      color: c,
      letterSpacing: ls,
      height: 1.3,
      decoration: TextDecoration.none,
    );

class MobileCandidate {
  const MobileCandidate({required this.id, required this.title, required this.phone, this.daysSince, this.selected = false});
  final String id;
  final String title;
  final String phone;
  final int? daysSince;
  final bool selected;
}

class MobileHistoryItem {
  const MobileHistoryItem({required this.raw, required this.name, required this.address, this.selected = false});
  final String raw;
  final String name;
  final String address;
  final bool selected;
}

class MobileMenuItem {
  const MobileMenuItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.qty,
    required this.isLast,
  });
  final String id;
  final String name;
  final String category;
  final int price;
  final String imageUrl;
  final int qty;
  final bool isLast;
}

class MobileCartLine {
  const MobileCartLine({required this.name, required this.qty, required this.price, this.note = ''});
  final String name;
  final int qty;
  final int price;
  final String note;
}

class MobileOrderInputData {
  const MobileOrderInputData({
    required this.step,
    required this.maxStepReached,
    required this.isEditing,
    required this.pickup,
    required this.canJumpToFinal,
    required this.loading,
    required this.phoneText,
    required this.onOpenMenu,
    required this.onNavigate,
    required this.onStepTapped,
    required this.onCancelOrder,
    required this.onTextChanged,
    // 0: 番号確認
    required this.isCompletingPhone,
    required this.phonePrefix,
    required this.phoneDigitsLen,
    required this.hasSelectedCustomer,
    required this.candidates,
    required this.onDial,
    required this.onClear,
    required this.onBackspace,
    required this.onSelectCandidate,
    required this.onPhoneNext,
    required this.onPhoneClose,
    // 1: 顧客確認
    required this.nameController,
    required this.companyController,
    required this.facilityText,
    required this.addressText,
    required this.onPickFacilityForCustomer,
    required this.onCustomerNext,
    required this.onCustomerBack,
    // 2: 配達先
    required this.isHistoryMode,
    required this.historyItems,
    required this.remarksController,
    required this.branchName,
    required this.estimatedDuration,
    required this.isApproximateLocation,
    required this.mapWidget,
    required this.onModeToggle,
    required this.onSelectHistory,
    required this.onAdjust,
    required this.onEditHistory,
    required this.onDeleteHistory,
    required this.onSearchFacility,
    required this.onDeliveryNext,
    // 3: 注文内容
    required this.menus,
    required this.cart,
    required this.totalPrice,
    required this.totalCount,
    required this.onAddMenu,
    required this.onRemoveMenu,
    required this.onClearCart,
    required this.onItemsNext,
    required this.onReloadMenus,
    // 4: 完了
    required this.packagingType,
    required this.packagingSmallQty,
    required this.packagingOtherController,
    required this.preMethod,
    required this.preIsSpecifiedNumber,
    required this.prePhoneController,
    required this.preDateLabel,
    required this.preDateEditable,
    required this.recipientController,
    required this.customerName,
    required this.documents,
    required this.paymentMethod,
    required this.summaryDate,
    required this.summaryAddress,
    required this.onPackagingChanged,
    required this.onPackagingQtyChanged,
    required this.onPreMethodChanged,
    required this.onPreNumberTypeChanged,
    required this.onPrePhoneChanged,
    required this.onPickPreDate,
    required this.onDocumentToggled,
    required this.onPaymentChanged,
    required this.onShowReceipt,
    required this.onSave,
  });

  final int step;
  final int maxStepReached;
  final bool isEditing;
  final bool pickup;
  final bool canJumpToFinal;
  final bool loading;
  final String phoneText;
  final VoidCallback? onOpenMenu;
  final void Function(int)? onNavigate;
  final void Function(int) onStepTapped;
  final VoidCallback onCancelOrder;
  final VoidCallback onTextChanged;

  final bool isCompletingPhone;
  final String phonePrefix;
  final int phoneDigitsLen;
  final bool hasSelectedCustomer;
  final List<MobileCandidate> candidates;
  final void Function(String) onDial;
  final VoidCallback onClear;
  final VoidCallback onBackspace;
  final void Function(String) onSelectCandidate;
  final VoidCallback onPhoneNext;
  final VoidCallback onPhoneClose;

  final TextEditingController nameController;
  final TextEditingController companyController;
  final String facilityText;
  final String addressText;
  final void Function(int tab) onPickFacilityForCustomer;
  final VoidCallback onCustomerNext;
  final VoidCallback onCustomerBack;

  final bool isHistoryMode;
  final List<MobileHistoryItem> historyItems;
  final TextEditingController remarksController;
  final String branchName;
  final String? estimatedDuration;
  final bool isApproximateLocation;
  final Widget? mapWidget;
  final void Function(bool) onModeToggle;
  final Future<void> Function(String raw) onSelectHistory;
  final VoidCallback onAdjust;
  final void Function(String raw) onEditHistory;
  final void Function(String raw) onDeleteHistory;
  final void Function(int tab) onSearchFacility;
  final VoidCallback onDeliveryNext;

  final List<MobileMenuItem> menus;
  final List<MobileCartLine> cart;
  final int totalPrice;
  final int totalCount;
  final void Function(String id) onAddMenu;
  final void Function(String id) onRemoveMenu;
  final VoidCallback onClearCart;
  final VoidCallback onItemsNext;
  final VoidCallback onReloadMenus;

  final String packagingType;
  final int packagingSmallQty;
  final TextEditingController packagingOtherController;
  final String preMethod;
  final bool preIsSpecifiedNumber;
  final TextEditingController prePhoneController;
  final String preDateLabel;
  final bool preDateEditable;
  final TextEditingController recipientController;
  final String customerName;
  final Set<String> documents;
  final String paymentMethod;
  final String summaryDate;
  final String summaryAddress;
  final void Function(String) onPackagingChanged;
  final void Function(int) onPackagingQtyChanged;
  final void Function(String) onPreMethodChanged;
  final void Function(bool specified) onPreNumberTypeChanged;
  final void Function(String) onPrePhoneChanged;
  final VoidCallback onPickPreDate;
  final void Function(String) onDocumentToggled;
  final void Function(String) onPaymentChanged;
  final VoidCallback onShowReceipt;
  final VoidCallback onSave;
}

// ---------------------------------------------------------------- 共通部品

class _StatusBar extends StatelessWidget {
  const _StatusBar();
  @override
  Widget build(BuildContext context) => Container(
        height: 44,
        color: Colors.white,
        padding: const EdgeInsets.only(left: 30, right: 26),
        child: Row(children: [
          Text('9:41', style: _ts(15)),
          const Spacer(),
          const Icon(Icons.signal_cellular_alt, size: 17, color: _ink),
          const SizedBox(width: 5),
          const Icon(Icons.wifi, size: 17, color: _ink),
          const SizedBox(width: 5),
          const Icon(Icons.battery_full, size: 17, color: _ink),
        ]),
      );
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.phone, this.onMenu});
  final String phone;
  final VoidCallback? onMenu;
  @override
  Widget build(BuildContext context) => Container(
        height: 52,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onMenu,
            child: const Icon(Icons.menu, size: 20, color: _ink),
          ),
          const SizedBox(width: 16),
          Text('受注入力', style: _ts(18)),
          const Spacer(),
          if (phone.isNotEmpty) Text(phone, style: _ts(15, w: FontWeight.w900, c: _purple)),
        ]),
      );
}

class _Stepper extends StatelessWidget {
  const _Stepper(this.d);
  final MobileOrderInputData d;
  static const _labels = ['番号確認', '配達先の確定', '注文内容', '完了'];
  static const _internal = [0, 2, 3, 4];

  @override
  Widget build(BuildContext context) {
    final cur = const {0: 0, 1: 0, 2: 1, 3: 2, 4: 3}[d.step] ?? 0;
    return Container(
      height: 59,
      color: Colors.white,
      child: Row(children: [
        for (int i = 0; i < 4; i++)
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => d.onStepTapped(_internal[i]),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < cur ? _green : (i == cur ? _orange : Colors.white),
                    border: Border.all(color: i < cur ? _green : (i == cur ? _orange : const Color(0xFFCFD3D8))),
                  ),
                  child: i < cur
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : Text('${i + 1}', style: _ts(11, c: i == cur ? Colors.white : _grey)),
                ),
                const SizedBox(height: 4),
                Text(_labels[i],
                    style: _ts(10,
                        w: i == cur ? FontWeight.w700 : FontWeight.w500,
                        c: i < cur ? _ink : (i == cur ? _orange : _grey))),
              ]),
            ),
          ),
      ]),
    );
  }
}

class _HomeBar extends StatelessWidget {
  const _HomeBar();
  @override
  Widget build(BuildContext context) => Container(
        width: 134,
        height: 5,
        decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(2.5)),
      );
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({this.onNavigate});
  final void Function(int)? onNavigate;
  static const _targets = [0, 1, 3, 6, 7];
  static const _icons = [Icons.post_add, Icons.list_alt, Icons.local_shipping, Icons.people, Icons.apps];
  static const _labels = ['受注入力', '受注一覧', '配送予定', '顧客', 'メニュー'];

  @override
  Widget build(BuildContext context) => Container(
        height: 82,
        decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: _line))),
        child: Stack(children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 6, 4, 0),
              child: Row(children: [
                for (int i = 0; i < 5; i++)
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onNavigate?.call(_targets[i]),
                      child: Column(children: [
                        Container(
                          width: 56,
                          height: 30,
                          decoration: i == 0
                              ? BoxDecoration(color: _purpleTint, borderRadius: BorderRadius.circular(15))
                              : null,
                          child: Center(child: Icon(_icons[i], size: 20, color: i == 0 ? _purple : _sub)),
                        ),
                        const SizedBox(height: 3),
                        Text(_labels[i],
                            style: _ts(10.5,
                                w: i == 0 ? FontWeight.w700 : FontWeight.w500, c: i == 0 ? _purple : _sub)),
                      ]),
                    ),
                  ),
              ]),
            ),
          ),
          const Positioned(left: 0, right: 0, bottom: 8, child: Center(child: _HomeBar())),
        ]),
      );
}

class _Btn extends StatelessWidget {
  const _Btn(this.label, this.color, this.onTap, {this.height = 48, this.icon, this.outline = false});
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final double height;
  final IconData? icon;
  final bool outline;
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: outline ? Colors.white : color,
            borderRadius: BorderRadius.circular(height >= 44 ? 12 : 10),
            border: outline ? Border.all(color: _line) : null,
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (icon != null) ...[Icon(icon, size: 18, color: outline ? _ink : Colors.white), const SizedBox(width: 6)],
            Text(label, style: _ts(height >= 44 ? 15 : 13, c: outline ? _ink : Colors.white)),
          ]),
        ),
      );
}

class _Chip extends StatelessWidget {
  const _Chip(this.label, {this.selected = false, this.onTap, this.outline});
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final Color? outline;
  @override
  Widget build(BuildContext context) {
    final bg = selected ? _lime : Colors.white;
    final border = selected ? _limeLine : (outline ?? _line);
    final fg = selected ? _limeText : _ink;
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
        child: Center(widthFactor: 1, child: Text(label, style: _ts(13, c: fg))),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child, this.padding = EdgeInsets.zero});
  final Widget child;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 14),
        padding: padding,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _cardLine),
        ),
        clipBehavior: Clip.antiAlias,
        child: child,
      );
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) =>
      Padding(padding: const EdgeInsets.fromLTRB(16, 14, 16, 6), child: Text(text, style: _ts(12, c: _sub)));
}

class _Field extends StatelessWidget {
  const _Field({required this.controller, required this.hint, this.onChanged, this.keyboardType});
  final TextEditingController controller;
  final String hint;
  final VoidCallback? onChanged;
  final TextInputType? keyboardType;
  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: (_) => onChanged?.call(),
        style: _ts(14, w: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: _ts(13, w: FontWeight.w400, c: _grey),
          isDense: true,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _line)),
          enabledBorder:
              OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _line)),
          focusedBorder:
              OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _purple)),
        ),
      );
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.left, required this.right});
  final Widget left;
  final Widget right;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
        decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: _line))),
        child: SafeArea(
          top: false,
          child: Row(children: [Expanded(child: left), const SizedBox(width: 10), Expanded(child: right)]),
        ),
      );
}

// ---------------------------------------------------------------- 画面本体

class MobileOrderInput extends StatelessWidget {
  const MobileOrderInput(this.data, {super.key});
  final MobileOrderInputData data;

  @override
  Widget build(BuildContext context) {
    final d = data;
    Widget body;
    Widget? bottom;
    switch (d.step) {
      case 0:
        body = _PhoneBody(d);
        break;
      case 1:
        body = _CustomerBody(d);
        bottom = _ActionBar(
          left: _Btn('番号の打ち直し', _keySub, d.onCustomerBack, outline: true),
          right: _Btn('登録して進む', _purple, d.onCustomerNext),
        );
        break;
      case 2:
        body = _DeliveryBody(d);
        final ready = d.facilityText.isNotEmpty && d.addressText.isNotEmpty ||
            (d.remarksController.text.contains('が目印') && d.addressText.isNotEmpty);
        bottom = _ActionBar(
          left: _Btn(d.isEditing ? '編集中止' : '注文中止', _red, d.onCancelOrder),
          right: _Btn('商品選択', ready ? _purple : const Color(0xFFB8BCC2), ready ? d.onDeliveryNext : null),
        );
        break;
      case 3:
        body = _ItemsBody(d);
        break;
      default:
        body = _FinalBody(d);
        bottom = Column(mainAxisSize: MainAxisSize.min, children: [
          _ActionBar(
            left: _Btn(d.isEditing ? '編集中止' : '注文中止', _red, d.onCancelOrder),
            right: _Btn(d.isEditing ? '更新' : '確定', _purple, d.onSave),
          ),
          _BottomNav(onNavigate: d.onNavigate),
        ]);
    }
    return Stack(children: [
      Scaffold(
        backgroundColor: _bg,
        resizeToAvoidBottomInset: true,
        body: Column(children: [
          const _StatusBar(),
          _TopBar(phone: d.step == 0 ? '' : d.phoneText, onMenu: d.onOpenMenu),
          _Stepper(d),
          Expanded(child: body),
          if (bottom != null && d.step != 3) bottom,
        ]),
      ),
      if (d.loading)
        const Positioned.fill(
          child: AbsorbPointer(
            child: ColoredBox(color: Color(0x80000000), child: Center(child: CircularProgressIndicator())),
          ),
        ),
    ]);
  }
}

// ---------------------------------------------------------------- 0: 番号確認

class _PhoneBody extends StatelessWidget {
  const _PhoneBody(this.d);
  final MobileOrderInputData d;

  Widget _candidate(MobileCandidate c) => GestureDetector(
        onTap: () => d.onSelectCandidate(c.id),
        child: Container(
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
          height: 66,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: c.selected ? _lime : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: c.selected ? _limeLine : _cardLine),
          ),
          child: Row(children: [
            Expanded(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(c.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: _ts(15, w: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(c.phone, style: _ts(13, w: FontWeight.w700, c: _red)),
              ]),
            ),
            if (c.daysSince != null) ...[
              Text('前回から', style: _ts(10, w: FontWeight.w400, c: _sub)),
              const SizedBox(width: 4),
              Text('${c.daysSince}', style: _ts(22, c: _blue)),
              Text('日', style: _ts(11.5, w: FontWeight.w400, c: _blue)),
            ],
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final sel = d.hasSelectedCustomer;
    final title = d.isCompletingPhone ? '市外局番を入力' : (sel ? 'お客様電話番号' : '下４桁を入力');
    final showTwoButtons = sel || d.isCompletingPhone || d.phoneDigitsLen >= 10;
    final showNew = !showTwoButtons && d.phoneDigitsLen >= 4;
    final bigStyle = _ts(sel || d.isCompletingPhone || d.phoneDigitsLen >= 10 ? 36 : 52, w: FontWeight.w900, c: _red, ls: 1);
    return Column(children: [
      Expanded(
        child: ListView(padding: const EdgeInsets.only(top: 12, bottom: 12), children: [
          _Card(
            child: Column(children: [
              Container(
                height: 37,
                color: _purple,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(children: [
                  Text(title, style: _ts(13, c: Colors.white)),
                  const Spacer(),
                  if (d.phoneText.isNotEmpty || d.isCompletingPhone)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: d.onPhoneClose,
                      child: const Icon(Icons.close, size: 18, color: Colors.white),
                    ),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: d.isCompletingPhone
                      ? Text.rich(TextSpan(children: [
                          TextSpan(text: d.phonePrefix, style: bigStyle.copyWith(color: _purple)),
                          TextSpan(text: d.phoneText, style: bigStyle),
                        ]))
                      : Text(d.phoneText.isEmpty ? '----' : d.phoneText, style: bigStyle),
                ),
              ),
              if (showTwoButtons || showNew)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  child: showNew
                      ? _Btn('新規登録', _purple, d.onPhoneNext, height: 38)
                      : Row(children: [
                          Expanded(child: _Btn('受注中止', _red, d.onCancelOrder, height: 38)),
                          const SizedBox(width: 8),
                          Expanded(child: _Btn('日程調整', _purple, d.onPhoneNext, height: 38)),
                        ]),
                ),
            ]),
          ),
          if (d.candidates.isNotEmpty && !d.isCompletingPhone) ...[
            _Label(sel ? '選択中の顧客' : '該当する候補'),
            for (final c in d.candidates) _candidate(c),
          ],
        ]),
      ),
      _Dial(d),
    ]);
  }
}

class _Dial extends StatelessWidget {
  const _Dial(this.d);
  final MobileOrderInputData d;

  Widget _k(Widget child, Color color, VoidCallback onTap) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)),
              child: child,
            ),
          ),
        ),
      );

  Widget _num(String n) =>
      _k(Text(n, style: _ts(24, c: Colors.white)), _key, () => d.onDial(n));

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: _line))),
        padding: const EdgeInsets.fromLTRB(9, 8, 9, 0),
        child: SafeArea(
          top: false,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Align(alignment: Alignment.centerLeft, child: Padding(padding: const EdgeInsets.only(left: 7, bottom: 6), child: Text('入力ダイヤル', style: _ts(11.5, c: _sub)))),
            for (int r = 0; r < 3; r++)
              Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Row(children: [for (int c = 1; c <= 3; c++) _num('${r * 3 + c}')]),
              ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(children: [
                _k(Text('クリア', style: _ts(15, c: Colors.white)), _keySub, d.onClear),
                _num('0'),
                _k(const Icon(Icons.backspace, size: 24, color: Colors.white), _keySub, d.onBackspace),
              ]),
            ),
          ]),
        ),
      );
}

// ---------------------------------------------------------------- 1: 顧客確認（新規）

class _CustomerBody extends StatelessWidget {
  const _CustomerBody(this.d);
  final MobileOrderInputData d;

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.only(top: 12, bottom: 24), children: [
        _Card(
          child: Column(children: [
            Container(
              height: 37,
              color: _purple,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.centerLeft,
              child: Text('新規顧客の登録', style: _ts(13, c: Colors.white)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(d.phoneText, style: _ts(32, w: FontWeight.w900, c: _red, ls: 1)),
            ),
          ]),
        ),
        const _Label('企業・施設名（未入力は個人宅）'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: _Field(controller: d.companyController, hint: '企業・施設名', onChanged: d.onTextChanged),
        ),
        const _Label('顧客名（必須）'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: _Field(controller: d.nameController, hint: 'お名前', onChanged: d.onTextChanged),
        ),
        const _Label('所属企業・住所の確定'),
        _Card(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Wrap(spacing: 6, runSpacing: 6, children: [
              _Chip('地域・カテゴリ', onTap: () => d.onPickFacilityForCustomer(0)),
              _Chip('キーワード', onTap: () => d.onPickFacilityForCustomer(1)),
              _Chip('住所', onTap: () => d.onPickFacilityForCustomer(2)),
            ]),
            const SizedBox(height: 12),
            _InfoRow(Icons.business, d.facilityText.isEmpty ? '未確定' : d.facilityText, d.facilityText.isNotEmpty),
            const SizedBox(height: 6),
            _InfoRow(Icons.place, d.addressText.isEmpty ? '未確定' : d.addressText, d.addressText.isNotEmpty),
          ]),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: _Btn(d.isEditing ? '編集中止' : '注文中止', _red, d.onCancelOrder, outline: true),
        ),
      ]);
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.text, this.ok);
  final IconData icon;
  final String text;
  final bool ok;
  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, size: 15, color: _red),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: _ts(11.5, w: ok ? FontWeight.w400 : FontWeight.w700, c: ok ? _ink : _red))),
      ]);
}

// ---------------------------------------------------------------- 2: 配達先の確定

class _DeliveryBody extends StatelessWidget {
  const _DeliveryBody(this.d);
  final MobileOrderInputData d;

  Widget _history(BuildContext context, MobileHistoryItem h) => GestureDetector(
        onTap: () => d.onSelectHistory(h.raw),
        onLongPress: () => _showActions(context, h),
        child: Container(
          color: h.selected ? _lime : Colors.white,
          padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
          child: Row(children: [
            Icon(Icons.location_on, size: 20, color: h.selected ? _orange : const Color(0xFFB0B5BB)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(h.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: _ts(14)),
                const SizedBox(height: 4),
                Text(h.address, maxLines: 2, overflow: TextOverflow.ellipsis, style: _ts(11.5, w: FontWeight.w400, c: _sub)),
              ]),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () async {
                if (!h.selected) await d.onSelectHistory(h.raw);
                d.onAdjust();
              },
              child: Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 9),
                decoration: BoxDecoration(
                    color: d.isApproximateLocation && h.selected ? _orange : const Color(0xFF78909C),
                    borderRadius: BorderRadius.circular(10)),
                child: Row(children: [
                  const Icon(Icons.map, size: 15, color: Colors.white),
                  const SizedBox(width: 4),
                  Text('調整', style: _ts(13, c: Colors.white)),
                ]),
              ),
            ),
          ]),
        ),
      );

  void _showActions(BuildContext context, MobileHistoryItem h) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('配達先を編集'),
            onTap: () {
              Navigator.pop(ctx);
              d.onEditHistory(h.raw);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: _red),
            title: const Text('配達先を削除'),
            onTap: () {
              Navigator.pop(ctx);
              d.onDeleteHistory(h.raw);
            },
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hist = d.historyItems;
    return ListView(padding: const EdgeInsets.only(top: 10, bottom: 20), children: [
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 14),
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(color: const Color(0xFFECEFF1), borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          for (final m in [true, false])
            Expanded(
              child: GestureDetector(
                onTap: () => d.onModeToggle(m),
                child: Container(
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: d.isHistoryMode == m ? _lime : Colors.transparent, borderRadius: BorderRadius.circular(10)),
                  child: Text(m ? '履歴から選択' : '新規登録',
                      style: _ts(13, c: d.isHistoryMode == m ? _limeText : _sub)),
                ),
              ),
            ),
        ]),
      ),
      const SizedBox(height: 12),
      if (d.isHistoryMode)
        _Card(
          child: hist.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text('配達実績がありません。新規登録を行ってください。',
                        style: _ts(12.5, w: FontWeight.w400, c: _sub), textAlign: TextAlign.center),
                  ),
                )
              : Column(children: [
                  for (int i = 0; i < hist.length; i++) ...[
                    if (i > 0) const Divider(height: 1, color: _cardLine),
                    _history(context, hist[i]),
                  ],
                ]),
        )
      else
        _Card(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('検索方法を選んでください', style: _ts(12, c: _sub)),
            const SizedBox(height: 8),
            Wrap(spacing: 6, runSpacing: 6, children: [
              _Chip('地域・カテゴリ', onTap: () => d.onSearchFacility(0)),
              _Chip('キーワード', onTap: () => d.onSearchFacility(1)),
              _Chip('住所', onTap: () => d.onSearchFacility(2)),
            ]),
            const SizedBox(height: 12),
            Text('備考（地図上の目印、搬入口情報など）', style: _ts(12, c: _sub)),
            const SizedBox(height: 6),
            _Field(controller: d.remarksController, hint: '備考を入力', onChanged: d.onTextChanged),
          ]),
        ),
      const _Label('配達先情報の確認'),
      _Card(
        child: Column(children: [
          SizedBox(
            height: 170,
            width: double.infinity,
            child: d.mapWidget ??
                Container(
                  color: const Color(0xFFCFE5D2),
                  alignment: Alignment.center,
                  child: Text('地図（Googleマップ）', style: _ts(13, c: const Color(0xFF5B8A65))),
                ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.store, size: 15, color: _blue),
                const SizedBox(width: 6),
                Text('${d.branchName} →', style: _ts(11.5, w: FontWeight.w400)),
                if (d.estimatedDuration != null) ...[
                  const SizedBox(width: 10),
                  const Icon(Icons.access_time, size: 14, color: _red),
                  const SizedBox(width: 3),
                  Text(d.estimatedDuration!, style: _ts(11.5, w: FontWeight.w400)),
                ],
              ]),
              const SizedBox(height: 6),
              _InfoRow(Icons.business, d.facilityText.isEmpty ? '未確定' : d.facilityText, d.facilityText.isNotEmpty),
              const SizedBox(height: 6),
              _InfoRow(Icons.place, d.addressText.isEmpty ? '未確定' : d.addressText, d.addressText.isNotEmpty),
            ]),
          ),
        ]),
      ),
      if (d.isHistoryMode && hist.isNotEmpty)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Text('履歴を長押しすると編集・削除できます', style: _ts(11, w: FontWeight.w400, c: _grey)),
        ),
    ]);
  }
}

// ---------------------------------------------------------------- 3: 注文内容

class _ItemsBody extends StatefulWidget {
  const _ItemsBody(this.d);
  final MobileOrderInputData d;
  @override
  State<_ItemsBody> createState() => _ItemsBodyState();
}

class _ItemsBodyState extends State<_ItemsBody> {
  String _cat = '';
  bool _cartOpen = false;

  static const _preset = ['厳選牛ステーキ弁当', '高級弁当', 'オードブル', '丼もの', 'ギフト', 'ドリンク・サイドメニュー'];

  List<String> _categories() {
    final actual = widget.d.menus.map((m) => m.category).toSet();
    return [..._preset.where(actual.contains), ...actual.where((c) => !_preset.contains(c))];
  }

  Widget _menuCard(MobileMenuItem m) {
    final d = widget.d;
    final active = m.qty > 0;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: active ? _purple : (m.isLast ? _orange : _cardLine), width: active || m.isLast ? 2 : 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Stack(fit: StackFit.expand, children: [
            Container(
              color: const Color(0xFFEEF0F2),
              child: m.imageUrl.isEmpty
                  ? const Center(child: Icon(Icons.restaurant, size: 30, color: Color(0xFFB5BAC0)))
                  : Image.network(m.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          const Center(child: Icon(Icons.restaurant, size: 30, color: Color(0xFFB5BAC0)))),
            ),
            if (m.isLast)
              Positioned(
                left: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFFFF7043), borderRadius: BorderRadius.circular(6)),
                  child: Text('前回注文', style: _ts(10.5, c: Colors.white)),
                ),
              ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
          child: Text(m.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: _ts(13)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 2, 10, 6),
          child: Text('¥${_yen(m.price)}', style: _ts(13, c: _red)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            GestureDetector(
              onTap: active ? () => d.onRemoveMenu(m.id) : null,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: _line)),
                child: Icon(Icons.remove, size: 16, color: active ? _ink : _grey),
              ),
            ),
            Text('${m.qty}', style: _ts(15, c: active ? _purple : _ink)),
            GestureDetector(
              onTap: () => d.onAddMenu(m.id),
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: _purple),
                child: const Icon(Icons.add, size: 16, color: Colors.white),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.d;
    if (d.menus.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.inventory_2_outlined, size: 56, color: _grey),
          const SizedBox(height: 12),
          Text('メニューデータが見つかりません', style: _ts(15, c: _sub)),
          const SizedBox(height: 14),
          _Btn('メニューを読み直す', _purple, d.onReloadMenus, height: 40, icon: Icons.refresh),
        ]),
      );
    }
    final cats = _categories();
    if (!cats.contains(_cat) && cats.isNotEmpty) _cat = cats.first;
    final shown = d.menus.where((m) => m.category == _cat).toList();
    return Column(children: [
      SizedBox(
        height: 52,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
          children: [
            for (final c in cats) ...[
              _Chip(
                c,
                selected: c == _cat,
                outline: d.menus.any((m) => m.category == c && m.isLast) ? _orange : null,
                onTap: () => setState(() => _cat = c),
              ),
              const SizedBox(width: 6),
            ],
          ],
        ),
      ),
      Expanded(
        child: shown.isEmpty
            ? Center(child: Text('このカテゴリに商品はありません', style: _ts(13, w: FontWeight.w400, c: _sub)))
            : GridView.builder(
                padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.95,
                ),
                itemCount: shown.length,
                itemBuilder: (_, i) => _menuCard(shown[i]),
              ),
      ),
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: _line)),
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
        child: SafeArea(
          top: false,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _cartOpen = !_cartOpen),
              child: Row(children: [
                const Icon(Icons.shopping_cart, size: 20, color: _purple),
                const SizedBox(width: 8),
                Text('カートの中身', style: _ts(13)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(color: _purpleTint, borderRadius: BorderRadius.circular(6)),
                  child: Text('${d.cart.length}品', style: _ts(10.5, c: _purple)),
                ),
                const Spacer(),
                Text('合計 ${d.totalCount}個', style: _ts(11.5, w: FontWeight.w400, c: _sub)),
                const SizedBox(width: 10),
                Text('¥${_yen(d.totalPrice)}', style: _ts(20, c: _red)),
                const SizedBox(width: 4),
                Icon(_cartOpen ? Icons.expand_more : Icons.expand_less, size: 20, color: _grey),
              ]),
            ),
            if (_cartOpen)
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 160),
                child: d.cart.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text('商品が選ばれていません', style: _ts(12, w: FontWeight.w400, c: _sub)),
                      )
                    : ListView(shrinkWrap: true, padding: const EdgeInsets.only(top: 8), children: [
                        for (final l in d.cart)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(children: [
                              Expanded(
                                child: Text(l.note.isEmpty ? l.name : '${l.name}（${l.note}）',
                                    maxLines: 1, overflow: TextOverflow.ellipsis, style: _ts(12.5, w: FontWeight.w500)),
                              ),
                              Text('× ${l.qty}', style: _ts(12.5, c: _purple)),
                              const SizedBox(width: 12),
                              Text('¥${_yen(l.price * l.qty)}', style: _ts(12.5, c: _sub)),
                            ]),
                          ),
                      ]),
              ),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                flex: 10,
                child: GestureDetector(
                  onTap: d.cart.isEmpty ? null : d.onClearCart,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                        color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: _line)),
                    child: Icon(Icons.delete_outline, size: 20, color: d.cart.isEmpty ? _grey : _ink),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 10,
                child: _Btn(d.isEditing ? '編集中止' : '注文中止', _red, d.onCancelOrder),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 16,
                child: _Btn('注文内容を確定する', d.cart.isEmpty ? const Color(0xFFB8BCC2) : _purple,
                    d.cart.isEmpty ? null : d.onItemsNext),
              ),
            ]),
            const SizedBox(height: 10),
          ]),
        ),
      ),
    ]);
  }
}

String _yen(int v) {
  final s = v.toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return b.toString();
}

// ---------------------------------------------------------------- 4: 完了

class _FinalBody extends StatefulWidget {
  const _FinalBody(this.d);
  final MobileOrderInputData d;
  @override
  State<_FinalBody> createState() => _FinalBodyState();
}

class _FinalBodyState extends State<_FinalBody> {
  late bool _recipientSpecified = widget.d.recipientController.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final d = widget.d;
    final selfName = d.customerName;
    final recipient = _recipientSpecified && d.recipientController.text.isNotEmpty
        ? d.recipientController.text
        : selfName;
    Widget section(String title, List<Widget> children) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _Card(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: _ts(13, c: _purple)),
              const SizedBox(height: 10),
              ...children,
            ]),
          ),
        );
    return ListView(padding: const EdgeInsets.only(top: 12, bottom: 12), children: [
      section('梱包・確認設定', [
        Text('梱包方法', style: _ts(12, c: _sub)),
        const SizedBox(height: 6),
        Wrap(spacing: 6, runSpacing: 6, children: [
          for (final p in const ['個包装', '紙袋', 'ダンボール', '小分け', 'その他'])
            _Chip(p, selected: d.packagingType == p, onTap: () => d.onPackagingChanged(p)),
        ]),
        if (d.packagingType == '小分け') ...[
          const SizedBox(height: 8),
          Row(children: [
            Text('数量', style: _ts(12, c: _sub)),
            const SizedBox(width: 10),
            _Stepper2(value: d.packagingSmallQty, onChanged: d.onPackagingQtyChanged),
            const SizedBox(width: 6),
            Text('個ずつ', style: _ts(12, w: FontWeight.w400)),
          ]),
        ],
        if (d.packagingType == 'その他') ...[
          const SizedBox(height: 8),
          _Field(controller: d.packagingOtherController, hint: '梱包方法（詳細）', onChanged: d.onTextChanged),
        ],
        const SizedBox(height: 14),
        Text('事前連絡', style: _ts(12, c: _sub)),
        const SizedBox(height: 6),
        Wrap(spacing: 6, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
          _Chip('受電番号', selected: !d.preIsSpecifiedNumber, onTap: () => d.onPreNumberTypeChanged(false)),
          _Chip('指定番号', selected: d.preIsSpecifiedNumber, onTap: () => d.onPreNumberTypeChanged(true)),
          Text('に', style: _ts(13)),
          _Chip('電話', selected: d.preMethod != 'SMS', onTap: () => d.onPreMethodChanged('電話')),
          _Chip('SMS', selected: d.preMethod == 'SMS', onTap: () => d.onPreMethodChanged('SMS')),
          Text('で連絡する', style: _ts(13)),
        ]),
        if (d.preIsSpecifiedNumber) ...[
          const SizedBox(height: 8),
          _Field(
            controller: d.prePhoneController,
            hint: '電話番号を入力',
            keyboardType: TextInputType.phone,
            onChanged: () => d.onPrePhoneChanged(d.prePhoneController.text),
          ),
        ],
        const SizedBox(height: 8),
        GestureDetector(
          onTap: d.preDateEditable ? d.onPickPreDate : null,
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: _line)),
            child: Row(children: [
              Icon(d.preDateEditable ? Icons.event : Icons.info_outline, size: 16, color: _blue),
              const SizedBox(width: 8),
              Expanded(child: Text(d.preDateLabel, style: _ts(12.5, w: FontWeight.w500))),
              if (d.preDateEditable) const Icon(Icons.chevron_right, size: 18, color: _grey),
            ]),
          ),
        ),
        const SizedBox(height: 14),
        Text('受取人の指定', style: _ts(12, c: _sub)),
        const SizedBox(height: 6),
        Row(children: [
          _Chip('ご本人', selected: !_recipientSpecified, onTap: () {
            d.recipientController.clear();
            setState(() => _recipientSpecified = false);
            d.onTextChanged();
          }),
          const SizedBox(width: 6),
          _Chip('指定', selected: _recipientSpecified, onTap: () => setState(() => _recipientSpecified = true)),
          const SizedBox(width: 10),
          if (!_recipientSpecified) Expanded(child: Text(selfName, maxLines: 1, overflow: TextOverflow.ellipsis, style: _ts(13))),
        ]),
        if (_recipientSpecified) ...[
          const SizedBox(height: 8),
          _Field(
            controller: d.recipientController,
            hint: '受取人のお名前',
            onChanged: () {
              setState(() {});
              d.onTextChanged();
            },
          ),
        ],
      ]),
      section('書類・支払い', [
        Row(children: [
          Text('書類を選択', style: _ts(12, c: _sub)),
          const Spacer(),
          GestureDetector(
            onTap: d.onShowReceipt,
            child: Text('領収書プレビュー ›', style: _ts(12, c: _purple)),
          ),
        ]),
        const SizedBox(height: 6),
        Wrap(spacing: 6, runSpacing: 6, children: [
          for (final doc in const ['領収書', '請求書', 'レシート', '納品書', '印字領収書'])
            _Chip(doc, selected: d.documents.contains(doc), onTap: () => d.onDocumentToggled(doc)),
        ]),
        const SizedBox(height: 14),
        Text('支払い方法', style: _ts(12, c: _sub)),
        const SizedBox(height: 6),
        Wrap(spacing: 6, runSpacing: 6, children: [
          for (final p in const ['現金', 'カード'])
            _Chip(p, selected: d.paymentMethod == p, onTap: () => d.onPaymentChanged(p)),
        ]),
      ]),
      section('最終確認', [
        _sumRow('日時', d.summaryDate),
        if (d.summaryAddress.isNotEmpty) _sumRow('配達先', d.summaryAddress),
        _sumRow('商品', '${d.totalCount}個'),
        _sumRow('合計', '¥${_yen(d.totalPrice)}'),
        _sumRow('梱包方法', d.packagingType),
        _sumRow('事前連絡', '$recipient ・ ${d.preMethod == 'SMS' ? 'SMS' : '電話'} ・ ${d.preDateLabel}'),
      ]),
    ]);
  }

  Widget _sumRow(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 64, child: Text(k, style: _ts(12, c: _sub))),
          Expanded(child: Text(v, style: _ts(12.5, w: FontWeight.w500))),
        ]),
      );
}

class _Stepper2 extends StatelessWidget {
  const _Stepper2({required this.value, required this.onChanged});
  final int value;
  final void Function(int) onChanged;
  @override
  Widget build(BuildContext context) => Row(children: [
        GestureDetector(
          onTap: value > 0 ? () => onChanged(value - 1) : null,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: _line)),
            child: const Icon(Icons.remove, size: 16, color: _ink),
          ),
        ),
        SizedBox(width: 36, child: Center(child: Text('$value', style: _ts(15, c: _purple)))),
        GestureDetector(
          onTap: () => onChanged(value + 1),
          child: Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: _purple),
            child: const Icon(Icons.add, size: 16, color: Colors.white),
          ),
        ),
      ]);
}
