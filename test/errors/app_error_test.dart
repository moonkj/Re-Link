/// AppError 계층 순수 로직 테스트
/// 커버: app_error.dart — 모든 에러 서브클래스, userMessage 확장
import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/core/errors/app_error.dart';

void main() {
  // ── AppError sealed class ─────────────────────────────────────────────

  group('AppError subtypes', () {
    test('AuthError sets message', () {
      const e = AuthError('인증 실패');
      expect(e.message, '인증 실패');
      expect(e, isA<AppError>());
    });

    test('NetworkError sets message', () {
      const e = NetworkError('네트워크 오류');
      expect(e.message, '네트워크 오류');
      expect(e, isA<AppError>());
    });

    test('DataError sets message', () {
      const e = DataError('데이터 손상');
      expect(e.message, '데이터 손상');
      expect(e, isA<AppError>());
    });

    test('StorageError sets message', () {
      const e = StorageError('파일 저장 실패');
      expect(e.message, '파일 저장 실패');
      expect(e, isA<AppError>());
    });

    test('UnknownError default message', () {
      const e = UnknownError();
      expect(e.message, '알 수 없는 오류가 발생했습니다.');
      expect(e, isA<AppError>());
    });

    test('UnknownError custom message', () {
      const e = UnknownError('커스텀 오류');
      expect(e.message, '커스텀 오류');
    });

    test('PlanLimitError sets all fields', () {
      const e = PlanLimitError(
        feature: '영상 저장',
        currentPlan: '무료',
        requiredPlan: '플러스',
      );
      expect(e.feature, '영상 저장');
      expect(e.currentPlan, '무료');
      expect(e.requiredPlan, '플러스');
      expect(e.message, contains('영상 저장'));
      expect(e.message, contains('플러스'));
    });

    test('PlanLimitError message format', () {
      const e = PlanLimitError(
        feature: '클라우드 백업',
        currentPlan: 'free',
        requiredPlan: 'family',
      );
      expect(e.message, '클라우드 백업 기능은 family 플랜이 필요합니다.');
    });
  });

  // ── toString ──────────────────────────────────────────────────────────

  group('AppError toString', () {
    test('AuthError toString', () {
      const e = AuthError('test');
      expect(e.toString(), 'AuthError: test');
    });

    test('NetworkError toString', () {
      const e = NetworkError('timeout');
      expect(e.toString(), 'NetworkError: timeout');
    });

    test('DataError toString', () {
      const e = DataError('corrupt');
      expect(e.toString(), 'DataError: corrupt');
    });

    test('StorageError toString', () {
      const e = StorageError('disk full');
      expect(e.toString(), 'StorageError: disk full');
    });

    test('UnknownError toString', () {
      const e = UnknownError();
      expect(e.toString(), contains('UnknownError'));
    });

    test('PlanLimitError toString', () {
      const e = PlanLimitError(
        feature: 'f',
        currentPlan: 'c',
        requiredPlan: 'r',
      );
      expect(e.toString(), contains('PlanLimitError'));
    });
  });

  // ── implements Exception ──────────────────────────────────────────────

  group('AppError implements Exception', () {
    test('AuthError is Exception', () {
      const e = AuthError('e');
      expect(e, isA<Exception>());
    });

    test('NetworkError is Exception', () {
      const e = NetworkError('e');
      expect(e, isA<Exception>());
    });

    test('DataError is Exception', () {
      const e = DataError('e');
      expect(e, isA<Exception>());
    });

    test('StorageError is Exception', () {
      const e = StorageError('e');
      expect(e, isA<Exception>());
    });

    test('UnknownError is Exception', () {
      const e = UnknownError();
      expect(e, isA<Exception>());
    });

    test('PlanLimitError is Exception', () {
      const e = PlanLimitError(
        feature: 'f',
        currentPlan: 'c',
        requiredPlan: 'r',
      );
      expect(e, isA<Exception>());
    });
  });

  // ── userMessage extension ─────────────────────────────────────────────

  group('AppErrorMessage extension', () {
    test('AuthError → returns its own message', () {
      const AppError e = AuthError('토큰 만료');
      expect(e.userMessage, '토큰 만료');
    });

    test('NetworkError → fixed user message', () {
      const AppError e = NetworkError('ETIMEDOUT');
      expect(e.userMessage, '네트워크 연결을 확인해 주세요.');
    });

    test('DataError → returns its own message', () {
      const AppError e = DataError('DB 무결성 위반');
      expect(e.userMessage, 'DB 무결성 위반');
    });

    test('PlanLimitError → returns constructed message', () {
      const AppError e = PlanLimitError(
        feature: '가족 공유',
        currentPlan: '무료',
        requiredPlan: '패밀리',
      );
      expect(e.userMessage, '가족 공유 기능은 패밀리 플랜이 필요합니다.');
    });

    test('StorageError → fixed user message', () {
      const AppError e = StorageError('ENOSPC');
      expect(e.userMessage, '파일 저장에 실패했습니다. 다시 시도해 주세요.');
    });

    test('UnknownError → fixed user message', () {
      const AppError e = UnknownError();
      expect(e.userMessage, '오류가 발생했습니다. 잠시 후 다시 시도해 주세요.');
    });
  });

  // ── switch exhaustiveness ─────────────────────────────────────────────

  group('Exhaustive pattern matching', () {
    test('all subtypes are handled in userMessage', () {
      // This test verifies that the switch expression in userMessage
      // handles all sealed subtypes by constructing each one
      final errors = <AppError>[
        const AuthError('a'),
        const NetworkError('n'),
        const DataError('d'),
        const PlanLimitError(
          feature: 'f',
          currentPlan: 'c',
          requiredPlan: 'r',
        ),
        const StorageError('s'),
        const UnknownError(),
      ];

      for (final e in errors) {
        expect(e.userMessage, isA<String>());
        expect(e.userMessage, isNotEmpty);
      }
    });
  });
}
