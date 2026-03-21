import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../design/tokens/app_colors.dart';
import '../models/user_plan.dart';
import '../../features/subscription/providers/plan_notifier.dart';

/// AdMob 배너 광고 위젯 (Free 플랜만 표시)
///
/// 사용법: 화면 하단에 배치
/// ```dart
/// Column(children: [
///   Expanded(child: content),
///   const AdBannerWidget(),
/// ])
/// ```
class AdBannerWidget extends ConsumerStatefulWidget {
  const AdBannerWidget({super.key});

  @override
  ConsumerState<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends ConsumerState<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _adLoaded = false;

  // 테스트 ID — 출시 전 실제 ID로 교체
  static const String _adUnitIdAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const String _adUnitIdIos = 'ca-app-pub-3940256099942544/2934735716';

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    final adUnitId = Platform.isIOS ? _adUnitIdIos : _adUnitIdAndroid;

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _adLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _bannerAd = null;
          if (mounted) setState(() => _adLoaded = false);
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final planAsync = ref.watch(planNotifierProvider);
    final plan = planAsync.valueOrNull ?? UserPlan.free;

    // 유료 플랜(플러스 이상): 광고 없음
    if (!plan.hasAds) return const SizedBox.shrink();

    if (!_adLoaded || _bannerAd == null) {
      // 광고 로드 전 placeholder (레이아웃 안정성)
      return const SizedBox(height: 50);
    }

    return Container(
      color: AppColors.bgElevated,
      alignment: Alignment.center,
      width: double.infinity,
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
