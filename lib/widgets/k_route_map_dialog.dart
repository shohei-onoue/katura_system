import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'html_view/k_html_view.dart';
import '../firebase_options.dart';
import '../services/google_maps_service.dart';
import 'package:katura_system/utils/app_colors.dart';
import 'k_responsive.dart';

/// ルート上の配達先1件。[location] は LatLng か住所(String)。
class KRouteStop {
  final Object location;
  final String time; // 配達時間（表示用）
  final String place; // 市区町村（表示用）
  final Color color; // カードの色
  const KRouteStop({required this.location, required this.time, required this.place, required this.color});
}

/// 配送ルートの地図ダイアログ。左7：地図、右3：配達予定カードと移動時間。
/// 出発地（店舗）から、経由地を通って最後の配達先まで。経路は Routes API で1回だけ取得する。
/// カードをタップすると開き（アコーディオン）、その区間のラインが青で表示される。
/// 開いたカードで「一般優先（標準）／高速優先」を選ぶと、その区間の移動時間と経路が変わる。
/// 区間のナビ情報はDB（route_cache）に保存し、2回目以降はAPIを呼ばない。
class KRouteMapDialog extends StatefulWidget {
  final String title;
  final LatLng origin;
  final List<KRouteStop> stops; // 最後が目的地、それ以外は経由地

  const KRouteMapDialog({super.key, required this.title, required this.origin, required this.stops});

  @override
  State<KRouteMapDialog> createState() => _KRouteMapDialogState();
}

class _KRouteMapDialogState extends State<KRouteMapDialog> {
  static const Color _selectedLine = Colors.blue;

  final GoogleMapsService _maps = GoogleMapsService();
  KHtmlController? _controller;
  String _summary = 'ルートを読み込み中...';
  List<LatLng> _points = []; // 出発地 → 各配達先の座標
  List<RouteLeg?> _legs = []; // 各配達先へ向かう区間
  List<bool> _highway = []; // 区間ごとの経路タイプ（false＝一般優先［標準］、true＝高速優先）
  final Map<String, RouteLeg?> _optLegs = {}; // 開いたカードに出す「一般／高速」それぞれの区間（キー＝"区間-高速か"）
  int _selected = -1;
  bool _mapReady = false;

  String _hex(Color c) => '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

  @override
  void initState() {
    super.initState();
    _highway = List.filled(widget.stops.length, false);
    _load();
  }

  /// 住所(String)の配達先は座標に直す。座標が分からなければ null。
  Future<LatLng?> _toLatLng(Object p) async {
    if (p is LatLng) return p;
    final r = await _maps.getLatLngFromAddress(p.toString());
    return r == null ? null : LatLng(r['lat'] as double, r['lng'] as double);
  }

  Future<void> _load() async {
    final resolved = await Future.wait(widget.stops.map((s) => _toLatLng(s.location)));
    if (!mounted) return;
    if (resolved.any((p) => p == null)) {
      setState(() => _summary = 'ルートを取得できませんでした');
      return;
    }
    final points = [widget.origin, ...resolved.cast<LatLng>()];
    // 区間ごとに取得（DBに保存済みの区間はAPIを呼ばない）
    final legs = await Future.wait([
      for (int i = 0; i < widget.stops.length; i++) _maps.getLeg(points[i], points[i + 1], highway: _highway[i]),
    ]);
    if (!mounted) return;
    if (legs.any((l) => l == null)) {
      setState(() => _summary = 'ルートを取得できませんでした');
      return;
    }
    _points = points;
    _legs = legs;
    final apiKey = DefaultFirebaseOptions.currentPlatform.apiKey;
    final pointsJson = jsonEncode(points.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList());
    final legsJson = jsonEncode(legs.map((l) => l!.polyline).toList());
    final html = '''
<!DOCTYPE html>
<html>
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://maps.googleapis.com/maps/api/js?key=$apiKey&libraries=geometry&language=ja"></script>
    <style>html, body, #map { height: 100%; margin: 0; padding: 0; }</style>
  </head>
  <body>
    <div id="map"></div>
    <script>
      const DEFAULT_COLOR = '${_hex(AppColors.secondaryText)}';
      const SELECTED_COLOR = '${_hex(_selectedLine)}';
      const lines = [];
      let selectedIdx = -1;
      function selectLeg(idx) {
        selectedIdx = idx;
        lines.forEach(function (l, i) {
          l.setOptions({ strokeColor: i === idx ? SELECTED_COLOR : DEFAULT_COLOR, zIndex: i === idx ? 2 : 1 });
        });
      }
      // 一般/高速を切り替えたときに、その区間の経路線だけ差し替える
      function setLegPath(idx, enc) {
        lines[idx].setPath(google.maps.geometry.encoding.decodePath(enc));
      }
      function initMap() {
        const points = $pointsJson;
        const legs = $legsJson;
        const map = new google.maps.Map(document.getElementById('map'), {
          mapTypeControl: false, streetViewControl: false, fullscreenControl: false,
        });
        const bounds = new google.maps.LatLngBounds();
        legs.forEach(function (enc) {
          const path = google.maps.geometry.encoding.decodePath(enc);
          lines.push(new google.maps.Polyline({ path: path, map: map, strokeColor: DEFAULT_COLOR, strokeWeight: 6, strokeOpacity: 0.9, zIndex: 1 }));
          path.forEach(function (p) { bounds.extend(p); });
        });
        points.forEach(function (p, i) {
          new google.maps.Marker({
            position: p, map: map,
            label: { text: i === 0 ? '店' : String(i), color: '${_hex(AppColors.whiteText)}', fontWeight: 'bold' },
          });
          bounds.extend(p);
        });
        map.fitBounds(bounds);
      }
      window.onload = initMap;
    </script>
  </body>
</html>
''';
    setState(() {
      _updateSummary();
      _mapReady = true;
      _controller = KHtmlController()..loadHtml(html);
    });
  }

  void _updateSummary() {
    final meters = _legs.fold<int>(0, (a, l) => a + (l?.meters ?? 0));
    final seconds = _legs.fold<int>(0, (a, l) => a + (l?.seconds ?? 0));
    _summary = '全${widget.stops.length}件　合計 ${(meters / 1000).toStringAsFixed(1)}km　約${(seconds / 60).ceil()}分（移動のみ）';
  }

  void _select(int i) {
    final next = _selected == i ? -1 : i; // もう一度タップで閉じる
    setState(() => _selected = next);
    _controller?.runJavaScript('selectLeg($next)');
    if (next >= 0) _loadOptionLegs(next);
  }

  /// 開いたカードの一般優先・高速優先の移動時間を取得する（DB保存済みならAPIは呼ばない）。
  Future<void> _loadOptionLegs(int i) async {
    for (final h in [false, true]) {
      if (_optLegs.containsKey('$i-$h') || i >= _points.length - 1) continue;
      final leg = await _maps.getLeg(_points[i], _points[i + 1], highway: h);
      if (!mounted) return;
      setState(() => _optLegs['$i-$h'] = leg);
    }
  }

  /// 区間 [i] の経路タイプを切り替え、移動時間と地図の経路線を更新する（DB保存済みならAPIは呼ばない）。
  Future<void> _setHighway(int i, bool highway) async {
    if (_highway[i] == highway) return;
    final leg = await _maps.getLeg(_points[i], _points[i + 1], highway: highway);
    if (!mounted || leg == null) return;
    setState(() {
      _highway[i] = highway;
      _legs[i] = leg;
      _optLegs['$i-$highway'] = leg;
      _updateSummary();
    });
    _controller?.runJavaScript('setLegPath($i, ${jsonEncode(leg.polyline)})');
  }

  Widget _travel(BuildContext context, int i) {
    final sec = i < _legs.length ? _legs[i]?.seconds : null;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: rs(context, 4)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_car, size: rs(context, 18), color: AppColors.primary),
          SizedBox(width: rs(context, 4)),
          Text(sec == null ? '移動--分' : '移動${(sec / 60).ceil()}分',
              style: TextStyle(fontSize: rf(context, 13), fontWeight: FontWeight.bold, color: AppColors.primary)),
        ],
      ),
    );
  }

  /// 開いたカード内の「一般優先／高速優先」ラジオボタン（背景は whiteText、右端に移動時間）
  Widget _routeTypeRadios(BuildContext context, int i) {
    final dark = TextStyle(fontSize: rf(context, 14), fontWeight: FontWeight.bold, color: AppColors.primaryText);
    Widget option(String label, bool value) {
      final sec = _optLegs['$i-$value']?.seconds;
      return InkWell(
        onTap: _mapReady ? () => _setHighway(i, value) : null,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: rs(context, 4)),
          child: Row(
            children: [
              Icon(_highway[i] == value ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: AppColors.primaryText, size: rs(context, 22)),
              SizedBox(width: rs(context, 8)),
              Expanded(child: Text(label, style: dark)),
              Text(sec == null ? '--分' : '${(sec / 60).ceil()}分', style: dark),
            ],
          ),
        ),
      );
    }
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: rs(context, 8)),
      padding: EdgeInsets.symmetric(horizontal: rs(context, 10), vertical: rs(context, 4)),
      decoration: BoxDecoration(color: AppColors.whiteText, borderRadius: BorderRadius.circular(rs(context, 6))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [option('一般優先', false), option('高速優先', true)],
      ),
    );
  }

  Widget _card(BuildContext context, int i) {
    final s = widget.stops[i];
    final white = TextStyle(fontSize: rf(context, 14), fontWeight: FontWeight.bold, color: AppColors.whiteText);
    return GestureDetector(
      onTap: () => _select(i),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: rs(context, 10), vertical: rs(context, 12)),
        decoration: BoxDecoration(
          color: _selected == i ? s.color : s.color.withValues(alpha: 0.5), // 未選択は透過50%
          borderRadius: BorderRadius.circular(rs(context, 8)),
          border: _selected == i ? Border.all(color: _selectedLine, width: 3) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('${i + 1}', style: white),
                SizedBox(width: rs(context, 8)),
                Text(s.time, style: white),
                SizedBox(width: rs(context, 8)),
                Expanded(child: Text(s.place, maxLines: 1, overflow: TextOverflow.ellipsis, style: white)),
                Icon(_selected == i ? Icons.expand_less : Icons.expand_more, color: AppColors.whiteText),
              ],
            ),
            if (_selected == i) _routeTypeRadios(context, i),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: AppColors.accentPurple,
          foregroundColor: AppColors.mainBackground,
          actions: [IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))],
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(rs(context, 16)),
              color: Colors.deepPurple.shade50,
              child: Row(
                children: [
                  const Icon(Icons.route, color: AppColors.accentOrange),
                  SizedBox(width: rs(context, 12)),
                  Expanded(child: Text(_summary, style: TextStyle(fontWeight: FontWeight.bold, fontSize: rf(context, 16)))),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 7,
                    child: _controller == null
                        ? const Center(child: CircularProgressIndicator())
                        : KHtmlView(controller: _controller!),
                  ),
                  Expanded(
                    flex: 3,
                    child: ListView(
                      padding: EdgeInsets.all(rs(context, 12)),
                      children: [
                        for (int i = 0; i < widget.stops.length; i++) ...[
                          _travel(context, i),
                          _card(context, i),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
