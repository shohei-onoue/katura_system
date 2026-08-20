import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum HeatmapMode { revenue, customer, loyalty }

class HeatmapPoint {
  final LatLng location;
  final double value;
  final String? status; // 'new', 'active', 'churned'

  HeatmapPoint({required this.location, required this.value, this.status});
}

class KPointHeatmap extends StatefulWidget {
  final List<HeatmapPoint> points;
  final HeatmapMode mode;
  final double threshold; // 基準値
  final CameraPosition initialPosition;
  final Function(GoogleMapController)? onMapCreated;

  const KPointHeatmap({
    super.key,
    required this.points,
    required this.mode,
    required this.threshold,
    required this.initialPosition,
    this.onMapCreated,
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
    if (widget.mode == HeatmapMode.loyalty) {
      switch (p.status) {
        case 'new': return Colors.red.withValues(alpha: 0.7);
        case 'active': return Colors.orange.withValues(alpha: 0.6);
        case 'churned': return Colors.grey.withValues(alpha: 0.5);
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

  void _rebuildHeatmap() {
    final Set<Circle> newCircles = {};
    int index = 0;
    
    // ズームに応じたサイズ調整
    double zoomFactor = math.pow(2, 11 - _currentZoom).toDouble().clamp(0.5, 10.0);
    double baseRadius = 800 * zoomFactor;

    for (var p in widget.points) {
      final color = _getColor(p);
      final double sizeWeight = widget.mode == HeatmapMode.loyalty ? 1.0 : (p.value / widget.threshold).clamp(0.5, 1.5);

      newCircles.add(Circle(
        circleId: CircleId('h_$index'),
        center: p.location,
        radius: baseRadius * sizeWeight,
        fillColor: color,
        strokeColor: color.withValues(alpha: 0.3),
        strokeWidth: 1,
      ));
      index++;
    }

    setState(() => _circles = newCircles);
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
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
    );
  }
}
