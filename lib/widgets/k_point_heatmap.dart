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

  @override
  void didUpdateWidget(KPointHeatmap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.points != widget.points || oldWidget.mode != widget.mode || oldWidget.threshold != widget.threshold) {
      _rebuildHeatmap();
    }
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

  double _distMeters(LatLng a, LatLng b) {
    double toRad(double d) => d * math.pi / 180.0;
    final dLat = toRad(b.latitude - a.latitude);
    final dLng = toRad(b.longitude - a.longitude);
    final la1 = toRad(a.latitude);
    final la2 = toRad(b.latitude);
    final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(la1) * math.cos(la2) * math.sin(dLng / 2) * math.sin(dLng / 2);
    return 2 * _earthRadius * math.asin(math.min(1.0, math.sqrt(h)));
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
    for (final p in pts) {
      final double sizeWeight = widget.mode == HeatmapMode.loyalty ? 0.8 : (p.value / widget.threshold).clamp(0.5, 1.5);
      centers.add(p.location);
      radii.add(baseRadius * sizeWeight);
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

    for (int i = 0; i < n; i++) {
      for (int j = i + 1; j < n; j++) {
        if (_distMeters(centers[i], centers[j]) <= radii[i] + radii[j]) {
          final ri = find(i);
          final rj = find(j);
          if (ri != rj) parent[ri] = rj;
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

    setState(() => _circles = newCircles);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: widget.initialPosition,
          onMapCreated: (c) {
            if (widget.onMapCreated != null) widget.onMapCreated!(c);
            _rebuildHeatmap();
          },
          circles: _circles,
          onCameraMove: (pos) => _currentZoom = pos.zoom,
          onCameraIdle: () => _rebuildHeatmap(),
          myLocationEnabled: false,
          zoomControlsEnabled: false,
        ),
        if (widget.isLoading)
          const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
