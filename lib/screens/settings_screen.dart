import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import 'themes.dart';

class SettingsScreen extends StatefulWidget {
  final Function(String) onUsernameUpdated;

  const SettingsScreen({super.key, required this.onUsernameUpdated});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  TextEditingController _usernameController = TextEditingController();
  String? _userId;

  @override
  void initState() {
    super.initState();
    _userId = AuthService().currentUser?.uid;
    _loadCurrentUsername();
  }

  Future<void> _loadCurrentUsername() async {
    if (_userId != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(_userId).get();
      if (doc.exists && doc.data() != null) {
        _usernameController.text = doc['username'] ?? '';
      }
    }
  }

  void _updateUsername() async {
    final newUsername = _usernameController.text.trim();
    if (newUsername.isNotEmpty && _userId != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .update({'username': newUsername});

      widget.onUsernameUpdated(newUsername);
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
                  ElevatedButton(
                    onPressed: _updateUsername,
                    child: const Text('Update Username'),
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