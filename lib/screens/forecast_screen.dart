import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForecastScreen extends StatefulWidget {
  final double latitude;
  final double longitude;

  const ForecastScreen({super.key, required this.latitude, required this.longitude});

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  final String apiKey = 'd6c6999652be6ef551b8088a4851845d';
  final String apiUrl = 'https://api.openweathermap.org/data/2.5/forecast';

  List<dynamic> hourlyForecast = [];
  bool isLoading = true;

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
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Forecast'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('3-Hour Forecast (Next 5 Days)', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: hourlyForecast.length,
                      itemBuilder: (context, index) {
                        final weather = hourlyForecast[index];
                        final time = weather['dt_txt'];
                        final temp = weather['main']['temp'];
                        final weatherDescription = weather['weather'][0]['description'];

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            title: Text('$time - $temp°C', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(weatherDescription),
                            trailing: Icon(Icons.wb_sunny),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
