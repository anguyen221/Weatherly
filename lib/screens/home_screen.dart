import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'forecast_screen.dart';
import 'map_screen.dart';
import 'themes.dart';
import 'theme_selector.dart';
import 'share_weather.dart';
import 'settings_screen.dart';
import 'community_reports_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<Map<String, String?>>? userDataFuture;
  int _selectedIndex = 0;
  String? _username;
  String? _customLocation;

  @override
  void initState() {
    super.initState();
    userDataFuture = _loadUserData();

    if (AppThemes.selectedTheme == null) {
      AppThemes.loadTheme().then((theme) {
        AppThemes.selectedTheme = ValueNotifier<String?>(theme);
        setState(() {});
      });
    }
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
            'customLocation': doc['customLocation'],
          };
        }
      } catch (e) {
        print("Error loading user data: $e");
      }
    }
    return {'username': null, 'location': null, 'customLocation': null};
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

    final userData = await userDataFuture!;
    final location = _customLocation ?? userData['customLocation'] ?? userData['location'];
    if (location == null) return;

    final coordinates = location.split(',');
    if (coordinates.length != 2) return;

    final latitude = double.tryParse(coordinates[0]);
    final longitude = double.tryParse(coordinates[1]);

    if (latitude == null || longitude == null) return;

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ForecastScreen(
            latitude: latitude,
            longitude: longitude,
            selectedIndex: _selectedIndex,
            onItemTapped: _onItemTapped,
          ),
        ),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MapScreen(
            latitude: latitude,
            longitude: longitude,
          ),
        ),
      );
    }
  }

  void _updateUsername(String newUsername) {
    setState(() {
      _username = newUsername;
    });
  }

  void _updateLocation(String newLocation) {
    setState(() {
      _customLocation = newLocation;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: AppThemes.selectedTheme ?? ValueNotifier(null),
      builder: (context, selectedTheme, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Weatherly Home"),
            actions: [
              IconButton(
                icon: const Icon(Icons.palette),
                tooltip: "Choose Theme",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ThemeSelectorScreen()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                tooltip: "Settings",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SettingsScreen(
                        onUsernameUpdated: _updateUsername,
                        onLocationUpdated: _updateLocation,
                      ),
                    ),
                  );
                  setState(() {
                    userDataFuture = _loadUserData();
                  });
                },
              ),
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
              final username = _username ?? userData?['username'];
              final location = _customLocation ?? userData?['customLocation'] ?? userData?['location'];

              return Container(
                decoration: AppThemes.getBackgroundDecoration(selectedTheme),
                width: double.infinity,
                height: double.infinity,
                child: Padding(
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
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CommunityReportsScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            '📣 Community Reports',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ShareWeatherScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            '🌈 Share Current Weather',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
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
      },
    );
  }
}