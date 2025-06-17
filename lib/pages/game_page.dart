import 'package:elders_word_dungeon_android/backops/google_ads.dart';
import 'package:elders_word_dungeon_android/game/game_field.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flame/game.dart';
import 'dart:math';
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
  late GoogleAds _googleAds;

  @override
  void initState() {
    _googleAds = GoogleAds();
    super.initState();
    gameField = GameField(level: widget.level);
    gameField.selectedHammerType = selectedHammerType;
    loadAdData();
  }

  void loadAdData() {
    _googleAds.loadGamePageBannerAd(
      adLoaded: () {
        setState(() {});
      },
    );
  }

  Widget _buildHammerOption(HammerType type, String label) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isSelectedOptionCurrentlyActive = selectedHammerType == type;

    Color getOptionColor(HammerType optionType) {
      switch (optionType) {
        case HammerType.none:
          return Colors.green;
        case HammerType.singleTile:
          return Colors.orange;
        case HammerType.fullRow:
          return Colors.red;
        case HammerType.fullColumn:
          return Colors.cyan;
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
        margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenHeight * 0.015,
        ),
        decoration: BoxDecoration(
          color: isSelectedOptionCurrentlyActive
              ? getOptionColor(type)
              : Colors.grey[800],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.035,
          ),
          textAlign: TextAlign.center,
          textScaler: const TextScaler.linear(1),
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
      case HammerType.fullColumn:
        return Colors.cyan;
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
      case HammerType.fullColumn:
        return Colors.cyan.shade300;
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
        return 'Aktif Mod: Hücresel Çekiç';
      case HammerType.fullRow:
        return 'Aktif Mod: Satır Çekici';
      case HammerType.fullColumn:
        return 'Aktif Mod: Sütun Çekici';
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack(
          children: [
            // Flame alanına gönderi
            SafeArea(
              child: GameWidget(game: gameField),
            ),
            // Açılır panel
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              bottom: screenHeight * 0.1,
              right: isHammerMenuOpen ? screenWidth * 0.05 : -(screenWidth * 1),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Container(
                    width: screenWidth * 0.75,
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: screenHeight * 0.015,
                    ),
                    decoration: BoxDecoration(
                      color: _getPanelBackgroundColor().withOpacity(0.8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _getPanelBorderColor(),
                        width: screenWidth * 0.005,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHammerOption(
                            HammerType.fullColumn, 'Sütun Çekici Modu'),
                        _buildHammerOption(
                            HammerType.fullRow, 'Satır Çekici Modu'),
                        _buildHammerOption(
                            HammerType.singleTile, 'Hücresel Çekiç Modu'),
                        _buildHammerOption(
                            HammerType.none, 'Kelime Seçim Modu'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Sayfadan ayrılma butonu
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.only(
                  left: screenWidth * 0.03,
                  top: screenHeight * 0.05,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    splashColor: Colors.red.withOpacity(0.9),
                    highlightColor: Colors.red.withOpacity(0.75),
                    onTap: () {
                      Navigator.pop(context);
                    },
                    customBorder: const CircleBorder(),
                    child: Transform.rotate(
                      angle: pi / 4,
                      child: Icon(
                        Icons.add_circle,
                        size: screenWidth * 0.1,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Aktif Mod Butonu
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: screenHeight * 0.02),
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
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: screenHeight * 0.0125,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.construction,
                        color: Colors.black,
                      ),
                      SizedBox(width: screenWidth * 0.015),
                      Text(
                        _getActiveButtonText(),
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                        textScaler: const TextScaler.linear(1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Banner Reklamı
            Padding(
              padding: EdgeInsets.only(top: screenHeight * 0.125),
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  child: _googleAds.gamePageBannerAd != null
                      ? SizedBox(
                          width: _googleAds.gamePageBannerAd!.size.width
                              .toDouble(),
                          height: _googleAds.gamePageBannerAd!.size.height
                              .toDouble(),
                          child: AdWidget(
                            ad: _googleAds.gamePageBannerAd!,
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
