import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import DateFormat
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'weather_provider.dart';

const Map<int, String> weatherDescriptions = {
  1000: 'Clear sky',
  1001: 'Cloudy',
  1002: 'Foggy',
  1100: 'Mostly clear',
  1101: 'Partly cloudy',
  1102: 'Mostly cloudy',
  2000: 'Fog',
  2100: 'Light fog',
  3000: 'Light wind',
  3001: 'Windy',
  3002: 'Strong wind',
  4000: 'Drizzle',
  4001: 'Rain',
  4200: 'Light rain',
  4201: 'Heavy rain',
  5000: 'Snow',
  5001: 'Flurries',
  5100: 'Light snow',
  5101: 'Heavy snow',
  6000: 'Freezing drizzle',
  6001: 'Freezing rain',
  6200: 'Light freezing rain',
  6201: 'Heavy freezing rain',
  7000: 'Ice pellets',
  7101: 'Heavy ice pellets',
  7102: 'Light ice pellets',
  8000: 'Thunderstorm',
};
String getPm25Description(double pm25) {
    if (pm25 <= 12.0) {
    return 'Good';
  } else if (pm25 <= 35.4) {
    return 'Moderate';
  } else if (pm25 <= 55.4) {
    return 'Unhealthy for Sensitive Groups';
  } else if (pm25 <= 150.4) {
    return 'Unhealthy';
  } else if (pm25 <= 250.4) {
    return 'Very Unhealthy';
  } else {
    return 'Hazardous';
  }
}

class WeatherScreen extends StatelessWidget {
  final TextEditingController _cityController = TextEditingController();

  WeatherScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isDaytime = now.hour >= 6 && now.hour < 18;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Forecast'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDaytime
                ? [Colors.blue.shade800, Colors.blue.shade200]
                : [Colors.black87, Colors.black],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _cityController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Enter City',
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  prefixIcon: Icon(Icons.location_city, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final city = _cityController.text;
                  Provider.of<WeatherProvider>(context, listen: false)
                      .fetchWeather(city);
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.blue.shade800,
                  backgroundColor: Colors.white,
                ),
                child: const Text('Get Weather'),
              ),
              const SizedBox(height: 16),
              Expanded(
                flex: 1,
                child: Consumer<WeatherProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (provider.errorMessage != null) {
                      return Center(
                        child: Text(
                          'Error: ${provider.errorMessage}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    } else if (provider.weatherData != null) {
                      final weather =
                          provider.weatherData!['data']['timelines'][0]
                              ['intervals'];
                      final List<ChartData> temperatureData =
                          weather.map<ChartData>((day) {
                        final DateTime date =
                            DateTime.parse(day['startTime']);
                        final double temperature =
                            day['values']['temperature'].toDouble();
                        return ChartData(date.hour.toDouble(), temperature);
                      }).toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AspectRatio(
                            aspectRatio: 1.70,
                            child: SfCartesianChart(
                              primaryXAxis: NumericAxis(
                                edgeLabelPlacement:
                                    EdgeLabelPlacement.shift,
                                title: AxisTitle(text: 'Hour of the Day'),
                              ),
                              primaryYAxis: NumericAxis(
                                minimum: 0,
                                maximum: 40,
                                interval: 10,
                                title: AxisTitle(text: 'Temperature (°C)'),
                              ),
                              series: <ChartSeries>[
                                LineSeries<ChartData, double>(
                                  dataSource: temperatureData,
                                  xValueMapper: (ChartData data, _) =>
                                      data.x,
                                  yValueMapper: (ChartData data, _) =>
                                      data.y,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            flex: 2,
                            child: ListView.builder(
                              itemCount: weather.length,
                              itemBuilder: (context, index) {
                                final day = weather[index];
                                final DateTime date =
                                    DateTime.parse(day['startTime']);
                                final double temperature =
                                    day['values']['temperature'].toDouble();
                                final int weatherCode =
                                    day['values']['weatherCode'];
                                final double? pm25 =
                                    day['values']['particulateMatter25'] !=
                                            null
                                        ? day['values']['particulateMatter25']
                                            .toDouble()
                                        : null;
                                final String weatherDescription =
                                    weatherDescriptions[weatherCode] ??
                                        'Unknown weather';
                                final String pm25Description =
                                    pm25 != null
                                        ? getPm25Description(pm25)
                                        : 'N/A';

                                return Card(
                                  color: isDaytime
                                      ? Colors.blue.shade900
                                      : Colors.black87,
                                  elevation: 4,
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 8),
                                  child: ListTile(
                                    title: Text(
                                      DateFormat.yMMMMd().add_jm().format(date),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 8),
                                        Text(
                                          'Temperature: $temperature°C',
                                          style:
                                              const TextStyle(color: Colors.white),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Weather: $weatherDescription',
                                          style:
                                              const TextStyle(color: Colors.white),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'PM2.5: $pm25Description',
                                          style:
                                              const TextStyle(color: Colors.white),
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    } else {
                      return const Center(
                        child: Text(
                          'No data available',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChartData {
  final double x;
  final double y;

  ChartData(this.x, this.y);
}
