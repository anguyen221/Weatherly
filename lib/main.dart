import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import 'services/auth_service.dart';
import 'firebase_options.dart';
import '../screens/themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final savedTheme = await AppThemes.loadTheme();

  runApp(WeatherlyApp(initialTheme: savedTheme));
}

class WeatherlyApp extends StatefulWidget {
  final String? initialTheme;

  const WeatherlyApp({super.key, this.initialTheme});

  @override
  State<WeatherlyApp> createState() => _WeatherlyAppState();
}

class _WeatherlyAppState extends State<WeatherlyApp> {
  late ValueNotifier<String?> selectedTheme;

  @override
  void initState() {
    super.initState();
    selectedTheme = ValueNotifier(widget.initialTheme);
    AppThemes.selectedTheme = selectedTheme;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: selectedTheme,
      builder: (context, themeName, _) {
        return MaterialApp(
          title: 'Weatherly',
          theme: ThemeData(primarySwatch: Colors.blue),
          home: BackgroundWrapper(
            themeName: themeName,
            child: const AuthGate(),
          ),
        );
      },
    );
  }
}

class BackgroundWrapper extends StatelessWidget {
  final Widget child;
  final String? themeName;

  const BackgroundWrapper({
    super.key,
    required this.child,
    required this.themeName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppThemes.getBackgroundDecoration(themeName),
      child: child,
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}