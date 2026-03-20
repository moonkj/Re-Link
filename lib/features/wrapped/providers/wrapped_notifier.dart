import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../shared/repositories/db_provider.dart';
import '../services/annual_review_service.dart';

part 'wrapped_notifier.g.dart';

/// 연말 가족 리뷰 상태 관리
@riverpod
class WrappedNotifier extends _$WrappedNotifier {
  @override
  Future<AnnualReviewData> build() async {
    final db = ref.watch(appDatabaseProvider);
    final service = AnnualReviewService(db);
    return service.generateReview(DateTime.now().year);
  }

  /// 특정 연도 리뷰 로드
  Future<void> loadYear(int year) async {
    state = const AsyncLoading();
    try {
      final db = ref.read(appDatabaseProvider);
      final service = AnnualReviewService(db);
      final data = await service.generateReview(year);
      state = AsyncData(data);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
