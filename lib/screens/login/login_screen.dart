import 'package:flutter/material.dart';
import '../../models/staff_model.dart';
import '../../services/auth_service.dart';
import '../../services/staff_service.dart';
import '../../widgets/k_numeric_dial_pad.dart';
import '../../widgets/k_responsive.dart';
import '../main_screen.dart';
import 'package:katura_system/utils/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService();
  final _staffService = StaffService();

  List<Staff> _staffList = [];
  bool _isLoading = true;

  Staff? _selectedStaff;
  String _pin = '';
  bool _isPinConfirmMode = false;
  String _firstPin = '';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _restoreOrLoad();
  }

  Future<void> _restoreOrLoad() async {
    final restored = await _authService.restoreSession();
    if (!mounted) return;
    if (restored != null) {
      _goToMain();
      return;
    }
    await _loadStaff();
  }

  Future<void> _loadStaff() async {
    setState(() => _isLoading = true);
    final staffList = await _staffService.getAllStaff();
    if (!mounted) return;
    setState(() {
      _staffList = staffList;
      _isLoading = false;
    });
  }

  void _goToMain() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const MainScreen()));
  }

  void _selectStaff(Staff staff) {
    setState(() {
      _selectedStaff = staff;
      _pin = '';
      _firstPin = '';
      _isPinConfirmMode = false;
      _errorMessage = null;
    });
  }

  void _backToStaffSelect() {
    setState(() {
      _selectedStaff = null;
      _pin = '';
      _firstPin = '';
      _isPinConfirmMode = false;
      _errorMessage = null;
    });
  }

  void _onDigit(String digit) {
    if (_pin.length >= 4) return;
    setState(() {
      _pin += digit;
      _errorMessage = null;
    });
    if (_pin.length == 4) {
      _submitPin();
    }
  }

  void _onClear() {
    setState(() => _pin = '');
  }

  void _onBackspace() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _submitPin() async {
    final staff = _selectedStaff;
    if (staff == null) return;

    // PIN未登録スタッフは、初回にPINを2回入力させて新規登録する
    if (staff.pinHash.isEmpty) {
      if (!_isPinConfirmMode) {
        setState(() {
          _firstPin = _pin;
          _pin = '';
          _isPinConfirmMode = true;
        });
        return;
      }
      if (_pin != _firstPin) {
        setState(() {
          _errorMessage = 'PINが一致しません。もう一度入力してください';
          _pin = '';
          _firstPin = '';
          _isPinConfirmMode = false;
        });
        return;
      }
      await _authService.registerPin(staff, _pin);
      if (!mounted) return;
      _goToMain();
      return;
    }

    final result = await _authService.login(staff, _pin);
    if (!mounted) return;
    switch (result) {
      case LoginResult.success:
        _goToMain();
        break;
      case LoginResult.wrongPin:
        setState(() {
          _errorMessage = 'PINが正しくありません';
          _pin = '';
        });
        break;
      case LoginResult.pinNotSet:
        setState(() {
          _errorMessage = 'PINが未登録です';
          _pin = '';
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      body: SafeArea(
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator()
              : (_selectedStaff == null
                    ? _buildStaffSelect(context)
                    : _buildPinEntry(context)),
        ),
      ),
    );
  }

  Widget _buildStaffSelect(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: rs(context, 560)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: rs(context, 48),
            color: Colors.deepOrange,
          ),
          SizedBox(height: rs(context, 8)),
          Text(
            'スタッフを選択してください',
            style: TextStyle(
              fontSize: rf(context, 18),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: rs(context, 24)),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.6,
            ),
            itemCount: _staffList.length,
            itemBuilder: (context, i) {
              final staff = _staffList[i];
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mainBackground,
                  foregroundColor: Colors.black87,
                  side: const BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(rs(context, 12)),
                  ),
                ),
                onPressed: () => _selectStaff(staff),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      staff.name,
                      style: TextStyle(
                        fontSize: rf(context, 16),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (staff.role.isNotEmpty)
                      Text(
                        staff.role,
                        style: TextStyle(
                          fontSize: rf(context, 12),
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPinEntry(BuildContext context) {
    final staff = _selectedStaff!;
    final isNewPin = staff.pinHash.isEmpty;
    final title = !isNewPin
        ? '${staff.name} さんのPINを入力'
        : (_isPinConfirmMode ? 'もう一度PINを入力（確認）' : '${staff.name} さんの新しいPINを設定');

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: rs(context, 360)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: _backToStaffSelect,
            icon: const Icon(Icons.arrow_back),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: rf(context, 16),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: rs(context, 16)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (i) {
              final filled = i < _pin.length;
              return Container(
                margin: EdgeInsets.symmetric(horizontal: rs(context, 8)),
                width: rs(context, 18),
                height: rs(context, 18),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: filled ? Colors.deepOrange : Colors.transparent,
                  border: Border.all(color: Colors.grey),
                ),
              );
            }),
          ),
          if (_errorMessage != null) ...[
            SizedBox(height: rs(context, 8)),
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
          ],
          SizedBox(height: rs(context, 24)),
          KNumericDialPad(
            onInput: _onDigit,
            onClear: _onClear,
            onBackspace: _onBackspace,
          ),
        ],
      ),
    );
  }
}
