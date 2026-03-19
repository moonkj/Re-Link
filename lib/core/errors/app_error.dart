/// Re-Link 도메인 에러 정의
sealed class AppError implements Exception {
  const AppError(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// 인증 에러
class AuthError extends AppError {
  const AuthError(super.message);
}

/// 네트워크 에러
class NetworkError extends AppError {
  const NetworkError(super.message);
}

/// 데이터 에러
class DataError extends AppError {
  const DataError(super.message);
}

/// 플랜 제한 에러 (업그레이드 유도)
class PlanLimitError extends AppError {
  const PlanLimitError({
    required this.feature,
    required this.currentPlan,
    required this.requiredPlan,
  }) : super('$feature 기능은 $requiredPlan 플랜이 필요합니다.');

  final String feature;
  final String currentPlan;
  final String requiredPlan;
}

/// 스토리지 에러
class StorageError extends AppError {
  const StorageError(super.message);
}

/// 알 수 없는 에러
class UnknownError extends AppError {
  const UnknownError([super.message = '알 수 없는 오류가 발생했습니다.']);
}

/// 에러 메시지 사용자 친화적 변환
extension AppErrorMessage on AppError {
  String get userMessage => switch (this) {
        AuthError e => e.message,
        NetworkError _ => '네트워크 연결을 확인해 주세요.',
        DataError e => e.message,
        PlanLimitError e => e.message,
        StorageError _ => '파일 저장에 실패했습니다. 다시 시도해 주세요.',
        UnknownError _ => '오류가 발생했습니다. 잠시 후 다시 시도해 주세요.',
      };
}
