import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/services/backup/backup_service.dart';
import '../../../shared/repositories/settings_repository.dart';
import '../../../core/database/tables/settings_table.dart';
import '../services/invite_service.dart';
import 'welcome_capsule_notifier.dart';

part 'invite_notifier.g.dart';

/// 초대 UI 상태
class InviteState {
  const InviteState({
    this.code,
    this.isGenerating = false,
    this.isSharing = false,
    this.backupPath,
    this.error,
    this.welcomeMessage,
    this.welcomeAudioPath,
    this.welcomeDone = false,
  });

  final String? code;
  final bool isGenerating;
  final bool isSharing;
  final String? backupPath;
  final String? error;
  final String? welcomeMessage;
  final String? welcomeAudioPath;
  final bool welcomeDone;

  bool get hasWelcome =>
      (welcomeMessage != null && welcomeMessage!.isNotEmpty) ||
      (welcomeAudioPath != null && welcomeAudioPath!.isNotEmpty);

  InviteState copyWith({
    String? code,
    bool? isGenerating,
    bool? isSharing,
    String? backupPath,
    String? error,
    String? welcomeMessage,
    String? welcomeAudioPath,
    bool? welcomeDone,
    bool clearError = false,
    bool clearWelcomeMessage = false,
    bool clearWelcomeAudio = false,
  }) =>
      InviteState(
        code: code ?? this.code,
        isGenerating: isGenerating ?? this.isGenerating,
        isSharing: isSharing ?? this.isSharing,
        backupPath: backupPath ?? this.backupPath,
        error: clearError ? null : (error ?? this.error),
        welcomeMessage: clearWelcomeMessage
            ? null
            : (welcomeMessage ?? this.welcomeMessage),
        welcomeAudioPath: clearWelcomeAudio
            ? null
            : (welcomeAudioPath ?? this.welcomeAudioPath),
        welcomeDone: welcomeDone ?? this.welcomeDone,
      );
}

@riverpod
class InviteNotifier extends _$InviteNotifier {
  @override
  InviteState build() => const InviteState();

  /// 초대 코드 생성
  void generateInvite() {
    state = state.copyWith(isGenerating: true, clearError: true);
    final code = InviteService.generateCode();
    state = InviteState(code: code, isGenerating: false);
  }

  /// 웰컴 캡슐 데이터를 InviteState에 반영
  void applyWelcomeCapsule(WelcomeCapsuleState capsule) {
    state = state.copyWith(
      welcomeMessage: capsule.hasMessage ? capsule.message : null,
      welcomeAudioPath: capsule.hasAudio ? capsule.audioPath : null,
      welcomeDone: true,
      clearWelcomeMessage: !capsule.hasMessage,
      clearWelcomeAudio: !capsule.hasAudio,
    );
  }

  /// 웰컴 캡슐 건너뛰기 표시
  void skipWelcomeCapsule() {
    state = state.copyWith(welcomeDone: true);
  }

  /// .rlink 백업 생성 + OS 공유 시트로 공유
  /// 공유 전 welcomeMessage/welcomeAudioPath를 settings에 기록
  Future<void> shareInvite() async {
    if (state.code == null) return;
    state = state.copyWith(isSharing: true, clearError: true);
    try {
      // 웰컴 캡슐 데이터를 settings에 저장 (백업에 포함되도록)
      final settingsRepo = ref.read(settingsRepositoryProvider);
      if (state.welcomeMessage != null && state.welcomeMessage!.isNotEmpty) {
        await settingsRepo.set(
          SettingsKey.welcomeMessage,
          state.welcomeMessage!,
        );
      }
      if (state.welcomeAudioPath != null &&
          state.welcomeAudioPath!.isNotEmpty) {
        await settingsRepo.set(
          SettingsKey.welcomeAudioPath,
          state.welcomeAudioPath!,
        );
      }

      // 백업 생성 (settings 포함)
      final service = ref.read(backupServiceProvider);
      final file = await service.createBackup();

      // 공유 텍스트 구성
      final formattedCode = InviteService.formatCode(state.code!);
      final hasWelcomeMsg = state.welcomeMessage != null &&
          state.welcomeMessage!.isNotEmpty;
      final shareText = '[Re-Link 가족 초대]\n'
          '초대 코드: $formattedCode\n\n'
          '1. Re-Link 앱을 설치하세요\n'
          '2. 첨부된 .rlink 파일을 열어주세요\n'
          '3. 초대 코드를 입력하면 가족 트리에 합류합니다'
          '${hasWelcomeMsg ? '\n\n💌 환영 메시지가 함께 전달됩니다!' : ''}';

      await Share.shareXFiles(
        [XFile(file.path)],
        text: shareText,
        sharePositionOrigin: const Rect.fromLTWH(0, 0, 100, 100),
      );

      state = state.copyWith(
        isSharing: false,
        backupPath: file.path,
      );
    } catch (e) {
      debugPrint('[InviteNotifier] 공유 실패: $e');
      state = state.copyWith(isSharing: false, error: e.toString());
    }
  }
}
