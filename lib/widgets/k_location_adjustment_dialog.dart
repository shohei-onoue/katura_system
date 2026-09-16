import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'k_responsive.dart';
import 'k_button.dart';
import '../firebase_options.dart';
import 'package:katura_system/utils/app_colors.dart';

class KLocationAdjustmentDialog extends StatefulWidget {
  final LatLng initialPosition;
  final String initialAddress;
  final Future<String?> Function(LatLng) getAddressFromLatLng;

  const KLocationAdjustmentDialog({
    super.key,
    required this.initialPosition,
    required this.initialAddress,
    required this.getAddressFromLatLng,
  });

  @override
  State<KLocationAdjustmentDialog> createState() => _KLocationAdjustmentDialogState();
}

class _KLocationAdjustmentDialogState extends State<KLocationAdjustmentDialog> {
  late LatLng _currentPosition;
  String _currentAddress = "";
  late WebViewController _webViewController;
  double _currentHeading = 0;
  double _currentPitch = 0;

  @override
  void initState() {
    super.initState();
    _currentPosition = widget.initialPosition;
    _currentAddress = widget.initialAddress;
    _initWebViewController();
  }

  void _initWebViewController() {
    final apiKey = DefaultFirebaseOptions.currentPlatform.apiKey;
    final escapedAddress = widget.initialAddress.replaceAll('\\', '\\\\').replaceAll("'", "\\'");
    final html = '''
<!DOCTYPE html>
<html>
  <head>
    <title>Street View Adjustment</title>
    <script src="https://maps.googleapis.com/maps/api/js?key=$apiKey&libraries=places&language=ja"></script>
    <style>
      html, body, #map { height: 100%; margin: 0; padding: 0; }
      #searchBox {
        box-sizing: border-box;
        width: 80%;
        max-width: 420px;
        padding: 10px 12px;
        font-size: 14px;
        border: 1px solid #ccc;
        border-radius: 4px;
        box-shadow: 0 2px 6px rgba(0,0,0,0.3);
        margin-top: 10px;
      }
    </style>
  </head>
  <body>
    <div id="map"></div>
    <script>
      let map;
      let panorama;
      let marker;

      function initMap() {
        const pos = { lat: ${_currentPosition.latitude}, lng: ${_currentPosition.longitude} };
        map = new google.maps.Map(document.getElementById("map"), {
          center: pos,
          zoom: 18,
          streetViewControl: true,
          mapTypeControl: false,
          fullscreenControl: false,
        });

        panorama = map.getStreetView();

        marker = new google.maps.Marker({
          position: pos,
          map: map,
          draggable: true,
          icon: {
            url: "https://maps.google.com/mapfiles/ms/icons/red-pushpin.png"
          }
        });

        marker.addListener("dragend", () => {
          const newPos = marker.getPosition();
          updateFlutter(newPos.lat(), newPos.lng(), 0, 0);
        });

        map.addListener("click", (e) => {
          marker.setPosition(e.latLng);
          updateFlutter(e.latLng.lat(), e.latLng.lng(), 0, 0);
        });

        panorama.addListener("position_changed", () => {
          const p = panorama.getPosition();
          const pov = panorama.getPov();
          if (p) {
            marker.setPosition(p);
            updateFlutter(p.lat(), p.lng(), pov.heading, pov.pitch);
          }
        });

        panorama.addListener("pov_changed", () => {
          const p = panorama.getPosition();
          const pov = panorama.getPov();
          if (p) {
            updateFlutter(p.lat(), p.lng(), pov.heading, pov.pitch);
          }
        });

        const input = document.createElement("input");
        input.id = "searchBox";
        input.type = "text";
        input.placeholder = "住所・施設名で検索";
        input.value = '$escapedAddress';
        map.controls[google.maps.ControlPosition.TOP_CENTER].push(input);

        const searchBox = new google.maps.places.SearchBox(input);
        searchBox.addListener("places_changed", () => {
          const places = searchBox.getPlaces();
          if (!places || places.length === 0 || !places[0].geometry) return;
          moveTo(places[0].geometry.location);
        });

        function moveTo(loc) {
          map.setCenter(loc);
          map.setZoom(18);
          marker.setPosition(loc);
          updateFlutter(loc.lat(), loc.lng(), 0, 0);
        }

        // 入力欄に住所が既に反映された状態で、その地点までマップを展開しておく
        if (input.value) {
          const service = new google.maps.places.PlacesService(map);
          service.findPlaceFromQuery({ query: input.value, fields: ["geometry"] }, (results, status) => {
            if (status === google.maps.places.PlacesServiceStatus.OK && results && results[0] && results[0].geometry) {
              moveTo(results[0].geometry.location);
            }
          });
        }
      }

      function updateFlutter(lat, lng, heading, pitch) {
        if (window.ToFlutter) {
          window.ToFlutter.postMessage(JSON.stringify({
            lat: lat,
            lng: lng,
            heading: heading,
            pitch: pitch
          }));
        }
      }

      window.onload = initMap;
    </script>
  </body>
</html>
''';

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'ToFlutter',
        onMessageReceived: (message) {
          final data = json.decode(message.message);
          setState(() {
            _currentPosition = LatLng(data['lat'], data['lng']);
            _currentHeading = (data['heading'] as num).toDouble();
            _currentPitch = (data['pitch'] as num).toDouble();
          });
          _updateAddress(_currentPosition);
        },
      )
      ..loadHtmlString(html);
  }

  Future<void> _updateAddress(LatLng pos) async {
    final addr = await widget.getAddressFromLatLng(pos);
    if (addr != null && mounted) {
      setState(() {
        _currentAddress = addr;
      });
    }
  }

  String _getStaticImageUrl() {
    final apiKey = DefaultFirebaseOptions.currentPlatform.apiKey;
    return 'https://maps.googleapis.com/maps/api/streetview'
        '?size=600x400'
        '&location=${_currentPosition.latitude},${_currentPosition.longitude}'
        '&heading=$_currentHeading'
        '&pitch=$_currentPitch'
        '&key=$apiKey';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('場所の微調整と写真撮影', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.deepPurple,
          foregroundColor: AppColors.background,
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(rs(context, 16)),
              color: Colors.deepPurple.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.deepOrange),
                      SizedBox(width: rs(context, 12)),
                      Expanded(
                        child: Text(_currentAddress, 
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: rf(context, 16))),
                      ),
                    ],
                  ),
                  SizedBox(height: rs(context, 4)),
                  Text('※ストリートビューで向きを合わせると、その写真が保存されます', 
                    style: TextStyle(fontSize: rf(context, 11), color: Colors.blueGrey)),
                ],
              ),
            ),
            Expanded(
              child: WebViewWidget(controller: _webViewController),
            ),
            Container(
              padding: EdgeInsets.all(rs(context, 20)),
              decoration: BoxDecoration(
                color: AppColors.background,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -5))],
              ),
              child: SizedBox(
                width: double.infinity,
                height: rs(context, 60),
                child: KButton(
                  label: 'この地点と写真で確定',
                  onPressed: () {
                    Navigator.pop(context, {
                      'position': _currentPosition,
                      'staticImageUrl': _getStaticImageUrl(),
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
