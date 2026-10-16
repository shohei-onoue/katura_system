import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../services/street_view_image_service.dart';
import 'phone_order_ui.dart';

/// 場所の微調整と写真撮影（Figma 89-3842 / 89-3868）。
/// 戻り値は {position: LatLng, staticImageUrl: String}（キャンセルは null）。
Future<Map<String, dynamic>?> showPhoneLocationAdjustPage(
  BuildContext context, {
  required LatLng initialPosition,
  required String address,
  Future<String?> Function(LatLng pos)? getAddressFromLatLng,
}) {
  return Navigator.of(context).push<Map<String, dynamic>>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => _PhoneLocationAdjustPage(initialPosition: initialPosition, address: address, getAddressFromLatLng: getAddressFromLatLng),
    ),
  );
}

class _PhoneLocationAdjustPage extends StatefulWidget {
  final LatLng initialPosition;
  final String address;
  final Future<String?> Function(LatLng pos)? getAddressFromLatLng;
  const _PhoneLocationAdjustPage({required this.initialPosition, required this.address, this.getAddressFromLatLng});
  @override
  State<_PhoneLocationAdjustPage> createState() => _PhoneLocationAdjustPageState();
}

class _PhoneLocationAdjustPageState extends State<_PhoneLocationAdjustPage> {
  GoogleMapController? _map;
  late LatLng _pos;
  late String _address;
  bool _satellite = false;
  bool _withPhoto = true;

  @override
  void initState() {
    super.initState();
    _pos = widget.initialPosition;
    _address = widget.address;
  }

  Future<void> _moveTo(LatLng p) async {
    setState(() => _pos = p);
    final f = widget.getAddressFromLatLng;
    if (f != null) {
      final a = await f(p);
      if (mounted && a != null && a.isNotEmpty) setState(() => _address = a);
    }
  }

  Widget _fab(IconData icon, VoidCallback onTap, {bool active = false}) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 4, offset: Offset(0, 1))],
            border: active ? Border.all(color: PO.purple, width: 2) : null,
          ),
          child: Icon(icon, size: 20, color: active ? PO.purple : PO.text),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PO.bg,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: PoHeader(title: '場所の微調整と写真撮影', bg: PO.purple, fg: Colors.white, onClose: () => Navigator.pop(context)),
          ),
          Container(
            height: 55,
            color: const Color(0xFFF6F2FC),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.location_on_rounded, size: 20, color: PO.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_address, maxLines: 1, overflow: TextOverflow.ellipsis, style: PO.ts(13)),
                      const SizedBox(height: 2),
                      Text('ピンをドラッグして配達先の位置を調整できます', style: PO.ts(10.5, color: PO.sub, w: FontWeight.w400)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(target: _pos, zoom: 18),
                    mapType: _satellite ? MapType.hybrid : MapType.normal,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    onMapCreated: (c) => _map = c,
                    markers: {
                      Marker(
                        markerId: const MarkerId('adjust'),
                        position: _pos,
                        draggable: true,
                        onDragEnd: _moveTo,
                      ),
                    },
                    onTap: _moveTo,
                  ),
                ),
                Positioned(
                  right: 14,
                  bottom: 16,
                  child: Column(
                    children: [
                      _fab(Icons.add_a_photo_rounded, () {
                        setState(() => _withPhoto = !_withPhoto);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_withPhoto ? 'この地点の写真を保存します' : '写真は保存しません')));
                      }, active: _withPhoto),
                      const SizedBox(height: 8),
                      _fab(Icons.my_location_rounded, () {
                        setState(() => _pos = widget.initialPosition);
                        _map?.animateCamera(CameraUpdate.newLatLngZoom(widget.initialPosition, 18));
                      }),
                      const SizedBox(height: 8),
                      _fab(Icons.layers_rounded, () => setState(() => _satellite = !_satellite), active: _satellite),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: PO.line))),
            padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
            child: SafeArea(
              top: false,
              child: PoButton(
                label: 'この地点と写真で確定',
                onTap: () => Navigator.pop(context, {
                  'position': _pos,
                  'staticImageUrl': _withPhoto ? StreetViewImageService.buildStaticUrl(_pos.latitude, _pos.longitude) : '',
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
