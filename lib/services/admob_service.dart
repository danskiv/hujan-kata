import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Layanan AdMob untuk iklan rewarded ("lihat iklan → +1 nyawa").
///
/// PENTING: ganti [rewardedAdUnitId] dengan Ad Unit ID asli dari AdMob
/// sebelum rilis. ID di bawah adalah TEST ID resmi Google.
class AdMobService {
  // Test Ad Unit ID (Android) — Google. Ganti sebelum rilis!
  static const String rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';

  RewardedAd? _rewardedAd;
  bool _isLoading = false;

  /// Inisialisasi AdMob. Panggil sekali di main().
  static Future<void> init() async {
    await MobileAds.instance.initialize();
  }

  /// Muat iklan rewarded (async).
  Future<void> loadRewardedAd() async {
    if (_isLoading || _rewardedAd != null) return;
    _isLoading = true;
    try {
      await RewardedAd.load(
        adUnitId: rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            _isLoading = false;
          },
          onAdFailedToLoad: (error) {
            _isLoading = false;
            _rewardedAd = null;
          },
        ),
      );
    } catch (_) {
      _isLoading = false;
    }
  }

  /// Tampilkan iklan; panggil [onReward] saat user menonton selesai.
  /// Kembalikan true jika iklan tampil, false jika gagal/tidak siap.
  Future<bool> showRewardedAd({required VoidCallback onReward}) async {
    final ad = _rewardedAd;
    if (ad == null) return false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd(); // siapkan untuk sesi berikutnya
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
      },
    );

    await ad.show(onUserEarnedReward: (ad, reward) => onReward());
    return true;
  }
}
