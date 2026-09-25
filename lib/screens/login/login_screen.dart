import 'package:flutter/material.dart';

import '../../services/email_auth_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/k_email_keyboard_pad.dart';
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
  void _openKeyboard({required TextEditingController controller, required bool isEmailMode}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 12,
            right: 12,
            top: 12,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 12,
          ),
          child: SafeArea(
            top: false,
            child: KEmailKeyboardPad(
              controller: controller,
              isEmailMode: isEmailMode,
              onCompleted: () => Navigator.of(sheetContext).pop(),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('メールアドレスとパスワードを入力してください')),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 48),
                Center(
                  child: Image.asset('assets/img/logo.png', width: 260),
                ),
                const SizedBox(height: 16),
                const Text(
                  'ログイン認証',
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 24,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Center(
                  child: SizedBox(
                    width: 340,
                    height: 40,
                    child: TextField(
                      controller: _emailController,
                      readOnly: true,
                      onTap: () => _openKeyboard(controller: _emailController, isEmailMode: true),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondaryText,
                      ),
                      decoration: InputDecoration(
                        hintText: 'メールアドレスを入力',
                        hintStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondaryText,
                        ),
                        filled: true,
                        fillColor: AppColors.mainBackground,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: AppColors.accentOrangeLight,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: AppColors.accentOrangeLight,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: AppColors.accentOrangeLight,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: SizedBox(
                    width: 340,
                    height: 40,
                    child: TextField(
                      controller: _passwordController,
                      obscureText: true,
                      readOnly: true,
                      onTap: () => _openKeyboard(controller: _passwordController, isEmailMode: false),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondaryText,
                      ),
                      decoration: InputDecoration(
                        hintText: 'パスワードを入力',
                        hintStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondaryText,
                        ),
                        filled: true,
                        fillColor: AppColors.mainBackground,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: AppColors.accentOrangeLight,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: AppColors.accentOrangeLight,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: AppColors.accentOrangeLight,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: SizedBox(
                    width: 340,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentOrangeLight,
                        foregroundColor: AppColors.whiteText,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.whiteText,
                              ),
                            )
                          : const Text(
                              'ログイン',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: SizedBox(
                    width: 340,
                    // 「ログイン状態を維持する」チェックボックスとラベルを横並びで表示
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Checkbox(
                            value: _keepLoggedIn,
                            side: const BorderSide(color: Colors.black),
                            onChanged: (value) {
                              setState(() => _keepLoggedIn = value ?? false);
                              EmailAuthService().saveKeepLoggedIn(_keepLoggedIn);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'ログイン状態を維持する',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // フッター上部の区切り線を表示
                  Container(height: 1, color: AppColors.borderLight2),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      '株式会社OLDROOKIE',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 16,
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
