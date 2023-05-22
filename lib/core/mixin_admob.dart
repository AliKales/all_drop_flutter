import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../common_libs.dart';

mixin MixinAdmob<T extends StatefulWidget> on State<T> {
  final String _bannerId = "ca-app-pub-8099073799754548/8092611735";
  final String _interstitialId = "ca-app-pub-8099073799754548/6779530068";
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    context.afterBuild((p0) => loadBannerAd());
  }

  void showInterstitialAd(VoidCallback onDone) {
    InterstitialAd.load(
        adUnitId: _interstitialId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              // Called when the ad showed the full screen content.
              onAdShowedFullScreenContent: (ad) {},
              // Called when an impression occurs on the ad.
              onAdImpression: (ad) {},
              // Called when the ad failed to show full screen content.
              onAdFailedToShowFullScreenContent: (ad, err) {
                // Dispose the ad here to free resources.
                ad.dispose();
                onDone();
              },
              // Called when the ad dismissed full screen content.
              onAdDismissedFullScreenContent: (ad) {
                // Dispose the ad here to free resources.
                ad.dispose();
                onDone();
              },
            );

            ad.show();
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            onDone();
          },
        ));
  }

  void loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: _bannerId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
      ),
    )..load();
  }

  Widget widgetBanner() {
    if (_bannerAd == null) return const SizedBox.shrink();
    return SizedBox(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
