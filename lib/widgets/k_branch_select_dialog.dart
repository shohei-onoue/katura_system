import 'package:flutter/material.dart';
import 'k_responsive.dart';

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
    final menu = FadeTransition(
      opacity: _controller,
      child: ScaleTransition(
        scale: _scale,
        alignment: widget.anchor != null ? Alignment.topRight : Alignment.topCenter,
        child: _buildMenuBody(context),
      ),
    );

    if (widget.anchor != null) {
      final screen = MediaQuery.of(context).size;
      final double maxW = rs(context, 380);
      final double right = (screen.width - widget.anchor!.dx).clamp(rs(context, 8), screen.width - rs(context, 40));
      final double top = widget.anchor!.dy.clamp(rs(context, 8), screen.height - rs(context, 200));
      return Stack(
        children: [
          Positioned(
            top: top,
            right: right,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxW),
              child: menu,
            ),
          ),
        ],
      );
    }

    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(top: rs(context, 90)),
        child: menu,
      ),
    );
  }

  Widget _buildMenuBody(BuildContext context) {
    return Material(
              color: const Color(0xFF000038),
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
                        '配達元店舗',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: rf(context, 15),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: rs(context, 16)),
                      child: Text(
                        '配達先から最も近い店舗を選択しています。',
                        style: TextStyle(color: Colors.white70, fontSize: rf(context, 11)),
                      ),
                    ),
                    SizedBox(height: rs(context, 8)),
                    Divider(height: 1, color: Colors.white24),
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
                                color: Colors.white,
                                size: rs(context, 22),
                              ),
                              SizedBox(width: rs(context, 12)),
                              Text(
                                b,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: rf(context, 16),
                                ),
                              ),
                              if (isNearest) ...[
                                SizedBox(width: rs(context, 8)),
                                Text(
                                  '（最寄り）',
                                  style: TextStyle(
                                    color: Colors.orange,
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
