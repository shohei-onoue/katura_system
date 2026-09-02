import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum HeatmapMode { revenue, customer, loyalty }

class HeatmapPoint {
  final LatLng location;
  final double value;
  final String? status; // 'new', 'active', 'churned'
  final Color? color; // 指定時はこの色をそのまま使用（店舗別・濃淡指定など）

  HeatmapPoint({required this.location, required this.value, this.status, this.color});
}

class KPointHeatmap extends StatefulWidget {
  final List<HeatmapPoint> points;
  final HeatmapMode mode;
  final double threshold; // 基準値
  final CameraPosition initialPosition;
  final Function(GoogleMapController)? onMapCreated;
  final bool isLoading;

  const KPointHeatmap({
    super.key,
    required this.points,
    required this.mode,
    required this.threshold,
    required this.initialPosition,
    this.onMapCreated,
    this.isLoading = false,
  });

  @override
  State<KPointHeatmap> createState() => _KPointHeatmapState();
}

class _KPointHeatmapState extends State<KPointHeatmap> {
  Set<Circle> _circles = {};
  double _currentZoom = 10.0;
  int _builtZoomBucket = -999; // 直近クラスタ計算時のズーム段階
  Timer? _idleDebounce;

  // 地図(プラットフォームビュー)の生成は重く初回フレームを止めるため、
  // 画面描画後に少し遅らせてマウントする。
  bool _mapMounted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 250), () {
        if (mounted) setState(() => _mapMounted = true);
      });
    });
  }

  @override
  void dispose() {
    _idleDebounce?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(KPointHeatmap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.points, widget.points) ||
        oldWidget.mode != widget.mode ||
        oldWidget.threshold != widget.threshold) {
      _rebuildHeatmap();
    }
  }

  /// カメラ停止時の再計算。ズーム段階が変わっていなければ円のサイズは変化しないので
  /// O(n^2) のクラスタ計算をスキップする。移動直後の連続 idle もデバウンスで間引く。
  void _onCameraIdle() {
    _idleDebounce?.cancel();
    _idleDebounce = Timer(const Duration(milliseconds: 180), () {
      if (!mounted) return;
      if (_currentZoom.round() == _builtZoomBucket) return;
      _rebuildHeatmap();
    });
  }

  Color _getColor(HeatmapPoint p) {
    if (p.color != null) return p.color!;
    if (widget.mode == HeatmapMode.loyalty) {
      switch (p.status) {
        case 'new': return Colors.green.withValues(alpha: 0.7);
        case 'active': return Colors.blue.withValues(alpha: 0.6);
        case 'churned': return Colors.black.withValues(alpha: 0.5);
        default: return Colors.blue.withValues(alpha: 0.4);
      }
    }

    final ratio = (p.value / widget.threshold).clamp(0.1, 1.0);
    if (widget.mode == HeatmapMode.revenue) {
      return Colors.blue.shade900.withValues(alpha: 0.2 + (ratio * 0.6));
    } else {
      return Colors.green.shade700.withValues(alpha: 0.2 + (ratio * 0.6));
    }
  }

  static const double _earthRadius = 6378137.0;
  static const double _deg2rad = math.pi / 180.0;

  /// 単一都市圏レベルの近距離用の等距円筒近似（三角関数のコストを避ける）。
  /// haversine とは cm〜数十cm 差でクラスタ判定には十分。
  double _distMeters(LatLng a, LatLng b) {
    final double meanLatRad = (a.latitude + b.latitude) * 0.5 * _deg2rad;
    final double dx =
        (b.longitude - a.longitude) * _deg2rad * math.cos(meanLatRad) * _earthRadius;
    final double dy = (b.latitude - a.latitude) * _deg2rad * _earthRadius;
    return math.sqrt(dx * dx + dy * dy);
  }

  Color _clusterColor(List<int> members) {
    // メンバー内の status 最頻値を代表色にする
    final counts = <String, int>{};
    for (final m in members) {
      final s = widget.points[m].status ?? 'default';
      counts[s] = (counts[s] ?? 0) + 1;
    }
    String best = 'default';
    int bc = -1;
    counts.forEach((k, v) {
      if (v > bc) {
        bc = v;
        best = k;
      }
    });
    final rep = members.firstWhere(
      (m) => (widget.points[m].status ?? 'default') == best,
      orElse: () => members.first,
    );
    return _getColor(widget.points[rep]);
  }

  void _rebuildHeatmap() {
    final pts = widget.points;
    final n = pts.length;

    // ズームに応じたサイズ調整
    final double zoomFactor = math.pow(2, 11 - _currentZoom).toDouble().clamp(0.5, 12.0);
    final double baseRadius = 600 * zoomFactor; // 800から600に少し小さくして重なりを軽減

    final centers = <LatLng>[];
    final radii = <double>[];
    double maxRadius = 0;
    for (final p in pts) {
      final double sizeWeight = widget.mode == HeatmapMode.loyalty ? 0.8 : (p.value / widget.threshold).clamp(0.5, 1.5);
      centers.add(p.location);
      final double r = baseRadius * sizeWeight;
      radii.add(r);
      if (r > maxRadius) maxRadius = r;
    }

    // 接触する円（中心間距離 <= 半径の和）を union-find で1クラスタにまとめる
    final parent = List<int>.generate(n, (i) => i);
    int find(int x) {
      while (parent[x] != x) {
        parent[x] = parent[parent[x]];
        x = parent[x];
      }
      return x;
    }

    // 全ペア総当り(O(n^2))を避け、セル幅 = 2*maxRadius の空間グリッドで
    // 近傍3x3セルのみを比較する（2円が接触し得る最大中心間距離は radii[i]+radii[j] <= 2*maxRadius）。
    if (n > 1) {
      final double cell = math.max(1.0, 2 * maxRadius);
      final double meanLatRad = centers[0].latitude * _deg2rad;
      final double mPerLng = _deg2rad * math.cos(meanLatRad) * _earthRadius;
      const double mPerLat = _deg2rad * _earthRadius;
      final double lng0 = centers[0].longitude;
      final double lat0 = centers[0].latitude;

      final grid = <int, List<int>>{};
      final cellX = List<int>.filled(n, 0);
      final cellY = List<int>.filled(n, 0);
      for (int i = 0; i < n; i++) {
        final int cx = ((centers[i].longitude - lng0) * mPerLng / cell).floor();
        final int cy = ((centers[i].latitude - lat0) * mPerLat / cell).floor();
        cellX[i] = cx;
        cellY[i] = cy;
        (grid[cx * 73856093 ^ cy * 19349663] ??= <int>[]).add(i);
      }

      for (int i = 0; i < n; i++) {
        for (int gx = cellX[i] - 1; gx <= cellX[i] + 1; gx++) {
          for (int gy = cellY[i] - 1; gy <= cellY[i] + 1; gy++) {
            final bucket = grid[gx * 73856093 ^ gy * 19349663];
            if (bucket == null) continue;
            for (final j in bucket) {
              if (j <= i) continue;
              if (_distMeters(centers[i], centers[j]) <= radii[i] + radii[j]) {
                final ri = find(i);
                final rj = find(j);
                if (ri != rj) parent[ri] = rj;
              }
            }
          }
        }
      }
    }

    final Map<int, List<int>> groups = {};
    for (int i = 0; i < n; i++) {
      groups.putIfAbsent(find(i), () => []).add(i);
    }

    final Set<Circle> newCircles = {};
    int index = 0;
    groups.forEach((root, members) {
      if (members.length == 1) {
        final i = members.first;
        final color = _getColor(pts[i]);
        newCircles.add(Circle(
          circleId: CircleId('h_$index'),
          center: centers[i],
          radius: radii[i],
          fillColor: color,
          strokeColor: color.withValues(alpha: 0.3),
          strokeWidth: 1,
        ));
      } else {
        // 重心を中心に、全メンバー円を包含する半径の円1つに置き換える
        double lat = 0, lng = 0;
        for (final m in members) {
          lat += centers[m].latitude;
          lng += centers[m].longitude;
        }
        final centroid = LatLng(lat / members.length, lng / members.length);
        double r = 0;
        for (final m in members) {
          final d = _distMeters(centroid, centers[m]) + radii[m];
          if (d > r) r = d;
        }
        final color = _clusterColor(members);
        newCircles.add(Circle(
          circleId: CircleId('h_$index'),
          center: centroid,
          radius: r,
          fillColor: color,
          strokeColor: color.withValues(alpha: 0.4),
          strokeWidth: 1,
        ));
      }
      index++;
    });

    _builtZoomBucket = _currentZoom.round();
    setState(() => _circles = newCircles);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_mapMounted)
          RepaintBoundary(
            child: GoogleMap(
              initialCameraPosition: widget.initialPosition,
              onMapCreated: (c) {
                if (widget.onMapCreated != null) widget.onMapCreated!(c);
                _rebuildHeatmap();
              },
              circles: _circles,
              onCameraMove: (pos) => _currentZoom = pos.zoom,
              onCameraIdle: _onCameraIdle,
              myLocationEnabled: false,
              zoomControlsEnabled: false,
            ),
          )
        else
          const ColoredBox(color: Color(0xFFE8EAED)),
        if (widget.isLoading || !_mapMounted)
          const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
