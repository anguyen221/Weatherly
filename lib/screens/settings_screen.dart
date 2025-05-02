// ignore_for_file: prefer_final_fields

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import 'themes.dart';

class SettingsScreen extends StatefulWidget {
  final Function(String) onUsernameUpdated;
  final Function(String) onLocationUpdated;

  const SettingsScreen({
    super.key,
    required this.onUsernameUpdated,
    required this.onLocationUpdated,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String? _userId;

  @override
  void initState() {
    super.initState();
    _userId = AuthService().currentUser?.uid;
    _loadUserSettings();
  }

  Future<void> _loadUserSettings() async {
    if (_userId != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(_userId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        _usernameController.text = data['username'] ?? '';
        _locationController.text = data['customLocation'] ?? '';
      }
    }
  }

  Future<void> _updateSettings() async {
    final newUsername = _usernameController.text.trim();
    final newLocation = _locationController.text.trim();

    if (_userId != null && newUsername.isNotEmpty) {
      await FirebaseFirestore.instance.collection('users').doc(_userId).update({
        'username': newUsername,
        'customLocation': newLocation,
      });

      widget.onUsernameUpdated(newUsername);
      widget.onLocationUpdated(newLocation);

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: AppThemes.selectedTheme ?? ValueNotifier(null),
      builder: (context, selectedTheme, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: Container(
            decoration: AppThemes.getBackgroundDecoration(selectedTheme),
            width: double.infinity,
            height: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(labelText: 'Username'),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location (e.g., 37.7749,-122.4194)',
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _updateSettings,
                    child: const Text('Save Changes'),
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