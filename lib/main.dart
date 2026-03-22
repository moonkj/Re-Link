import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'app.dart';
import 'core/services/notification/notification_service.dart';

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

  // ── 글로벌 에러 핸들링 (release 모드 블랙 스크린 방지) ──────────────
  // Flutter 프레임워크 에러 → 콘솔 출력 (크래시 방지)
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };

  // 비동기 미처리 에러 → 플랫폼 디스패처가 흡수 (앱 종료 방지)
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('[Re-Link] Unhandled error: $error\n$stack');
    return true; // true = 에러 처리됨, 앱 종료 방지
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
    // 카카오 SDK 초기화
    // TODO: ed9d5c7ed7690d43a6d8ac866353cf31를 카카오 개발자 콘솔에서 발급받은 네이티브 앱 키로 교체하세요
    // https://developers.kakao.com → 내 애플리케이션 → 앱 키 → 네이티브 앱 키
    KakaoSdk.init(nativeAppKey: 'ed9d5c7ed7690d43a6d8ac866353cf31');

    // AdMob + 알림 초기화: 1.5초 지연 (iOS 26 watchdog 방지)
    // - NotificationService는 Riverpod 싱글톤이 lazy-init으로 처리
    // - 여기서 별도 인스턴스 생성하면 이중 초기화로 충돌 발생
    Future.delayed(const Duration(milliseconds: 1500), () {
      MobileAds.instance.initialize().then((_) {}).catchError((_) {});
    });
  });
}
