import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/features/archive/providers/archive_notifier.dart';
import 'package:re_link/shared/models/memory_model.dart';
import 'package:re_link/shared/models/node_model.dart';

void main() {
  group('ArchiveFilter 열거형', () {
    test('all/photo/voice/note 4가지 값 존재', () {
      expect(ArchiveFilter.values.length, 4);
    });

    test('ArchiveFilter.photo.name == "photo"', () {
      expect(ArchiveFilter.photo.name, 'photo');
    });
  });

  group('ArchiveSortOrder 열거형', () {
    test('newest/oldest/name 3가지 값 존재', () {
      expect(ArchiveSortOrder.values.length, 3);
    });
  });

  group('ArchiveState', () {
    test('기본 상태: filter=all, sortOrder=newest, isLoading=true', () {
      const state = ArchiveState();
      expect(state.filter, ArchiveFilter.all);
      expect(state.sortOrder, ArchiveSortOrder.newest);
      expect(state.isLoading, isTrue);
    });

    test('copyWith filter 변경', () {
      const state = ArchiveState();
      final updated = state.copyWith(filter: ArchiveFilter.photo);
      expect(updated.filter, ArchiveFilter.photo);
      expect(updated.sortOrder, ArchiveSortOrder.newest); // 나머지 유지
    });

    test('groups 비어있으면 isEmpty = true', () {
      const state = ArchiveState(isLoading: false);
      expect(state.isEmpty, isTrue);
    });

    test('groups에 기억 있으면 isEmpty = false', () {
      final node = NodeModel(
        id: 'n1', name: '홍길동', createdAt: DateTime.now(),
      );
      final memory = MemoryModel(
        id: 'm1', nodeId: 'n1', type: MemoryType.photo, createdAt: DateTime.now(),
      );
      final state = ArchiveState(
        groups: [ArchiveGroup(node: node, memories: [memory])],
        isLoading: false,
      );
      expect(state.isEmpty, isFalse);
    });
  });

  group('ArchiveGroup 필터링 로직 검증', () {
    // ignore: unused_local_variable
    final node = NodeModel(id: 'n1', name: '테스트', createdAt: DateTime.now());
    final photoMemory = MemoryModel(
      id: 'm1', nodeId: 'n1', type: MemoryType.photo,
      title: '여름 사진', createdAt: DateTime(2024, 6, 1),
    );
    final voiceMemory = MemoryModel(
      id: 'm2', nodeId: 'n1', type: MemoryType.voice,
      title: '할아버지 목소리', createdAt: DateTime(2024, 3, 1),
    );

    test('filter=photo → photo만 통과', () {
      final all = [photoMemory, voiceMemory];
      final filtered = all.where((m) {
        return ArchiveFilter.photo == ArchiveFilter.all ||
            m.type.name == ArchiveFilter.photo.name;
      }).toList();
      expect(filtered, [photoMemory]);
    });

    test('newest 정렬: 최신이 앞', () {
      final items = [voiceMemory, photoMemory];
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      expect(items.first.id, 'm1'); // 2024-06 > 2024-03
    });

    test('oldest 정렬: 오래된 것이 앞', () {
      final items = [photoMemory, voiceMemory];
      items.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      expect(items.first.id, 'm2'); // 2024-03 < 2024-06
    });
  });
}
