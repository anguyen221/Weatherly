import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapScreen extends StatefulWidget {
  final double latitude;
  final double longitude;

  const MapScreen({super.key, required this.latitude, required this.longitude});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final String apiKey = 'd6c6999652be6ef551b8088a4851845d';
  String weatherDescription = '';
  double temperature = 0;

  String selectedLayer = 'precipitation_new';

  final Map<String, String> mapLayers = {
    'precipitation_new': 'Precipitation Map',
    'clouds_new': 'Cloud Map',
    'temp_new': 'Temperature Map',
    'wind_new': 'Wind Map',
  };

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  Future<void> _fetchWeatherData() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://api.openweathermap.org/data/2.5/weather?lat=${widget.latitude}&lon=${widget.longitude}&appid=$apiKey&units=imperial'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          weatherDescription = data['weather'][0]['description'];
          temperature = data['main']['temp'];
        });
      } else {
        setState(() {
          weatherDescription = 'Error loading weather data';
        });
      }
    } catch (e) {
      setState(() {
        weatherDescription = 'Error fetching data: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedMapTitle = mapLayers[selectedLayer] ?? 'Weather Map';

    return Scaffold(
      appBar: AppBar(
        title: Text(selectedMapTitle),
        actions: [
          DropdownButton<String>(
            value: selectedLayer,
            dropdownColor: Colors.white,
            underline: Container(),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            items: mapLayers.entries.map((entry) {
              return DropdownMenuItem<String>(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedLayer = value;
                });
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(widget.latitude, widget.longitude),
                minZoom: 4.0,
                maxZoom: 19.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openweathermap.org/map/$selectedLayer/{z}/{x}/{y}.png?appid=$apiKey',
                  userAgentPackageName: 'com.example.weatherly',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(widget.latitude, widget.longitude),
                      width: 30.0,
                      height: 30.0,
                      child: const Icon(Icons.location_pin),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weather: $weatherDescription',
                  style: const TextStyle(fontSize: 18),
                ),
                Text(
                  'Temperature: $temperature°F',
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
