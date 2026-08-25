import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/staff_model.dart';
import 'staff_service.dart';

enum LoginResult {
  success,
  wrongPin,
  pinNotSet,
}

/// スタッフ選択＋PINコードによるログインとセッション管理
class AuthService {
  static const _prefsKeyStaffId = 'logged_in_staff_id';

  final StaffService _staffService = StaffService();

  static String hashPin(String pin) {
    return sha256.convert(utf8.encode(pin)).toString();
  }

  /// PINでログインする。未登録スタッフの場合は [LoginResult.pinNotSet] を返す。
  Future<LoginResult> login(Staff staff, String pin) async {
    if (staff.pinHash.isEmpty) {
      return LoginResult.pinNotSet;
    }
    if (staff.pinHash != hashPin(pin)) {
      return LoginResult.wrongPin;
    }
    await _persistSession(staff.id);
    return LoginResult.success;
  }

  /// 初回ログイン時にPINを新規登録する
  Future<void> registerPin(Staff staff, String pin) async {
    final hash = hashPin(pin);
    await _staffService.setPinHash(staff.id, hash);
    await _persistSession(staff.id);
  }

  Future<void> _persistSession(String staffId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKeyStaffId, staffId);
  }

  /// 端末に保存されたセッションから、ログイン中のスタッフを復元する
  Future<Staff?> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final staffId = prefs.getString(_prefsKeyStaffId);
    if (staffId == null) return null;

    final staffList = await _staffService.getAllStaff();
    for (final staff in staffList) {
      if (staff.id == staffId) return staff;
    }
    // スタッフが削除／非アクティブ化されていた場合はセッションを破棄
    await logout();
    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKeyStaffId);
  }
}
