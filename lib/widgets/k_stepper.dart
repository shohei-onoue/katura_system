import 'package:flutter/material.dart';

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
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: List.generate(steps.length, (index) {
          final isCompleted = index < currentStep;
          final isActive = index == currentStep;
          
          return Expanded(
            child: GestureDetector(
              onTap: () => onStepTapped(index),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isActive ? Colors.deepOrange : (isCompleted ? Colors.green : Colors.grey.shade300),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isActive ? Colors.white : Colors.grey.shade600,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    steps[index],
                    style: TextStyle(
                      color: isActive ? Colors.black : Colors.grey.shade500,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                  if (index < steps.length - 1)
                    Expanded(
                      child: Container(
                        height: 2,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        color: isCompleted ? Colors.green : Colors.grey.shade200,
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
