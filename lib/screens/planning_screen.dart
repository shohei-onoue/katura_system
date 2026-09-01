import 'package:flutter/material.dart';
import '../widgets/k_responsive.dart';

class PlanningScreen extends StatelessWidget {
  const PlanningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('調理・仕入れ計画', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.construction_rounded, size: rs(context, 64), color: Colors.orange),
            SizedBox(height: rs(context, 16)),
            Text('準備中',
                style: TextStyle(fontSize: rf(context, 20), fontWeight: FontWeight.bold, color: Colors.orange.shade800)),
          ],
        ),
      ),
    );
  }
}
