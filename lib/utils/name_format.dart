/// 顧客名の表示用：末尾に「様」を付ける（すでに 様・さま・御中 なら付けない。空は空のまま）。
String withHonorific(String name) {
  final n = name.trim();
  if (n.isEmpty) return n;
  if (RegExp(r'(様|さま|御中)$').hasMatch(n)) return n;
  return '$n 様';
}
