import 'package:flutter/material.dart';
import 'k_responsive.dart';

class KStepper extends StatelessWidget {
  final int currentStep;
  final int maxReachedStep;
  final bool isFinalStepAvailable; // 追加: 商品が入っている場合などに最終ステップを活性化
  final List<String> steps;
  final Function(int) onStepTapped;

  const KStepper({
    super.key,
    required this.currentStep,
    this.maxReachedStep = 0,
    this.isFinalStepAvailable = false,
    required this.steps,
    required this.onStepTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: rav(context, 4), horizontal: rav(context, 12)),
      decoration: const BoxDecoration(
        color: Colors.transparent, // 背景を透明にしてカードの影を際立たせる
      ),
      child: Row(
        children: List.generate(steps.length, (index) {
          final isLast = index == steps.length - 1;
          final isClickable = index <= maxReachedStep || (isLast && isFinalStepAvailable);
          final isCompleted = index <= maxReachedStep && index != currentStep; // 修正: 実際に到達・通過済みのものだけチェックマーク
          final isActive = index == currentStep;
          final isAvailableButUnvisited = isClickable && !isCompleted && !isActive; // 追加: ジャンプ可能な未来のステップ
          
          return Expanded(
            flex: isActive ? 16 : 10, // 現在地を大幅に強調
            child: GestureDetector(
              onTap: isClickable ? () => onStepTapped(index) : null,
              child: AnimatedScale(
                scale: isActive ? 1.05 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      if (isActive) 
                        BoxShadow(
                          color: Colors.deepOrange.withValues(alpha: 0.3),
                          blurRadius: rav(context, 12),
                          spreadRadius: rav(context, 2),
                          offset: Offset(0, rav(context, 4)),
                        ),
                    ],
                  ),
                  child: Card(
                    elevation: isActive ? 8 : (isClickable ? 2 : 0),
                    margin: EdgeInsets.symmetric(horizontal: rav(context, 2), vertical: rav(context, 4)),
                    color: isActive ? Colors.white : (isClickable ? Colors.grey.shade50 : Colors.grey.shade100),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(rav(context, 8)),
                      side: BorderSide(
                        color: isActive ? Colors.deepOrange : (isAvailableButUnvisited ? Colors.deepPurple.withValues(alpha: 0.3) : Colors.transparent),
                        width: rav(context, 2),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: rav(context, 6), horizontal: rav(context, 4)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: rav(context, 22),
                            height: rav(context, 22),
                            decoration: BoxDecoration(
                              color: isActive 
                                  ? Colors.deepOrange 
                                  : (isCompleted 
                                      ? Colors.green 
                                      : (isAvailableButUnvisited ? Colors.deepPurple : Colors.grey.shade400)),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: isCompleted
                                  ? Icon(Icons.check, color: Colors.white, size: rav(context, 14))
                                  : Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: rf(context, 11),
                                      ),
                                    ),
                            ),
                          ),
                          SizedBox(width: rav(context, 4)),
                          Flexible(
                            child: Text(
                              steps[index],
                              style: TextStyle(
                                color: isActive ? Colors.black : (isClickable ? Colors.black87 : Colors.grey.shade600),
                                fontWeight: isActive || isAvailableButUnvisited ? FontWeight.bold : FontWeight.normal,
                                fontSize: rf(context, 12),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
