import 'package:elders_word_dungeon_android/pages/level_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LevelPage()),
            );
          },
          child: const Text(
            'Play',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}
