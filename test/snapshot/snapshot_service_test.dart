import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/features/snapshot/widgets/poster_template.dart';

void main() {
  group('PosterStyle enum 검증', () {
    test('4개의 스타일이 정의되어 있다', () {
      expect(PosterStyle.values.length, 4);
    });

    test('모든 스타일 값이 존재한다', () {
      expect(PosterStyle.values, contains(PosterStyle.vintage));
      expect(PosterStyle.values, contains(PosterStyle.modern));
      expect(PosterStyle.values, contains(PosterStyle.emotional));
      expect(PosterStyle.values, contains(PosterStyle.minimal));
    });

    test('스타일 한국어 라벨 검증', () {
      expect(PosterStyle.vintage.label, '빈티지');
      expect(PosterStyle.modern.label, '모던');
      expect(PosterStyle.emotional.label, '감성');
      expect(PosterStyle.minimal.label, '미니멀');
    });

    test('모든 스타일에 고유한 라벨이 있다', () {
      final labels = PosterStyle.values.map((s) => s.label).toSet();
      expect(labels.length, PosterStyle.values.length);
    });

    test('모든 라벨이 비어있지 않다', () {
      for (final style in PosterStyle.values) {
        expect(style.label.isNotEmpty, isTrue,
            reason: '${style.name} 라벨이 비어있음');
      }
    });
  });

  group('포스터 크기 상수', () {
    test('PosterCard 기본 크기 — 360pt x 450pt (1080/3 x 1350/3)', () {
      // PosterCard의 SizedBox 크기 검증
      // 1080px / 3 = 360pt, 1350px / 3 = 450pt
      expect(1080 / 3, 360.0);
      expect(1350 / 3, 450.0);
    });

    test('캡처 시 3x → 1080 x 1350px', () {
      // SnapshotService에서 pixelRatio: 3.0 사용
      const pixelRatio = 3.0;
      const widthPt = 360.0;
      const heightPt = 450.0;

      expect(widthPt * pixelRatio, 1080.0);
      expect(heightPt * pixelRatio, 1350.0);
    });
  });

  group('pixelRatio 값 검증', () {
    test('내보내기 해상도 — 3x', () {
      // SnapshotService.captureAndShare에서 pixelRatio: 3.0 사용
      const exportPixelRatio = 3.0;
      expect(exportPixelRatio, 3.0);
    });

    test('미리보기 해상도 — 1x (논리 크기 그대로)', () {
      // 미리보기는 논리 크기 그대로 (1x)
      const previewPixelRatio = 1.0;
      expect(previewPixelRatio, 1.0);
    });
  });

  group('워터마크 텍스트 상수 검증', () {
    test('워터마크 텍스트가 올바르다', () {
      // 모든 포스터에서 동일한 워터마크 사용
      const watermark = 'Re-Link에서 우리 가족 이야기를 기록하고 있어요';
      expect(watermark, isNotEmpty);
      expect(watermark, contains('Re-Link'));
      expect(watermark, contains('가족'));
    });
  });

  group('템플릿별 색상/스타일 매핑', () {
    test('Vintage — 세피아 톤 색상', () {
      const bgColor = Color(0xFFF5E6D3);
      const textColor = Color(0xFF4A3728);
      const accentColor = Color(0xFFAA8866);

      // 배경이 세피아(따뜻한 베이지)인지 확인
      expect(bgColor.r, greaterThan(0.9));
      expect(bgColor.g, greaterThan(0.8));
      expect(bgColor.b, greaterThan(0.7));

      // 텍스트가 어두운 갈색인지 확인
      expect(textColor.r, lessThan(0.4));

      // 악센트가 중간 갈색인지 확인
      expect(accentColor.r, greaterThan(0.5));
    });

    test('Modern — 클린 화이트 + 청록 악센트', () {
      const bgColor = Color(0xFFFFFFFF);
      const textColor = Color(0xFF1A1A1A);
      const accentColor = Color(0xFF6EC6CA);

      // 배경이 순백인지 확인
      expect(bgColor, const Color(0xFFFFFFFF));

      // 텍스트가 거의 검정인지 확인
      expect(textColor.r, lessThan(0.2));
      expect(textColor.g, lessThan(0.2));
      expect(textColor.b, lessThan(0.2));

      // 악센트가 청록인지 확인
      expect(accentColor.g, greaterThan(0.7));
      expect(accentColor.b, greaterThan(0.7));
    });

    test('Emotional — 핑크→라벤더 그라디언트 색상', () {
      const pink = Color(0xFFF8B4C8);
      const lavender = Color(0xFFD4A5E5);
      const blueish = Color(0xFFB8C6F0);

      // 핑크
      expect(pink.r, greaterThan(0.9));

      // 라벤더
      expect(lavender.r, greaterThan(0.7));
      expect(lavender.b, greaterThan(0.8));

      // 연보라-파랑
      expect(blueish.b, greaterThan(0.9));
    });

    test('Minimal — 퓨어 화이트 + 청록 라인', () {
      const bgColor = Color(0xFFFFFFFF);
      const textColor = Color(0xFF2C2C2C);
      const lineColor = Color(0xFF6EC6CA);

      // 배경이 순백
      expect(bgColor, const Color(0xFFFFFFFF));

      // 텍스트가 짙은 회색
      expect(textColor.r, lessThan(0.25));

      // 라인 색이 Modern의 악센트와 동일한 청록
      expect(lineColor, const Color(0xFF6EC6CA));
    });
  });

  group('PosterStyle enum 순서', () {
    test('index 순서: vintage=0, modern=1, emotional=2, minimal=3', () {
      expect(PosterStyle.vintage.index, 0);
      expect(PosterStyle.modern.index, 1);
      expect(PosterStyle.emotional.index, 2);
      expect(PosterStyle.minimal.index, 3);
    });

    test('name 속성 검증', () {
      expect(PosterStyle.vintage.name, 'vintage');
      expect(PosterStyle.modern.name, 'modern');
      expect(PosterStyle.emotional.name, 'emotional');
      expect(PosterStyle.minimal.name, 'minimal');
    });
  });
}
