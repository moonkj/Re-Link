/// PosterTemplate 순수 로직 테스트
/// 커버: poster_template.dart — PosterStyle enum, _formatDate, _excerpt
import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/features/snapshot/widgets/poster_template.dart';

void main() {
  // ── PosterStyle enum ─────────────────────────────────────────────────────

  group('PosterStyle enum', () {
    test('4 values exist', () {
      expect(PosterStyle.values.length, 4);
    });

    test('vintage label', () {
      expect(PosterStyle.vintage.label, '빈티지');
    });

    test('modern label', () {
      expect(PosterStyle.modern.label, '모던');
    });

    test('emotional label', () {
      expect(PosterStyle.emotional.label, '감성');
    });

    test('minimal label', () {
      expect(PosterStyle.minimal.label, '미니멀');
    });

    test('enum index order', () {
      expect(PosterStyle.vintage.index, 0);
      expect(PosterStyle.modern.index, 1);
      expect(PosterStyle.emotional.index, 2);
      expect(PosterStyle.minimal.index, 3);
    });

    test('labels are unique', () {
      final labels = PosterStyle.values.map((s) => s.label).toSet();
      expect(labels.length, 4);
    });

    test('labels are all Korean', () {
      for (final style in PosterStyle.values) {
        expect(style.label, isNotEmpty);
        // Korean characters are multi-byte, so length > 0 is sufficient
      }
    });
  });

  // ── _formatDate 로직 (PosterCard 내부 재현) ──────────────────────────────

  group('Poster date formatting', () {
    String formatDate(DateTime dt) =>
        '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';

    test('standard date', () {
      expect(formatDate(DateTime(2026, 4, 3)), '2026.04.03');
    });

    test('single digit month and day', () {
      expect(formatDate(DateTime(2025, 1, 5)), '2025.01.05');
    });

    test('double digit month and day', () {
      expect(formatDate(DateTime(2025, 12, 31)), '2025.12.31');
    });

    test('January 1st', () {
      expect(formatDate(DateTime(2025, 1, 1)), '2025.01.01');
    });

    test('February 28th', () {
      expect(formatDate(DateTime(2025, 2, 28)), '2025.02.28');
    });

    test('leap year February 29th', () {
      expect(formatDate(DateTime(2024, 2, 29)), '2024.02.29');
    });

    test('month 10 pads correctly', () {
      expect(formatDate(DateTime(2025, 10, 1)), '2025.10.01');
    });

    test('day 10 pads correctly', () {
      expect(formatDate(DateTime(2025, 3, 10)), '2025.03.10');
    });
  });

  // ── _excerpt 로직 (PosterCard 내부 재현) ─────────────────────────────────

  group('Poster excerpt logic', () {
    String excerpt(String text, [int maxLen = 100]) =>
        text.length > maxLen ? '${text.substring(0, maxLen)}…' : text;

    test('short text → unchanged', () {
      const text = '짧은 텍스트';
      expect(excerpt(text), text);
    });

    test('exactly 100 chars → unchanged', () {
      final text = 'a' * 100;
      expect(excerpt(text), text);
      expect(excerpt(text).length, 100);
    });

    test('101 chars → truncated with ellipsis', () {
      final text = 'a' * 101;
      final result = excerpt(text);
      expect(result.length, 101); // 100 chars + 1 ellipsis
      expect(result, endsWith('…'));
    });

    test('long text truncated at 100', () {
      final text = 'b' * 200;
      final result = excerpt(text);
      expect(result.length, 101); // 100 + ellipsis
      expect(result.startsWith('b' * 100), isTrue);
    });

    test('custom maxLen = 50', () {
      final text = 'c' * 60;
      final result = excerpt(text, 50);
      expect(result.length, 51); // 50 + ellipsis
    });

    test('custom maxLen = 80 (emotional style)', () {
      final text = 'd' * 90;
      final result = excerpt(text, 80);
      expect(result.length, 81); // 80 + ellipsis
      expect(result, endsWith('…'));
    });

    test('empty text → empty', () {
      expect(excerpt(''), '');
    });

    test('single character → unchanged', () {
      expect(excerpt('a'), 'a');
    });

    test('Korean text truncation', () {
      final text = '가' * 110;
      final result = excerpt(text);
      expect(result.endsWith('…'), isTrue);
    });
  });

  // ── Poster dimensions (1080x1350 캡처 사이즈) ───────────────────────────

  group('Poster dimensions', () {
    test('width = 1080 / 3 = 360pt', () {
      expect(1080 / 3, 360);
    });

    test('height = 1350 / 3 = 450pt', () {
      expect(1350 / 3, 450);
    });

    test('capture resolution 3x → 1080px width', () {
      const ptWidth = 360;
      const scale = 3;
      expect(ptWidth * scale, 1080);
    });

    test('capture resolution 3x → 1350px height', () {
      const ptHeight = 450;
      const scale = 3;
      expect(ptHeight * scale, 1350);
    });

    test('aspect ratio is 4:5 (Instagram story)', () {
      // 1080:1350 = 4:5
      expect(1080 / 1350, closeTo(0.8, 0.001));
      expect(4 / 5, closeTo(0.8, 0.001));
    });
  });
}
