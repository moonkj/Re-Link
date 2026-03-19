/// StoryFeedState + StoryFeedItem 단위 테스트
/// 커버: story_feed_notifier.dart 미커버 라인 (33-85)
import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/features/story/providers/story_feed_notifier.dart';
import 'package:re_link/shared/models/memory_model.dart';

void main() {
  group('StoryFeedState', () {
    test('기본 상태: items=[], isLoading=true', () {
      const state = StoryFeedState();
      expect(state.items, isEmpty);
      expect(state.isLoading, isTrue);
    });

    test('copyWith items 변경', () {
      final memory = MemoryModel(
        id: 'm1', nodeId: 'n1', type: MemoryType.note, createdAt: DateTime.now(),
      );
      final item = StoryFeedItem(memory: memory, nodeName: '홍길동');
      const state = StoryFeedState();
      final updated = state.copyWith(items: [item], isLoading: false);
      expect(updated.items.length, 1);
      expect(updated.isLoading, isFalse);
    });

    test('copyWith items만 변경 — isLoading 유지', () {
      const state = StoryFeedState(isLoading: false);
      final updated = state.copyWith(items: []);
      expect(updated.isLoading, isFalse);
      expect(updated.items, isEmpty);
    });

    test('copyWith isLoading만 변경 — items 유지', () {
      final memory = MemoryModel(
        id: 'm2', nodeId: 'n1', type: MemoryType.photo, createdAt: DateTime.now(),
      );
      final item = StoryFeedItem(memory: memory, nodeName: '테스트');
      final state = StoryFeedState(items: [item]);
      final updated = state.copyWith(isLoading: false);
      expect(updated.items.length, 1);
      expect(updated.isLoading, isFalse);
    });
  });

  group('StoryFeedItem', () {
    test('nodePhotoPath null 허용', () {
      final memory = MemoryModel(
        id: 'm1', nodeId: 'n1', type: MemoryType.voice, createdAt: DateTime.now(),
      );
      final item = StoryFeedItem(memory: memory, nodeName: '홍길동');
      expect(item.nodePhotoPath, isNull);
      expect(item.nodeName, '홍길동');
    });

    test('nodePhotoPath 설정 가능', () {
      final memory = MemoryModel(
        id: 'm2', nodeId: 'n1', type: MemoryType.photo, createdAt: DateTime.now(),
      );
      final item = StoryFeedItem(
        memory: memory,
        nodeName: '김철수',
        nodePhotoPath: '/path/photo.jpg',
      );
      expect(item.nodePhotoPath, '/path/photo.jpg');
    });

    test('private 기억 MemoryModel.isPrivate = true', () {
      final memory = MemoryModel(
        id: 'm3', nodeId: 'n1', type: MemoryType.note,
        createdAt: DateTime.now(), isPrivate: true,
      );
      expect(memory.isPrivate, isTrue);
    });

    test('public 기억 MemoryModel.isPrivate = false', () {
      final memory = MemoryModel(
        id: 'm4', nodeId: 'n1', type: MemoryType.voice,
        createdAt: DateTime.now(), isPrivate: false,
      );
      expect(memory.isPrivate, isFalse);
    });

    test('StoryFeedState.isLoading 기본 true', () {
      const s = StoryFeedState();
      expect(s.isLoading, isTrue);
    });

    test('StoryFeedState items 복수 항목', () {
      final items = List.generate(3, (i) {
        final m = MemoryModel(
          id: 'm$i', nodeId: 'n1', type: MemoryType.note, createdAt: DateTime.now(),
        );
        return StoryFeedItem(memory: m, nodeName: '이름$i');
      });
      final state = StoryFeedState(items: items, isLoading: false);
      expect(state.items.length, 3);
    });
  });

  group('StoryFeedState null-safe copyWith', () {
    test('copyWith 인수 없으면 기존 값 유지', () {
      final memory = MemoryModel(
        id: 'x1', nodeId: 'n1', type: MemoryType.photo, createdAt: DateTime.now(),
      );
      final item = StoryFeedItem(memory: memory, nodeName: '기존');
      final state = StoryFeedState(items: [item], isLoading: false);
      final same = state.copyWith();
      expect(same.items.length, 1);
      expect(same.isLoading, isFalse);
    });
  });
}
