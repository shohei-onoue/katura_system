import 'package:flutter/material.dart';
import '../../../models/planning_models.dart';

class CookingScheduleList extends StatelessWidget {
  final bool isLoading;
  final List<CookingTask> cookingTasks;

  const CookingScheduleList({
    super.key,
    required this.isLoading,
    required this.cookingTasks,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (cookingTasks.isEmpty) return const Center(child: Text('対象の受注データがありません'));

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: cookingTasks.length,
      itemBuilder: (context, index) {
        final task = cookingTasks[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 100,
                  color: Colors.orange.shade50,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('開始', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      Text(task.startTime, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const Icon(Icons.arrow_downward, size: 12, color: Colors.grey),
                      Text(task.endTime, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(task.menuName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text('${task.quantity}個', 
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('納品先: ${task.customerName} (${task.branchName})', 
                          style: const TextStyle(color: Colors.blueGrey, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text('配送予定: ${task.deliveryTime}', 
                          style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
