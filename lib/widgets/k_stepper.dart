import 'package:flutter/material.dart';
import 'k_responsive.dart';

class KStepper extends StatelessWidget {
  final int currentStep;
  final List<String> steps;
  final Function(int) onStepTapped;

  const KStepper({
    super.key,
    required this.currentStep,
    required this.steps,
    required this.onStepTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: rs(context, 4), horizontal: rs(context, 12)),
      decoration: BoxDecoration(
        color: Colors.transparent, // 背景を透明にしてカードの影を際立たせる
      ),
      child: Row(
        children: List.generate(steps.length, (index) {
          final isCompleted = index < currentStep;
          final isActive = index == currentStep;
          
          return Expanded(
            flex: isActive ? 16 : 10, // 現在地を大幅に強調
            child: GestureDetector(
              onTap: () => onStepTapped(index),
              child: AnimatedScale(
                scale: isActive ? 1.08 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      if (isActive) 
                        BoxShadow(
                          color: Colors.deepOrange.withValues(alpha: 0.3),
                          blurRadius: rs(context, 12),
                          spreadRadius: rs(context, 2),
                          offset: Offset(0, rs(context, 4)),
                        ),
                    ],
                  ),
                  child: Card(
                    elevation: isActive ? 12 : (isCompleted ? 2 : 0),
                    margin: EdgeInsets.symmetric(horizontal: rs(context, 4), vertical: rs(context, 4)),
                    color: isActive ? Colors.white : (isCompleted ? Colors.grey.shade50 : Colors.grey.shade100),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(rs(context, 8)),
                      side: BorderSide(
                        color: isActive ? Colors.deepOrange : Colors.transparent,
                        width: rs(context, 2.5),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: rs(context, 6), horizontal: rs(context, 8)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: rs(context, 24),
                            height: rs(context, 24),
                            decoration: BoxDecoration(
                              color: isActive ? Colors.deepOrange : (isCompleted ? Colors.green : Colors.grey.shade400),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: isCompleted
                                  ? Icon(Icons.check, color: Colors.white, size: rs(context, 16))
                                  : Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: rf(context, 12),
                                      ),
                                    ),
                            ),
                          ),
                          SizedBox(width: rs(context, 8)),
                          Flexible(
                            child: Text(
                              steps[index],
                              style: TextStyle(
                                color: isActive ? Colors.black : Colors.grey.shade600,
                                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                fontSize: rf(context, 13),
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
