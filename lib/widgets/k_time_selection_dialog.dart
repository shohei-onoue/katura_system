import 'package:flutter/material.dart';
import 'k_responsive.dart';
import 'k_button.dart';
import 'k_drum_time_picker.dart';

class KTimeSelectionDialog extends StatelessWidget {
  final DateTime initialDateTime;
  final TimeOfDay minTime;
  final TimeOfDay maxTime;
  final int interval;
  final String title;
  final Color themeColor;

  const KTimeSelectionDialog({
    super.key,
    required this.initialDateTime,
    this.minTime = const TimeOfDay(hour: 0, minute: 0),
    this.maxTime = const TimeOfDay(hour: 23, minute: 59),
    this.interval = 15,
    this.title = '時間の設定',
    this.themeColor = Colors.deepPurple,
  });

  @override
  Widget build(BuildContext context) {
    DateTime tempTime = initialDateTime;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rav(context, 16))),
      child: Container(
        width: rs(context, 400),
        padding: EdgeInsets.all(rav(context, 20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: TextStyle(fontSize: rf(context, 18), fontWeight: FontWeight.bold)),
            SizedBox(height: rav(context, 20)),
            
            KDrumTimePicker(
              minTime: minTime,
              maxTime: maxTime,
              interval: interval,
              selectedDateTime: tempTime,
              onTimeSelected: (dt) {
                tempTime = dt;
              },
              themeColor: themeColor,
            ),
            
            SizedBox(height: rav(context, 24)),
            
            Row(
              children: [
                Expanded(
                  child: KButton(
                    label: 'キャンセル', 
                    onPressed: () => Navigator.pop(context),
                    isSecondary: true,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(width: rav(context, 12)),
                Expanded(
                  child: KButton(
                    label: '反映', 
                    onPressed: () {
                      Navigator.pop(context, tempTime);
                    },
                    color: themeColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
