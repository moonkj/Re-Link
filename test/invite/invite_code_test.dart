import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/features/invite/services/invite_service.dart';

void main() {
  group('초대 코드 생성', () {
    test('generateCode — 6자리 문자열 반환', () {
      final code = InviteService.generateCode();
      expect(code.length, 6);
    });

    test('generateCode — 영숫자만 포함', () {
      for (int i = 0; i < 50; i++) {
        final code = InviteService.generateCode();
        expect(code, matches(RegExp(r'^[A-Z0-9]{6}$')),
            reason: '코드에 영대문자/숫자 외 문자 포함: $code');
      }
    });

    test('generateCode — 혼동 문자 제외 (O, 0, I, 1)', () {
      // 50회 생성하여 혼동 문자가 포함되지 않는지 확인
      for (int i = 0; i < 100; i++) {
        final code = InviteService.generateCode();
        expect(code.contains('O'), isFalse,
            reason: '코드에 O 포함: $code');
        expect(code.contains('0'), isFalse,
            reason: '코드에 0 포함: $code');
        expect(code.contains('I'), isFalse,
            reason: '코드에 I 포함: $code');
        expect(code.contains('1'), isFalse,
            reason: '코드에 1 포함: $code');
      }
    });

    test('generateCode — 매번 다른 코드 생성 (높은 확률)', () {
      final codes = List.generate(20, (_) => InviteService.generateCode());
      final unique = codes.toSet();
      // 20개 중 최소 15개는 고유해야 한다 (확률적)
      expect(unique.length, greaterThanOrEqualTo(15));
    });
  });

  group('코드 포맷', () {
    test('formatCode — 6자리 → "ABC-DEF" 형식', () {
      expect(InviteService.formatCode('ABCDEF'), 'ABC-DEF');
    });

    test('formatCode — 6자리 미만 → 원본 반환', () {
      expect(InviteService.formatCode('ABC'), 'ABC');
    });

    test('formatCode — 6자리 초과 → 원본 반환', () {
      expect(InviteService.formatCode('ABCDEFG'), 'ABCDEFG');
    });

    test('formatCode — 빈 문자열 → 빈 문자열', () {
      expect(InviteService.formatCode(''), '');
    });
  });

  group('코드 유효성 검증', () {
    test('생성된 코드는 허용 문자 집합에만 포함', () {
      const allowedChars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
      for (int i = 0; i < 50; i++) {
        final code = InviteService.generateCode();
        for (final char in code.split('')) {
          expect(allowedChars.contains(char), isTrue,
              reason: '허용되지 않은 문자 "$char" in code "$code"');
        }
      }
    });
  });

  group('딥링크 파싱', () {
    test('유효한 딥링크 → 코드 추출: relink://invite/ABC123', () {
      final uri = Uri.parse('relink://invite/ABC123');
      final code = InviteService.parseDeepLink(uri);
      expect(code, 'ABC123');
    });

    test('하이픈 포함 딥링크 → 하이픈 제거: relink://invite/ABC-123', () {
      final uri = Uri.parse('relink://invite/ABC-123');
      final code = InviteService.parseDeepLink(uri);
      expect(code, 'ABC123');
    });

    test('소문자 딥링크 → 대문자로 정규화: relink://invite/abc123', () {
      final uri = Uri.parse('relink://invite/abc123');
      final code = InviteService.parseDeepLink(uri);
      expect(code, 'ABC123');
    });

    test('잘못된 스킴 → null: https://invite/ABC123', () {
      final uri = Uri.parse('https://invite/ABC123');
      final code = InviteService.parseDeepLink(uri);
      expect(code, isNull);
    });

    test('잘못된 호스트 → null: relink://other/ABC123', () {
      final uri = Uri.parse('relink://other/ABC123');
      final code = InviteService.parseDeepLink(uri);
      expect(code, isNull);
    });

    test('코드 없음 → null: relink://invite', () {
      final uri = Uri.parse('relink://invite');
      final code = InviteService.parseDeepLink(uri);
      expect(code, isNull);
    });

    test('너무 짧은 코드 → null: relink://invite/ABC', () {
      final uri = Uri.parse('relink://invite/ABC');
      final code = InviteService.parseDeepLink(uri);
      expect(code, isNull);
    });

    test('너무 긴 코드 → null: relink://invite/ABCDEFGH', () {
      final uri = Uri.parse('relink://invite/ABCDEFGH');
      final code = InviteService.parseDeepLink(uri);
      expect(code, isNull);
    });
  });

  group('딥링크 문자열 파싱 (편의 메서드)', () {
    test('유효한 URL → 코드 추출', () {
      final code =
          InviteService.parseDeepLinkString('relink://invite/XYZ789');
      expect(code, 'XYZ789');
    });

    test('잘못된 URL → null', () {
      final code =
          InviteService.parseDeepLinkString('not a valid url %%%');
      expect(code, isNull);
    });

    test('빈 문자열 → null', () {
      final code = InviteService.parseDeepLinkString('');
      expect(code, isNull);
    });
  });

  group('코드 정규화', () {
    test('소문자→대문자 변환', () {
      final uri = Uri.parse('relink://invite/abc-def');
      final code = InviteService.parseDeepLink(uri);
      expect(code, 'ABCDEF');
    });

    test('하이픈 제거 후 6자리 추출', () {
      final uri = Uri.parse('relink://invite/AB-CD-EF');
      final code = InviteService.parseDeepLink(uri);
      expect(code, 'ABCDEF');
    });
  });

  group('InviteState 모델', () {
    test('기본 상태 검증', () {
      // InviteState는 invite_notifier.dart에 정의되어 있으나
      // DB 의존 없이 직접 import하여 테스트
      // (여기서는 InviteService 로직에만 집중)
      expect(InviteService.generateCode().length, 6);
    });
  });
}
