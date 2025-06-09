import 'package:elders_word_dungeon_android/pages/game_page.dart';
import 'package:flutter/material.dart';

class LevelPage extends StatelessWidget {
  const LevelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Bölüm Seçimi',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // 3 sütun
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
        ),
        itemCount: 9, // Şimdilik 9 bölüm
        itemBuilder: (context, index) {
          final levelNumber = index + 1;
          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontSize: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => GamePage(level: levelNumber),
                ),
              );
            },
            child: Text('Level $levelNumber'),
          );
        },
      ),
    );
  }
}
