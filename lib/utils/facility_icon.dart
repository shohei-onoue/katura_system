import 'package:flutter/material.dart';

/// 受注カードに出すアイコン。引取りは「手渡し」、施設名があれば「会社」、なければ（個人宅）「家」。
IconData orderIcon({required String deliveryType, required String facilityName}) {
  if (deliveryType == '引取') return Icons.volunteer_activism;
  final n = facilityName.trim();
  if (n.isEmpty || n == '個人宅') return Icons.home_rounded;
  return Icons.business_rounded;
}
