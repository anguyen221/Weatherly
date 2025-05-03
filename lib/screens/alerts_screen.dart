// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
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
    _initializeFirebase();
    _checkNotificationPermission();
    _listenToForegroundMessages();
  }

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp();
    _getFCMToken(); 
  }

  Future<void> _checkNotificationPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission();
    setState(() {
      _isNotificationsEnabled = settings.authorizationStatus == AuthorizationStatus.authorized;
    });
  }

  Future<void> _getFCMToken() async {
    String? token = await _firebaseMessaging.getToken();
    debugPrint("🔑 FCM Token: $token");
  }

  void _listenToForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("📨 Foreground message: ${message.notification?.title}");
      if (message.notification != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📢 ${message.notification!.title ?? "New Alert"}'),
          ),
        );
      }
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
                    onPressed: () {
                      Navigator.pop(context);
                    },
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
