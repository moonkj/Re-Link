import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/services/backup/backup_service.dart';
import '../services/invite_service.dart';

part 'invite_notifier.g.dart';

/// 초대 UI 상태
class InviteState {
  const InviteState({
    this.code,
    this.isGenerating = false,
    this.isSharing = false,
    this.backupPath,
    this.error,
  });

  final String? code;
  final bool isGenerating;
  final bool isSharing;
  final String? backupPath;
  final String? error;

  InviteState copyWith({
    String? code,
    bool? isGenerating,
    bool? isSharing,
    String? backupPath,
    String? error,
    bool clearError = false,
  }) =>
      InviteState(
        code: code ?? this.code,
        isGenerating: isGenerating ?? this.isGenerating,
        isSharing: isSharing ?? this.isSharing,
        backupPath: backupPath ?? this.backupPath,
        error: clearError ? null : (error ?? this.error),
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

  /// .rlink 백업 생성 + OS 공유 시트로 공유
  Future<void> shareInvite() async {
    if (state.code == null) return;
    state = state.copyWith(isSharing: true, clearError: true);
    try {
      final service = ref.read(backupServiceProvider);
      final file = await service.createBackup();

      final formattedCode = InviteService.formatCode(state.code!);
      await Share.shareXFiles(
        [XFile(file.path)],
        text: '[Re-Link 가족 초대]\n'
            '초대 코드: $formattedCode\n\n'
            '1. Re-Link 앱을 설치하세요\n'
            '2. 첨부된 .rlink 파일을 열어주세요\n'
            '3. 초대 코드를 입력하면 가족 트리에 합류합니다',
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
