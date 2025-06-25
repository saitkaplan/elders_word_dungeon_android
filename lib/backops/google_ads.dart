import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

typedef VoidCallback = void Function();

class GoogleAds with ChangeNotifier {
  InterstitialAd? interstitialAd;
  void loadInterstitialAd(
      {bool showAfterLoad = false, required VoidCallback onAdClosed}) {
    final String interstitialAdId;
    if (kDebugMode) {
      interstitialAdId = dotenv.env["test_interstitial_id"] ??
          "ca-app-pub-3940256099942544/1033173712";
    } else {
      interstitialAdId = dotenv.env["interstitial_id"] ??
          "ca-app-pub-3940256099942544/1033173712";
    }
    InterstitialAd.load(
      adUnitId: interstitialAdId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          interstitialAd = ad;
          interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              onAdClosed();
            },
            onAdFailedToShowFullScreenContent: (ad, err) {
              ad.dispose();
              if (kDebugMode) {
                print('BannerAd failed to load: $err');
              }
            },
          );
          if (showAfterLoad) showInterstitialAd();
        },
        onAdFailedToLoad: (LoadAdError error) {},
      ),
    );
  }

  void showInterstitialAd() {
    if (interstitialAd != null) {
      interstitialAd!.show();
    }
  }

  // Oyun Ekranı Banner'ı;
  BannerAd? gamePageBannerAd;
  void loadGamePageBannerAd({required VoidCallback adLoaded}) {
    final String bannerAdId;
    if (kDebugMode) {
      bannerAdId = dotenv.env["test_banner_id"] ??
          "ca-app-pub-3940256099942544/6300978111";
    } else {
      bannerAdId = dotenv.env["game_page_banner_id"] ??
          "ca-app-pub-3940256099942544/6300978111";
    }
    gamePageBannerAd = BannerAd(
      adUnitId: bannerAdId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          gamePageBannerAd = ad as BannerAd;
          notifyListeners();
          adLoaded();
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          if (kDebugMode) {
            print('BannerAd failed to load: $err');
          }
        },
      ),
    )..load();
  }

  void disposeGamePageBannerAd() {
    gamePageBannerAd?.dispose();
    gamePageBannerAd = null;
  }

  // Level Ekranı Banner'ı;
  BannerAd? levelPageBannerAd;
  void loadLevelPageBannerAd({required VoidCallback adLoaded}) {
    final String bannerAdId;
    if (kDebugMode) {
      bannerAdId = dotenv.env["test_banner_id"] ??
          "ca-app-pub-3940256099942544/6300978111";
    } else {
      bannerAdId = dotenv.env["level_page_banner_id"] ??
          "ca-app-pub-3940256099942544/6300978111";
    }
    levelPageBannerAd = BannerAd(
      adUnitId: bannerAdId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          levelPageBannerAd = ad as BannerAd;
          notifyListeners();
          adLoaded();
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          if (kDebugMode) {
            print('BannerAd failed to load: $err');
          }
        },
      ),
    )..load();
  }

  void disposeLevelPageBannerAd() {
    levelPageBannerAd?.dispose();
    levelPageBannerAd = null;
  }
}
