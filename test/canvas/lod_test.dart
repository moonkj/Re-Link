import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/features/canvas/utils/lod_utils.dart';

void main() {
  group('lodFromScale', () {
    test('0.3× → birdEye', () {
      expect(lodFromScale(0.3), LodLevel.birdEye);
    });

    test('0.5 경계 — birdEye', () {
      expect(lodFromScale(0.49), LodLevel.birdEye);
    });

    test('0.5× → overview', () {
      expect(lodFromScale(0.5), LodLevel.overview);
    });

    test('0.8× → overview', () {
      expect(lodFromScale(0.8), LodLevel.overview);
    });

    test('0.999× → overview', () {
      expect(lodFromScale(0.999), LodLevel.overview);
    });

    test('1.0× → detail', () {
      expect(lodFromScale(1.0), LodLevel.detail);
    });

    test('1.5× → detail', () {
      expect(lodFromScale(1.5), LodLevel.detail);
    });

    test('2.0× → zoom', () {
      expect(lodFromScale(2.0), LodLevel.zoom);
    });

    test('3.0× → zoom', () {
      expect(lodFromScale(3.0), LodLevel.zoom);
    });

    test('LodLevel 값 4개', () {
      expect(LodLevel.values.length, 4);
    });
  });
}
