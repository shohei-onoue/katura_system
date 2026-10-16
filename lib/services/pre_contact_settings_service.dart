import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// 事前連絡の設定（既定の連絡方法・SMS/メール文面テンプレート）
class PreContactSettings {
  final String defaultMethod; // '電話' / 'SMS' / 'メール' / ''
  final String smsTemplate;
  final String mailTemplate;

  const PreContactSettings({
    this.defaultMethod = '',
    this.smsTemplate = '',
    this.mailTemplate = '',
  });
}

class PreContactSettingsService {
  PreContactSettingsService._();

  /// 起動中キャッシュ（load成功時に更新）。同期関数から参照用。
  static String cachedDefaultMethod = '';
  static String cachedSmsTemplate = '';
  static String cachedMailTemplate = '';

  /// 変更通知用（load/save成功時に更新）
  static final ValueNotifier<PreContactSettings> notifier =
      ValueNotifier<PreContactSettings>(const PreContactSettings());

  static DocumentReference<Map<String, dynamic>> get _doc =>
      FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'katura-system-database',
      ).collection('settings').doc('pre_contact_config');

  static void _updateCache(PreContactSettings s) {
    cachedDefaultMethod = s.defaultMethod;
    cachedSmsTemplate = s.smsTemplate;
    cachedMailTemplate = s.mailTemplate;
    notifier.value = s;
  }

  static Future<PreContactSettings> load() async {
    try {
      final snap = await _doc.get();
      final d = snap.data() ?? <String, dynamic>{};
      final s = PreContactSettings(
        defaultMethod: (d['defaultMethod'] as String?) ?? '',
        smsTemplate: (d['smsTemplate'] as String?) ?? '',
        mailTemplate: (d['mailTemplate'] as String?) ?? '',
      );
      _updateCache(s);
      return s;
    } catch (_) {
      return const PreContactSettings();
    }
  }

  static Future<void> save({
    required String defaultMethod,
    required String smsTemplate,
    required String mailTemplate,
  }) async {
    await _doc.set({
      'defaultMethod': defaultMethod,
      'smsTemplate': smsTemplate,
      'mailTemplate': mailTemplate,
    }, SetOptions(merge: true));
    _updateCache(PreContactSettings(
      defaultMethod: defaultMethod,
      smsTemplate: smsTemplate,
      mailTemplate: mailTemplate,
    ));
  }

  /// {お客様名} {配達日} {配達時間} {お弁当} {お会計} {お支払い方法} を置換する。
  static String applyTemplate(
    String template, {
    required String name,
    required DateTime date,
    required String time,
    String items = '',
    String total = '',
    String payment = '',
  }) {
    return template
        .replaceAll('{お客様名}', name)
        .replaceAll('{配達日}', '${date.month}月${date.day}日')
        .replaceAll('{配達時間}', time)
        .replaceAll('{お弁当}', items)
        .replaceAll('{お会計}', total)
        .replaceAll('{お支払い方法}', payment);
  }
}
