import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapsService {
  // 開発環境用のAPIキー（DefaultFirebaseOptionsから取得したものを使用）
  static const String _apiKey = 'AIzaSyBujgkbXlSkWIhDMCqp1nmrIJrUOF3P4_Y';

  Future<List<String>> getPlaceSuggestions(String input, {String? sessionToken, LatLng? locationBias}) async {
    if (input.isEmpty) return [];

    // ログイン店舗最寄り施設優先の Location Bias (円形範囲: 50km)
    String biasParam = "";
    if (locationBias != null) {
      biasParam = '&locationbias=circle:50000@${locationBias.latitude},${locationBias.longitude}';
    }

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json'
      '?input=$input'
      '&types=address'
      '&language=ja'
      '&components=country:jp'
      '&key=$_apiKey'
      '${sessionToken != null ? "&sessiontoken=$sessionToken" : ""}'
      '$biasParam'
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final predictions = data['predictions'] as List;
        
        // サジェスト内への市区町村名補助表示の強化
        return predictions.map((p) {
          final description = p['description'] as String;
          // 日本国内の場合、「日本、」を削除して視認性を高める
          return description.replaceFirst('日本、', '');
        }).toList();
      }
    } catch (e) {
      debugPrint('Google Maps API Error: $e');
    }
    return [];
  }

  Future<Map<String, double>?> getLatLngFromAddress(String address) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json'
      '?address=${Uri.encodeComponent(address)}'
      '&key=$_apiKey'
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          return {
            'lat': location['lat'] as double,
            'lng': location['lng'] as double,
          };
        }
      }
    } catch (e) {
      print('Geocoding API Error: $e');
    }
    return null;
  }
}
