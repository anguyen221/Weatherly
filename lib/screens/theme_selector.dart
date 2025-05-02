import 'package:flutter/material.dart';
import 'themes.dart';

class ThemeSelectorScreen extends StatelessWidget {
  const ThemeSelectorScreen({Key? key}) : super(key: key);

  void _selectTheme(BuildContext context, String themeName) async {
    await AppThemes.saveTheme(themeName);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$themeName theme selected')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final themes = AppThemes.themeImages;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Theme'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: themes.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
        ),
        itemBuilder: (context, index) {
          final themeName = themes.keys.elementAt(index);
          final imagePath = themes[themeName]!;

          return GestureDetector(
            onTap: () => _selectTheme(context, themeName),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(imagePath),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    child: Text(
                      themeName.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}