// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'forecast_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<Map<String, String?>>? userDataFuture;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    userDataFuture = _loadUserData();
  }

  Future<Map<String, String?>> _loadUserData() async {
    final uid = AuthService().currentUser?.uid;
    if (uid != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (doc.exists) {
          return {
            'username': doc['username'],
            'location': doc['location'],
          };
        }
      } catch (e) {
        print("Error loading user data: $e");
      }
    }
    return {'username': null, 'location': null};
  }

  void _logout() async {
    await AuthService().logout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  void _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      final userData = await userDataFuture!;
      final location = userData['location'];

      if (location != null) {
        final coordinates = location.split(',');
        if (coordinates.length == 2) {
          final latitude = double.tryParse(coordinates[0]);
          final longitude = double.tryParse(coordinates[1]);

          if (latitude != null && longitude != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ForecastScreen(
                  latitude: latitude,
                  longitude: longitude,
                ),
              ),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Weatherly Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: FutureBuilder<Map<String, String?>>(
        future: userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final userData = snapshot.data;
          final username = userData?['username'];
          final location = userData?['location'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                username != null
                    ? Text(
                        'Welcome, $username!',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      )
                    : const Text("Loading..."),
                const SizedBox(height: 10),
                location != null
                    ? Text(
                        'Location: $location',
                        style: const TextStyle(fontSize: 18),
                      )
                    : const SizedBox.shrink(),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.wb_sunny),
            label: 'Forecast',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
        ],
      ),
    );
  }
}
