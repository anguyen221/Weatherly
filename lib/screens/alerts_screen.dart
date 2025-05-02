import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'themes.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  bool _isNotificationsEnabled = false;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    _checkNotificationPermission();
  }

  Future<void> _checkNotificationPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission();
    setState(() {
      _isNotificationsEnabled = settings.authorizationStatus == AuthorizationStatus.authorized;
    });
  }

  void _toggleNotifications() async {
    if (_isNotificationsEnabled) {
      await _firebaseMessaging.unsubscribeFromTopic("weather_alerts");
    } else {
      await _firebaseMessaging.subscribeToTopic("weather_alerts");
    }

    setState(() {
      _isNotificationsEnabled = !_isNotificationsEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: AppThemes.selectedTheme ?? ValueNotifier(null),
      builder: (context, selectedTheme, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Alerts Settings"),
          ),
          body: Container(
            decoration: AppThemes.getBackgroundDecoration(selectedTheme),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enable Push Notifications for Weather Alerts:',
                    style: TextStyle(fontSize: 18),
                  ),
                  SwitchListTile(
                    title: const Text('Enable Notifications'),
                    value: _isNotificationsEnabled,
                    onChanged: (bool value) {
                      _toggleNotifications();
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Save Settings'),
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
