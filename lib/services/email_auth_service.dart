import 'package:firebase_auth/firebase_auth.dart';

/// メールアドレス／パスワードによるFirebase Auth認証
class EmailAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

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
