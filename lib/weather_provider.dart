import 'package:flutter/foundation.dart';
import 'weather_service.dart';

class WeatherProvider with ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  Map<String, dynamic>? _weatherData;
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, dynamic>? get weatherData => _weatherData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchWeather(String city) async {
    _isLoading = true;
    notifyListeners();

    try {
      final coordinates = await _weatherService.fetchCoordinates(city);
      final lat = coordinates['results'][0]['geometry']['lat'];
      final lon = coordinates['results'][0]['geometry']['lng'];
      _weatherData = await _weatherService.fetchWeather(lat, lon);
      _errorMessage = null;
    } catch (e) {
      _weatherData = null;
      _errorMessage = e.toString();
      if (kDebugMode) {
        print('Error fetching weather: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
