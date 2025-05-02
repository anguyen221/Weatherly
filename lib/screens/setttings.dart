import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _usernameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUsername();
  }

  Future<void> _loadCurrentUsername() async {
    final uid = AuthService().currentUser?.uid;
    if (uid != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (doc.exists && doc['username'] != null) {
          _usernameController.text = doc['username'];
        }
      } catch (e) {
        print("Error loading username: $e");
      }
    }
  }

  Future<void> _updateUsername() async {
    final uid = AuthService().currentUser?.uid;
    if (uid != null) {
      setState(() {
        _isLoading = true;
      });
      try {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'username': _usernameController.text,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username updated successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating username: $e')),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Update your username:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _updateUsername,
                    child: const Text('Update Username'),
                  ),
          ],
        ),
      ),
    );
  }
}