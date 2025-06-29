import 'package:elders_word_dungeon_android/backops/google_ads.dart';
import 'package:elders_word_dungeon_android/pages/game_page.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------------
/// Elder's Word Dungeon (Android Version)
/// Copyright (c) 2025 Sait Kaplan
/// Licensed under the MIT License. See LICENSE file in the root of the project.
///
/// You are NOT allowed to claim authorship, remove this notice, or use this
/// file in commercial projects without explicit permission from the author.
/// ---------------------------------------------------------------------------

class LevelPage extends StatefulWidget {
  const LevelPage({super.key});

  @override
  State<LevelPage> createState() => _LevelPageState();
}

class _LevelPageState extends State<LevelPage> {
  late GoogleAds _googleAds;
  final ScrollController _scrollController = ScrollController();

  int earnedPoint = 0;
  int levelButtonCount = 10;

  @override
  void initState() {
    _googleAds = GoogleAds();
    super.initState();
    loadAdData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.minScrollExtent);
      }
    });
  }

  void loadAdData() {
    _googleAds.loadLevelPageBannerAd(
      adLoaded: () {
        setState(() {});
      },
    );
  }

  List<Widget> _buildLevelButtons() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    List<Offset> positions = [
      // Buton Konumları (x, y)
      // En Üst Level 1, en alt ise son level.
      // Genişlik çarpanı 0.7'i geçmemeli!
      Offset(screenWidth * 0.31, screenHeight * 0.05), // 1
      Offset(screenWidth * 0.22, screenHeight * 0.15), // 2
      Offset(screenWidth * 0.47, screenHeight * 0.25), // 3
      Offset(screenWidth * 0.63, screenHeight * 0.35), // 4
      Offset(screenWidth * 0.46, screenHeight * 0.45), // 5
      Offset(screenWidth * 0.28, screenHeight * 0.55), // 6
      Offset(screenWidth * 0.42, screenHeight * 0.65), // 7
      Offset(screenWidth * 0.56, screenHeight * 0.75), // 8
      Offset(screenWidth * 0.34, screenHeight * 0.85), // 9
      Offset(screenWidth * 0.14, screenHeight * 0.95), // 10
    ];
    setState(() {
      levelButtonCount = (positions.length + 1);
    });
    return List.generate(positions.length, (index) {
      final levelNumber = index + 1;
      return Positioned(
        left: positions[index].dx,
        top: positions[index].dy,
        child: InkWell(
          onTap: () async {
            final result = await Navigator.of(context).push<int>(
              MaterialPageRoute(
                builder: (_) => GamePage(
                  level: levelNumber,
                  earnedPoint: earnedPoint,
                ),
              ),
            );
            if (result != null) {
              setState(() {
                earnedPoint = result;
              });
              if (kDebugMode) {
                print(
                  'BÖLÜM TAMAMLANDI VE SKOR DEĞERİ OLAN $earnedPoint SAYISI GÜNCELLENDİ!',
                );
              }
            }
          },
          child: Container(
            width: screenWidth * 0.25,
            height: screenHeight * 0.05,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.green[700],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Bölüm $levelNumber',
              style: TextStyle(
                color: Colors.white,
                fontSize: screenWidth * 0.035,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              textScaler: const TextScaler.linear(1),
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: statusBarHeight,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(width: screenWidth * 0.05),
                    IconButton(
                      icon: Icon(
                        CupertinoIcons.arrow_left_circle_fill,
                        size: screenWidth * 0.09,
                      ),
                      color: Colors.white,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Text(
                      'Bölüm Seçimi',
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                      textScaler: const TextScaler.linear(1),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "Güncel Skor: $earnedPoint",
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                      textScaler: const TextScaler.linear(1),
                    ),
                    SizedBox(width: screenWidth * 0.05),
                  ],
                ),
              ],
            ),
          ),
          Flexible(
            child: Stack(
              children: [
                SingleChildScrollView(
                  controller: _scrollController,
                  child: SizedBox(
                    height: ((screenHeight * 0.05) * levelButtonCount) * 2,
                    child: Stack(
                      children: _buildLevelButtons(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              child: _googleAds.levelPageBannerAd != null
                  ? SizedBox(
                      width:
                          _googleAds.levelPageBannerAd!.size.width.toDouble(),
                      height:
                          _googleAds.levelPageBannerAd!.size.height.toDouble(),
                      child: AdWidget(
                        ad: _googleAds.levelPageBannerAd!,
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
