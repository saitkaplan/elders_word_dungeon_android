import 'package:elders_word_dungeon_android/pages/level_page.dart';
import 'dart:ui';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isPlayable = false;

  void prototypeAttention() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  top: screenHeight * 0.04,
                  bottom: screenHeight * 0.04,
                  right: screenWidth * 0.055,
                  left: screenWidth * 0.055,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Oyun Mantığı & Oynanışı Hk.",
                      style: TextStyle(
                        fontSize: screenWidth * 0.075,
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        shadows: const [
                          Shadow(offset: Offset(-1, -1), color: Colors.black),
                          Shadow(offset: Offset(1, -1), color: Colors.black),
                          Shadow(offset: Offset(1, 1), color: Colors.black),
                          Shadow(offset: Offset(-1, 1), color: Colors.black),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      textScaler: const TextScaler.linear(1),
                    ),
                    SizedBox(height: screenHeight * 0.005),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Text(
                              "Oynanış hakkında temel bilgiler bu bölmede yazmaktadır. Lütfen tüm bilgilendirmeleri okumadan oyuna başlamayın!!!\n\n"
                              "Oyunun temel hedefi ise şunlardır;\n\n"
                              "Oyun alanının en alt satırından başlayarak, sağa-sola ve aşağı-yukarı sürükleme hareketleriyle harf havuzundan kelime bulmak oyunun en temel amacıdır. Bulunması gereken kelimelerin ne olduğu ise bölüm başlığında belirtilen kategoride bildirilmektedir.\n\n"
                              "Kelime seçme işlemi yukarıdaki paragrafta da denildiği üzere tut sürükle şeklinde olmaktadır. En alt satırda kelime seçiminde kullanılabilecek bir harf kalmadığında ise çekiç sistemi devreye girmektedir.\n\n"
                              "Çekiç sistemi ise çeşitli özelliklerdeki çekiçleri kullanarak kullanılmayan harf kutucuklarını oyun alanından kaldırmaya ve oyunun devam etmesine yaramaktadır. Buradaki önemli etken çekiçlerin kullanımının dahi puan eksiltmesidir.\n\n"
                              "Çekiç sistemi istenildiğinde her an kullanılabilecek bir sistemdir. Yani istenildiğinde doğru bir kelimenin herhangi bir harfini de oyun alanından kaldırma ihtimaliniz bulunmaktadır.\n\n"
                              "Puanlama sistemi için ilk prototipte belirlenen değerler;\n\n"
                              "Doğru seçilen kelimenin her harfi için +20 puan,\n"
                              "Türü fark etmeksizin kullanılan her çekiç için ise -10 puan olarak belirlenmiştir.",
                              style: TextStyle(
                                fontSize: screenWidth * 0.045,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                              textScaler: const TextScaler.linear(1),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.25),
                        foregroundColor: Colors.black,
                        shadowColor: Colors.black.withOpacity(0.2),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: EdgeInsets.only(
                          top: screenHeight * 0.011,
                          bottom: screenHeight * 0.011,
                          left: screenWidth * 0.075,
                          right: screenWidth * 0.075,
                        ),
                      ),
                      onPressed: () {
                        isPlayable = true;
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Bilgilendirmeyi Kapat",
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          color: Colors.black,
                        ),
                        textScaler: const TextScaler.linear(1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: screenHeight * 0.2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "The Elder's\nWord Dungeon'ına\n\n"
                    "Hoşgeldiniz!",
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    textScaler: const TextScaler.linear(1),
                  ),
                ],
              ),
            ],
          ),
          Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () {
                if (isPlayable) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LevelPage()),
                  );
                }
              },
              child: Text(
                "Oyuna Başla",
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
                textScaler: const TextScaler.linear(1),
              ),
            ),
          ),
          Column(
            children: [
              SizedBox(height: screenHeight * 0.575),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: screenWidth * 0.5,
                    height: screenWidth * 0.5,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          "assets/images/logos/ers_logo.png",
                          width: screenWidth * 0.5,
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Text(
                            "Sunar",
                            style: TextStyle(
                              fontSize: screenWidth * 0.05,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            textScaler: const TextScaler.linear(1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            children: [
              SizedBox(height: screenHeight * 0.85),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      prototypeAttention();
                    },
                    child: Padding(
                      padding: EdgeInsets.all(screenWidth * 0.02),
                      child: Text(
                        "Başlamadan Önce\nBana Dokun",
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.center,
                        textScaler: const TextScaler.linear(1),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Text(
              "Prototip 1 (Ver: 1.0.0)",
              style: TextStyle(
                fontSize: screenWidth * 0.03,
                color: Colors.blueGrey.shade200,
              ),
              textAlign: TextAlign.center,
              textScaler: const TextScaler.linear(1),
            ),
          )
        ],
      ),
    );
  }
}
