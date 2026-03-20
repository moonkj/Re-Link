import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../shared/repositories/settings_repository.dart';
import '../../../core/database/tables/settings_table.dart';

part 'welcome_capsule_notifier.g.dart';

/// 웰컴 캡슐 상태
class WelcomeCapsuleState {
  const WelcomeCapsuleState({
    this.message = '',
    this.audioPath,
    this.isRecording = false,
    this.recordingSeconds = 0,
  });

  final String message;
  final String? audioPath;
  final bool isRecording;
  final int recordingSeconds;

  bool get hasMessage => message.trim().isNotEmpty;
  bool get hasAudio => audioPath != null;
  bool get hasContent => hasMessage || hasAudio;

  WelcomeCapsuleState copyWith({
    String? message,
    String? audioPath,
    bool? isRecording,
    int? recordingSeconds,
    bool clearAudio = false,
  }) =>
      WelcomeCapsuleState(
        message: message ?? this.message,
        audioPath: clearAudio ? null : (audioPath ?? this.audioPath),
        isRecording: isRecording ?? this.isRecording,
        recordingSeconds: recordingSeconds ?? this.recordingSeconds,
      );
}

@riverpod
class WelcomeCapsuleNotifier extends _$WelcomeCapsuleNotifier {
  @override
  WelcomeCapsuleState build() => const WelcomeCapsuleState();

  /// 환영 메시지 텍스트 설정
  void setMessage(String text) {
    state = state.copyWith(message: text);
  }

  /// 녹음 시작 — 외부에서 RecorderController 제어, 여기선 상태만
  void startRecording() {
    state = state.copyWith(isRecording: true, recordingSeconds: 0);
  }

  /// 녹음 경과 시간 업데이트
  void updateRecordingSeconds(int seconds) {
    state = state.copyWith(recordingSeconds: seconds);
  }

  /// 녹음 중지 — 파일 경로 저장
  void stopRecording(String path) {
    state = state.copyWith(
      isRecording: false,
      audioPath: path,
    );
  }

  /// 녹음 삭제
  void removeAudio() {
    state = state.copyWith(clearAudio: true, recordingSeconds: 0);
  }

  /// 웰컴 캡슐 데이터를 settings에 저장 (공유 전 호출)
  Future<void> saveToSettings() async {
    final repo = ref.read(settingsRepositoryProvider);
    if (state.hasMessage) {
      await repo.set(SettingsKey.welcomeMessage, state.message.trim());
    }
    if (state.hasAudio) {
      await repo.set(SettingsKey.welcomeAudioPath, state.audioPath!);
    }
  }

  /// 수신자 측: 웰컴 캡슐 표시 여부 확인
  /// welcomeMessage 또는 welcomeAudioPath 가 있고, 아직 재생 안 했으면 true
  Future<bool> checkShouldShowWelcome() async {
    final repo = ref.read(settingsRepositoryProvider);
    final played = await repo.getBool(
      SettingsKey.welcomeCapsulePlayed,
      defaultValue: false,
    );
    if (played) return false;

    final msg = await repo.get(SettingsKey.welcomeMessage);
    final audio = await repo.get(SettingsKey.welcomeAudioPath);
    return (msg != null && msg.isNotEmpty) || (audio != null && audio.isNotEmpty);
  }

  /// 수신자 측: 저장된 웰컴 데이터 로드
  Future<({String? message, String? audioPath})> loadWelcomeData() async {
    final repo = ref.read(settingsRepositoryProvider);
    final msg = await repo.get(SettingsKey.welcomeMessage);
    final audio = await repo.get(SettingsKey.welcomeAudioPath);
    return (message: msg, audioPath: audio);
  }

  /// 수신자 측: 웰컴 캡슐 재생 완료 표시
  Future<void> markAsPlayed() async {
    final repo = ref.read(settingsRepositoryProvider);
    await repo.set(SettingsKey.welcomeCapsulePlayed, 'true');
  }
}
