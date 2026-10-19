import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'html_view/k_html_view.dart';
import '../firebase_options.dart';
import '../services/google_maps_service.dart';
import 'package:katura_system/utils/app_colors.dart';
import 'k_responsive.dart';
import '../screens/phone/phone_order_list_style.dart';

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
  final bool vertical; // true＝スマホ用（上に地図、下にルートカード）

  const KRouteMapDialog({super.key, required this.title, required this.origin, required this.stops, this.vertical = false});

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
  bool _sheetOpen = true; // スマホ版：配達時間シートの開閉

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
      function notifyDart(m) {
        try { if (window.KMap) window.KMap.postMessage(m); } catch (e) {}
      }
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
          const line = new google.maps.Polyline({ path: path, map: map, strokeColor: DEFAULT_COLOR, strokeWeight: 6, strokeOpacity: 0.9, zIndex: 1 });
          const lineIdx = lines.length;
          line.addListener('click', function () { notifyDart('leg:' + lineIdx); });
          lines.push(line);
          path.forEach(function (p) { bounds.extend(p); });
        });
        points.forEach(function (p, i) {
          const marker = new google.maps.Marker({
            position: p, map: map,
            label: { text: i === 0 ? '店' : String(i), color: '${_hex(AppColors.whiteText)}', fontWeight: 'bold' },
          });
          marker.addListener('click', function () { notifyDart(i === 0 ? 'open' : 'leg:' + (i - 1)); });
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
      _controller = (widget.vertical ? KHtmlController(channelName: 'KMap', onMessage: _onMapMessage) : KHtmlController())..loadHtml(html);
    });
  }

  void _updateSummary() {
    final meters = _legs.fold<int>(0, (a, l) => a + (l?.meters ?? 0));
    final seconds = _legs.fold<int>(0, (a, l) => a + (l?.seconds ?? 0));
    _summary = '全${widget.stops.length}件　合計 ${(meters / 1000).toStringAsFixed(1)}km　約${(seconds / 60).ceil()}分（移動のみ）';
  }

  /// 地図のピン/ラインのタップ（スマホ版）：カード欄を開き、該当カードを選択する（選択中でも閉じない）。
  void _onMapMessage(String m) {
    if (!mounted) return;
    setState(() => _sheetOpen = true);
    if (!m.startsWith('leg:')) return;
    final i = int.tryParse(m.substring(4));
    if (i == null || i < 0 || i >= widget.stops.length || _selected == i) return;
    _select(i);
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
      padding: EdgeInsets.symmetric(vertical: _s(4)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_car, size: _s(18), color: AppColors.primary),
          SizedBox(width: _s(4)),
          Text(sec == null ? '移動--分' : '移動${(sec / 60).ceil()}分',
              style: TextStyle(fontSize: _f(13), fontWeight: FontWeight.bold, color: AppColors.primary)),
        ],
      ),
    );
  }

  /// 開いたカード内の「一般優先／高速優先」ラジオボタン（背景は whiteText、右端に移動時間）
  Widget _routeTypeRadios(BuildContext context, int i) {
    final dark = TextStyle(fontSize: _f(14), fontWeight: FontWeight.bold, color: AppColors.primaryText);
    Widget option(String label, bool value) {
      final sec = _optLegs['$i-$value']?.seconds;
      return InkWell(
        onTap: _mapReady ? () => _setHighway(i, value) : null,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: _s(4)),
          child: Row(
            children: [
              Icon(_highway[i] == value ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: AppColors.primaryText, size: _s(22)),
              SizedBox(width: _s(8)),
              Expanded(child: Text(label, style: dark)),
              Text(sec == null ? '--分' : '${(sec / 60).ceil()}分', style: dark),
            ],
          ),
        ),
      );
    }
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: _s(8)),
      padding: EdgeInsets.symmetric(horizontal: _s(10), vertical: _s(4)),
      decoration: BoxDecoration(color: AppColors.whiteText, borderRadius: BorderRadius.circular(_s(6))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [option('一般優先', false), option('高速優先', true)],
      ),
    );
  }

  Widget _card(BuildContext context, int i) {
    final s = widget.stops[i];
    final white = TextStyle(fontSize: _f(14), fontWeight: FontWeight.bold, color: AppColors.whiteText);
    return GestureDetector(
      onTap: () => _select(i),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: _s(10), vertical: _s(12)),
        decoration: BoxDecoration(
          color: _selected == i ? s.color : s.color.withValues(alpha: 0.5), // 未選択は透過50%
          borderRadius: BorderRadius.circular(_s(8)),
          border: _selected == i ? Border.all(color: _selectedLine, width: 3) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('${i + 1}', style: white),
                SizedBox(width: _s(8)),
                Text(s.time, style: white),
                SizedBox(width: _s(8)),
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

  double _s(double v) => widget.vertical ? v * 0.8 : rs(context, v); // スマホ(縦)は実寸基準
  double _f(double v) => widget.vertical ? v : rf(context, v);

  Widget _mapView() => _controller == null ? const Center(child: CircularProgressIndicator()) : KHtmlView(controller: _controller!);

  Widget _cardList() => ListView(
        padding: EdgeInsets.all(_s(12)),
        children: [
          for (int i = 0; i < widget.stops.length; i++) ...[
            _travel(context, i),
            _card(context, i),
          ],
        ],
      );

  // ---- スマホ(vertical)：Figma「1号車 配送ルート」 ----
  Widget _vTravel(int i) {
    final sec = i < _legs.length ? _legs[i]?.seconds : null;
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.directions_car_rounded, size: 14, color: PL.blue),
          const SizedBox(width: 3),
          Text(sec == null ? '移動--分' : '移動${(sec / 60).ceil()}分', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: PL.blue)),
        ],
      ),
    );
  }

  String _navPlace(Object p) => p is LatLng ? '${p.latitude},${p.longitude}' : Uri.encodeComponent(p.toString());

  Object _stopLoc(int i) => _points.length > i + 1 ? _points[i + 1] : widget.stops[i].location;

  /// stops の [from, to) 区間をGoogleマップのナビで開く。出発地は [origin]。最後が目的地、それ以外は経由地。
  /// 一般道の区間は高速道路を避ける（avoid=highways）。高速の区間は指定なし（Googleマップ任せ）。
  Future<void> _openNav(Object? origin, int from, int to, {bool highway = false}) async {
    final locs = [for (int i = from; i < to; i++) _navPlace(_stopLoc(i))];
    var url = 'https://www.google.com/maps/dir/?api=1${origin == null ? '' : '&origin=${_navPlace(origin)}'}&destination=${locs.last}&travelmode=driving';
    if (locs.length > 1) url += '&waypoints=${locs.sublist(0, locs.length - 1).join('%7C')}';
    if (!highway) url += '&avoid=highways';
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  /// 「ナビ開始」。メニューで選んだ優先道路（[highway]）を全区間に使い、最大10件ずつに分けて開く。
  /// 10件を超える場合は区間を選ばせる。
  Future<void> _startNav(bool highway) async {
    const maxStops = 10;
    final n = widget.stops.length;
    if (n == 0) return;
    final sections = <(int, int, bool)>[];
    var from = 0;
    for (int i = 1; i <= n; i++) {
      if (i == n || i - from >= maxStops) {
        sections.add((from, i, highway));
        from = i;
      }
    }
    Future<void> open((int, int, bool) sec) => _openNav(sec.$1 == 0 ? widget.origin : _stopLoc(sec.$1 - 1), sec.$1, sec.$2, highway: sec.$3);
    if (sections.length == 1) return open(sections.first);
    final sel = await showDialog<int>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('ナビ開始（区間を選択）'),
        children: [
          for (int k = 0; k < sections.length; k++)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, k),
              child: Text('${sections[k].$1 + 1}〜${sections[k].$2}件目（${sections[k].$3 ? '高速' : '一般道'}）'),
            ),
        ],
      ),
    );
    if (sel == null) return;
    await open(sections[sel]);
  }

  Widget _navButton() => PopupMenuButton<bool>(
        tooltip: 'ナビ開始',
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        icon: const Icon(Icons.navigation_rounded, size: 24, color: Colors.white),
        onSelected: _startNav,
        itemBuilder: (_) => const [
          PopupMenuItem(value: false, child: Text('一般道')),
          PopupMenuItem(value: true, child: Text('高速')),
        ],
      );

  Widget _vRadio(int i, String label, bool value) {
    final on = _highway[i] == value;
    final sec = _optLegs['$i-$value']?.seconds;
    return InkWell(
      onTap: _mapReady ? () => _setHighway(i, value) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Icon(on ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded, size: 20, color: on ? PL.purple : PL.iconGrey),
            const SizedBox(width: 8),
            Expanded(child: Text(label, style: TextStyle(fontSize: 13, fontWeight: on ? FontWeight.bold : FontWeight.normal, color: PL.ink))),
            Text(sec == null ? '--分' : '${(sec / 60).ceil()}分', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: PL.ink)),
          ],
        ),
      ),
    );
  }

  Widget _vCard(int i) {
    final st = widget.stops[i];
    final sel = _selected == i;
    final head = Row(
      children: [
        sel
            ? SizedBox(width: 20, child: Text('${i + 1}', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: st.color)))
            : Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Text('${i + 1}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: st.color)),
              ),
        const SizedBox(width: 8),
        Expanded(
          child: Text('${st.time} ${st.place}', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: sel ? PL.ink : Colors.white)),
        ),
        Icon(sel ? Icons.expand_less_rounded : Icons.expand_more_rounded, size: 20, color: sel ? PL.ink : Colors.white),
      ],
    );
    return GestureDetector(
      onTap: () => _select(i),
      child: Container(
        padding: EdgeInsets.fromLTRB(12, sel ? 10 : 9, 12, sel ? 6 : 9),
        decoration: BoxDecoration(
          color: sel ? Colors.white : st.color.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
          border: sel ? Border.all(color: _selectedLine, width: 2) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            head,
            if (sel) ...[
              const SizedBox(height: 6),
              _vRadio(i, '一般道', false),
              _vRadio(i, '高速道路', true),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  tooltip: 'ナビ開始',
                  icon: const Icon(Icons.navigation_rounded, size: 24, color: PL.purple),
                  onPressed: () => _openNav(null, i, i + 1, highway: _highway[i]),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVertical(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      child: Scaffold(
        backgroundColor: PL.bg,
        appBar: AppBar(
          toolbarHeight: 52,
          backgroundColor: PL.purple,
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20), onPressed: () => Navigator.pop(context)),
          title: Text(widget.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          actions: [_navButton()],
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: PL.purpleBar,
              child: Row(
                children: [
                  const Icon(Icons.alt_route_rounded, size: 20, color: PL.red),
                  const SizedBox(width: 12),
                  Expanded(child: Text(_summary, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: PL.ink))),
                ],
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, c) {
                  final full = c.maxHeight * 0.555;
                  final collapsed = 32.0 + MediaQuery.of(context).viewPadding.bottom; // ハンドル32 + ジェスチャーバー余白
                  return Column(
                    children: [
                      Expanded(child: _mapView()), // 地図とシートは重ねない（重ねるとWebViewにタップを奪われるため）
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        height: _sheetOpen ? full : collapsed,
                        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
                        clipBehavior: Clip.antiAlias,
                        child: OverflowBox(
                          alignment: Alignment.topCenter,
                          minHeight: full,
                          maxHeight: full,
                          child: Column(
                            children: [
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => setState(() => _sheetOpen = !_sheetOpen),
                                onVerticalDragEnd: (d) {
                                  final v = d.primaryVelocity ?? 0;
                                  if (v > 100) setState(() => _sheetOpen = false);
                                  if (v < -100) setState(() => _sheetOpen = true);
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 32,
                                  padding: const EdgeInsets.only(top: 10, bottom: 6),
                                  alignment: Alignment.topCenter,
                                  child: Container(width: 40, height: 5, decoration: BoxDecoration(color: const Color(0xFFD4D7DC), borderRadius: BorderRadius.circular(2.5))),
                                ),
                              ),
                              Expanded(
                                child: ListView(
                                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
                                  children: [
                                    for (int i = 0; i < widget.stops.length; i++) ...[_vTravel(i), _vCard(i)],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.vertical) return _buildVertical(context);
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
              padding: EdgeInsets.all(_s(16)),
              color: Colors.deepPurple.shade50,
              child: Row(
                children: [
                  const Icon(Icons.route, color: AppColors.accentOrange),
                  SizedBox(width: _s(12)),
                  Expanded(child: Text(_summary, style: TextStyle(fontWeight: FontWeight.bold, fontSize: _f(16)))),
                ],
              ),
            ),
            Expanded(
              child: widget.vertical
                  ? Column(children: [Expanded(flex: 4, child: _mapView()), Expanded(flex: 5, child: _cardList())])
                  : Row(children: [Expanded(flex: 7, child: _mapView()), Expanded(flex: 3, child: _cardList())]),
            ),
          ],
        ),
      ),
    );
  }
}
