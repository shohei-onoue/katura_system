import 'package:flutter/material.dart';
import 'k_responsive.dart';
import 'k_button.dart';
import 'k_dialog_title.dart';
import 'k_multimodal_text_field.dart';
import 'k_shared_quantity_input.dart';
import '../models/menu_model.dart';
import 'package:katura_system/utils/app_colors.dart';

class KItemDetailsDialog extends StatefulWidget {
  final MenuModel menu;
  final int initialQuantity;

  const KItemDetailsDialog({
    super.key,
    required this.menu,
    this.initialQuantity = 1,
  });

  @override
  State<KItemDetailsDialog> createState() => _KItemDetailsDialogState();
}

class _KItemDetailsDialogState extends State<KItemDetailsDialog> {
  late int _quantity;
  late int _specialOrderQuantity;
  final _specialOrderController = TextEditingController();
  String _teaOption = 'なし';
  String _teaType = 'ペットボトル';
  late int _price; // 専用価格（初期値0円。0のままなら基本価格を使う）

  @override
  void initState() {
    super.initState();
    // メニューカードで入力済みの数量を同期。特注数量はデフォルト0のまま
    _quantity = widget.initialQuantity > 0 ? widget.initialQuantity : 1;
    _specialOrderQuantity = 0;
    _price = 0;
  }

  @override
  void dispose() {
    _specialOrderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double qInputWidth = rs(context, 100);
    final double rowHeight = rs(context, 44);

    return Dialog(
      backgroundColor: AppColors.popupBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rav(context, 16))),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: rs(context, 750),
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Padding(
          padding: EdgeInsets.all(rav(context, 20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ヘッダー
              Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: KDialogTitle('${widget.menu.name} の詳細設定', fontSize: rf(context, 18)),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Divider(height: rs(context, 16)),

              // 1. 注文数量
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildSectionLabel('1. 注文数量')),
                  KSharedQuantityInput(
                    value: _quantity,
                    onChanged: (v) {
                      setState(() {
                        _quantity = v;
                        if (_specialOrderQuantity > _quantity) {
                          _specialOrderQuantity = _quantity;
                        }
                      });
                    },
                    title: '注文数量',
                    width: qInputWidth,
                    height: rowHeight,
                    clearOnDirectInput: true,
                  ),
                ],
              ),
              Divider(height: rs(context, 28)),

              // 2. 値段
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildSectionLabel('2. 値段')),
                  Padding(
                    padding: EdgeInsets.only(top: (rowHeight - rf(context, 15) * 1.4) / 2, right: rs(context, 6)),
                    child: Text('￥', style: TextStyle(fontSize: rf(context, 15), fontWeight: FontWeight.bold, color: AppColors.primaryText)),
                  ),
                  KSharedQuantityInput(
                    value: _price,
                    onChanged: (v) => setState(() => _price = v),
                    title: '値段',
                    width: qInputWidth,
                    height: rowHeight,
                    showButtons: false,
                    unit: '円',
                  ),
                ],
              ),
              Divider(height: rs(context, 28)),

              // 3. 特注内容
              Row(
                children: [
                  SizedBox(
                    width: rs(context, 121),
                    height: rowHeight,
                    child: Align(alignment: Alignment.topLeft, child: _buildSectionLabel('3. 特注内容')),
                  ),
                  SizedBox(width: rs(context, 12)),
                  Expanded(
                    child: KMultimodalTextField(
                      label: '',
                      controller: _specialOrderController,
                      maxLines: 1,
                      showLabel: false,
                      height: rowHeight,
                      hintText: '例：エビフライ追加など',
                    ),
                  ),
                  SizedBox(width: rs(context, 12)),
                  _buildSpecialQuickButtons(),
                  SizedBox(width: rs(context, 12)),
                  KSharedQuantityInput(
                    value: _specialOrderQuantity,
                    onChanged: (v) {
                      if (v <= _quantity) {
                        setState(() => _specialOrderQuantity = v);
                      }
                    },
                    title: '特注の適用数量',
                    width: qInputWidth,
                    height: rowHeight,
                  ),
                ],
              ),
              Divider(height: rs(context, 28)),

              // 4. お茶設定
              Row(
                children: [
                  SizedBox(
                    width: rs(context, 93),
                    height: rowHeight,
                    child: Align(alignment: Alignment.topLeft, child: _buildSectionLabel('4. お茶設定')),
                  ),
                  SizedBox(width: rs(context, 44)),
                  _buildTeaOptionsUI(),
                  SizedBox(width: rs(context, 44)),
                  SizedBox(
                    width: rs(context, 58),
                    height: rowHeight,
                    child: Center(
                      child: Container(width: 1, height: rs(context, 40), color: const Color(0xFFCAC4D0)),
                    ),
                  ),
                  SizedBox(width: rs(context, 44)),
                  _buildTeaTypeUI(),
                ],
              ),

              SizedBox(height: rs(context, 32)),
              // アクションボタン
              Row(
                children: [
                  Expanded(
                    child: KButton(
                      label: 'キャンセル',
                      color: Colors.grey,
                      isSecondary: true,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  SizedBox(width: rs(context, 16)),
                  Expanded(
                    child: KButton(
                      label: 'カートへ入れる',
                      color: AppColors.accentPurple,
                      onPressed: () {
                        Navigator.pop(context, _buildResult());
                      },
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

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: rf(context, 15),
        fontWeight: FontWeight.bold,
        color: Colors.blueGrey.shade900,
      ),
    );
  }

  Map<String, dynamic> _line(int qty, int price, String special, int specialQty) {
    return {
      'id': widget.menu.id,
      'name': widget.menu.name,
      'price': price,
      'quantity': qty,
      'specialOrder': special,
      'specialOrderQuantity': specialQty,
      'topping': '',
      'teaOption': _teaOption,
      'teaType': _teaOption == 'なし' ? '' : _teaType,
      'teaQuantity': 0,
    };
  }

  /// 値段は特注分に適用。通常分は基本価格の別行に分けて合計が正しくなるようにする
  List<Map<String, dynamic>> _buildResult() {
    final base = widget.menu.price;
    final special = _specialOrderController.text;
    // 0円のままなら専用価格は未設定として基本価格を使う（合計0円を防ぐ）
    final unitPrice = _price > 0 ? _price : base;
    final priceChanged = unitPrice != base;
    var specQty = _specialOrderQuantity;
    if (specQty == 0 && priceChanged) specQty = _quantity;
    if (specQty == 0) return [_line(_quantity, base, special, 0)];
    final normalQty = _quantity - specQty;
    return [
      if (normalQty > 0) _line(normalQty, base, '', 0),
      _line(specQty, unitPrice, special, specQty),
    ];
  }

  /// 選択ボタン（幅100×高さ44固定）。選択中は selectButton、未選択は薄いグレー
  Widget _buildSelectChip(String label, bool isSelected, VoidCallback onTap) {
    return SizedBox(
      width: rs(context, 100),
      height: rs(context, 44),
      child: Material(
        color: isSelected ? AppColors.selectButton : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(rs(context, 8)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(rs(context, 8)),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: rf(context, 13),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChipRow(List<Widget> chips) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < chips.length; i++) ...[
          if (i > 0) SizedBox(width: rs(context, 10.67)),
          chips[i],
        ],
      ],
    );
  }

  Widget _buildSpecialQuickButtons() {
    return _buildChipRow(['肉増量'].map((t) {
      final selected = _specialOrderController.text.contains(t);
      return _buildSelectChip(t, selected, () {
        setState(() {
          final cur = _specialOrderController.text;
          _specialOrderController.text = selected
              ? cur.replaceAll(t, '').trim()
              : (cur.isEmpty ? t : '$cur $t');
        });
      });
    }).toList());
  }

  Widget _buildTeaTypeUI() {
    return _buildChipRow(['ペットボトル', 'パック'].map((t) =>
        _buildSelectChip(t, _teaType == t, () => setState(() => _teaType = t))).toList());
  }

  Widget _buildTeaOptionsUI() {
    return _buildChipRow(['込み', '別'].map((opt) =>
        _buildSelectChip(opt, _teaOption == opt,
          () => setState(() => _teaOption = _teaOption == opt ? 'なし' : opt))).toList());
  }
}
