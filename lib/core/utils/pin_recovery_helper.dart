import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../design/tokens/app_colors.dart';
import '../../features/auth/providers/auth_notifier.dart';
import '../../features/canvas/providers/my_node_provider.dart';
import '../../shared/widgets/pin_dialog.dart';
import '../services/auth/auth_service.dart';
import '../services/auth/kakao_auth_helper.dart';

/// PIN 복구 헬퍼
///
/// 로그인 재인증을 통한 PIN 초기화 + 새 PIN 등록 흐름을 제공한다.
/// [showPinDialog]의 verify 모드와 설정 화면 양쪽에서 사용.
class PinRecoveryHelper {
  /// PIN 복구 흐름 실행
  ///
  /// 1. 현재 로그인된 provider로 재인증
  /// 2. 성공 시 기존 PIN 삭제
  /// 3. 새 PIN 등록 다이얼로그 표시
  ///
  /// 반환: 새 PIN이 등록되면 true, 취소/실패 시 false
  static Future<bool> recover({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    final user = ref.read(authNotifierProvider).valueOrNull;
    if (user == null) {
      _showSnackBar(context, '로그인 상태가 아닙니다. 먼저 로그인해주세요.');
      return false;
    }

    final provider = user.provider;

    // 재인증 시도
    final reauthed = await _reauthenticate(
      context: context,
      ref: ref,
      provider: provider,
    );

    if (!reauthed) return false;
    if (!context.mounted) return false;

    // PIN 삭제
    await ref.read(myNodeNotifierProvider.notifier).clearPin();

    // 새 PIN 등록 다이얼로그
    if (!context.mounted) return false;
    final result = await showPinDialog(
      context: context,
      mode: PinDialogMode.register,
    );

    if (result != null && result.success && result.pin != null) {
      await ref.read(myNodeNotifierProvider.notifier).setPin(result.pin!);
      if (context.mounted) {
        _showSnackBar(context, 'PIN이 재설정되었습니다');
      }
      return true;
    }

    // 새 PIN 등록 취소 시에도 기존 PIN은 이미 삭제된 상태
    // (재인증에 성공했으므로 보안상 문제 없음)
    if (context.mounted) {
      _showSnackBar(context, 'PIN이 초기화되었습니다');
    }
    return true;
  }

  /// provider에 맞는 재인증 수행
  static Future<bool> _reauthenticate({
    required BuildContext context,
    required WidgetRef ref,
    required String provider,
  }) async {
    try {
      switch (provider) {
        case 'apple':
          final user =
              await ref.read(authServiceProvider).signInWithApple();
          return user != null;

        case 'google':
          final user =
              await ref.read(authServiceProvider).signInWithGoogle();
          return user != null;

        case 'kakao':
          if (!context.mounted) return false;
          final token = await KakaoAuthHelper.login(context);
          // 토큰 획득 성공 = 재인증 성공 (서버 호출 불필요)
          return token.isNotEmpty;

        default:
          debugPrint('[PinRecovery] 알 수 없는 provider: $provider');
          return false;
      }
    } catch (e) {
      debugPrint('[PinRecovery] 재인증 실패: $e');
      return false;
    }
  }

  static void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
