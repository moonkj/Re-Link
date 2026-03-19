import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/features/story/providers/story_feed_notifier.dart';
import 'package:re_link/shared/models/memory_model.dart';
import 'package:re_link/shared/models/node_model.dart';

void main() {
  group('StoryFeedItem', () {
    test('StoryFeedItem 생성 확인', () {
      final memory = MemoryModel(
        id: 'm1',
        nodeId: 'n1',
        type: MemoryType.photo,
        createdAt: DateTime.now(),
      );
      final item = StoryFeedItem(
        memory: memory,
        nodeName: '홍길동',
        nodePhotoPath: null,
      );
      expect(item.nodeName, '홍길동');
      expect(item.memory.type, MemoryType.photo);
    });

    test('private 기억은 feed에 포함되지 않음 — isPrivate 플래그 확인', () {
      final privateMemory = MemoryModel(
        id: 'm2',
        nodeId: 'n1',
        type: MemoryType.note,
        createdAt: DateTime.now(),
        isPrivate: true,
      );
      expect(privateMemory.isPrivate, isTrue);
    });

    test('public 기억은 feed에 포함 가능 — isPrivate = false', () {
      final publicMemory = MemoryModel(
        id: 'm3',
        nodeId: 'n1',
        type: MemoryType.voice,
        createdAt: DateTime.now(),
        isPrivate: false,
      );
      expect(publicMemory.isPrivate, isFalse);
    });
  });

  group('MemoryModel.formattedDuration', () {
    test('60초 → "01:00"', () {
      final m = MemoryModel(
        id: 'v1',
        nodeId: 'n1',
        type: MemoryType.voice,
        durationSeconds: 60,
        createdAt: DateTime.now(),
      );
      expect(m.formattedDuration, '01:00');
    });

    test('null이면 formattedDuration = null', () {
      final m = MemoryModel(
        id: 'v2',
        nodeId: 'n1',
        type: MemoryType.voice,
        createdAt: DateTime.now(),
      );
      expect(m.formattedDuration, isNull);
    });
  });
}
