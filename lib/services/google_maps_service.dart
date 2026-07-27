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

  Future<Map<String, double>?> getLatLngFromAddress(String address) async {
    final cleanAddress = address.split(RegExp(r'[(\（]'))[0].trim();
    final urlStr = 'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(cleanAddress)}&key=$_apiKey&language=ja';
    final url = Uri.parse(kIsWeb && _corsProxy.isNotEmpty ? '$_corsProxy$urlStr' : urlStr);

    debugPrint('Geocoding Request: $cleanAddress');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final loc = data['results'][0]['geometry']['location'];
          return {'lat': loc['lat'] as double, 'lng': loc['lng'] as double};
        }
      }
    } catch (e) {
      debugPrint('Geocoding Error: $e');
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
