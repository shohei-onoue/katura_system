// Figma node 89:1635 (mobile UI, 390x844 design). Data-driven version.
import 'package:flutter/material.dart';

import '../../models/branch_model.dart';
import '../../services/settings_service.dart';

const _bg = Color(0xFFF3F7F6);
const _ink = Color(0xFF1D1B20);
const _grey = Color(0xFF6B6F76);
const _purple = Color(0xFF673AB7);
const _purpleTint = Color(0xFFEDE7F6);
const _edge = Color(0xFFEDF0F2);
const _line = Color(0xFFE4E7EB);
const _red = Color(0xFFD32F2F);

TextStyle _ts(double size, {FontWeight w = FontWeight.w700, Color c = _ink}) =>
    TextStyle(
      fontSize: size,
      fontWeight: w,
      color: c,
      height: 1.3,
      decoration: TextDecoration.none,
    );

Icon _ic(IconData d, double s, Color c) => Icon(d, size: s, color: c);

class MobileSettingsData {
  const MobileSettingsData({
    required this.inputMode,
    required this.onInputMode,
    required this.prefLoading,
    required this.sendingTime,
    required this.callbackPhone,
    required this.onEditTime,
    required this.onEditPhone,
    required this.branchLoading,
    required this.branches,
    required this.onAddBranch,
    required this.onEditBranch,
    required this.onDeleteBranch,
    required this.onAdjustBranch,
    this.onOpenMenu,
    this.onNavigate,
  });

  final KInputMode inputMode;
  final void Function(KInputMode) onInputMode;
  final bool prefLoading;
  final String sendingTime;
  final String callbackPhone;
  final VoidCallback onEditTime;
  final VoidCallback onEditPhone;
  final bool branchLoading;
  final List<BranchModel> branches;
  final VoidCallback onAddBranch;
  final void Function(BranchModel) onEditBranch;
  final void Function(BranchModel) onDeleteBranch;
  final void Function(BranchModel) onAdjustBranch;
  final VoidCallback? onOpenMenu;
  final void Function(int)? onNavigate;
}

/// 店舗編集シートの保存内容
class MobileBranchEditResult {
  const MobileBranchEditResult({
    required this.name,
    required this.company,
    required this.address,
    required this.phone,
    required this.vehicles,
  });
  final String name;
  final String company;
  final String address;
  final String phone;
  final String vehicles;
}

/// 店舗の追加・編集シート
class MobileBranchEditSheet extends StatefulWidget {
  const MobileBranchEditSheet({
    super.key,
    required this.title,
    required this.branch,
    required this.pickAddress,
    required this.inputNumber,
    required this.onSave,
  });

  final String title;
  final BranchModel branch;
  final Future<String?> Function() pickAddress;
  final Future<String?> Function(String title, String initial, String unit)
  inputNumber;
  final Future<String?> Function(MobileBranchEditResult) onSave;

  @override
  State<MobileBranchEditSheet> createState() => _MobileBranchEditSheetState();
}

class _MobileBranchEditSheetState extends State<MobileBranchEditSheet> {
  late final TextEditingController _name = TextEditingController(
    text: widget.branch.name,
  );
  late final TextEditingController _company = TextEditingController(
    text: widget.branch.companyName,
  );
  late String _address = widget.branch.address;
  late String _phone = widget.branch.phone;
  late String _vehicles = widget.branch.deliveryVehicleCount == 0
      ? ''
      : widget.branch.deliveryVehicleCount.toString();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _company.dispose();
    super.dispose();
  }

  BoxDecoration get _deco => BoxDecoration(
    color: const Color(0xFFF6F7F9),
    border: Border.all(color: _line),
    borderRadius: BorderRadius.circular(10),
  );

  Widget _label(String s) => Padding(
    padding: const EdgeInsets.only(top: 11, bottom: 5),
    child: Text(s, style: _ts(11.5, c: _grey)),
  );

  Widget _tap(String text, String hint, VoidCallback onTap) =>
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: 44,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 13),
          decoration: _deco,
          child: Text(
            text.isEmpty ? hint : text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _ts(14, w: FontWeight.w400, c: text.isEmpty ? _grey : _ink),
          ),
        ),
      );

  Widget _text(TextEditingController c) => Container(
    height: 44,
    padding: const EdgeInsets.symmetric(horizontal: 13),
    decoration: _deco,
    child: TextField(
      controller: c,
      style: _ts(14, w: FontWeight.w400),
      decoration: const InputDecoration(
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 13),
      ),
    ),
  );

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      setState(() => _error = '店舗名を入力してください');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final err = await widget.onSave(
      MobileBranchEditResult(
        name: _name.text.trim(),
        company: _company.text.trim(),
        address: _address,
        phone: _phone,
        vehicles: _vehicles,
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
          mainAxisSize: MainAxisSize.min,
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
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                children: [
                  _label('店舗名'),
                  _text(_name),
                  _label('社名'),
                  _text(_company),
                  _label('住所'),
                  _tap(_address, '住所を検索', () async {
                    final v = await widget.pickAddress();
                    if (v != null) setState(() => _address = v);
                  }),
                  _label('電話番号'),
                  _tap(_phone, '番号を入力', () async {
                    final v = await widget.inputNumber('電話番号の入力', _phone, '');
                    if (v != null) setState(() => _phone = v);
                  }),
                  _label('配送車両数'),
                  _tap(_vehicles.isEmpty ? '' : '$_vehicles台', '台数を入力', () async {
                    final v = await widget.inputNumber('配送車両数の入力', _vehicles, '台');
                    if (v != null) {
                      setState(() => _vehicles = v.replaceAll(RegExp(r'[^0-9]'), ''));
                    }
                  }),
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
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text('完了', style: _ts(15, c: Colors.white)),
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

/// 店舗削除確認ダイアログ（Figma 89:2160）
Future<bool> showMobileStoreDeleteDialog(
  BuildContext context,
  String name,
) async {
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
              child: Center(child: _ic(Icons.delete_outline, 28, const Color(0xFFF44336))),
            ),
            const SizedBox(height: 12),
            Text('店舗を削除しますか？', style: _ts(17)),
            const SizedBox(height: 10),
            Text(
              '「$name」を削除します。この操作は取り消せません。',
              textAlign: TextAlign.center,
              style: _ts(13, w: FontWeight.w400, c: _grey),
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
                      child: Center(
                        child: Text('削除', style: _ts(14, c: Colors.white)),
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
  return r == true;
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({this.onNavigate});

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
                            decoration: i == 4
                                ? BoxDecoration(
                                    color: _purpleTint,
                                    borderRadius: BorderRadius.circular(15),
                                  )
                                : null,
                            child: Center(
                              child: _ic(_icons[i], 20, i == 4 ? _purple : _grey),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _labels[i],
                            style: _ts(
                              10.5,
                              w: i == 4 ? FontWeight.w700 : FontWeight.w500,
                              c: i == 4 ? _purple : _grey,
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
        Positioned(
          left: 0,
          right: 0,
          bottom: 8,
          child: Center(
            child: Container(
              width: 134,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class MobileSettings891635 extends StatelessWidget {
  const MobileSettings891635(this.d, {super.key});

  final MobileSettingsData d;

  Widget _section(IconData icon, String title) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 15, 16, 8),
    child: Row(
      children: [
        _ic(icon, 16, _purple),
        const SizedBox(width: 5),
        Text(title, style: _ts(12, c: _grey)),
      ],
    ),
  );

  Widget _card(Widget child, {EdgeInsets? padding}) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 14),
    padding: padding,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: _edge),
      borderRadius: BorderRadius.circular(14),
    ),
    child: child,
  );

  Widget _modeBtn(String label, KInputMode m) {
    final sel = d.inputMode == m;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => d.onInputMode(m),
        child: Container(
          height: 36,
          decoration: BoxDecoration(
            color: sel ? _purple : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(label, style: _ts(13, c: sel ? Colors.white : _grey)),
          ),
        ),
      ),
    );
  }

  Widget _prefRow(IconData icon, String label, String value, VoidCallback onTap, {bool strong = false}) =>
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: 49,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              _ic(icon, 20, _grey),
              const SizedBox(width: 10),
              Text(label, style: _ts(11.5, w: FontWeight.w400, c: _grey)),
              const Spacer(),
              Text(
                value.isEmpty ? '未設定' : value,
                style: _ts(16, w: strong ? FontWeight.w700 : FontWeight.w400, c: strong ? _ink : _grey),
              ),
              const SizedBox(width: 12),
              _ic(Icons.edit, 18, _purple),
            ],
          ),
        ),
      );

  Widget _branchCard(BranchModel b) => Container(
    margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: _edge),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 110,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                color: const Color(0xFFEEF0F2),
                child: b.imageUrl.isEmpty
                    ? Center(child: _ic(Icons.storefront, 36, const Color(0xFFB5BAC0)))
                    : Image.network(
                        b.imageUrl,
                        webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Center(
                          child: _ic(Icons.storefront, 36, const Color(0xFFB5BAC0)),
                        ),
                      ),
              ),
              if (b.id.isNotEmpty)
                Positioned(
                  left: 10,
                  bottom: 9,
                  child: GestureDetector(
                    onTap: () => d.onAdjustBranch(b),
                    child: Container(
                      height: 20,
                      padding: const EdgeInsets.symmetric(horizontal: 7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          _ic(Icons.edit_location_alt, 12, const Color(0xFFFF6D00)),
                          const SizedBox(width: 3),
                          Text('位置調整', style: _ts(10.5, c: const Color(0xFFFF6D00))),
                        ],
                      ),
                    ),
                  ),
                ),
              Positioned(
                right: 10,
                bottom: 9,
                child: GestureDetector(
                  onTap: () => d.onDeleteBranch(b),
                  child: Container(
                    height: 20,
                    padding: const EdgeInsets.symmetric(horizontal: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        _ic(Icons.delete_outline, 12, _red),
                        const SizedBox(width: 3),
                        Text('削除', style: _ts(10.5, c: _red)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(b.name.isEmpty ? '（店舗名未設定）' : b.name, style: _ts(16)),
                    const SizedBox(height: 4),
                    Text(
                      b.companyName.isEmpty ? '社名未設定' : b.companyName,
                      style: _ts(11.5, w: FontWeight.w400, c: _grey),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      b.address.isEmpty ? '住所未設定' : b.address,
                      style: _ts(11.5, w: FontWeight.w400, c: _grey),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        _ic(Icons.call, 12, _grey),
                        const SizedBox(width: 4),
                        Text(
                          b.phone.isEmpty ? '電話番号未設定' : b.phone,
                          style: _ts(11.5, w: FontWeight.w400, c: _grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => d.onEditBranch(b),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: _ic(Icons.more_vert, 20, const Color(0xFF9AA0A6)),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _bg,
    bottomNavigationBar: _BottomNav(onNavigate: d.onNavigate),
    body: Column(
      children: [
        Container(
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
        ),
        Container(
          height: 52,
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: d.onOpenMenu,
                child: _ic(Icons.menu, 20, _ink),
              ),
              const SizedBox(width: 16),
              Text('設定', style: _ts(18)),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 16),
            children: [
              _section(Icons.edit_note, '文字入力方式'),
              _card(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'アプリ内すべての文字入力欄に、選択した入力方式が一括で反映されます。',
                      style: _ts(11.5, w: FontWeight.w400, c: _grey),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECEFF1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          _modeBtn('ペンタブ', KInputMode.pen),
                          _modeBtn('キーボード', KInputMode.keyboard),
                        ],
                      ),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(14),
              ),
              _section(Icons.mail_outline, '事前確認・事前連絡'),
              _card(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 13, 14, 10),
                      child: Text(
                        '事前確認メールを配達前日に自動送信する時刻と、事前電話連絡の担当者番号を設定します。担当者番号には、電話連絡のし忘れ防止リマインドSMSが送信されます。',
                        style: _ts(11.5, w: FontWeight.w400, c: _grey),
                      ),
                    ),
                    if (d.prefLoading)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else ...[
                      _prefRow(
                        Icons.schedule,
                        '送信時刻',
                        d.sendingTime.isEmpty ? '' : '前日 ${d.sendingTime}',
                        d.onEditTime,
                        strong: true,
                      ),
                      _prefRow(
                        Icons.phone_forwarded,
                        '担当者番号',
                        d.callbackPhone,
                        d.onEditPhone,
                        strong: d.callbackPhone.isNotEmpty,
                      ),
                    ],
                  ],
                ),
              ),
              _section(Icons.storefront, '店舗登録'),
              if (d.branchLoading)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                for (final b in d.branches) _branchCard(b),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: d.onAddBranch,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ic(Icons.add, 20, const Color(0xFFFF6D00)),
                      const SizedBox(width: 4),
                      Text('店舗を追加', style: _ts(16, c: const Color(0xFFFF6D00))),
                    ],
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
