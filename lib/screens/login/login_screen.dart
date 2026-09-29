import 'package:flutter/material.dart';

import '../../services/email_auth_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/k_email_keyboard_pad.dart';
import '../../widgets/k_responsive.dart';
import '../main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;
  bool _keepLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _restoreLogin();
  }

  /// 保存済みの「ログイン状態を維持する」設定に従い、自動ログインするか判断する。
  Future<void> _restoreLogin() async {
    final authService = EmailAuthService();
    final keepLoggedIn = await authService.loadKeepLoggedIn();
    if (!mounted) return;
    setState(() => _keepLoggedIn = keepLoggedIn);

    final user = await authService.waitForRestoredUser();
    if (!mounted || user == null) return;

    if (keepLoggedIn) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainScreen()),
        (route) => false,
      );
    } else {
      await authService.signOut();
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// メール・パスワード欄タップ時にカスタムオンスクリーンキーボードを
  /// ボトムシートで表示し、OS標準キーボードの代わりに使わせる。
  void _openKeyboard({
    required TextEditingController controller,
    required bool isEmailMode,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: AppColors.mainBackground,
          insetPadding: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: KEmailKeyboardPad(
                controller: controller,
                isEmailMode: isEmailMode,
                onCompleted: () => Navigator.of(dialogContext).pop(),
              ),
            ),
          ),
        );
      },
    ).whenComplete(() {
      if (mounted) setState(() {});
    });
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('メールアドレスとパスワードを入力してください')));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await EmailAuthService().signInWithEmail(email, password);
      await EmailAuthService().saveKeepLoggedIn(_keepLoggedIn);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 画面幅・高さに対する比率でサイズ・余白を算出（widgets/k_responsive.dart の既存方式に準拠）
    final fieldWidth = rs(context, 340).clamp(240.0, 420.0);
    final fieldHeight = rs(context, 40).clamp(36.0, 56.0);
    final logoWidth = rs(context, 260).clamp(160.0, 340.0);
    final titleFont = rf(context, 24).clamp(18.0, 32.0);
    final fieldFont = rf(context, 16).clamp(13.0, 20.0);
    final buttonFont = rf(context, 16).clamp(13.0, 20.0);
    final checkLabelFont = rf(context, 16).clamp(13.0, 20.0);
    final footerFont = rf(context, 16).clamp(13.0, 20.0);
    final fieldRadius = rs(context, 20).clamp(14.0, 26.0);
    final checkboxSize = rs(context, 20).clamp(16.0, 24.0);
    final progressSize = rs(context, 20).clamp(16.0, 24.0);
    // ロゴ〜タイトルの間隔を詰め、email/password欄が画面中央付近に来るようにする
    final gapLogoTitle = rh(context, 16).clamp(8.0, 24.0);
    final gapTitleField = rh(context, 20).clamp(10.0, 32.0);
    final gap24 = rh(context, 24).clamp(12.0, 32.0);
    final gap32 = rh(context, 32).clamp(16.0, 48.0);
    final gap8 = rh(context, 8).clamp(4.0, 16.0);
    final footerBottom = rh(context, 24).clamp(12.0, 40.0);
    final footerPaddingH = rs(context, 24).clamp(12.0, 32.0);

    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset('assets/img/logo.png', width: logoWidth),
                          SizedBox(height: gapLogoTitle),
                          Text(
                            'ログイン認証',
                            style: TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: titleFont,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: gapTitleField),
                  Center(
                    child: SizedBox(
                      width: fieldWidth,
                      height: fieldHeight,
                      child: TextField(
                        controller: _emailController,
                        readOnly: true,
                        onTap: () => _openKeyboard(
                          controller: _emailController,
                          isEmailMode: true,
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: fieldFont,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondaryText,
                        ),
                        decoration: InputDecoration(
                          hintText: 'メールアドレスを入力',
                          hintStyle: TextStyle(
                            fontSize: fieldFont,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondaryText,
                          ),
                          filled: true,
                          fillColor: AppColors.mainBackground,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(fieldRadius),
                            borderSide: const BorderSide(
                              color: AppColors.accentOrange,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(fieldRadius),
                            borderSide: const BorderSide(
                              color: AppColors.accentOrange,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(fieldRadius),
                            borderSide: const BorderSide(
                              color: AppColors.accentOrange,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: gap24),
                  Center(
                    child: SizedBox(
                      width: fieldWidth,
                      height: fieldHeight,
                      child: TextField(
                        controller: _passwordController,
                        obscureText: true,
                        readOnly: true,
                        onTap: () => _openKeyboard(
                          controller: _passwordController,
                          isEmailMode: false,
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: fieldFont,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondaryText,
                        ),
                        decoration: InputDecoration(
                          hintText: 'パスワードを入力',
                          hintStyle: TextStyle(
                            fontSize: fieldFont,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondaryText,
                          ),
                          filled: true,
                          fillColor: AppColors.mainBackground,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(fieldRadius),
                            borderSide: const BorderSide(
                              color: AppColors.accentOrange,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(fieldRadius),
                            borderSide: const BorderSide(
                              color: AppColors.accentOrange,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(fieldRadius),
                            borderSide: const BorderSide(
                              color: AppColors.accentOrange,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: gap32),
                          SizedBox(
                            width: fieldWidth,
                            height: fieldHeight,
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accentOrange,
                                foregroundColor: AppColors.whiteText,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    fieldRadius,
                                  ),
                                ),
                              ),
                              child: _isSubmitting
                                  ? SizedBox(
                                      width: progressSize,
                                      height: progressSize,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.whiteText,
                                      ),
                                    )
                                  : Text(
                                      'ログイン',
                                      style: TextStyle(
                                        fontSize: buttonFont,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          SizedBox(height: gapLogoTitle),
                          SizedBox(
                            width: fieldWidth,
                            // 「ログイン状態を維持する」チェックボックスとラベルを横並びで表示
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                setState(() => _keepLoggedIn = !_keepLoggedIn);
                                EmailAuthService().saveKeepLoggedIn(
                                  _keepLoggedIn,
                                );
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: checkboxSize,
                                    height: checkboxSize,
                                    child: Checkbox(
                                      value: _keepLoggedIn,
                                      side: const BorderSide(
                                        color: AppColors.primaryText,
                                      ),
                                      onChanged: (value) {
                                        setState(
                                          () => _keepLoggedIn = value ?? false,
                                        );
                                        EmailAuthService().saveKeepLoggedIn(
                                          _keepLoggedIn,
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(width: gap8),
                                  Text(
                                    'ログイン状態を維持する',
                                    style: TextStyle(
                                      fontSize: checkLabelFont,
                                      fontWeight: FontWeight.w300,
                                      color: AppColors.primaryText,
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
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: footerBottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // フッター上部の区切り線を表示
                  Container(height: 1, color: AppColors.secondaryText),
                  SizedBox(height: gap8),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: footerPaddingH),
                    child: Text(
                      '株式会社OLDROOKIE',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: footerFont,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondaryText,
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
