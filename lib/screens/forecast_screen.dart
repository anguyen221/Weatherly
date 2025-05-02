import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'themes.dart';

class ForecastScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  final int selectedIndex;
  final Function(int) onItemTapped;

  const ForecastScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  final String apiKey = 'd6c6999652be6ef551b8088a4851845d';
  final String apiUrl = 'https://api.openweathermap.org/data/2.5/forecast';

  List<dynamic> hourlyForecast = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  Future<void> _fetchWeatherData() async {
    try {
      final response = await http.get(
        Uri.parse(
            '$apiUrl?lat=${widget.latitude}&lon=${widget.longitude}&appid=$apiKey&units=metric'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['list'] != null && data['list'].isNotEmpty) {
          setState(() {
            hourlyForecast = data['list'];
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = 'No forecast data available.';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to load weather data.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: AppThemes.selectedTheme ?? ValueNotifier(null),
      builder: (context, selectedTheme, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Weather Forecast')),
          body: Container(
            decoration: AppThemes.getBackgroundDecoration(selectedTheme),
            width: double.infinity,
            height: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '3-Hour Forecast (Next 5 Days)',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : errorMessage.isNotEmpty
                          ? Center(
                              child: Text(
                                errorMessage,
                                style: const TextStyle(color: Colors.red, fontSize: 16),
                              ),
                            )
                          : Expanded(
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: hourlyForecast.length,
                                itemBuilder: (context, index) {
                                  final weather = hourlyForecast[index];
                                  final time = weather['dt_txt'];
                                  final temp = weather['main']['temp'];
                                  final weatherDescription = weather['weather'][0]['description'];
                                  final iconCode = weather['weather'][0]['icon'];

                                  return Card(
                                    margin: const EdgeInsets.symmetric(vertical: 5),
                                    child: ListTile(
                                      title: Text('$time - $temp°C',
                                          style: const TextStyle(fontWeight: FontWeight.bold)),
                                      subtitle: Text(weatherDescription),
                                      trailing: Image.network(
                                          'https://openweathermap.org/img/wn/$iconCode.png'),
                                    ),
                                  );
                                },
                              ),
                            ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}