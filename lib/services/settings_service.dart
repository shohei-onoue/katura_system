import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum KInputMode { keyboard, pen }

/// アプリ全体の設定を一括管理する（文字入力方式など）
class SettingsService {
  static const _prefsKeyInputMode = 'default_input_mode';

  /// アプリ全体で共有する文字入力方式（キーボード／ペンタブ）
  /// KMultimodalTextField はこの値を購読し、設定変更が全フィールドへ即時反映される。
  static final ValueNotifier<KInputMode> inputMode = ValueNotifier(KInputMode.pen);

  /// アプリ起動時に一度呼び出し、保存済みの設定を復元する
  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKeyInputMode);
    inputMode.value = saved == KInputMode.keyboard.name ? KInputMode.keyboard : KInputMode.pen;
  }

  static Future<void> setInputMode(KInputMode mode) async {
    inputMode.value = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKeyInputMode, mode.name);
  }
}
