import 'package:elders_word_dungeon_android/game/game_field.dart';
import 'package:flame/game.dart';
import 'dart:ui';
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
  HammerType selectedHammerType = HammerType.none;
  bool isHammerMenuOpen = false;

  final double _mainButtonWidth = 180.0;
  final double _mainButtonHeight = 48.0;
  final double _panelBottomSpacing = 10.0;

  @override
  void initState() {
    super.initState();
    gameField = GameField(level: widget.level);
    gameField.selectedHammerType = selectedHammerType;
  }

  Widget _buildHammerOption(HammerType type, String label) {
    final bool isSelectedOptionCurrentlyActive = selectedHammerType == type;

    Color getOptionColor(HammerType optionType) {
      switch (optionType) {
        case HammerType.none:
          return Colors.green;
        case HammerType.singleTile:
          return Colors.orange;
        case HammerType.fullRow:
          return Colors.red;
      }
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedHammerType = type;
          gameField.selectedHammerType = type;
          isHammerMenuOpen = false;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelectedOptionCurrentlyActive
              ? getOptionColor(type)
              : Colors.grey[800],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Color _getActiveButtonColor() {
    switch (selectedHammerType) {
      case HammerType.none:
        return Colors.green;
      case HammerType.singleTile:
        return Colors.orange;
      case HammerType.fullRow:
        return Colors.red;
    }
  }

  Color _getPanelBorderColor() {
    switch (selectedHammerType) {
      case HammerType.none:
        return Colors.green.shade300;
      case HammerType.singleTile:
        return Colors.orange.shade300;
      case HammerType.fullRow:
        return Colors.red.shade300;
    }
  }

  Color _getPanelBackgroundColor() {
    return const Color(0xFF1E242B);
  }

  String _getActiveButtonText() {
    switch (selectedHammerType) {
      case HammerType.none:
        return 'Aktif Mod: Kelime Seçimi';
      case HammerType.singleTile:
        return 'Aktif Mod: Tekli Çekiç';
      case HammerType.fullRow:
        return 'Aktif Mod: Satır Çekici';
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    // final double screenHeight = MediaQuery.of(context).size.height;

    final double panelWidth = screenWidth * 0.7;
    final double panelBottomPosition =
        20 + _mainButtonHeight + _panelBottomSpacing;

    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: gameField),
          // Açılır panel
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: panelBottomPosition,
            right: isHammerMenuOpen ? 16 : -panelWidth,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  width: panelWidth,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: _getPanelBackgroundColor().withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _getPanelBorderColor(),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHammerOption(HammerType.none, 'Kelime Seçim Modu'),
                      _buildHammerOption(
                          HammerType.singleTile, 'Tekli Çekiç Modu'),
                      _buildHammerOption(
                          HammerType.fullRow, 'Satır Çekici Modu'),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Oyun alanı butonu
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    isHammerMenuOpen = !isHammerMenuOpen;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getActiveButtonColor(),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  elevation: 8,
                  minimumSize: Size(_mainButtonWidth, _mainButtonHeight),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.construction,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getActiveButtonText(),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
