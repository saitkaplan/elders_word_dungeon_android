import 'package:elders_word_dungeon_android/pages/home_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  // Temel yükleme ve ayarların alınması
  WidgetsFlutterBinding.ensureInitialized();
  // .env dosyasının alınması
  await dotenv.load(fileName: ".env");
  // Reklam işlemlerinin uygulamaya yüklenmesi
  MobileAds.instance.initialize();
  // Durum çubuğunu verilerinin güncellenmesi
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.blueGrey.shade900,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  // Uygulamanın dikey moda sabitlenmesi
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Elder's Word Dungeon",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
