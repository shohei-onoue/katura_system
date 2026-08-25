import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../widgets/k_choice_group.dart';
import '../widgets/k_responsive.dart';

/// アプリ全体の設定を一括管理する画面
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('設定', style: TextStyle(fontWeight: FontWeight.bold, fontSize: rf(context, 18))),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(rav(context, 24)),
        child: Container(
          constraints: BoxConstraints(maxWidth: rs(context, 480)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(rs(context, 12)),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 4))],
          ),
          padding: EdgeInsets.all(rs(context, 24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.edit_note, color: Colors.deepPurple.withValues(alpha: 0.7)),
                  SizedBox(width: rs(context, 8)),
                  Text('文字入力方式',
                    style: TextStyle(fontSize: rf(context, 16), fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: rs(context, 4)),
              Text(
                'アプリ内すべての文字入力欄に、選択した入力方式が一括で反映されます。',
                style: TextStyle(fontSize: rf(context, 12), color: Colors.grey.shade600),
              ),
              SizedBox(height: rs(context, 16)),
              ValueListenableBuilder<KInputMode>(
                valueListenable: SettingsService.inputMode,
                builder: (context, mode, _) {
                  return KChoiceGroup<KInputMode>(
                    label: '',
                    showLabel: false,
                    selectedValue: mode,
                    selectedColor: Colors.deepPurple,
                    onSelected: (newMode) {
                      SettingsService.setInputMode(newMode);
                    },
                    items: [
                      KChoiceItem(label: 'ペンタブ', value: KInputMode.pen),
                      KChoiceItem(label: 'キーボード', value: KInputMode.keyboard),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
