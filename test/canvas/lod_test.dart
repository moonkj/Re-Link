import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/features/canvas/utils/lod_utils.dart';

void main() {
  group('lodFromScale', () {
    test('0.1× → birdEye', () {
      expect(lodFromScale(0.1), LodLevel.birdEye);
    });

    test('0.24× → birdEye', () {
      expect(lodFromScale(0.24), LodLevel.birdEye);
    });

    test('0.25× → overview (경계)', () {
      expect(lodFromScale(0.25), LodLevel.overview);
    });

    test('0.3× → overview', () {
      expect(lodFromScale(0.3), LodLevel.overview);
    });

    test('0.44× → overview', () {
      expect(lodFromScale(0.44), LodLevel.overview);
    });

    test('0.45× → detail (경계)', () {
      expect(lodFromScale(0.45), LodLevel.detail);
    });

    test('0.5× → detail', () {
      expect(lodFromScale(0.5), LodLevel.detail);
    });

    test('0.8× → detail', () {
      expect(lodFromScale(0.8), LodLevel.detail);
    });

    test('1.0× → detail', () {
      expect(lodFromScale(1.0), LodLevel.detail);
    });

    test('1.5× → detail', () {
      expect(lodFromScale(1.5), LodLevel.detail);
    });

    test('1.99× → detail', () {
      expect(lodFromScale(1.99), LodLevel.detail);
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
