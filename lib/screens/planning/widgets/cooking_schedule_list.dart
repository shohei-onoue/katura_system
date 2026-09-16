import 'package:flutter/material.dart';
import '../../../models/planning_models.dart';
import '../../../widgets/k_responsive.dart';
import 'package:katura_system/utils/app_colors.dart';

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
      padding: EdgeInsets.all(rs(context, 24)),
      itemCount: cookingTasks.length,
      itemBuilder: (context, index) {
        final task = cookingTasks[index];
        return Card(
          margin: EdgeInsets.only(bottom: rs(context, 16)),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: rs(context, 100),
                  color: Colors.orange.shade50,
                  padding: EdgeInsets.all(rs(context, 12)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('開始', style: TextStyle(fontSize: rf(context, 10), color: Colors.grey)),
                      Text(task.startTime, style: TextStyle(fontWeight: FontWeight.bold, fontSize: rf(context, 16))),
                      Icon(Icons.arrow_downward, size: rs(context, 12), color: Colors.grey),
                      Text(task.endTime, style: TextStyle(fontWeight: FontWeight.bold, fontSize: rf(context, 16))),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(rs(context, 16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(task.menuName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: rf(context, 18))),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: rs(context, 8), vertical: rs(context, 2)),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(rs(context, 4)),
                              ),
                              child: Text('${task.quantity}個', 
                                style: TextStyle(color: AppColors.background, fontSize: rf(context, 12), fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        SizedBox(height: rs(context, 8)),
                        Text('納品先: ${task.customerName} (${task.branchName})', 
                          style: TextStyle(color: Colors.blueGrey, fontSize: rf(context, 13))),
                        SizedBox(height: rs(context, 4)),
                        Text('配送予定: ${task.deliveryTime}', 
                          style: TextStyle(color: Colors.grey, fontSize: rf(context, 13))),
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
