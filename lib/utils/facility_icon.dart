import 'package:flutter/material.dart';

/// 受注カードに出すアイコン。引取りは「手渡し」、それ以外は施設名から種類を判定する（空なら個人宅＝家）。
IconData orderIcon({required String deliveryType, required String facilityName}) {
  if (deliveryType == '引取') return Icons.volunteer_activism;
  final n = facilityName.trim();
  if (n.isEmpty || n == '個人宅') return Icons.home_rounded;
  bool has(List<String> ws) => ws.any(n.contains);
  if (has(['病院'])) return Icons.local_hospital_rounded;
  if (has(['クリニック', '医院', '診療所', '歯科'])) return Icons.medical_services_rounded;
  if (has(['製薬', '薬局', 'ファーマ', '薬品'])) return Icons.medication_rounded;
  if (has(['寺', '院', '堂'])) return Icons.temple_buddhist_rounded;
  if (has(['神社', '大社', '神宮', '宮'])) return Icons.temple_hindu_rounded;
  if (has(['学校', '学園', '大学', '幼稚園', '保育'])) return Icons.school_rounded;
  return Icons.business_rounded;
}
