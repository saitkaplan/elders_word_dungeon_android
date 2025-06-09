import 'package:elders_word_dungeon_android/pages/home_page.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

void main() {
  // Temel yükleme ve ayarların alınması
  WidgetsFlutterBinding.ensureInitialized();
  // Reklam işlemlerinin uygulamaya yüklenmesi
  // MobileAds.instance.initialize();
  // Durum çubuğunu şeffaf ve beyaz temaya dönüşmesi
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
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
