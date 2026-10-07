import 'package:flutter/material.dart';
import 'k_responsive.dart';
import 'package:katura_system/utils/app_colors.dart';

/// 配達元店舗を選ぶアニメーション付きメニュー。
/// showDialog で表示し、選択された店舗名を pop で返す（項目タップで即確定）。
class KBranchSelectDialog extends StatefulWidget {
  final List<String> branches;
  final String initialSelected;
  /// 指定した場合、この画面座標（履歴カード右端のチェックアイコン中心）を起点にメニューを展開する
  final Offset? anchor;

  const KBranchSelectDialog({
    super.key,
    required this.branches,
    required this.initialSelected,
    this.anchor,
  });

  @override
  State<KBranchSelectDialog> createState() => _KBranchSelectDialogState();
}

class _KBranchSelectDialogState extends State<KBranchSelectDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    )..forward();
    _scale = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _close([String? value]) async {
    await _controller.reverse();
    if (mounted) Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    // 画面の中心に表示する
    return Center(
      child: FadeTransition(
        opacity: _controller,
        child: ScaleTransition(
          scale: _scale,
          alignment: Alignment.center,
          child: _buildMenuBody(context),
        ),
      ),
    );
  }

  Widget _buildMenuBody(BuildContext context) {
    return Material(
              color: AppColors.dialogBackground,
              elevation: 12,
              borderRadius: BorderRadius.circular(rs(context, 14)),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: rs(context, 280),
                  maxWidth: rs(context, 380),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                          rs(context, 16), rs(context, 14), rs(context, 16), rs(context, 6)),
                      child: Text(
                        '｜配達元店舗',
                        style: TextStyle(
                          color: AppColors.dialogLabel,
                          fontWeight: FontWeight.bold,
                          fontSize: rf(context, 15),
                        ),
                      ),
                    ),
                    SizedBox(height: rs(context, 8)),
                    Divider(height: 1, color: Colors.black26),
                    ...widget.branches.map((b) {
                      final bool isNearest = b == widget.initialSelected;
                      return InkWell(
                        onTap: () => _close(b),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: rs(context, 16), vertical: rs(context, 14)),
                          child: Row(
                            children: [
                              Icon(
                                isNearest
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked,
                                color: isNearest ? AppColors.acceptButton : AppColors.dialogText,
                                size: rs(context, 22),
                              ),
                              SizedBox(width: rs(context, 12)),
                              Text(
                                b,
                                style: TextStyle(
                                  color: AppColors.dialogText,
                                  fontWeight: FontWeight.bold,
                                  fontSize: rf(context, 16),
                                ),
                              ),
                              if (isNearest) ...[
                                SizedBox(width: rs(context, 8)),
                                Text(
                                  '（最寄り）',
                                  style: TextStyle(
                                    color: AppColors.accentOrange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: rf(context, 13),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }),
                    SizedBox(height: rs(context, 6)),
                  ],
                ),
              ),
            );
  }
}
