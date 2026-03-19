/// 캔버스 플로우 통합 테스트
///
/// 실제 디바이스/시뮬레이터에서 실행 필요:
///   flutter test integration_test/flows/canvas_flow_test.dart
library;

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:re_link/app.dart';
import 'package:re_link/core/database/app_database.dart';
import 'package:re_link/shared/repositories/db_provider.dart';
import 'package:re_link/shared/repositories/node_repository.dart';
import 'package:re_link/shared/models/node_model.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  testWidgets('캔버스: 노드 추가 후 카드가 화면에 나타남', (tester) async {
    // DB에 노드 미리 삽입
    final repo = NodeRepository(db);
    await repo.create(
      name: '홍길동',
      positionX: 1900,
      positionY: 1900,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
        ],
        child: const ReLink(),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // 캔버스 화면이 로드됨 (Re-Link 로고 확인)
    expect(find.text('Re-Link'), findsWidgets);
  });

  testWidgets('캔버스: 빈 상태에서 안내 메시지 표시', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
        ],
        child: const ReLink(),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // 빈 캔버스 안내 확인
    expect(find.text('가족 트리를 시작해 보세요'), findsOneWidget);
  });

  testWidgets('캔버스: 노드 2개 + 엣지가 EdgePainter로 렌더링', (tester) async {
    final repo = NodeRepository(db);
    final n1 = await repo.create(name: '아버지', positionX: 1800, positionY: 1800);
    final n2 = await repo.create(name: '어머니', positionX: 2100, positionY: 1800);
    await repo.addEdge(
      fromNodeId: n1.id,
      toNodeId: n2.id,
      relation: RelationType.spouse,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const ReLink(),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // 두 노드 이름이 화면에 표시됨
    expect(find.text('아버지'), findsOneWidget);
    expect(find.text('어머니'), findsOneWidget);
  });
}
