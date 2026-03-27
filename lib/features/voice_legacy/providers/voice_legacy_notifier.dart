import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/notification/notification_service.dart';
import '../../../core/utils/path_utils.dart';
import '../../../shared/repositories/voice_legacy_repository.dart';

part 'voice_legacy_notifier.g.dart';

/// 전체 보이스 유언 목록 스트림
@riverpod
Stream<List<VoiceLegacyTableData>> allVoiceLegacies(Ref ref) =>
    ref.watch(voiceLegacyRepositoryProvider).watchAll();

/// 보이스 유언 CRUD 오퍼레이션
@riverpod
class VoiceLegacyNotifier extends _$VoiceLegacyNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  VoiceLegacyRepository get _repo =>
      ref.read(voiceLegacyRepositoryProvider);

  /// 보이스 유언 생성
  Future<String?> create({
    required String fromNodeId,
    required String toNodeId,
    required String title,
    required String voicePath,
    required int durationSeconds,
    required String openCondition,
    DateTime? openDate,
  }) async {
    state = const AsyncLoading();
    try {
      // 절대경로 → 상대경로 변환 (복원 시 경로 호환성)
      final relPath = PathUtils.toRelative(voicePath) ?? voicePath;
      final id = await _repo.create(
        fromNodeId: fromNodeId,
        toNodeId: toNodeId,
        title: title,
        voicePath: relPath,
        durationSeconds: durationSeconds,
        openCondition: openCondition,
        openDate: openDate,
      );
      // openDate가 있으면 봉인 해제 알림 스케줄
      if (openDate != null) {
        _scheduleVoiceLegacyNotification(id, title, openDate);
      }
      state = const AsyncData(null);
      return id;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  /// 봉인 해제
  Future<bool> open(String id) async {
    state = const AsyncLoading();
    try {
      await _repo.open(id);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  /// 삭제 — 음성 파일 + 알림도 함께 삭제/취소
  Future<bool> delete(String id) async {
    state = const AsyncLoading();
    try {
      // 음성 파일 삭제
      final legacy = await _repo.get(id);
      if (legacy != null) {
        try {
          final absPath = PathUtils.toAbsolute(legacy.voicePath);
          if (absPath != null) {
            final file = File(absPath);
            if (await file.exists()) await file.delete();
          }
        } catch (_) {}
      }
      // 해당 voice legacy 알림 취소
      _cancelVoiceLegacyNotification(id);
      await _repo.delete(id);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  /// 보이스 유언 봉인 해제 알림 스케줄
  void _scheduleVoiceLegacyNotification(
    String legacyId,
    String title,
    DateTime openDate,
  ) {
    try {
      final svc = ref.read(notificationServiceProvider);
      svc.scheduleAt(
        id: NotificationId.voiceLegacyBase.forItem(legacyId),
        title: '보이스 유언이 공개되었어요',
        body: '"$title" 봉인이 해제되었습니다. 지금 들어보세요.',
        dateTime: openDate,
        channelId: 're_link_event',
        payload: 'voice_legacy:$legacyId',
      );
    } catch (e) {
      debugPrint('[VoiceLegacyNotifier] 알림 스케줄 실패: $e');
    }
  }

  /// 보이스 유언 알림 취소
  void _cancelVoiceLegacyNotification(String legacyId) {
    try {
      final svc = ref.read(notificationServiceProvider);
      svc.cancel(NotificationId.voiceLegacyBase.forItem(legacyId));
    } catch (e) {
      debugPrint('[VoiceLegacyNotifier] 알림 취소 실패: $e');
    }
  }
}
