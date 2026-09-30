import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../firebase_options.dart';

class GoogleMapsService {
  // 開発環境用のAPIキー
  static String get _apiKey => DefaultFirebaseOptions.currentPlatform.apiKey;

  // Web環境でのCORS回避用プロキシ（デバッグ用。必要に応じて設定）
  // 現場のスピードを優先し、Web実行時は警告を出しつつも試行する構造にする。
  static const String _corsProxy = ""; 

  Future<List<String>> getPlaceSuggestions(String input, {String? sessionToken, LatLng? locationBias}) async {
    if (input.isEmpty) return [];

    String urlStr = 'https://maps.googleapis.com/maps/api/place/autocomplete/json'
      '?input=$input'
      '&types=address'
      '&language=ja'
      '&components=country:jp'
      '&key=$_apiKey';

    if (locationBias != null) {
      urlStr += '&locationbias=circle:50000@${locationBias.latitude},${locationBias.longitude}';
    }

    if (sessionToken != null) {
      urlStr += "&sessiontoken=$sessionToken";
    }

    final url = Uri.parse(kIsWeb && _corsProxy.isNotEmpty ? '$_corsProxy$urlStr' : urlStr);

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final predictions = data['predictions'] as List;
        return predictions.map((p) => (p['description'] as String).replaceFirst('日本、', '')).toList();
      }
    } catch (e) {
      debugPrint('Google Maps API Error: $e');
    }
    return [];
  }

  Future<Map<String, dynamic>?> getLatLngFromAddress(String address) async {
    final cleanAddress = address.split(RegExp(r'[(\（]'))[0].trim();
    final urlStr = 'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(cleanAddress)}&key=$_apiKey&language=ja';
    final url = Uri.parse(kIsWeb && _corsProxy.isNotEmpty ? '$_corsProxy$urlStr' : urlStr);

    debugPrint('Geocoding Request: $cleanAddress');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final geom = data['results'][0]['geometry'];
          final loc = geom['location'];
          return {
            'lat': loc['lat'] as double, 
            'lng': loc['lng'] as double,
            'location_type': geom['location_type'] as String,
          };
        }
      }
    } catch (e) {
      debugPrint('Geocoding Error: $e');
    }
    return null;
  }

  Future<String?> getAddressFromLatLng(LatLng position) async {
    final urlStr = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$_apiKey&language=ja';
    final url = Uri.parse(kIsWeb && _corsProxy.isNotEmpty ? '$_corsProxy$urlStr' : urlStr);

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          return (data['results'][0]['formatted_address'] as String).replaceFirst('日本、', '');
        }
      }
    } catch (e) {
      debugPrint('Reverse Geocoding Error: $e');
    }
    return null;
  }

  /// 配達元(origin)から配達先(destination)までのナビ経路の所要時間（表示用文字列。例："25分"）を取得する
  Future<String?> getEstimatedDuration(LatLng origin, LatLng destination) async {
    final sec = await getDurationSeconds(origin, destination);
    if (sec == null) return null;
    final min = (sec / 60).ceil();
    return min >= 60 ? '${min ~/ 60}時間${min % 60}分' : '$min分';
  }

  /// 出発地から、経由地を順に通って最後の地点までの経路（Routes API）。失敗時は null。
  /// [stops] は LatLng か住所(String)。最後が目的地、それ以外は経由地。
  /// 返り値: 経路線(encodedPolyline)・合計メートル・合計秒・各地点の座標（出発地→各stopの順）
  Future<({String polyline, int meters, int seconds, List<LatLng> points, List<({String polyline, int seconds})> legs})?> getRoute(LatLng origin, List<Object> stops) async {
    if (stops.isEmpty) return null;
    const urlStr = 'https://routes.googleapis.com/directions/v2:computeRoutes';
    final url = Uri.parse(kIsWeb && _corsProxy.isNotEmpty ? '$_corsProxy$urlStr' : urlStr);
    Map<String, dynamic> wp(Object p) => p is LatLng
        ? {'location': {'latLng': {'latitude': p.latitude, 'longitude': p.longitude}}}
        : {'address': p.toString()};
    final body = json.encode({
      'origin': wp(origin),
      'destination': wp(stops.last),
      if (stops.length > 1) 'intermediates': stops.sublist(0, stops.length - 1).map(wp).toList(),
      'travelMode': 'DRIVE',
      'languageCode': 'ja',
    });
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': _apiKey,
          'X-Goog-FieldMask': 'routes.polyline.encodedPolyline,routes.distanceMeters,routes.duration,routes.legs.startLocation,routes.legs.endLocation,routes.legs.polyline.encodedPolyline,routes.legs.duration',
        },
        body: body,
      );
      if (response.statusCode != 200) {
        debugPrint('Routes API HTTP ${response.statusCode}: ${response.body}');
        return null;
      }
      final routes = json.decode(response.body)['routes'] as List?;
      if (routes == null || routes.isEmpty) return null;
      final r = routes.first as Map<String, dynamic>;
      LatLng ll(Map m) => LatLng((m['latLng']['latitude'] as num).toDouble(), (m['latLng']['longitude'] as num).toDouble());
      final legs = (r['legs'] as List).cast<Map<String, dynamic>>();
      return (
        polyline: r['polyline']['encodedPolyline'] as String,
        meters: (r['distanceMeters'] as num?)?.toInt() ?? 0,
        seconds: int.tryParse(r['duration'].toString().replaceAll('s', '')) ?? 0,
        points: [ll(legs.first['startLocation']), ...legs.map((l) => ll(l['endLocation']))],
        legs: legs
            .map((l) => (polyline: l['polyline']['encodedPolyline'] as String, seconds: int.tryParse(l['duration'].toString().replaceAll('s', '')) ?? 0))
            .toList(),
      );
    } catch (e) {
      debugPrint('Routes API Error: $e');
      return null;
    }
  }

  /// 配達元(origin)から配達先(destination)までのナビ経路の所要時間（秒）を取得する。失敗時は null。
  /// Routes API（Google公式の新しい経路API）を使う。旧Distance Matrix APIは新規プロジェクトでは使えないため。
  Future<int?> getDurationSeconds(LatLng origin, LatLng destination) async {
    const urlStr = 'https://routes.googleapis.com/directions/v2:computeRoutes';
    final url = Uri.parse(kIsWeb && _corsProxy.isNotEmpty ? '$_corsProxy$urlStr' : urlStr);
    final body = json.encode({
      'origin': {'location': {'latLng': {'latitude': origin.latitude, 'longitude': origin.longitude}}},
      'destination': {'location': {'latLng': {'latitude': destination.latitude, 'longitude': destination.longitude}}},
      'travelMode': 'DRIVE',
      'languageCode': 'ja',
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': _apiKey,
          'X-Goog-FieldMask': 'routes.duration',
        },
        body: body,
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final routes = data['routes'] as List?;
        if (routes != null && routes.isNotEmpty) {
          // 例: "1234s"
          final d = routes.first['duration']?.toString() ?? '';
          final sec = int.tryParse(d.replaceAll('s', ''));
          if (sec != null) return sec;
        }
        debugPrint('Routes API: 経路なし ${response.body}');
      } else {
        debugPrint('Routes API HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('Routes API Error: $e');
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> searchPlacesByText(String query, {LatLng? location}) async {
    String urlStr = 'https://maps.googleapis.com/maps/api/place/textsearch/json'
      '?query=${Uri.encodeComponent(query)}'
      '&language=ja'
      '&region=jp'
      '&key=$_apiKey';
    
    if (location != null) {
      urlStr += '&location=${location.latitude},${location.longitude}&radius=10000';
    }

    final url = Uri.parse(kIsWeb && _corsProxy.isNotEmpty ? '$_corsProxy$urlStr' : urlStr);

    debugPrint('Google Maps Text Search: $query (Web: $kIsWeb)');

    try {
      final response = await http.get(url);
      debugPrint('API Response Status Code: ${response.statusCode}');
      debugPrint('API Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final status = data['status'] as String;
        debugPrint('Google Maps Text Search Status: $status');

        if (status == 'OK') {
          final results = data['results'] as List;
          return results.map((item) {
            final loc = item['geometry']['location'];
            return {
              'name': item['name'],
              'address': (item['formatted_address'] as String).replaceFirst('日本、', ''),
              'lat': loc['lat'] as double,
              'lng': loc['lng'] as double,
              'type': 'Google検索',
            };
          }).toList();
        }
      } else if (kIsWeb) {
        debugPrint('Web CORS Error likely. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Text Search Exception: $e');
    }
    return [];
  }
}
