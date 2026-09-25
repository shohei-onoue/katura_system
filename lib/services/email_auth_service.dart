import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// メールアドレス／パスワードによるFirebase Auth認証
class EmailAuthService {
  static const _prefsKeyKeepLoggedIn = 'keep_logged_in';

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  /// 表示用のユーザー名を返す（表示名 → メールアドレス → null の順）。
  String? get currentUserDisplayName {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    final name = user.displayName;
    if (name != null && name.isNotEmpty) return name;
    final email = user.email;
    if (email != null && email.isNotEmpty) return email;
    return null;
  }

  /// 「ログイン状態を保持する」設定を読み込む（未保存時は false）。
  Future<bool> loadKeepLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefsKeyKeepLoggedIn) ?? false;
  }

  /// 「ログイン状態を保持する」設定を保存する。
  Future<void> saveKeepLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKeyKeepLoggedIn, value);
  }

  /// Firebaseによるセッション復元を待ち、復元されたユーザーを返す。
  /// Webでは復元完了まで currentUser が null のため、最初の認証状態イベントを待つ。
  Future<User?> waitForRestoredUser() => _firebaseAuth.authStateChanges().first;

  /// メールアドレスとパスワードでサインインする。
  /// 失敗時は分かりやすい日本語メッセージを持つ [Exception] を投げる。
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_messageFor(e));
    }
  }

  Future<void> signOut() => _firebaseAuth.signOut();

  String _messageFor(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'メールアドレスまたはパスワードが正しくありません';
      case 'user-disabled':
        return 'このアカウントは無効化されています';
      case 'too-many-requests':
        return 'ログイン試行回数が多すぎます。しばらくしてから再度お試しください';
      case 'network-request-failed':
        return 'ネットワークエラーが発生しました。通信環境をご確認ください';
      default:
        return 'ログインに失敗しました。時間をおいて再度お試しください';
    }
  }
}
