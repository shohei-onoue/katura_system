import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';
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
/// カードをタップすると、その配達先へ向かう区間のラインが青で表示される。
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

  WebViewController? _controller;
  String _summary = 'ルートを読み込み中...';
  List<int> _legSeconds = []; // 各配達先へ向かう区間の移動秒数
  int _selected = -1;

  String _hex(Color c) => '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final route = await GoogleMapsService().getRoute(widget.origin, widget.stops.map((s) => s.location).toList());
    if (!mounted) return;
    if (route == null) {
      setState(() => _summary = 'ルートを取得できませんでした');
      return;
    }
    final km = route.meters / 1000;
    final min = (route.seconds / 60).ceil();
    final apiKey = DefaultFirebaseOptions.currentPlatform.apiKey;
    final points = jsonEncode(route.points.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList());
    final legs = jsonEncode(route.legs.map((l) => l.polyline).toList());
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
      function selectLeg(idx) {
        lines.forEach(function (l, i) {
          l.setOptions({ strokeColor: i === idx ? SELECTED_COLOR : DEFAULT_COLOR, zIndex: i === idx ? 2 : 1 });
        });
      }
      function initMap() {
        const points = $points;
        const legs = $legs;
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
      _summary = '全${widget.stops.length}件　合計 ${km.toStringAsFixed(1)}km　約$min分（移動のみ）';
      _legSeconds = route.legs.map((l) => l.seconds).toList();
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadHtmlString(html);
    });
  }

  void _select(int i) {
    final next = _selected == i ? -1 : i;
    setState(() => _selected = next);
    _controller?.runJavaScript('selectLeg($next)');
  }

  Widget _travel(BuildContext context, int i) {
    final sec = i < _legSeconds.length ? _legSeconds[i] : null;
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
        child: Row(
          children: [
            Text('${i + 1}', style: white),
            SizedBox(width: rs(context, 8)),
            Text(s.time, style: white),
            SizedBox(width: rs(context, 8)),
            Expanded(child: Text(s.place, maxLines: 1, overflow: TextOverflow.ellipsis, style: white)),
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
                        : WebViewWidget(controller: _controller!),
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
