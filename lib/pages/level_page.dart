import 'package:elders_word_dungeon_android/backops/google_ads.dart';
import 'package:elders_word_dungeon_android/pages/game_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';

class LevelPage extends StatefulWidget {
  const LevelPage({super.key});

  @override
  State<LevelPage> createState() => _LevelPageState();
}

class _LevelPageState extends State<LevelPage> {
  late GoogleAds _googleAds;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _googleAds = GoogleAds();
    super.initState();
    loadAdData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
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
      const Offset(85, 900), // 1
      const Offset(160, 800), // 2
      const Offset(110, 700), // 3
      const Offset(270, 600), // 4
      const Offset(75, 500), // 5
      const Offset(205, 400), // 6
      const Offset(145, 300), // 7
      const Offset(30, 200), // 8
      const Offset(240, 100), // 9
    ];

    return List.generate(positions.length, (index) {
      final levelNumber = index + 1;
      return Positioned(
        left: positions[index].dx,
        top: positions[index].dy,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => GamePage(level: levelNumber),
              ),
            );
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
    // final double screenHeight = MediaQuery.of(context).size.height;
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
          ),
          Expanded(
            child: Stack(
              children: [
                SingleChildScrollView(
                  controller: _scrollController,
                  child: SizedBox(
                    height: (50 * 10) * 2,
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
