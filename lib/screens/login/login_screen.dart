import 'package:flutter/material.dart';

import '../../services/email_auth_service.dart';
import '../../utils/app_colors.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (EmailAuthService().currentUser != null) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainScreen()),
          (route) => false,
        );
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondaryText,
                      ),
                      decoration: InputDecoration(
                        hintText: 'メールアドレスを入力してください',
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
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondaryText,
                      ),
                      decoration: InputDecoration(
                        hintText: 'パスワードを入力してください',
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
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
