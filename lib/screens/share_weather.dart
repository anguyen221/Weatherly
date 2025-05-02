import 'package:flutter/material.dart';

class ShareWeatherScreen extends StatelessWidget {
  const ShareWeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Weather'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Share your current weather on social media:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _shareWeather(context, 'Text');
              },
              child: const Text('Share via Text'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _shareWeather(context, 'Instagram');
              },
              child: const Text('Share via Instagram'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _shareWeather(context, 'Facebook');
              },
              child: const Text('Share via Facebook'),
            ),
          ],
        ),
      ),
    );
  }

  void _shareWeather(BuildContext context, String platform) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Share Weather'),
          content: Text('You selected to share via $platform.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}