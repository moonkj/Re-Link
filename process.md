# Re-Link 개발 진행 현황

> 마지막 업데이트: 2026-03-19
> 현재 단계: Phase 3 완료 + 콜드 스타트 최적화

---

## Phase 0 — 프로젝트 초기화

### 환경 설정
- [x] Flutter 3.41.2 설치 확인
- [x] Flutter 프로젝트 생성 (`flutter create . --org com.relink`)
- [x] CLAUDE.md 작성 (로컬 퍼스트 아키텍처 반영)
- [x] process.md 작성 (이 파일)
- [x] Memory 시스템 구성 (MEMORY.md + 메모리 파일)
- [x] `.gitignore` 업데이트
- [x] Git 저장소 초기화 (`git init`, branch: `main`)
- [x] `pubspec.yaml` 의존성 전체 업데이트
- [x] `flutter pub get` 실행 (패키지 설치)
- [x] `lib/` 폴더 구조 생성

### 아키텍처 결정
- [x] **로컬 퍼스트** 채택 (서버 없음, 기기 내 저장)
- [x] **AI 기능 제거** (서버 비용 절감, 1인 개발자 최적화)
- [x] **클라우드 백업** 방식 결정: iOS=iCloud, Android=Google Drive
- [x] **가족 공유** = .rlink 파일 내보내기/가져오기 (서버 불필요)

### Drift DB 스키마
- [x] `profile` 테이블
- [x] `nodes` 테이블
- [x] `node_edges` 테이블
- [x] `memories` 테이블
- [x] `settings` 테이블
- [x] `AppDatabase` 클래스 (마이그레이션 포함)

### 디자인 토큰 파일
- [x] `lib/design/tokens/app_colors.dart`
- [x] `lib/design/tokens/app_typography.dart`
- [x] `lib/design/tokens/app_spacing.dart`
- [x] `lib/design/tokens/app_radius.dart`
- [x] `lib/design/tokens/app_shadows.dart`
- [x] `lib/design/glass/app_glass.dart`
- [x] `lib/design/motion/app_motion.dart`
- [x] `lib/design/tokens/app_theme.dart`

### 핵심 설정 파일
- [x] `lib/core/config/env_config.dart`
- [x] `lib/core/constants/app_constants.dart`
- [x] `lib/core/errors/app_error.dart`
- [x] `lib/core/router/app_router.dart` (프로필→캔버스→백업)
- [x] `lib/app.dart`
- [x] `lib/main.dart` (서버 없음, Riverpod만)

### Repository / Service
- [x] `lib/shared/repositories/db_provider.dart`
- [x] `lib/shared/repositories/node_repository.dart`
- [x] `lib/shared/repositories/profile_repository.dart`
- [x] `lib/shared/repositories/settings_repository.dart`
- [x] `lib/core/services/media/media_service.dart`
- [x] `lib/core/services/backup/backup_service.dart`
- [x] `lib/core/services/backup/backup_format.dart`
- [x] `lib/core/services/cloud/cloud_backup_provider.dart`
- [x] `lib/core/services/cloud/icloud_backup.dart`
- [x] `lib/core/services/cloud/google_drive_backup.dart`

### 화면 골격
- [x] `lib/features/profile_setup/presentation/profile_setup_screen.dart`
- [x] `lib/features/canvas/presentation/canvas_screen.dart`
- [x] `lib/features/backup/presentation/backup_screen.dart`

### 코드 생성 & 검증
- [x] `build_runner` 실행 → `.g.dart` 파일 생성
- [x] `flutter analyze` → 0 issues

### 디바이스 테스트 환경 (아이패드)
- [x] `ios/Runner/Info.plist` — 권한 설명 추가 (마이크/카메라/앨범) + AdMob App ID
- [x] `ios/Podfile` — `platform :ios, '13.0'` 활성화
- [x] `android/AndroidManifest.xml` — 권한 + AdMob 메타데이터 + 앱 라벨
- [x] `android/app/build.gradle.kts` — `minSdk = 23` 설정
- [x] `flutter build ios --no-codesign` → 빌드 성공 (39.1MB)

---

## Phase 1 — MVP (Week 1–8)

### Week 1–2: 프로필 + 기본 구조

#### Coder
- [ ] 프로필 설정 화면 완성 (사진, 이름, 저장)
- [ ] 복원 감지 화면 (재설치 시 백업 발견)
- [ ] 프로필 편집 화면
- [ ] 하단 네비게이션 완성

---

### Week 3–4: 무한 캔버스 + 노드 CRUD ✅

#### UX Designer
- [x] 캔버스 인터랙션 설계 (InteractiveViewer + 드래그/팬 분리)
- [x] 노드 추가/편집 바텀시트 설계 (GlassBottomSheet)
- [x] Ghost Node 시각 가이드 (점선 테두리, 50% 투명)

#### Coder
- [x] `InteractiveViewer` 무한 캔버스 (4000×4000, minScale 0.3, maxScale 3.0)
- [x] `NodeCard` 렌더링 (110×130px, 온도별 테두리 색상)
- [x] Ghost Node 렌더링 (GhostNodeBorder, 50% 투명, `?` 아이콘)
- [x] 노드 드래그 & 위치 저장 (`_DraggableNodeCard` 로컬 상태 → DB write on drag end)
- [x] `EdgePainter` (베지에 곡선, 관계별 색상, 라벨)
- [x] 노드 탭 → `NodeDetailSheet` (온도 슬라이더, 액션 버튼)
- [x] `AddNodeSheet` (이름*, 별명, 사진, 생년월일, Ghost 토글)
- [x] `EditNodeSheet` (모든 필드 편집)
- [x] `RelationPickerSheet` (5가지 관계 타입)
- [x] 연결 모드 (롱프레스 → 배너 → 대상 탭 → 관계 선택)
- [x] `NodeNotifier` + `CanvasNotifier` (Riverpod)
- [x] FAB 노드 추가 (캔버스 중심 좌표 계산)
- [x] 줌 리셋 버튼

#### Debugger
- [x] `flutter pub run build_runner build` → `.g.dart` 생성
- [x] `flutter analyze lib/` → 0 issues

#### Test Engineer
- [x] `test/canvas/node_repository_test.dart` — 17개 테스트 (CRUD + Edge + cascade)
- [x] `test/canvas/canvas_state_test.dart` — 10개 테스트 (CanvasState 순수 로직)
- [x] 전체 27/27 통과

#### Performance
- [x] `RepaintBoundary`로 캔버스 영역 분리
- [x] 드래그 중 DB write 없음 (onPanEnd에서만 저장)
- [x] `EdgePainter.shouldRepaint` 최소화
- [x] `const` 위젯 최대 활용

---

### Week 5–6: 기억 저장 (사진 / 음성 / 메모) ✅

#### UX Designer
- [x] 기억 목록 화면 흐름 (NodeDetailSheet → MemoryScreen)
- [x] 타입별 UX 설계 (사진 그리드 / 음성 파형 / 메모 리스트)
- [x] 플랜 제한 UX (PlanLimitError → SnackBar + 업그레이드 버튼)

#### Coder
- [x] `AppDatabase`: `getMemory`, `countMemoriesByType`, `sumVoiceDuration` 추가
- [x] `MemoryRepository`: CRUD + 스트림 + 플랜 제한 쿼리
- [x] `MemoryNotifier`: addPhoto/Voice/Note, deleteMemory, 플랜 체크
- [x] `memoriesForNodeProvider`: 노드별 기억 스트림
- [x] `AddMemorySheet`: 타입 선택 (사진/음성/메모) + 사진/메모 폼
- [x] `VoiceRecorderSheet`: RecorderController 파형 + 타이머 + 저장
- [x] `MemoryDetailSheet`: 타입별 상세 (사진 전체화면/음성 재생/메모)
- [x] `MemoryScreen`: 필터 탭 + 사진 그리드 + 음성/메모 리스트 + FAB
- [x] `AppRoutes.memory` + go_router 연결
- [x] `NodeDetailSheet` "기억" 버튼 → `MemoryScreen` 라우팅

#### Debugger
- [x] `flutter analyze lib/` → 0 issues
- [x] audio_waveforms v2.0.2 API 호환 (RecorderSettings, startPlayer)

#### Test Engineer
- [x] `test/memory/memory_repository_test.dart` — 16개 테스트 (CRUD + cascade + 플랜)
- [x] 전체 44/44 통과

#### Performance
- [x] 사진 썸네일 그리드 (300px WebP) — 원본 lazy load
- [x] 음성 파형 waveform 한 번만 추출 (`shouldExtractWaveform: true`)

---

### Week 7–8: 플랜 시스템 + AdMob ✅

#### UX Designer
- [x] 플랜 선택 화면 흐름 설계 (3플랜 카드, 현재 플랜 하이라이트, 구매/업그레이드 CTA)
- [x] 플랜 제한 UX (SnackBar + 업그레이드 버튼)
- [x] 구매 복원 버튼

#### Coder
- [x] `lib/core/services/plan/plan_service.dart` — InAppPurchase 래퍼
- [x] `lib/features/subscription/providers/plan_notifier.dart` — Riverpod AsyncNotifier
- [x] `lib/features/subscription/presentation/subscription_screen.dart` — 플랜 선택 화면
- [x] `lib/shared/widgets/ad_banner_widget.dart` — AdMob 배너 (Free/Basic)
- [x] `lib/shared/widgets/plan_limit_banner.dart` — 제한 초과 SnackBar 헬퍼
- [x] `user_plan.dart` — maxAiCallsPerMonth 제거
- [x] `main.dart` — MobileAds.instance.initialize() 추가
- [x] `app_router.dart` — /subscription 실제 화면 연결, AdBanner 메인 셸 통합
- [x] 구매 플로우 (buy, restore, pendingCompletePurchase)
- [x] Premium 광고 제거 (hasAds 기반 조건부 렌더링)

#### Debugger
- [x] `flutter pub run build_runner build` → 89 outputs
- [x] `flutter analyze lib/` → 0 issues

#### Test Engineer
- [x] `test/subscription/plan_service_test.dart` — 14개 테스트 (planFromProductId, UserPlan 제한값, 광고 여부)
- [x] 전체 58/58 통과

#### Performance
- [x] Premium 플랜 시 AdBanner 즉시 SizedBox.shrink() 반환 (ad 로드 없음)
- [x] PlanNotifier AsyncNotifier 비동기 초기화
- [x] const 위젯 최대 활용

---

## Phase 2 — 확장 (Week 9–20) ✅

### 클라우드 백업 연동 ✅

#### UX Designer
- [x] 백업 화면 흐름 설계 (상태 카드 + 액션 타일 + 클라우드 목록)
- [x] 자동 백업 토글 UX (24시간 주기)
- [x] 복원 확인 다이얼로그 (데이터 덮어쓰기 경고)

#### Architect
- [x] `CloudBackupProvider` 추상 인터페이스 (upload/listBackups/download/prune/isAvailable)
- [x] `BackupState` 불변 상태 (isLoading, lastBackupAt, cloudBackups, cloudProvider, error)
- [x] `BackupNotifier` (플랫폼별 클라우드 자동 선택: iOS→iCloud, Android→Google Drive)

#### Coder
- [x] `lib/core/services/cloud/icloud_backup.dart` — icloud_storage 2.2.0 실제 구현
- [x] `lib/core/services/cloud/google_drive_backup.dart` — googleapis + google_sign_in 구현
- [x] `lib/features/backup/providers/backup_notifier.dart` — BackupState + BackupNotifier
- [x] `lib/features/backup/presentation/backup_screen.dart` — 전체 백업 UI
- [x] `pubspec.yaml` — file_picker 추가
- [x] 자동 백업 (`checkAutoBackup`) — 앱 포그라운드 진입 시 24시간 체크
- [x] 오래된 백업 자동 삭제 (`pruneOldBackups`, 최대 5개)

#### Debugger
- [x] `flutter pub run build_runner build` → 142 outputs
- [x] `flutter analyze lib/` → 0 issues
- [x] icloud_storage 2.2.0 API 타입 수정 (non-nullable returns, int sizeInBytes)
- [x] Switch.activeColor → activeThumbColor deprecation 수정

#### Test Engineer
- [x] `test/backup/backup_format_test.dart` — 7개 테스트 (BackupManifest + BackupInfo)
- [x] 전체 65/65 통과

#### Reviewer
- [x] `mounted` 체크 위치 정상 (BuildContext across async gap 없음)
- [x] `pruneOldBackups` Future.wait 병렬 삭제 적용

#### Performance
- [x] 클라우드 목록 로드는 initState 한 번만 (addPostFrameCallback)
- [x] BackupState copyWith 불변 패턴으로 불필요한 rebuild 최소화

### 가족 공유 ✅
- [x] .rlink 파일 내보내기 (OS 공유시트 — share_plus)
- [x] .rlink 파일 가져오기 (FilePicker .rlink 확장자 필터)
- [x] iOS Entitlements 설정 (iCloud.com.relink 컨테이너)
- [ ] 트리 병합 미리보기 화면 (Phase 3로 이동)
- [ ] 충돌 해결 UI (Phase 3로 이동)

### 음성 캡슐 고도화 ✅
- [x] 녹음 시간 제한 (플랜별: Basic 30분/Premium 300분) — `_checkVoiceLimit`
- [x] 음성 목록 관리 — MemoryScreen 음성 탭
- [x] 음성 사용량 배너 (`_VoiceUsageBanner`, LinearProgressIndicator)
- [x] `totalVoiceMinutes` / `totalPhotoCount` Riverpod 프로바이더

---

## Phase 3 — 폴리시 (Week 21–28) ✅

### 온도계 시스템 (Vibe Meter) ✅
- [x] 노드별 온도 설정 UI (6단계 슬라이더 — NodeDetailSheet)
- [x] 온도에 따른 노드 테두리/바 색상 (NodeCard)
- [ ] 온도 히스토리 (Phase 4로 이동 — 과도한 복잡도)

### Ghost Node ✅
- [x] Ghost Node 생성 (AddNodeSheet Ghost 토글)
- [x] 실제 인물 매핑 플로우 (NodeDetailSheet "실제 인물로 연결하기" 배너 → EditNodeSheet)
- [ ] 자동 Ghost 생성 (Phase 4로 이동)

### 검색 ✅

#### UX Designer
- [x] 캔버스 앱바 검색 아이콘 → SearchScreen (전체화면)
- [x] 노드/기억 통합 검색 결과 (섹션별 표시)
- [x] 디바운스 400ms, 빈 상태/결과없음 화면

#### Architect
- [x] `SearchNotifier` — AsyncValue<SearchResult>, Future.wait 병렬 쿼리
- [x] `SearchResult` 모델 (nodes + memories)
- [x] DB에 LIKE 검색 메서드 추가 (searchNodes, searchMemories)

#### Coder
- [x] `lib/features/search/providers/search_notifier.dart`
- [x] `lib/features/search/presentation/search_screen.dart`
- [x] `AppDatabase.searchNodes()` / `searchMemories()` — LIKE 쿼리
- [x] `NodeRepository.searchNodes()` / `MemoryRepository.searchMemories()`
- [x] `/search` 라우트 추가 (`app_router.dart`)
- [x] 캔버스 앱바 검색 아이콘 버튼

#### Debugger
- [x] `flutter analyze` → 0 issues

#### Test Engineer
- [x] `test/search/search_test.dart` — 11개 테스트 (NodeModel/MemoryModel 필터 + 빈 쿼리)
- [x] 전체 76/76 통과

#### Performance
- [x] 디바운스 400ms (불필요한 쿼리 방지)
- [x] `Future.wait` 병렬 DB 쿼리 (nodes + memories 동시)

### 설정 화면 ✅

#### UX Designer
- [x] 프로필 카드 + 편집 버튼
- [x] 요금제 현황 + 업그레이드 CTA
- [x] 백업 설정 (자동 백업 토글, 마지막 백업, 백업 화면 이동)
- [x] 앱 정보 (버전, 오픈소스 라이선스)

#### Coder
- [x] `lib/features/settings/presentation/settings_screen.dart`
- [x] `_ProfileSection` — 프로필 카드 + `_ProfileEditSheet` (이름/별명 편집)
- [x] `_PlanSection` — 현재 플랜 표시 + 업그레이드 버튼
- [x] `_BackupSection` — 자동 백업 토글 + 마지막 백업 시간
- [x] `_AppInfoSection` — package_info_plus 버전 + 오픈소스 라이선스
- [x] `app_router.dart` — `/settings` PlaceholderScreen → SettingsScreen 교체
- [x] 앱 정보 (JSON 내보내기 Phase 4로 이동)

---

## Phase 4 — 런치 (Week 29–34)

### 앱스토어 준비
- [ ] 앱 아이콘
- [ ] 스플래시 화면
- [ ] 스크린샷 (6.5인치, 5.5인치)
- [ ] 앱 설명 (한국어)
- [ ] 개인정보처리방침
- [ ] 이용약관

### 성능 최적화
- [ ] Flutter DevTools 프로파일링
- [ ] 앱 크기 최적화 (iOS < 50MB, Android < 30MB)
- [x] 콜드 스타트 최적화 — MobileAds 비동기 초기화, Splash 딜레이 제거, LaunchScreen 배경 어둡게
- [ ] 캔버스 60fps

### 출시
- [ ] TestFlight 베타
- [ ] Google Play 내부 테스트
- [ ] App Store 심사 제출
- [ ] Google Play 심사 제출
- [ ] 출시 🎉

---

## 진행 현황 요약

| Phase | 진행율 | 상태 |
|-------|--------|------|
| Phase 0 초기화 | 100% | ✅ 완료 |
| Phase 1 MVP | 100% | ✅ 완료 (Week 7–8 완료) |
| Phase 2 확장 | 85% | ✅ 완료 (트리 병합 Phase 3 이동) |
| Phase 3 폴리시 | 80% | ✅ 완료 (히스토리/자동Ghost Phase 4 이동) |
| Phase 4 런치 | 0% | ⏳ 대기 |
