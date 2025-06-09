import 'package:elders_word_dungeon_android/game/game_field.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class GamePage extends StatefulWidget {
  final int level;
  const GamePage({
    super.key,
    required this.level,
  });

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late GameField gameField;

  @override
  void initState() {
    super.initState();
    gameField = GameField(level: widget.level);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: gameField),
          Positioned(
            top: 50,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  gameField.isHammerMode = !gameField.isHammerMode;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    gameField.isHammerMode ? Colors.orange : Colors.blue,
              ),
              child: Text(gameField.isHammerMode ? 'Hammer ON' : 'Hammer OFF'),
            ),
          ),
        ],
      ),
    );
  }
}
