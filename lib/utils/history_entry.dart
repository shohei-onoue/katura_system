/// 配達先の履歴1件（"施設名: 住所 (緯度, 経度) [IMG:..] [RMK:..]"）を、表示・選択用に整える。
/// - 古い保存形式 "施設名:住所"（コロンの後ろにスペースなし）を "施設名: 住所" に直す
/// - 施設名が空なら「個人宅」にする（「名称なし」を出さない）
String normalizeHistoryEntry(String entry) {
  var e = entry.trim();
  if (e.startsWith(': ') || e.startsWith(':')) {
    e = '個人宅: ${e.substring(1).trim()}';
  } else if (!e.contains(': ')) {
    final m = RegExp(r'^([^:\[\(]+):(\S.*)$').firstMatch(e);
    if (m != null) e = '${m.group(1)!.trim()}: ${m.group(2)!}';
  }
  return e;
}
