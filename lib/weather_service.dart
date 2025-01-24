import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String weatherApiKey = '8zNNv2n5rTNNxp3Yhxm2SFL9ddJdHnDE';
  static const String weatherBaseUrl = 'https://api.tomorrow.io/v4/timelines';
  static const String geocodingApiKey = '1b43d715b854474bae1e0a164d754132';
  static const String geocodingBaseUrl = 'https://api.opencagedata.com/geocode/v1/json';

  Future<Map<String, dynamic>> fetchWeather(double lat, double lon) async {
    final url = '$weatherBaseUrl?location=$lat,$lon&fields=temperature&fields=weatherCode&fields=particulateMatter25&timesteps=1d&units=metric&apikey=$weatherApiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      if (kDebugMode) {
        print('Failed to load weather data: ${response.statusCode} ${response.reasonPhrase}');
      }
      throw Exception('Failed to load weather data');
    }
  }

  Future<Map<String, dynamic>> fetchCoordinates(String city) async {
    final url = '$geocodingBaseUrl?q=$city&key=$geocodingApiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'].isNotEmpty) {
        return data;
      } else {
        throw Exception('No results found for the city');
      }
    } else {
      if (kDebugMode) {
        print('Failed to load coordinates: ${response.statusCode} ${response.reasonPhrase}');
      }
      throw Exception('Failed to load coordinates');
    }
  }
}
