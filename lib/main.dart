import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 화면 방향 고정 (세로)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 상태바 스타일
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // AdMob 초기화 — 비동기 실행 (runApp 블로킹 방지)
  MobileAds.instance.initialize();

  // 서버 없음 — Drift DB는 첫 사용 시 자동 생성됨
  runApp(const ProviderScope(child: ReLink()));
}
