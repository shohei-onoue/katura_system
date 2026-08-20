import 'package:flutter/material.dart';
import 'k_responsive.dart';
import 'k_button.dart';
import 'k_multimodal_text_field.dart';
import 'k_shared_quantity_input.dart';
import '../models/menu_model.dart';

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
  int _teaQuantity = 0;

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity > 0 ? widget.initialQuantity : 1;
    _specialOrderQuantity = _quantity; 
  }

  @override
  void dispose() {
    _specialOrderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double qInputWidth = rs(context, 80); // 受注内容ステップと統一

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rav(context, 16))),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: rs(context, 750),
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(rav(context, 24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ヘッダー
              Row(
                children: [
                  Icon(Icons.edit_note, color: Colors.deepPurple, size: rs(context, 24)),
                  SizedBox(width: rs(context, 12)),
                  Expanded(
                    child: Text(
                      '${widget.menu.name} の詳細設定',
                      style: TextStyle(fontSize: rf(context, 18), fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Divider(height: rs(context, 32)),
              
              // 1. 注文数量
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildSectionLabel('1. 注文数量'),
                  Text('数量', style: _subLabelStyle(context)),
                ],
              ),
              SizedBox(height: rs(context, 8)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: rs(context, 12)),
                      child: Text('注文するお弁当の総数を入力してください', 
                        style: TextStyle(color: Colors.grey, fontSize: rf(context, 13))),
                    )
                  ),
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
                    height: rs(context, 44),
                  ),
                ],
              ),
              SizedBox(height: rs(context, 32)),

              // 2. 特注内容
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildSectionLabel('2. 特注内容'),
                  Text('適用数量', style: _subLabelStyle(context)),
                ],
              ),
              SizedBox(height: rs(context, 8)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: KMultimodalTextField(
                      label: '',
                      controller: _specialOrderController,
                      maxLines: 1,
                      showLabel: false,
                      height: rs(context, 44), // 数量入力と高さを合わせる
                      hintText: '特注内容を入力（例：わさび抜き）',
                    ),
                  ),
                  SizedBox(width: rs(context, 16)),
                  KSharedQuantityInput(
                    value: _specialOrderQuantity,
                    onChanged: (v) {
                      if (v <= _quantity) {
                        setState(() => _specialOrderQuantity = v);
                      }
                    },
                    title: '特注の適用数量',
                    width: qInputWidth,
                    height: rs(context, 44),
                  ),
                ],
              ),
              SizedBox(height: rs(context, 32)),

              // 3. お茶の設定
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildSectionLabel('3. お茶の設定'),
                  if (_teaOption == '特典')
                    Text('特典本数', style: _subLabelStyle(context)),
                ],
              ),
              SizedBox(height: rs(context, 8)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: rs(context, 2)),
                      child: _buildTeaOptionsUI(),
                    ),
                  ),
                  SizedBox(width: rs(context, 16)),
                  Opacity(
                    opacity: _teaOption == '特典' ? 1.0 : 0.0,
                    child: IgnorePointer(
                      ignoring: _teaOption != '特典',
                      child: KSharedQuantityInput(
                        value: _teaQuantity,
                        onChanged: (v) => setState(() => _teaQuantity = v),
                        title: '特典お茶の本数',
                        width: qInputWidth,
                        height: rs(context, 44),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: rs(context, 48)),
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
                      color: Colors.deepPurple,
                      onPressed: () {
                        Navigator.pop(context, [{
                          'id': widget.menu.id,
                          'name': widget.menu.name,
                          'price': widget.menu.price,
                          'quantity': _quantity,
                          'specialOrder': _specialOrderController.text,
                          'specialOrderQuantity': _specialOrderQuantity,
                          'topping': '', 
                          'teaOption': _teaOption,
                          'teaQuantity': _teaQuantity,
                        }]);
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

  TextStyle _subLabelStyle(BuildContext context) {
    return TextStyle(
      fontSize: rf(context, 12), 
      fontWeight: FontWeight.bold, 
      color: Colors.blueGrey
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

  Widget _buildTeaOptionsUI() {
    final options = ['なし', '込み', '別', '特典'];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final isSelected = _teaOption == opt;
        return ChoiceChip(
          label: Text(opt, style: const TextStyle(fontWeight: FontWeight.bold)),
          selected: isSelected,
          onSelected: (val) {
            if (val) setState(() => _teaOption = opt);
          },
          selectedColor: Colors.deepPurple,
          labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontSize: 13),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          visualDensity: VisualDensity.standard,
          showCheckmark: false,
        );
      }).toList(),
    );
  }
}
