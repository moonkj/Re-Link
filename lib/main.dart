import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 실기기 에러 가시화: 검은 화면 대신 에러 내용 표시
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: const Color(0xFF1A0000),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              const Text(
                'Re-Link 렌더링 오류',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: SingleChildScrollView(
                  child: Text(
                    details.exception.toString(),
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  };

  // 상태바 스타일 (동기, 빠름)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // 앱 실행 — DB는 첫 쿼리 시 LazyDatabase가 자동 생성
  runApp(const ProviderScope(child: ReLink()));

  // 첫 프레임 완료 후 무거운 초기화 (iOS 26 watchdog 방지)
  WidgetsBinding.instance.addPostFrameCallback((_) {
    // 화면 방향 설정 (플랫폼 채널, 첫 프레임 후 안전)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // AdMob 초기화 (첫 프레임 후 — startup watchdog 방지)
    MobileAds.instance.initialize().catchError((_) => InitializationStatus({}));
  });
}
