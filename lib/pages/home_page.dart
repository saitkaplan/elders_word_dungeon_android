import 'package:elders_word_dungeon_android/pages/level_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      body: Center(
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.2),
            Text(
              "Welcome\nto\n"
              "The Elder's Word Dungeon",
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                color: Colors.tealAccent,
              ),
              textAlign: TextAlign.center,
              textScaler: const TextScaler.linear(1),
            ),
            SizedBox(height: screenHeight * 0.2),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LevelPage()),
                );
              },
              child: Text(
                'Play',
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                textScaler: const TextScaler.linear(1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
