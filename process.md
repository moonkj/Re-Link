# Re-Link 개발 진행 현황

> 마지막 업데이트: 2026-03-20
> 현재 단계: Phase 4j 완료 — 라이트 모드 & 관계선 관리 (에이전트 팀 병렬 실행)
> v2.0 계획: Phase 5a~5g 전체 26개 기능 계획 완료 (v1.0 런치 후 착수)

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
- [x] 프로필 설정 화면 완성 (사진, 이름, 저장) — `profile_setup_screen.dart`
- [ ] 복원 감지 화면 (재설치 시 백업 발견) — 향후 추가 예정
- [x] 프로필 편집 화면 — SettingsScreen `_ProfileEditSheet`
- [x] 하단 네비게이션 완성 — 5탭 ShellRoute (Phase 4a 완료)

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
- [x] 트리 병합 미리보기 화면 → Phase 4f에서 완료 (`merge_preview_screen.dart`)
- [x] 충돌 해결 UI → Phase 4f에서 완료 (`conflict_resolve_screen.dart`)

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

## Phase 4 — 완성 & 런치 (Week 29–52)

> Phase 4는 5개 서브페이즈로 나뉩니다. 각 서브페이즈는 7단계 워크플로(UX→Architect→Coder→Debugger→Test→Reviewer→Performance)를 따릅니다.

---

## Phase 4a — 화면 완성 (Week 29–34)

> 계획 문서에 정의된 미구현 화면 및 기능 전체 구현

### Splash Screen ✅

#### UX Designer
- [x] 브랜드 로고 페이드인 애니메이션 시퀀스 설계 (400ms Scene 티어)
- [x] LaunchScreen → SplashScreen 전환 끊김 없음 검증
- [x] DB 초기화 완료 → 자동 라우팅 (온보딩 or 캔버스) 플로우 설계

#### Architect
- [x] `app_router.dart` — `/splash` 최초 진입점 + GoRouter redirect (onboarding flag 체크)

#### Coder
- [x] `_SplashScreen` — FadeTransition (0→1, 400ms) + CircularProgressIndicator
- [x] 라우팅: `onboarding_done == false` → `/onboarding`, else → `/canvas`

#### Debugger
- [x] `flutter analyze lib/` → 0 issues

#### Test Engineer
- [x] `test/onboarding/onboarding_test.dart` — onboarding_done flag 분기 포함

#### Performance Engineer
- [x] AnimatedOpacity 페이드인으로 콜드 스타트 흰화면 방지

---

### Onboarding (3스텝) ✅

#### UX Designer
- [x] 3스텝 스와이프 플로우 설계 (PageView)
- [x] 스텝별 아이콘 일러스트 + 제목 + 설명 콘텐츠
- [x] 스킵 버튼(우상단) + 페이지 인디케이터 도트 + 시작하기/다음 CTA

#### Architect
- [x] `/onboarding` 라우트 추가 (GoRouter)

#### Coder
- [x] `lib/features/onboarding/presentation/onboarding_screen.dart`
- [x] `OnboardingPage` 위젯 (3개) — 아이콘 + 텍스트
- [x] `PageController` + AnimatedContainer 인디케이터
- [x] "시작하기" → `setOnboardingDone()` → `/profile_setup`
- [x] 스킵 → `setOnboardingDone()` → `/profile_setup`

#### Debugger
- [x] `flutter analyze lib/` → 0 issues

#### Test Engineer
- [x] `test/onboarding/onboarding_test.dart` — 13개 테스트 (onboarding/elderlyMode/privacy)

#### Performance Engineer
- [x] PageView lazy rendering (itemBuilder)

---

### 5탭 네비게이션 (ShellRoute) 완성 ✅

#### UX Designer
- [x] 5탭 구조: 홈(캔버스) / 이야기(Story Feed) / + / 보관함 / 설정
- [x] `_CustomBottomNav` — 커스텀 바텀 바, 가운데 + 글래스 원형 강조
- [x] 선택/비선택 색상 분기 (primary / white 50%)

#### Architect
- [x] `app_router.dart` — 5탭 ShellRoute (canvas/story/archive/settings)
- [x] 기존 3탭 → 5탭 전환, backup 독립 라우트로 이동

#### Coder
- [x] `lib/core/router/app_router.dart` 전면 재작성
- [x] `_CustomBottomNav` + `_NavItem` 위젯
- [x] + 버튼 탭 → canvas 이동 (FAB 연동)

#### Debugger
- [x] `flutter analyze lib/` → 0 issues

#### Performance Engineer
- [x] const 위젯 최대 활용

---

### Story Feed Screen (이야기 탭) ✅

#### UX Designer
- [x] 최근 기억 타임라인 카드 (역순 — 신규→과거)
- [x] 타입별 카드: 사진(썸네일+설명) / 음성(재생버튼+시간) / 메모(텍스트)
- [x] 노드 미니 아바타 + 이름 + 날짜 헤더
- [x] 빈 상태: EmptyStateWidget (auto_stories 아이콘)

#### Architect
- [x] `StoryFeedNotifier` — watchAll() + watchAll(nodes) 듀얼 스트림 join
- [x] `StoryFeedItem` 모델 (memory + nodeName + nodePhotoPath)
- [x] private 기억 피드 제외 로직

#### Coder
- [x] `lib/features/story/presentation/story_feed_screen.dart`
- [x] `lib/features/story/providers/story_feed_notifier.dart`
- [x] `StoryCard` 위젯 (photo/voice/note 분기)
- [x] `SliverList.builder` lazy 렌더링

#### Debugger
- [x] `flutter analyze lib/` → 0 issues

#### Test Engineer
- [x] `test/story/story_feed_test.dart` — 5개 테스트 (StoryFeedItem, isPrivate, formattedDuration)

#### Performance Engineer
- [x] SliverList.builder lazy 렌더링 (CustomScrollView)

---

### Archive Screen (보관함 탭) ✅

#### UX Designer
- [x] 전체 가족 기억 통합 + 필터 탭 (전체/사진/음성/메모)
- [x] 노드별 섹션 그룹핑 (이름 아바타 헤더)
- [x] 정렬 PopupMenu (최신순/오래된순/이름순)
- [x] 내부 검색바 (onChange 연동)

#### Architect
- [x] `ArchiveNotifier` — filter/sortOrder/searchQuery 상태 + 듀얼 스트림
- [x] `ArchiveFilter` (all/photo/voice/note), `ArchiveSortOrder` (newest/oldest/name)
- [x] `ArchiveGroup` 모델 (node + memories)

#### Coder
- [x] `lib/features/archive/presentation/archive_screen.dart`
- [x] `lib/features/archive/providers/archive_notifier.dart`
- [x] NestedScrollView + TabBar + ListView.builder
- [x] `_ArchiveGroup` + `_MemoryTile` 위젯
- [x] `isPrivate` lock 아이콘 표시

#### Debugger
- [x] `flutter analyze lib/` → 0 issues

#### Test Engineer
- [x] `test/archive/archive_filter_test.dart` — 10개 테스트

#### Performance Engineer
- [x] ListView.builder lazy 렌더링

---

### Focus Mode (캔버스) ✅

#### UX Designer
- [x] 더블탭 → focusedNodeId 설정
- [x] 비선택 노드 AnimatedOpacity 0.15 (200ms)
- [x] 연결 이웃 노드 opacity 0.7
- [x] 더블탭 재클릭 → clearFocus

#### Architect
- [x] `CanvasState.focusedNodeId` 추가
- [x] `nodeOpacity(nodeId)` — 엣지 기반 이웃 계산

#### Coder
- [x] `CanvasNotifier.setFocus()` / `clearFocus()`
- [x] `_DraggableNodeCard` — `AnimatedOpacity(focusOpacity)` 래핑
- [x] `onDoubleTap: _onNodeDoubleTap()` — HapticService.light() 포함

#### Debugger
- [x] `flutter analyze lib/` → 0 issues

#### Test Engineer
- [x] `test/canvas_focus/focus_mode_test.dart` — 11개 테스트 (opacity/isFocusMode/copyWith)

#### Performance Engineer
- [x] `AnimatedOpacity` — duration 200ms, RepaintBoundary 내 독립 렌더

---

### Time Slider (타임라인) ✅

#### UX Designer
- [x] 앱바 타임라인 아이콘 → `TimeSliderWidget` 펼침 (Positioned 오버레이)
- [x] 연도 슬라이더 (1900 ~ 현재), "전체" 리셋 버튼, 닫기 버튼

#### Architect
- [x] `CanvasState.timeSliderVisible` + `timeSliderYear` 추가
- [x] `nodeVisibleInTime(node)` — birthDate 기반 visibility

#### Coder
- [x] `lib/features/canvas/widgets/time_slider.dart`
- [x] `CanvasNotifier.toggleTimeSlider()` / `setTimeSliderYear()`
- [x] 캔버스 노드 렌더: `nodeVisibleInTime` 필터 적용
- [x] 앱바 timeline 아이콘 + 활성화 색상 표시

#### Debugger
- [x] `flutter analyze lib/` → 0 issues

#### Test Engineer
- [x] `test/canvas_focus/focus_mode_test.dart` — Time Slider 5개 테스트 포함

#### Performance Engineer
- [x] Slider.onChanged → 즉시 반영 (setState 없이 Riverpod 상태 업데이트)

---

### Heritage Export Screen (가계도 포스터) ✅

#### UX Designer
- [x] 4개 템플릿: Classic/Modern/Minimal/Festival (배경색+아이콘 분기)
- [x] 3가지 해상도: SNS(2×)/A4-A2(3×) pixelRatio
- [x] Premium 비가입 → 워터마크 오버레이

#### Architect
- [x] `ExportService` — RepaintBoundary → toImage() → File → share_plus

#### Coder
- [x] `lib/features/export/presentation/heritage_export_screen.dart`
- [x] `lib/features/export/services/export_service.dart`
- [x] `_ExportPreview` (4템플릿 분기), `_TemplateChip`, `_ResolutionChip`
- [x] Settings → 가계도 포스터 내보내기 ListTile 추가
- [x] planNotifier로 premium 여부 확인

#### Debugger
- [x] `flutter analyze lib/` → 0 issues

#### Performance Engineer
- [x] 미리보기: 기본 pixelRatio (낮은 해상도)
- [x] 내보내기: SNS=2.0×, A4/A2=3.0× (고해상도)

---

### Privacy Layer (개인 메모 잠금) ✅ (일부)

#### UX Designer
- [x] Settings Privacy Layer 토글 (FaceID/TouchID)
- [x] Archive: isPrivate 기억에 lock 아이콘 표시
- [x] StoryFeed: isPrivate 기억 피드 제외

#### Architect
- [x] `MemoryModel.isPrivate` 필드 추가
- [x] DB schemaVersion 1→2, `onUpgrade` migration: addColumn(isPrivate)
- [x] `MemoryRepository.setPrivate()` + `AppDatabase.setMemoryPrivate()`

#### Coder
- [x] `lib/core/database/tables/memories_table.dart` — isPrivate BoolColumn
- [x] `lib/core/database/app_database.dart` — migration + setMemoryPrivate()
- [x] `lib/shared/models/memory_model.dart` — isPrivate 필드
- [x] `lib/shared/repositories/memory_repository.dart` — setPrivate()
- [x] `lib/features/settings/presentation/settings_screen.dart` — _AccessibilitySection
- [ ] local_auth 패키지 연동 + PrivacyService (향후 추가 예정)
- [ ] 실제 생체인증 게이팅 (MemoryCard 블러 — 향후)

#### Debugger
- [x] `flutter analyze lib/` → 0 issues
- [x] DB 마이그레이션 schemaVersion 2

#### Test Engineer
- [x] `test/onboarding/onboarding_test.dart` — privacyEnabled 설정 2개 테스트

---

### Ghost Node 자동 생성 ✅

#### UX Designer
- [x] 노드 추가 시 "부모 Ghost 자동 생성" 토글 — `AddNodeSheet` 스위치 추가
- [x] 자동 생성된 Ghost 노드 표시 (점선+? 아이콘) — 기존 NodeCard Ghost 렌더링 활용
- [x] Ghost → 실제 인물 전환 배너 (NodeDetailSheet) — Phase 4f 완료

#### Architect
- [x] `NodeNotifier.createGhostParentsFor(child)` — 아버지·어머니 Ghost 자동 생성 + 배우자 엣지
- [x] Ghost 자동 배치 좌표: 자녀 노드 기준 x±120, y-220

#### Coder
- [x] `NodeNotifier.createNodeWithAutoGhost()` — 배우자 Ghost 자동 생성 로직
- [x] `NodeNotifier.createGhostParentsFor()` — 부모 Ghost 2개 자동 생성
- [x] `AddNodeSheet` — "부모 Ghost 자동 생성" Switch 추가 + `_autoGhostParents` 상태
- [x] Ghost 자동 배치 좌표 계산

#### Debugger
- [x] `flutter analyze lib/` → 0 issues

#### Test Engineer
- [x] `test/canvas/ghost_auto_creation_test.dart` — 7개 테스트 전체 통과

---

### Family Invite UI (가족 공유 관리) ✅ → Phase 4f에서 완료

#### UX Designer
- [x] .rlink 보내기/받기 플로우 최종 설계
- [x] 트리 병합 미리보기 화면 (노드 수 + 충돌 수 표시)
- [x] 충돌 해결 UI (내 노드 / 상대방 노드 / 둘 다 유지)

#### Architect
- [x] `MergePreviewNotifier` — .rlink 파싱 + 충돌 감지
- [x] `MergeConflict` 모델 (nodeId, myNode, theirNode)

#### Coder
- [x] `lib/features/family/presentation/merge_preview_screen.dart`
- [x] `lib/features/family/presentation/conflict_resolve_screen.dart`
- [x] `lib/features/family/providers/merge_preview_notifier.dart`
- [x] `BackupService` + `NodeRepository.createWithModel()` / `updateFromModel()`
- [x] `/merge-preview` 라우트 추가

#### Debugger
- [x] `flutter analyze lib/` → 0 issues

#### Test Engineer
- [x] (merge 로직은 MergePreviewNotifier 단위 검증 완료)

---

## Phase 4b — 캔버스 최적화 (Week 35–38)

> 대규모 노드(200+)에서 60fps 달성을 목표로 캔버스 렌더링 최적화

### InteractiveViewer + QuadTree 뷰포트 컬링 ✅

#### UX Designer
- [x] 줌 레벨별 UX 검증 (Bird's Eye → Zoom 전환 시 자연스러움)

#### Architect
- [x] `QuadTree<NodeModel>` 자료구조 설계 (viewport 기반 노드 쿼리)
- [x] `AnimatedBuilder(transformationController)` — 실시간 뷰포트 컬링 전략
- [x] 뷰포트 ±200px 버퍼 렌더링 전략

#### Coder
- [x] `lib/features/canvas/utils/quad_tree.dart` — QuadTree 구현
- [x] `lib/features/canvas/utils/lod_utils.dart` — LOD 레벨 유틸
- [x] `CanvasScreen` — `AnimatedBuilder` 기반 뷰포트 컬링 적용
- [x] 줌 레벨 → LOD 단계 매핑 (< 0.5: birdEye, 0.5–1.0: overview, 1.0–2.0: detail, > 2.0: zoom)
- [x] `NodeCardLod` 위젯 — LOD 단계별 렌더링 분기
  - Bird's Eye: `Container(width:8, height:8)` 점(dot)만
  - Overview: 원형 아바타 + 이름 텍스트
  - Detail/Zoom: 전체 NodeCard
- [x] EdgePainter `RepaintBoundary` 분리 — 노드 rebuid와 독립
- [x] 드래그 scale 보정 (delta / scale 변환)

#### Debugger
- [x] `flutter analyze lib/` → 0 issues
- [x] QuadTree 쿼리 결과 검증 (경계값 테스트)

#### Test Engineer
- [x] `test/canvas/quad_tree_test.dart` — 11개 테스트 통과
- [x] `test/canvas/lod_test.dart` — 10개 테스트 통과

#### Reviewer
- [x] QuadTree 업데이트: panUpdate 매 프레임마다 (AnimatedBuilder 기반)

#### Performance Engineer
- [x] EdgePainter `RepaintBoundary` 독립 분리
- [x] 노드 카드만 LOD 기반 재렌더 (에지 페인터는 데이터 변경 시만)

---

### Minimap ✅

#### Coder
- [x] `lib/features/canvas/widgets/minimap_widget.dart`
- [x] `_MinimapPainter` — 노드 점 + 뷰포트 사각형 (CustomPainter)
- [x] `AnimatedBuilder(transformationController)` — 실시간 업데이트
- [x] 좌하단 `Positioned` (캔버스 FAB와 위치 분리)

#### Debugger
- [x] `flutter analyze lib/` → 0 issues

#### Performance Engineer
- [x] `RepaintBoundary` 독립 분리 — 캔버스 노드 repaint와 분리

---

### Hero Transition ✅

#### Coder
- [x] `NodeCard._NodeAvatar` → `Hero(tag: 'node_avatar_${node.id}')` + `flightShuttleBuilder`
- [x] `NodeDetailSheet` 아바타 → `Hero(tag: 'node_avatar_${node.id}')` 연결
- [x] `MemoryThumbnail` → `MemoryDetail`: `Hero(tag: 'photo_${memory.id}')` — PhotoGrid + MixedList + MemoryDetailSheet 적용

#### Performance Engineer
- [x] Hero FlightShuttleBuilder — ScaleTransition으로 자연스러운 전환

---

### Pseudo-3D 깊이 (세대별 시각적 계층) ✅

#### Coder
- [x] `lib/features/canvas/utils/generation_utils.dart` — BFS 세대 계산 + pseudo3dTransform
- [x] `_DraggableNodeCard` — `generationDepth` 파라미터 추가
- [x] 세대 기반 transform 계산:
  - depth 0: scale 1.0, opacity 1.0, translateY 0
  - depth 5: scale 0.90, opacity 0.70, translateY -12 (선형 보간)
- [x] Focus Mode opacity × Pseudo-3D opacity 합성

#### Test Engineer
- [x] `test/canvas/generation_depth_test.dart` — BFS + pseudo3dTransform 10개 테스트 통과

#### Performance Engineer
- [x] 세대 계산 캐싱: `build()` 에서 노드/엣지 변경 시만 재계산 (Riverpod watch)

---

## Phase 4c — 디자인 시스템 & 품질 (Week 39–42)

> Glassmorphism 완성도, 햅틱, 접근성, Empty States, 어르신 모드

### Glassmorphism 2.0 완성도 ✅

#### UX Designer
- [x] 모든 바텀시트 blur:40 / opacity:0.72(라이트) / 0.70(다크) 적용 여부 검토
- [x] 노드 카드 blur:20 / opacity:0.15 일관성 검토
- [x] glassBorder (0x33FFFFFF) 전체 적용 현황 점검

#### Coder
- [x] `GlassCard` — brightness 기반 opacity 자동 조정 (라이트: opacity×4.8, 다크: 유지)
- [x] 모든 바텀시트 `GlassBottomSheet` 래퍼 통일 (기존 완료)
- [x] `GlassButton` → `StatefulWidget` — pressed(opacity 0.65)/disabled(opacity 0.4) 상태 효과

#### Reviewer
- [x] `BackdropFilter` 중첩 사용 최소화 (화면당 최대 3 레이어)

#### Performance Engineer
- [x] EdgePainter RepaintBoundary 분리로 BackdropFilter 재렌더 최소화

---

### 햅틱 시스템 (3단계) ✅

#### Coder
- [x] `lib/core/utils/haptic_service.dart` — HapticFeedback 래퍼 (light/medium/heavy/selection)
- [x] 노드 더블탭 → HapticService.light()
- [x] 연결 모드 진입 → HapticService.medium()
- [x] 타임슬라이더 토글 → HapticService.light()

#### Test Engineer
- [x] `test/haptic/haptic_service_test.dart` — 4개 테스트 (completes 검증)

---

### 접근성 (Accessibility) ✅

#### UX Designer
- [x] VoiceOver/TalkBack Semantics 레이블 전체 목록 작성 (NodeCard, SwitchListTile)
- [x] 동적 텍스트 크기 — 어르신 모드로 1.3× TextScaler 전역 적용

#### Coder
- [x] `NodeCard` — `Semantics(label: 이름/미확인 인물, hint, button: true)` 추가
- [x] 캔버스 아이콘 버튼 — `Tooltip` 추가 (검색/타임라인/중앙이동)
- [x] `_AccessibilitySection` SwitchListTile — `Semantics(toggled: ...)` 래퍼 추가
- [x] `MediaQuery.textScaler` — ElderlyMode 시 1.3× 앱 전역 주입 (app.dart builder)

#### Test Engineer
- [x] `test/accessibility/semantics_test.dart` — NodeCard Semantics 4개 테스트 통과

#### Reviewer
- [x] NodeCard 터치 타겟: kNodeCardWidth×kNodeCardHeight = 110×130dp (48dp 기준 충족)

---

### 어르신 모드 (Elderly Mode) ✅

#### UX Designer
- [x] 어르신 모드 ON 시: 텍스트 1.3× 배율 (전역)
- [x] 어르신 모드 토글 즉시 반영 (반응형 provider)

#### Coder
- [x] `SettingsRepository` — `elderly_mode` 키 기존 완료
- [x] `lib/features/settings/providers/elderly_mode_notifier.dart` — `AsyncNotifier<bool>`
- [x] `app.dart` — ElderlyMode `MediaQuery.builder` → `TextScaler.linear(1.3)` 전역 주입
- [x] `_AccessibilitySection` — `ElderlyModeNotifier` 반응형 토글 (FutureBuilder 제거)

#### Test Engineer
- [x] `test/settings/elderly_mode_notifier_test.dart` — 5개 테스트 (초기값/set/toggle/DB저장/반복호출)

---

### Empty States (빈 상태 화면) ✅

#### Coder
- [x] `lib/shared/widgets/empty_state_widget.dart` — 범용 EmptyState (아이콘+제목+설명+CTA버튼)
- [x] Story Feed 빈 상태 (auto_stories 아이콘)
- [x] Archive 빈 상태 (photo_library 아이콘)

---

## Phase 4d — 성능 최적화 & 테스트 (Week 43–46)

> 60fps 캔버스, 앱 크기, 콜드 스타트, 메모리 누수 검증

### Flutter DevTools 프로파일링

#### Performance Engineer
- [ ] **Timeline**: 캔버스 스크롤 중 frame build 시간 < 16ms
- [ ] **Widget Rebuild Inspector**: 불필요한 rebuild 식별 + 수정
- [ ] **Memory**: 30분 사용 후 메모리 누수 없음
- [ ] **CPU Profiler**: 핫스팟 메서드 최적화
- [ ] 프로파일링 결과 기록 (노드 50/200/500개 각각)

### 앱 크기 최적화 ✅

#### Performance Engineer
- [x] 미사용 패키지 17개 제거 (genealogy_chart/infinite_canvas/cached_network_image/google_fonts/glassmorphism/shimmer/lottie/flutter_animate/flutter_svg/photo_view/hive_ce/hive_ce_flutter/shared_preferences/flutter_secure_storage/connectivity_plus/device_info_plus/equatable/open_filex/just_audio)
- [x] `hive_ce_generator` dev_dependency 제거
- [x] `integration_test` SDK 추가 (통합 테스트용)
- [ ] `flutter build ipa --analyze-size` — 실제 릴리즈 빌드 크기 측정 (Phase 4e)
- [ ] `--split-debug-info` / `--obfuscate` 릴리즈 빌드 옵션 (Phase 4e)

### 콜드 스타트

- [x] MobileAds 비동기 초기화 — 메인 스레드 블로킹 없음
- [x] Splash 딜레이 제거
- [x] LaunchScreen 배경색 어둡게 (흰화면 방지)
- [ ] 콜드 스타트 시간 측정: 목표 < 2초 (iPhone 12 기준)
- [ ] Drift DB 초기화 시간 최적화 (isolate 확인)

### 캔버스 60fps 검증

#### Performance Engineer
- [ ] 노드 200개 Detail 레벨 스크롤: 60fps 달성
- [ ] 노드 500개 Bird's Eye 스크롤: 60fps 달성
- [ ] 연결 모드(연결선 실시간 드래그): 60fps 달성
- [ ] Focus Mode 전환 애니메이션: 60fps 달성

### 통합 테스트 ✅

#### Test Engineer
- [x] `integration_test/flows/canvas_flow_test.dart` — 노드 추가/빈상태/엣지 렌더링 (디바이스 필요)
- [x] `integration_test/flows/plan_guard_test.dart` — 플랜 제한 시나리오 (디바이스 필요)
- [x] `test/plan/plan_guard_test.dart` — UserPlan enum + DB + 노드카운트 단위 테스트 9개
- [x] `test/canvas/quad_tree_test.dart`, `lod_test.dart`, `generation_depth_test.dart` — 31개
- [x] `test/settings/elderly_mode_notifier_test.dart` — 5개
- [x] `test/accessibility/semantics_test.dart` — 4개
- [x] 전체 단위 테스트 407/407 통과

#### Performance Engineer (코드 레벨 최적화)
- [x] QuadTree 캐싱: `_qtSourceNodes != nodes` 체크로 노드 변경 시만 재빌드
- [x] `_CanvasBackground` RepaintBoundary 분리 (배경 정적 → 노드 repaint와 독립)
- [x] EdgePainter RepaintBoundary 분리 (Phase 4b)
- [ ] DevTools Timeline / CPU Profiler 프로파일링 (Phase 4e, 실제 디바이스)

---

## Phase 4e — 런치 준비 (Week 47–52)

### 앱 아이콘 & 스플래시

#### UX Designer
- [x] 앱 아이콘 디자인 (1024×1024 PNG — iOS, 512×512 — Android)
- [ ] 다크/라이트 아이콘 버전

#### Coder
- [x] `flutter_launcher_icons` 패키지 적용
- [x] iOS LaunchScreen.storyboard 최종 확인
- [x] Android splash12.xml (Android 12+) 적용 — `values-v31/styles.xml` (windowSplashScreenBackground + AnimatedIcon)

---

### App Store / Google Play 준비

#### UX Designer
- [ ] 스크린샷 촬영 (iPhone 6.9인치, 6.5인치, iPad 12.9인치)
- [ ] Google Play 스크린샷 (폰/태블릿)
- [ ] 프리뷰 동영상 (선택)

#### Coder
- [x] 앱 설명 한국어 작성 (App Store + Google Play)
- [x] 개인정보처리방침 페이지 (인앱 — `privacy_policy_screen.dart`)
- [x] 이용약관 페이지 (인앱 — `terms_screen.dart`, `/terms` 라우트, Settings 링크 연결)
- [x] `Info.plist` 권한 설명 최종 검토 (한국어 — 카메라/마이크/사진 라이브러리 완료)

---

### TestFlight & 내부 테스트

#### Coder
- [ ] `flutter build ipa --release` → Xcode Archive → TestFlight 업로드
- [ ] `flutter build appbundle --release` → Google Play 내부 테스트 트랙
- [ ] 테스트 디바이스 목록: iPhone SE3/12/15, Galaxy S24
- [ ] 핵심 플로우 테스트 체크리스트:
  - [ ] 첫 실행 → 온보딩 → 프로필 설정
  - [ ] 노드 추가/편집/삭제/연결
  - [ ] 기억 추가 (사진/음성/메모)
  - [ ] 클라우드 백업/복원
  - [ ] .rlink 내보내기/가져오기
  - [ ] 인앱 구매 (Sandbox)
  - [ ] 어르신 모드
  - [ ] Privacy Layer

---

### 심사 제출

- [ ] App Store Connect 메타데이터 완성
- [ ] Google Play Console 스토어 등록정보 완성
- [ ] App Store 심사 제출
- [ ] Google Play 심사 제출 (프로덕션 트랙)
- [ ] 심사 피드백 대응
- [ ] 출시

---

---

## Phase 4g — 실기기 테스트 & 버그 수정 (2026-03-19 ~)

### 캔버스 뷰포트 버그 수정 ✅

#### Debugger
- [x] **버그**: 앱 시작 시 InteractiveViewer가 캔버스 (0,0) 기준으로 시작 → 노드가 화면 가장자리에서 잘림
- [x] **원인**: `_CanvasScreenState`에 `initState` 없어 기본 transform(identity) 사용됨

#### Coder
- [x] `_CanvasScreenState.initState` 추가 — `postFrameCallback`에서 `_resetZoom()` 호출
- [x] `_resetZoom()` 개선 — 노드가 있으면 노드 중심점으로 이동, 없으면 캔버스 중앙(2000, 2000)으로 이동

---

### 캔버스 인터랙션 버그 수정 ✅ (2026-03-20)

> 7단계 워크프로세스(UX→Architect→Coder→Debugger→Test→Reviewer→Performance) 따라 검토

#### UX Designer
- [x] InteractiveViewer ClipRect 히트테스트 차단 문제 발견 — 캔버스 좌표 > 화면 크기 시 모든 터치 무시
- [x] Listener 기반 제스처로 전환 후 GestureDetector 아레나 경합 해소 확인
- [x] 노드 겹침 문제 확인 → 자동 분산 로직 필요

#### Architect
- [x] InteractiveViewer `constrained: false` + `clipBehavior: Clip.none` 필수 설정 도출
- [x] 제스처 계층: Listener(raw pointer) → 탭(300ms+20px), 롱프레스(400ms), 드래그(롱프레스 후 5px 이동)
- [x] AnimatedOpacity(0.0)의 내부 IgnorePointer 우회: Listener를 AnimatedOpacity 바깥에 배치

#### Coder
- [x] InteractiveViewer: `constrained: false`, `clipBehavior: Clip.none` 적용
- [x] `_DraggableNodeCard` — GestureDetector → Listener 기반 완전 재작성
- [x] `NodeCard` / `NodeCardLod` — 제스처 콜백 전부 제거 (순수 표시 위젯화)
- [x] 노드 자동 분산 (`_spreadOverlappingNodes`) — 200×200 영역 내 노드를 격자 패턴 배치
- [x] 충돌 방지 (`_showAddNodeSheet`) — 기존 노드와 겹침 감지 + 오프셋 이동

#### Debugger
- [x] `flutter analyze lib/` → 0 issues

#### Test Engineer
- [x] `test/accessibility/semantics_test.dart` — NodeCard API 변경 반영 (onTap/onLongPress/onDragEnd 제거)
- [x] 전체 테스트 409/409 통과

---

### 코드 검토 & 버그 수정 ✅ (2026-03-20)

> 7단계 워크프로세스 전체 파일 상세 검토

#### UX Designer — 발견된 7개 구현 버그
- [x] **Critical**: Focus Mode(더블탭) 진입 불가 — `_onNodeDoubleTap` 정의만 있고 호출 없음
- [x] **Critical**: `_resetZoom()` 노드 중심 이동 미구현 — 항상 캔버스 (2000,2000) 고정
- [x] **High**: 연결 모드 임시선 미작동 — `_connectPointer` 업데이트 없음
- [x] **High**: `getDatabasePath()` 경로 불일치 — `drift/relink.db` vs `relink.db`
- [x] **Medium**: `NodeModel.copyWith` nullable 필드 null 설정 불가

#### Coder
- [x] **Bug 1 — Focus Mode 더블탭**: `_DraggableNodeCard`에 `onDoubleTap` 콜백 추가 + Listener에 더블탭 감지(300ms 내 두 번째 탭)
- [x] **Bug 2 — _resetZoom 노드 중심**: 노드 존재 시 노드 평균 좌표로 이동, 없으면 캔버스 중앙
- [x] **Bug 3 — 연결 모드 임시선**: InteractiveViewer 위에 `Listener(HitTestBehavior.translucent)` 배치, 캔버스 좌표로 `_connectPointer` 업데이트
- [x] **Bug 4 — getDatabasePath**: `drift/relink.db` → `relink.db`로 통일 (`_openConnection`과 일치)
- [x] **Bug 5 — copyWith nullable**: `clearNickname`/`clearPhotoPath`/`clearBio`/`clearBirthDate`/`clearDeathDate` 플래그 추가

#### Debugger
- [x] `flutter analyze lib/` → 0 issues

#### Test Engineer
- [x] `semantics_test.dart` — NodeCard 순수 표시 위젯화 API 반영
- [x] 전체 테스트 409/409 통과

#### Reviewer
- [x] `mounted` 체크 위치 정상 (BuildContext across async gap 없음)
- [x] 더블탭 판정: 첫 탭→onTap 즉시 + 300ms 내 재탭→onDoubleTap (응답성 우선)
- [x] 연결 모드 Listener: `HitTestBehavior.translucent`로 하위 터치 전달
- [x] `ref.read` 적절 사용 (build 외부)

#### Performance Engineer
- [x] 연결 모드 Listener setState: EdgePainter RepaintBoundary 분리로 노드 카드 영향 없음
- [x] `_resetZoom` 노드 순회 O(n) — 200개 이하에서 무시 가능
- [x] 기존 최적화 유지 (QuadTree/LOD/RepaintBoundary)

### 실기기 설치 (아이패드)
- [x] `flutter analyze lib/` → 0 issues (409/409 테스트 통과)
- [x] `xcrun devicectl device install app` + `device process launch` — iPad Pro (12.9") 설치 성공
- [x] 엣지 실시간 추적 수정 후 설치 확인 (2026-03-20)
- [x] 디자인 시스템 전면 교체 후 재설치 확인 (2026-03-20, 36.3MB → Phase 4h 색상 반영)
- [ ] 핵심 플로우 실기기 검증:
  - [ ] 앱 시작 시 뷰포트 중앙 정렬 확인
  - [ ] 노드 더블탭 → Focus Mode 진입/해제 확인
  - [ ] 연결 모드 임시 점선 표시 확인
  - [ ] Ghost 부모 자동 생성 토글 동작 확인
  - [ ] 사진 기억 Hero 전환 애니메이션 확인
  - [ ] 캔버스 pan/zoom 60fps 확인
  - [ ] 새 색상 체계(Mint/Blue) 실기기 렌더링 확인

---

## Phase 4f — UX 고도화 (ux_ui_design.md 미구현 항목)

> ux_ui_design.md / tech_stack_analysis.md / ReLink_Project_Plan.pdf 분석 후 식별된 미구현 항목

### Spring 애니메이션 프리셋 ✅

#### Coder
- [x] `app_motion.dart` — 5가지 `SpringDescription` 상수 추가 (springSnappy/Default/Bouncy/Gentle/Node)
- [x] `app_motion.dart` — ghostFill/focusPanelSlide/vibeMeterStep Duration 상수 추가

---

### 햅틱 피드백 완전 매핑 ✅

#### Coder
- [x] `haptic_service.dart` — `ghostFill()` (heavyImpact×2)
- [x] `haptic_service.dart` — `heritageExport()` (heavyImpact×2)
- [x] `haptic_service.dart` — `vibeMeterStep()` (selectionClick)
- [x] `haptic_service.dart` — `connectionMade()` (mediumImpact)
- [x] `haptic_service.dart` — `memoryAdded()` (mediumImpact)
- [x] `haptic_service.dart` — `nodeDeleted()` (heavyImpact)
- [x] `haptic_service.dart` — `planLimitReached()` (heavyImpact)
- [x] `haptic_service.dart` — `backupComplete()` (lightImpact)
- [x] Ghost 인물 전환 → `ghostFill()` 트리거 (node_card.dart didUpdateWidget)
- [x] Heritage Export → `heritageExport()` 트리거 (heritage_export_screen.dart)
- [x] Vibe Meter 스텝 변경 → `vibeMeterStep()` 트리거 (vibe_meter_sheet.dart)
- [x] 노드 연결 완료 → `connectionMade()` 트리거 (canvas_screen.dart)
- [x] 기억 저장 완료 → `memoryAdded()` 트리거 (add_memory_sheet.dart, voice_recorder_sheet.dart)

---

### 음성 캡슐 고도화 (Voice Capsule UX) ✅

#### UX Designer
- [x] 재생 속도 컨트롤 설계 (0.5×/1×/1.5×/2×)
- [x] Liquid Glass 마이크 버튼 디자인 (녹음 중 pulse 애니메이션)

#### Coder
- [x] `voice_recorder_sheet.dart` — `_PlaybackSpeed` enum + 속도 조절 Row
- [x] `voice_recorder_sheet.dart` — `_PulseMicButton` — AnimationController pulse 애니메이션
- [x] `PlayerController.setRate()` — 속도 적용
- [x] `_PlaybackSpeed` — 0.5×/1×/1.5×/2× 4단계

#### Performance
- [x] pulse 애니메이션 `RepaintBoundary` 독립

---

### Focus Mode 정보 패널 ✅

#### UX Designer
- [x] 포커스 시 하단 패널: 이름/관계수/온도 표시
- [x] TweenAnimationBuilder 슬라이드업 (280ms easeOutCubic)

#### Coder
- [x] `canvas_screen.dart` — `_FocusInfoPanel` 위젯
- [x] `focusedNodeId` → 해당 노드 이름/관계수/온도 표시
- [x] 상세보기/닫기 버튼

---

### Ghost Node 전환 애니메이션 ✅

#### UX Designer
- [x] Ghost → 실제 인물 전환 시 scale(1.0→1.2→1.0) + glow 애니메이션

#### Coder
- [x] `node_card.dart` — `_fillController` AnimationController + `_wasGhost` 감지
- [x] `didUpdateWidget` — `wasGhost && !isGhost` 시 `_fillController.forward()`
- [x] `Listenable.merge` — pulse + fill + glow 합성 AnimatedBuilder
- [x] 전환 완료 → `HapticService.ghostFill()` 호출

---

### Vibe Meter 바텀시트 (온도 애니메이션) ✅

#### UX Designer
- [x] 6단계 아이콘 선택기 (ac_unit/cloud/wb_sunny/local_fire_department/whatshot/flare)
- [x] 선택 단계 scale+glow 강조 (AnimatedContainer + AnimatedScale)
- [x] selectionClick 햅틱 + AnimatedSwitcher 중앙 아이콘 전환

#### Coder
- [x] `lib/features/canvas/widgets/vibe_meter_sheet.dart` — 독립 바텀시트
- [x] 온도 게이지 트랙 (AnimatedContainer 진행 표시)
- [x] `NodeDetailSheet` — 온도 슬라이더 → VibeMeterSheet 탭으로 교체

---

### Family Merge Preview (가족 파일 병합) ✅

#### UX Designer
- [x] .rlink 가져오기 후 병합 미리보기 화면 (새 인물 수 + 충돌 목록)
- [x] 충돌 해결 UI (내 노드 / 상대방 노드 / 둘 다 유지)

#### Architect
- [x] `MergePreviewNotifier` — Riverpod Notifier + `MergePreviewState`
- [x] `MergeConflict` 모델 (nodeId, myNode, theirNode)
- [x] .rlink 내 relink.db 임시 파싱 → `NodeRepository.getAll()`로 충돌 감지

#### Coder
- [x] `lib/features/family/presentation/merge_preview_screen.dart`
- [x] `lib/features/family/presentation/conflict_resolve_screen.dart`
- [x] `lib/features/family/providers/merge_preview_notifier.dart`
- [x] `NodeRepository.getAll()` / `createWithModel()` / `updateFromModel()` 추가
- [x] `AppDatabase.forMerge(path)` — 임시 파일 DB 생성자 추가
- [x] `/merge-preview` 라우트 추가 (AppRoutes.mergePreview)

#### Debugger
- [x] `flutter analyze lib/` → 0 issues
- [x] `flutter test test/` → 407/407 통과 (커버리지 81.1% ≥ 80% 목표)

---

## Phase 4h — 디자인 문서 반영 (2026-03-20)

> 디자인 문서 Chapter 04 (4.1~4.6) UX/UI 스펙을 현재 구현에 반영

### 4.1 Glassmorphism 2.0 ✅

#### Coder
- [x] `GlassCard` — Light blur:24/opacity:0.72, Dark blur:32/opacity:0.60 자동 적용
- [x] `GlassCard` — `blur`/`opacity` 파라미터 제거 → 밝기 기반 자동 계산
- [x] `GlassBottomSheet` — blur:32, bg: `0xE60D1117` (90% Night BG)
- [x] `PrimaryGlassButton` — 그라디언트 Mint→Blue 교체

---

### 4.2 Color System (Day/Night Palette) ✅

#### Coder
- [x] `app_colors.dart` 전면 재작성:
  - Day: Primary Mint `#6EC6CA`, Primary Blue `#4A9EBF`, BG `#F5F7FA`, Accent Mint `#5BBFBE`, Accent Warm `#F4845F`
  - Night: BG `#0D1117`, Surface `#1E2840`, Navy `#2D6B8A`, Violet `#3B4D8B`, Mint Bright `#64D4D4`, Coral `#FF9970`
  - Semantic: Success `#52C77A`, Error `#FF6B6B`, Warning `#F4C05A`, Info `#4A9EBF`
- [x] 10개 feature 파일에서 19곳 하드코딩 색상 교체:
  - `0xFF6C63FF` → `0xFF6EC6CA` (primary)
  - `0xFF9C94FF` → `0xFF4A9EBF` (gradient end)
  - `0xFF0A0A1A` → `0xFF0D1117` (night bg)
  - `0xFF1A1040` → `0xFF1E2840` (night surface)
  - `0x4D6C63FF` → `0x4D6EC6CA` (glow)
- [x] `app_shadows.dart` — Primary glow `#6EC6CA` 기반으로 변경

---

### 4.3 Vibe Meter (온도 6색) ✅

#### Coder
- [x] 온도 색상 전면 교체:
  - Cold `#6B9FCC` / Cool `#5BBFBE` / Neutral `#7BC67A`
  - Warm `#F4C05A` / Hot `#F4845F` / Burning `#E8525A`

---

### 4.4 Typography (T1-T6 시스템) ✅

#### Coder
- [x] T1 Display — Noto Serif KR 40sp Bold (`google_fonts` 런타임 로드, CJK 24MB 번들 방지)
- [x] T2 Heading Large — Pretendard 28sp Bold
- [x] T3 Heading Small — Pretendard 22sp SemiBold
- [x] T4 Body Large — Pretendard 17sp Medium
- [x] T5 Body Regular — Pretendard 15sp Regular
- [x] T6 Caption — Pretendard 12sp Regular
- [x] Code — JetBrains Mono 14sp Regular (assets/fonts/ 번들)
- [x] `pubspec.yaml` — JetBrainsMono 폰트 2개 추가, `google_fonts` 패키지 추가
- [x] `app_theme.dart` — TextTheme `const` → non-const (Noto Serif KR getter 호환)

---

### 4.5 Spacing & Corner Radius ✅

#### Coder
- [x] `app_radius.dart` 컴포넌트별 반경 재정의:
  - Chip: 100dp, Action Button: 16dp, Icon Button: 24dp
  - Node Card Small: 20dp, Node Card Large: 28dp
  - Bottom Sheet: 28dp, Dialog: 24dp, Voice Capsule: 20dp
  - TextField: 14dp, Avatar: 999dp
- [x] `app_theme.dart` — dialogTheme `glassCard` → `dialog` (24dp)

---

### 4.6 Spring Motion & Haptic ✅

#### Coder
- [x] `app_motion.dart` — 3-Tier Duration 상수 추가:
  - Tier 1 Quick (100-200ms), Tier 2 Standard (250-400ms), Tier 3 Dramatic (500-800ms)
- [x] `app_motion.dart` — Haptic 매핑 가이드 추가 (7가지 액션 → HapticFeedback 종류)
- [x] 5가지 Spring 프리셋 기존 유지 확인 (Snappy/Default/Bouncy/Gentle/Node)

---

### 빌드 검증 ✅

- [x] `flutter analyze` → 에러/경고 0개
- [x] `flutter build ios` → 36.3MB 빌드 성공
- [x] iPad Pro (12.9") 설치 + 실행 확인

---

## Phase 4i — 화면별 UX 설계 반영 (Chapter 05) (2026-03-20 ~)

> 디자인 문서 Chapter 05 (화면별 UX 설계) 중 미구현 항목 구현
> 7단계 워크프로세스(UX→Architect→Coder→Debugger→Test→Reviewer→Performance) 따라 진행

---

### 화면 01 — Splash Screen 고도화 ✅

#### UX Designer
- [x] 앱 로고: Re-Link 워드마크 + Bezier 곡선 마크
- [x] 태그라인: "단절된 선을 잇고, 잊혀진 온기를 기록하다." (단어별 순차 페이드인)
- [x] 배경: Mint→Blue 그라디언트 (Day) / Deep Navy (Night)

#### Coder
- [x] 로고 scale 0.8→1.0 (elasticOut, 400ms) 애니메이션
- [x] 태그라인 단어별 stagger 페이드인 (80ms 간격, 6단어)
- [x] 배경 Mint-Blue 그라디언트 적용 (Day/Night 분기)
- [x] `_BezierMarkPainter` — 두 점을 잇는 곡선 + 양쪽 점(노드) 브랜드 마크

#### Debugger
- [x] `flutter analyze` → 0 issues

---

### 화면 02~04 — 온보딩 고도화 ✅

#### UX Designer
- [x] Step 2 설계: 첫 가족 연결 (부모/배우자/자녀 빠른 추가 버튼)
- [x] 미니 캔버스 프리뷰 (핵심 인터랙션 선체험 — CustomPainter)
- [ ] Step 3: 알림 권한 요청 + 완성 셀레브레이션 애니메이션 (v2.0 W-3 Daily Prompt와 통합 예정)

#### Architect
- [x] 프로필 → "나" 노드 자동 생성 (profileSetup → firstFamily 라우트 전환)
- [x] 관계 추가 플로우: 버튼 탭 → 이름 입력 → NodeNotifier.createNode + addEdge

#### Coder
- [x] `lib/features/onboarding/presentation/first_family_screen.dart` — FirstFamilyScreen 전체 구현
- [x] Step 2 화면: 첫 가족 구성원 빠른 추가 (부모/배우자/자녀 3버튼 + 이름 입력)
- [x] 필드 포커스 시 민트 밑줄 애니메이션 (`focusedBorder: Color(0xFF6EC6CA)`)
- [x] Bezier 곡선 관계선 draw 애니메이션 (600ms easeOutCubic)
- [x] 연결 완료: `HapticService.connectionMade()` 햅틱
- [x] `_MiniCanvasPainter` — 미니 캔버스 (나+가족 노드+관계선 시각화)
- [x] `app_router.dart` — `/first-family` 라우트 + FirstFamilyScreen 추가
- [x] `profile_setup_screen.dart` — 저장 후 `/canvas` → `/first-family` 라우트 변경

#### Debugger
- [x] `flutter analyze` → 0 issues (기존 warning 1 + info 1만 존재)

---

### 화면 05 — 캔버스 인터랙션 고도화 ✅

#### UX Designer
- [x] 노드 드래그 시 scale 1.0→1.08 + elevation 증가 효과

#### Coder
- [x] `_DraggableNodeCard` — 롱프레스/드래그 중 `AnimatedScale(1.08)` + translateY -4 elevation
- [x] Focus Mode 포커스 노드 scale 1.15 + 민트 glow BoxShadow (24blur, 4spread)

#### Debugger
- [x] `flutter analyze` → 0 issues

---

### 화면 06 — 노드 상세 고도화 ✅

#### UX Designer
- [x] 탭 네비게이터: 타임라인 / 메모 / 음성 / 관계 (4탭 구조)
- [x] 연도순 이벤트 카드: 생일·사망·기억 통합 타임라인

#### Architect
- [x] ConsumerStatefulWidget + SingleTickerProviderStateMixin (TabController)
- [x] 각 탭 별도 위젯: `_TimelineTab`, `_MemoTab`, `_VoiceTab`, `_RelationTab`

#### Coder
- [x] `NodeDetailSheet` — TabBar + TabBarView (타임라인/메모/음성/관계)
- [x] `_TimelineTab` — birthDate/deathDate + 기억 통합 시간순 정렬, GlassCard 이벤트 카드
- [x] `_MemoTab` — note 타입 필터, 제목/설명/날짜/잠금 아이콘
- [x] `_VoiceTab` — voice 타입 필터, 마이크 아바타/시간/재생 배지
- [x] `_RelationTab` — 연결 노드 목록, 관계 타입 라벨, 삭제 버튼 + 확인 다이얼로그
- [x] 아바타 탭 → `_PhotoFullScreenDialog` (InteractiveViewer pinch zoom 0.5×~4×)
- [x] 온도 뱃지 탭 → VibeMeterSheet 바텀시트 호출
- [x] 4탭 모두 빈 상태 EmptyStateWidget 적용

#### Debugger
- [x] `flutter analyze` → 0 issues

---

### 화면 08 — Voice Capsule 태그 시스템 ✅

#### UX Designer
- [x] 태그 선택 UI: 이야기/생일/인터뷰/노래/기타 (5개 Chip)

#### Coder
- [x] `VoiceRecorderSheet` — 태그 선택 Row (5개 ChoiceChip)
- [x] `MemoryModel.tags` 필드 연동 (DB 저장/로드)
- [x] `AddMemorySheet` — 메모 감정 태그 UI 추가 (기쁨/그리움/놀람/사랑/슬픔)

#### Debugger
- [x] `flutter analyze` → 0 issues

---

### 화면 09 — Time Slider 시대 레이블 ✅

#### UX Designer
- [x] 시대 구분 레이블: 일제(~1945)/해방(~1950)/전쟁(~1953)/산업화(~1990)/현대(~현재)
- [x] 해당 연도 주요 가족 이벤트 토스트 팝업

#### Coder
- [x] `TimeSliderWidget` — 시대 구분 마커 5개 (Stack + Positioned 레이블)
- [x] `_buildEraLabels()` — LayoutBuilder 기반 시대별 라벨 + 경계선 렌더링
- [x] `lib/features/canvas/widgets/time_event_toast.dart` — GlassCard 스타일 토스트 (2초 자동 사라짐)
- [x] `TimeEventToast.buildEventMessage()` — birthDate/deathDate 매칭 메시지 생성 ("1952년 — 할아버지 탄생 외 N명")
- [x] `canvas_screen.dart` — 연도 변경 감지 + TimeEventToast 오버레이 통합

#### Debugger
- [x] `flutter analyze` → 0 issues

---

### 화면 10 — Focus Mode 애니메이션 시퀀스 ✅

#### UX Designer
- [x] 진입 시 카메라 중앙 이동 + scale 1.15 + 민트 glow + 패널
- [x] 비초점 노드 opacity 0.15 (AnimatedOpacity 200ms)

#### Coder
- [x] Focus 진입 시 `_animateCameraToNode()` — 포커스 노드 화면 중앙 이동
- [x] 포커스 노드 `AnimatedScale(1.15)` + 민트 glow `BoxShadow(0x806EC6CA, blur:24, spread:4)`
- [x] `AnimatedContainer` 300ms 트랜지션으로 glow on/off

#### Debugger
- [x] `flutter analyze` → 0 issues

---

### 화면 11 — Ghost Node 고도화 ✅

#### UX Designer
- [x] Ghost 라벨 다양화: "알 수 없는 조상" (부모), "미확인 배우자" (배우자), "관계 미상" (기타), "?" (기본)
- [x] 채우기 유도 CTA: "이 분을 알고 계신 가족이 있나요?" + share_plus 공유 버튼

#### Architect
- [x] `resolveGhostLabel(node, edges)` — edge 관계 타입 기반 Ghost 라벨 결정 로직

#### Coder
- [x] `node_card.dart` — `resolveGhostLabel()` 함수 + `ghostLabel` 파라미터 추가
- [x] `_GhostContent` — Ghost 라벨 텍스트 표시 (이름 아래 9pt)
- [x] `NodeDetailSheet` — Ghost CTA 배너 + `Share.share()` 연동 ("Re-Link에서 가족 트리를 만들고 있어요...")
- [x] `canvas_screen.dart` — `_DraggableNodeCard`에서 `resolveGhostLabel` 호출 + `ghostLabel` 전달

#### Debugger
- [x] `flutter analyze` → 0 issues

---

### 화면 13 — 개인 메모 (Privacy Layer) 고도화 ✅

#### UX Designer
- [x] 감정 태그 선택 UI: 기쁨/그리움/놀람/사랑/슬픔 (5개 Chip + 이모지)
- [x] 메모 공개 범위 토글: 개인 전용 ↔ 가족 공유 (메모별 설정)

#### Coder
- [x] `AddMemorySheet` 메모 폼 — `EmotionTag` enum + 감정 태그 Chip Row 추가
- [x] 감정 태그 → `MemoryModel.tags` 필드 연동 (기존 tagsJson DB 컬럼 활용)
- [x] 메모 공개 범위 토글 (isPrivate) — 메모 생성 시 Switch 노출
- [x] `MemoryRepository.create()` — `isPrivate` 파라미터 추가
- [x] `MemoryNotifier.addNote()` — `tags`/`isPrivate` 파라미터 추가

#### Debugger
- [x] `flutter analyze` → 0 issues (info 1개, deprecation warning만)

---

### 화면 14 — Heritage Export 고도화 ✅

#### UX Designer
- [x] 색상 테마 4종: 앱 테마 연동 / 흑백 / 세피아 / 커스텀
- [x] 완료 시 heavyImpact ×2 축하 진동 (Phase 4f에서 이미 구현)

#### Coder
- [x] `ExportColorTheme` enum (appTheme/bw/sepia/custom) + `_ColorThemeChip` UI
- [x] `_ExportPreview` — 색상 테마 오버라이드 적용 (bw/sepia/custom → bg+titleColor 변경)
- [x] 내보내기 완료 시 `HapticService.heritageExport()` (heavyImpact ×2) — 이미 적용됨

#### Debugger
- [x] `flutter analyze` → 0 issues

---

### 화면 15 — 설정 & 프로필 고도화 ✅

#### UX Designer
- [x] 테마 선택: 시스템 따라 / 항상 라이트 / 항상 다크
- [x] 햅틱 On/Off 토글
- [x] 애니메이션 줄이기 토글

#### Coder
- [x] `ThemeModeNotifier` — Riverpod AsyncNotifier (system/light/dark 저장)
- [x] `HapticNotifier` — Riverpod AsyncNotifier (enabled/disabled 저장)
- [x] `ReduceMotionNotifier` — Riverpod AsyncNotifier (enabled/disabled 저장)
- [x] `app.dart` — `theme: AppTheme.light`, `darkTheme: AppTheme.dark`, `themeMode` 반응형 연동
- [x] `AppTheme.light` — Light 테마 추가 (Day palette 기반)
- [x] `HapticService.enabled` — 글로벌 on/off 플래그, 모든 메서드에서 체크
- [x] `_ThemeSection` — 시스템/라이트/다크 3버튼 선택 UI
- [x] `_AccessibilitySection` — 햅틱 On/Off + 애니메이션 줄이기 토글 추가
- [x] `SettingsRepository` — `getThemeMode`/`isHapticEnabled`/`isReduceMotion` 메서드 추가
- [x] `SettingsKey` — `themeMode`/`hapticEnabled`/`reduceMotion` 키 추가

#### Debugger
- [x] `flutter analyze` → 0 issues

---

### 빌드 & 실기기 검증
- [x] `flutter analyze` → 0 issues (info 1개 — deprecation only)
- [x] `flutter build ios` → 36.3MB 빌드 성공 (코드 사이닝 포함)
- [x] iPad Pro (12.9") 설치 + 실행 확인

---

## Phase 4j — 라이트 모드 & 관계선 관리 (2026-03-20)

> 7단계 워크프로세스(UX→Architect→Coder→Debugger→Test→Reviewer→Performance) 따라 진행

---

### 라이트 모드 색상 적응 (Critical) ✅

#### UX Designer
- [x] 라이트/다크 모드별 배경, 텍스트, 글래스 색상 매핑 정의
- [x] 캔버스, 하단시트, 네비게이션 바 라이트 모드 검증

#### Architect
- [x] AppColors 공유 alias를 brightness-aware getter로 전환
- [x] app.dart에서 brightness 동기화 메커니즘

#### Coder
- [x] `AppColors` — bgBase/textPrimary/textSecondary/textTertiary/glassBorder 등 적응형 getter
- [x] 22개 파일 154개 const 참조 수정
- [x] 캔버스 배경 그라디언트 밝기 분기
- [x] 하단 네비게이션 바 밝기 분기 (light `0xFFF5F7FA` / dark `0xFF0D0D1F`)

#### Debugger
- [x] `flutter analyze` → 0 issues (info only)

---

### 엣지(연결) 삭제/수정 기능 ✅

#### UX Designer
- [x] 노드 상세 시트에 연결 목록 표시 + 삭제 버튼
- [x] 중복 연결 추가 방지 로직

#### Architect
- [x] NodeDetailSheet — 연결 목록 조회 + 개별 삭제 UI
- [x] NodeNotifier.addEdge — 중복 체크 로직

#### Coder
- [x] `NodeDetailSheet` — RelationTab 연결 목록 표시 (상대 노드 이름 + 관계 + 삭제/수정 버튼)
- [x] `NodeNotifier.addEdge` — 기존 연결 있으면 관계 타입 업데이트 (중복 방지)
- [x] `NodeRepository` — `findEdge()` 양방향 엣지 조회 + `updateEdgeRelation()` 메서드
- [x] `AppDatabase` — `findEdgeBetween()` + `updateEdgeRelation()` SQL 쿼리
- [x] `_ChangeRelationSheet` — 기존 엣지 관계 타입 변경 UI

#### Debugger
- [x] `flutter analyze` → 0 issues (info only)

---

### 부부 자석 스냅 + 자녀 통합 관계선 ✅

#### UX Designer
- [x] 배우자 노드 근접 드래그 시 자동 스냅 (옵션 토글)
- [x] 자녀 관계선: 부부 커넥터 중점에서 단일 선으로 표시

#### Architect
- [x] 스냅 거리 임계값 (50px) + 스냅 위치 계산 (좌/우/상/하)
- [x] EdgePainter — 부부-자녀 T-shape 통합선 렌더링 로직

#### Coder
- [x] `canvas_screen.dart` — 드래그 종료 시 배우자 스냅 로직
- [x] 설정 토글: 부부 자석 스냅 On/Off (`spouse_snap_notifier.dart`)
- [x] `EdgePainter` — `_drawCoupleChildrenLine()` 부부 쌍 감지 → 자녀 선 T-shape 집약
- [x] `SettingsRepository` — `isSpouseSnapEnabled()` / `setSpouseSnap()` 저장

#### Test Engineer
- [x] `spouse_snap_test.dart` — 8개 테스트 (스냅 거리/위치/설정 토글)
- [x] `edge_painter_couple_child_test.dart` — 14개 테스트 (T-shape 렌더링)

#### Debugger
- [x] `flutter analyze` → 0 issues (info only)

---

### 돌아가신 분 캔버스 표시 ✅

#### UX Designer
- [x] 사망일 있는 노드: 꽃 아이콘(Icons.local_florist) + 반투명(opacity 0.7) + 회색 테두리

#### Coder
- [x] `NodeCard` — `!node.isAlive` 시 `Opacity(0.7)` + 우상단 `Icons.local_florist` (16px)
- [x] `_buildDecoration()` — 고인 노드 테두리 색상 `Color(0xFF8E8E93)` 회색 오버라이드
- [x] `_NormalContent` — 온도 바 회색 처리
- [x] `_BirdEyeDot` — 고인 노드 회색 점 표시
- [x] `_OverviewCard` — 고인 노드 opacity 0.7 + 꽃 아이콘 + Stack 레이아웃
- [x] Semantics 접근성: 고인 노드 '고인' 접미사 추가

#### Debugger
- [x] `flutter analyze` → 0 issues

---

### 빌드 & 실기기 검증
- [x] `flutter analyze` → 0 errors/warnings (15 info only)
- [x] `flutter test` → 431/431 전체 통과
- [ ] `flutter build ios` → 빌드 성공
- [ ] iPad Pro 설치 + 실행 확인

---

---

# v2.0 — 감성 기능 & 성장 엔진 (Phase 5)

> **목표**: v1.0 런치 이후, 리텐션 강화 + 차별화 + 수익화 확장을 위한 v2.0 기능 구현
> **선정 기준**: ①차별화 강도 × ②수익화 연결 × ③개발 난이도(낮을수록 우선) × ④리텐션 효과
> **핵심 원칙**: 서버 비용 0원 유지 (모든 기능 로컬 퍼스트)
>
> **수익화 전략 변경** (v2.0):
> - Free (10노드): 기억 스트릭, 온도 일기, 스마트 명절 허브(기본), 기억 캡슐 1개, 가족 초대 1명
> - BASIC (₩4,900): 확장 기능 + 200노드
> - PREMIUM (₩14,900): 무제한 + 프리미엄 스킨/템플릿/리포트

---

## Phase 5a — v2.0 MVP 킬러 피처 (Quick Wins)

> 개발 난이도 낮고 리텐션/수익화 효과 높은 5개 기능 우선 구현
> 각 기능 7단계 워크프로세스(UX→Architect→Coder→Debugger→Test→Reviewer→Performance) 적용

---

### E-2. 온도 일기 (Temperature Diary)

> 기존 Vibe Meter 확장 — 각 가족 노드에 "오늘의 온도" 감성 일기. 슬라이더 하나로 5초 기록.
> 서버 비용 없음, 극소 용량 (숫자 데이터), DAU 유도에 최적

#### UX Designer
- [ ] 캔버스 노드 탭 → 온도 일기 퀵 엔트리 (슬라이더 + 이모션 태그)
- [ ] 텍스트 없이 온도 수치 + 이모션 태그만으로 기록 가능
- [ ] 노드별 온도 그래프 화면 (시간 축 히스토리)
- [ ] "엄마와의 온도 그래프" — 감성적 가족 역사 아카이브

#### Architect
- [ ] `temperature_logs` 테이블 추가 (nodeId, temperature, emotionTag, date)
- [ ] DB migration schemaVersion 증가
- [ ] `TemperatureLogRepository` — CRUD + 기간별 조회
- [ ] `TemperatureDiaryNotifier` — Riverpod AsyncNotifier

#### Coder
- [ ] `lib/core/database/tables/temperature_logs_table.dart` — Drift 테이블
- [ ] `lib/shared/repositories/temperature_log_repository.dart`
- [ ] `lib/features/temperature/providers/temperature_diary_notifier.dart`
- [ ] `lib/features/temperature/presentation/temperature_diary_screen.dart` — 온도 그래프 화면
- [ ] `lib/features/temperature/widgets/quick_temp_entry.dart` — 슬라이더 퀵 입력
- [ ] `NodeDetailSheet` — 온도 일기 퀵 엔트리 연동
- [ ] 온도 그래프 `CustomPainter` (일/주/월 뷰)

#### Debugger
- [ ] `flutter analyze` → 0 issues

#### Test Engineer
- [ ] `test/temperature/temperature_repository_test.dart` — CRUD + 기간 조회
- [ ] `test/temperature/temperature_diary_test.dart` — 그래프 데이터 변환

#### Reviewer
- [ ] `mounted` 체크 위치 확인
- [ ] AsyncValue 패턴 일관성

#### Performance Engineer
- [ ] 그래프 데이터 페이징 (최근 30일 기본, 스크롤 시 추가 로드)
- [ ] `RepaintBoundary` 그래프 영역 분리

---

### G-2. 기억 스트릭 & 연속 기록 보호권 (Memory Streak)

> Duolingo식 스트릭 — 매일 가족 기억 하나 기록하면 연속 기록. 불꽃 아이콘 표시.
> 보호권으로 이탈 방지. 서버 비용 없음 (날짜 비교 로직만).

#### UX Designer
- [ ] 캔버스 앱바에 스트릭 카운터 (불꽃 아이콘 + 일수)
- [ ] 스트릭 유지 축하 애니메이션 (7일/30일/100일 마일스톤)
- [ ] 스트릭 끊김 경고 + 보호권 사용 프롬프트
- [ ] 온도 일기 한 번 기록만으로도 스트릭 유지 (진입 장벽 최소화)

#### Architect
- [ ] `settings` 테이블 활용: `streak_count`, `streak_last_date`, `streak_freeze_count` 키
- [ ] `StreakNotifier` — 앱 포그라운드 시 스트릭 상태 계산
- [ ] 스트릭 체크 로직: 오늘 날짜 vs lastDate (0일=유지, 1일=갱신, 2일+=끊김 or 보호권)

#### Coder
- [ ] `lib/features/streak/providers/streak_notifier.dart` — AsyncNotifier
- [ ] `lib/features/streak/widgets/streak_badge.dart` — 불꽃 아이콘 + 카운트
- [ ] `lib/features/streak/widgets/streak_milestone_dialog.dart` — 마일스톤 축하
- [ ] 캔버스 앱바 스트릭 배지 통합
- [ ] 기억/온도 저장 시 `StreakNotifier.recordActivity()` 호출
- [ ] 스트릭 보호권: Free 0개, Basic 월 3개, Premium 무제한

#### Debugger
- [ ] `flutter analyze` → 0 issues

#### Test Engineer
- [ ] `test/streak/streak_notifier_test.dart` — 연속/끊김/보호권/마일스톤 로직

#### Reviewer
- [ ] 날짜 비교 타임존 안전성 확인

#### Performance Engineer
- [ ] 스트릭 체크: 앱 포그라운드 시 1회만 (중복 호출 방지)

---

### W-3. 오늘의 가족 질문 알림 (Daily Family Prompt)

> 매일 아침 8시 가족 관련 질문 알림. "아버지의 고향은 어디인지 기억하시나요?"
> 정적 질문 풀 100개+ (서버 불필요). 알림 탭 → 해당 노드 기록 화면 이동.

#### UX Designer
- [ ] 알림 탭 → 해당 노드의 기록 화면으로 즉시 이동
- [ ] 질문 카드 UI (글래스 카드, 노드 아바타 + 질문 텍스트)
- [ ] "무엇을 기록할지 모르겠다" 온보딩 장벽 제거

#### Architect
- [ ] `lib/core/data/family_prompts.dart` — 정적 질문 풀 JSON (100개+)
- [ ] 질문 카테고리: 고향/어린시절/음식/명절/관계/추억/꿈/가치관
- [ ] `DailyPromptNotifier` — 오늘의 질문 선택 (날짜 기반 시드 랜덤)
- [ ] `local_notifications` 패키지 — 매일 반복 알림

#### Coder
- [ ] `lib/core/data/family_prompts.dart` — 100개 질문 데이터
- [ ] `lib/features/prompt/providers/daily_prompt_notifier.dart`
- [ ] `lib/features/prompt/widgets/daily_prompt_card.dart` — 질문 카드
- [ ] `lib/core/services/notification/local_notification_service.dart` — 로컬 알림
- [ ] 캔버스 화면 상단 오늘의 질문 배너 (dismissible)
- [ ] `pubspec.yaml` — `flutter_local_notifications` 패키지 추가

#### Debugger
- [ ] `flutter analyze` → 0 issues

#### Test Engineer
- [ ] `test/prompt/daily_prompt_test.dart` — 질문 선택 로직, 중복 방지

#### Reviewer
- [ ] 알림 권한 요청 타이밍 (온보딩 or 설정)

#### Performance Engineer
- [ ] 질문 데이터 앱 번들 내 정적 로드 (런타임 파싱 최소화)

---

### E-6. 추억 꽃다발 (Memory Bouquet)

> 가족 구성원에게 "감사 꽃 한 송이" 보내기. 매주 가족 트리 위에 꽃 피고, 연말 꽃다발 리포트.
> 이모지/SVG 기반 — 서버 비용 제로. 정수값 하나만 저장.

#### UX Designer
- [ ] 노드 상세 → "꽃 보내기" 버튼 (꽃 종류 5개 선택)
- [ ] 캔버스 노드 위 꽃 아이콘 표시 (이번 주 받은 꽃)
- [ ] 연말 "가족 꽃다발 리포트" — Spotify Wrapped 스타일 슬라이드쇼

#### Architect
- [ ] `bouquets` 테이블 (fromNodeId, toNodeId, flowerType, date)
- [ ] `BouquetRepository` — CRUD + 주간/연간 집계
- [ ] `BouquetNotifier` — 꽃 보내기 + 리포트 생성

#### Coder
- [ ] `lib/core/database/tables/bouquets_table.dart`
- [ ] `lib/shared/repositories/bouquet_repository.dart`
- [ ] `lib/features/bouquet/providers/bouquet_notifier.dart`
- [ ] `lib/features/bouquet/widgets/flower_picker.dart` — 꽃 5종 선택 UI
- [ ] `lib/features/bouquet/widgets/bouquet_on_node.dart` — 캔버스 노드 위 꽃 표시
- [ ] `lib/features/bouquet/presentation/annual_bouquet_screen.dart` — 연말 리포트
- [ ] 수익화: 무료(기본 꽃) / 프리미엄(희귀 꽃 디자인, 골드 부케 특별판)

#### Debugger
- [ ] `flutter analyze` → 0 issues

#### Test Engineer
- [ ] `test/bouquet/bouquet_repository_test.dart` — CRUD + 집계

#### Reviewer
- [ ] 꽃 애니메이션 과다 렌더 방지

#### Performance Engineer
- [ ] 캔버스 꽃 아이콘: LOD birdEye에서 숨김

---

### S-1. 가족 트리 아트 카드 (Family Tree Art Card)

> 가족 트리를 아름다운 아트 카드 이미지로 변환 → SNS 공유. Re-Link 바이럴 엔진.
> RepaintBoundary + 이미지 저장 — 서버 완전 불필요.

#### UX Designer
- [ ] 아트 스타일 4종: 수채화풍 / 미니멀 / 전통 한지풍 / 모던
- [ ] 공유 이미지에 Re-Link 로고 워터마크 삽입 (유기적 브랜드 노출)
- [ ] 프리미엄: 고해상도 + 로고 제거 + 추가 아트 스타일

#### Architect
- [ ] `ArtCardService` — RepaintBoundary → toImage() → share_plus
- [ ] 기존 `ExportService` 확장 or 별도 서비스
- [ ] 아트 스타일별 색상 팔레트 + 레이아웃 정의

#### Coder
- [ ] `lib/features/art_card/presentation/art_card_screen.dart` — 스타일 선택 + 미리보기
- [ ] `lib/features/art_card/services/art_card_service.dart` — 렌더링 + 내보내기
- [ ] `lib/features/art_card/widgets/art_tree_painter.dart` — 아트 스타일별 CustomPainter
- [ ] 공유 이미지 Re-Link 로고 삽입 (Canvas drawImage)
- [ ] Settings / 캔버스 메뉴에서 진입점 추가

#### Debugger
- [ ] `flutter analyze` → 0 issues

#### Test Engineer
- [ ] `test/art_card/art_card_service_test.dart` — 스타일별 렌더링 설정

#### Reviewer
- [ ] 공유 이미지 개인정보 노출 수준 확인 (이름만 vs 사진 포함 옵션)

#### Performance Engineer
- [ ] 미리보기: 1× 해상도 / 내보내기: 2~3× 고해상도
- [ ] 렌더링 isolate 분리 (UI 스레드 블로킹 방지)

---

## Phase 5b — 감성 기능 확장

> 차별화 핵심 — 감성적 가치 기반 기능

---

### E-1. 기억 캡슐 (Memory Capsule)

> 특정 미래 날짜에만 열리는 디지털 타임캡슐. 편지·사진·음성을 봉인.
> "아이가 스무 살이 되면 열어보세요" — 프리미엄 전환 동기.

#### UX Designer
- [ ] 캡슐 생성 플로우: 콘텐츠 선택 → 열림 날짜 설정 → 봉인 애니메이션
- [ ] 캡슐 목록 화면 (잠금 상태 / 열림 가능 상태 분기)
- [ ] 캡슐 열림 순간 셀레브레이션 애니메이션 + 햅틱

#### Architect
- [ ] `capsules` 테이블 (id, title, openDate, isOpened, createdAt)
- [ ] `capsule_items` 테이블 (capsuleId, memoryId)
- [ ] `CapsuleRepository` — CRUD + 열림 가능 체크
- [ ] `CapsuleNotifier` — 캡슐 생성/열기 + 로컬 알림 스케줄링

#### Coder
- [ ] DB 테이블 + Repository + Notifier
- [ ] `lib/features/capsule/presentation/capsule_list_screen.dart`
- [ ] `lib/features/capsule/presentation/create_capsule_screen.dart`
- [ ] `lib/features/capsule/widgets/capsule_card.dart` — 잠금/열림 상태 UI
- [ ] `lib/features/capsule/widgets/seal_animation.dart` — 봉인 애니메이션
- [ ] 로컬 알림: 열림 날짜 도달 시 푸시
- [ ] 수익화: Free 1개 캡슐, Premium 무제한 + 50년 보관 보장

#### Debugger
- [ ] `flutter analyze` → 0 issues

#### Test Engineer
- [ ] `test/capsule/capsule_repository_test.dart`
- [ ] `test/capsule/capsule_open_logic_test.dart` — 날짜 비교 로직

#### Reviewer
- [ ] 캡슐 열림 날짜 조작 방지 (createdAt 검증)

#### Performance Engineer
- [ ] 캡슐 목록 lazy 로드

---

### E-7. 마지막 페이지 (The Last Page)

> 세상을 떠난 가족 구성원의 디지털 추모 공간. Ghost Node 확장.
> 생전 메시지, 가족 추억, 기일 추모 메시지 모음.

#### UX Designer
- [ ] 추모 공간 진입: deathDate 있는 노드 탭 → "추모 공간" 탭 표시
- [ ] 기일 알림 (음력/양력 선택)
- [ ] 추모 슬라이드쇼 (사진+음성 자동 재생)

#### Architect
- [ ] `memorial_messages` 테이블 (nodeId, message, authorName, date)
- [ ] 기일 계산 로직 (음력 변환 — 정적 테이블 or 패키지)
- [ ] `MemorialNotifier` — 추모 공간 상태 관리

#### Coder
- [ ] DB 테이블 + Repository + Notifier
- [ ] `lib/features/memorial/presentation/memorial_screen.dart` — 추모 공간
- [ ] `lib/features/memorial/widgets/memorial_slideshow.dart` — 자동 슬라이드쇼
- [ ] 기일 로컬 알림 스케줄링
- [ ] 수익화: 프리미엄 (추모 공간 고급 테마, 기일 알림, 추모 영상 슬라이드쇼 자동 생성)

#### Debugger
- [ ] `flutter analyze` → 0 issues

#### Test Engineer
- [ ] `test/memorial/memorial_repository_test.dart`

#### Reviewer
- [ ] 추모 콘텐츠 민감도 — 삭제 확인 다이얼로그 강화

#### Performance Engineer
- [ ] 슬라이드쇼 이미지 프리로드 (다음 2장)

---

### K-5. 가족 단어장 (Family Glossary)

> 우리 가족만의 사투리, 은어, 별명, 고유 표현 기록. 텍스트+음성.
> 구현 난이도 낮고 감성 가치 높음.

#### UX Designer
- [ ] 단어장 목록 화면 (검색 + 알파벳/가나다 정렬)
- [ ] 단어 카드: 표현 + 뜻 + 사용 예시 + 음성 녹음
- [ ] "외할머니가 부르던 나의 어릴 적 별명" 예시 제공

#### Architect
- [ ] `glossary` 테이블 (id, word, meaning, example, voicePath, nodeId, createdAt)
- [ ] `GlossaryRepository` — CRUD + 검색
- [ ] `GlossaryNotifier` — Riverpod AsyncNotifier

#### Coder
- [ ] DB 테이블 + Repository + Notifier
- [ ] `lib/features/glossary/presentation/glossary_screen.dart`
- [ ] `lib/features/glossary/widgets/glossary_card.dart`
- [ ] `lib/features/glossary/widgets/add_glossary_sheet.dart` — 단어 추가 바텀시트
- [ ] 음성 녹음 연동 (기존 RecorderController 재사용)
- [ ] 수익화: 프리미엄 (가족 단어장 PDF 책 형태 내보내기)

#### Debugger
- [ ] `flutter analyze` → 0 issues

#### Test Engineer
- [ ] `test/glossary/glossary_repository_test.dart`

#### Reviewer
- [ ] 음성 파일 경로 관리 (MediaService 재사용)

#### Performance Engineer
- [ ] 목록 SliverList.builder lazy 렌더링

---

## Phase 5c — 게이미피케이션 엔진

> Duolingo식 리텐션 메커니즘 — 서버 비용 0원 조건

---

### G-1. 가족 나무 성장 시스템 (Family Tree Growth)

> 가족 노드 추가 + 기억 기록할수록 앱 배경 나무가 무성하게 자라는 비주얼.
> 계절 변화 (봄 벚꽃 → 여름 녹음 → 가을 단풍 → 겨울 설경).

#### UX Designer
- [ ] 나무 성장 5단계: 새싹 → 묘목 → 작은 나무 → 큰 나무 → 대수(大樹)
- [ ] 계절 변화 (현재 월 기준 자동 적용)
- [ ] 나무 이미지 SNS 공유 버튼

#### Architect
- [ ] 성장 지표 계산: 노드 수 × 2 + 기억 수 × 1 + 스트릭 일수 × 0.5
- [ ] 성장 단계 임계값: 0-10/11-30/31-80/81-200/201+
- [ ] `TreeGrowthNotifier` — 성장 상태 계산 + 캐싱

#### Coder
- [ ] `lib/features/tree_growth/providers/tree_growth_notifier.dart`
- [ ] `lib/features/tree_growth/widgets/growing_tree_painter.dart` — CustomPainter
- [ ] `lib/features/tree_growth/widgets/tree_share_card.dart` — 공유 카드
- [ ] 캔버스 배경에 나무 오버레이 (RepaintBoundary 분리)
- [ ] 계절 자동 감지 (DateTime.now().month → Season enum)
- [ ] 수익화: 프리미엄 나무 스킨 (벚꽃나무/소나무/은행나무 등)

#### Debugger
- [ ] `flutter analyze` → 0 issues

#### Test Engineer
- [ ] `test/tree_growth/tree_growth_test.dart` — 성장 단계 계산

#### Performance Engineer
- [ ] CustomPainter `shouldRepaint` — 성장 단계 변경 시만 repaint
- [ ] 나무 렌더링 RepaintBoundary 독립

---

### G-3. 세대 탐험가 배지 시스템 (Generation Explorer Badges)

> 가족 역사 맥락에 특화된 배지. "증조부 발견자", "5대 연결 달성", "명절 기록가".
> 서버 저장: 정수/비트마스크로 최소화.

#### UX Designer
- [ ] 배지 목록 화면 (획득/미획득 분기)
- [ ] 배지 획득 시 축하 다이얼로그 + 햅틱
- [ ] 캔버스 노드에 배지 아이콘 표시 (해당 노드 관련 배지)

#### Architect
- [ ] `badges` 테이블 (badgeId, earnedAt) or 비트마스크 정수 in settings
- [ ] 배지 정의: 정적 enum (20+ 종류)
- [ ] `BadgeNotifier` — 배지 획득 조건 체크 (이벤트 기반)

#### Coder
- [ ] `lib/features/badges/models/badge_definition.dart` — 배지 정의 enum
- [ ] `lib/features/badges/providers/badge_notifier.dart`
- [ ] `lib/features/badges/presentation/badge_list_screen.dart`
- [ ] `lib/features/badges/widgets/badge_earned_dialog.dart`
- [ ] 수익화: 프리미엄 (골드/다이아몬드 배지 프레임, 특별 애니메이션)

#### Debugger
- [ ] `flutter analyze` → 0 issues

#### Test Engineer
- [ ] `test/badges/badge_condition_test.dart` — 배지 조건 로직

#### Performance Engineer
- [ ] 배지 조건 체크: 관련 이벤트 발생 시만 (전체 스캔 방지)

---

### G-4. 가족 챌린지 (Family Quest)

> 매주 자동 생성 미션. "이번 주에 부모님 어린 시절 사진 1장 추가하기".
> 규칙 기반 자동 생성 (AI 불필요).

#### UX Designer
- [ ] 주간 미션 카드 (캔버스 또는 홈 화면 배너)
- [ ] 미션 진행률 표시 (체크박스 + 프로그레스 바)
- [ ] 미션 완료 보상: 배지 + 나무 성장 보너스

#### Architect
- [ ] `lib/core/data/quest_templates.dart` — 미션 템플릿 (40+ 종류)
- [ ] 미션 생성 규칙: 주간 시드 + 현재 노드/기억 상태 기반 필터
- [ ] `QuestNotifier` — 주간 미션 생성 + 진행률 추적

#### Coder
- [ ] `lib/features/quest/providers/quest_notifier.dart`
- [ ] `lib/features/quest/widgets/quest_card.dart`
- [ ] `lib/features/quest/presentation/quest_screen.dart`
- [ ] 미션 완료 감지: 기억/노드 CRUD 이벤트에 훅
- [ ] 수익화: 프리미엄 (특별 시즌 챌린지 — 설날/추석/어버이날)

#### Debugger
- [ ] `flutter analyze` → 0 issues

#### Test Engineer
- [ ] `test/quest/quest_generation_test.dart` — 미션 생성 로직

#### Performance Engineer
- [ ] 미션 상태 체크: 관련 이벤트 시만 (앱 포그라운드 1회 + CRUD 이벤트)

---

## Phase 5d — 한국 시장 특화

> 한국 가족 문화 특화 기능 — 글로벌 경쟁사 차별화 핵심

---

### K-1. 스마트 명절 허브 (Smart Holiday Hub)

> 설날/추석/기일이 다가오면 홈 화면이 해당 명절 테마로 변환.
> 관련 조상 노드 하이라이트 + "이번 명절에 기억해야 할 조상 이야기" 알림.

#### UX Designer
- [ ] 명절 감지 → 캔버스 배경 테마 자동 전환 (설날: 한복 색, 추석: 달/송편 모티프)
- [ ] 명절 관련 조상 노드 하이라이트 (glow 효과)
- [ ] 음력/양력 자동 전환 (한국 사용자 필수)
- [ ] 제사 순서 안내 가이드 (프리미엄)

#### Architect
- [ ] `lib/core/data/korean_holidays.dart` — 한국 명절 데이터 (음력 변환 포함)
- [ ] `HolidayNotifier` — 현재 날짜 기준 명절 감지
- [ ] 테마 오버라이드 시스템 (명절 기간 동안 임시 테마)

#### Coder
- [ ] 명절 데이터 + 음력 변환 로직 (음력 계산 라이브러리 or 정적 테이블)
- [ ] `lib/features/holiday/providers/holiday_notifier.dart`
- [ ] `lib/features/holiday/widgets/holiday_banner.dart` — 명절 배너
- [ ] 캔버스 배경 테마 오버라이드
- [ ] 수익화: 프리미엄 (명절 특별 테마, 제사 순서 안내, 애니메이션 효과)
- [ ] `pubspec.yaml` — 음력 변환 패키지 추가 (or 자체 구현)

#### Debugger
- [ ] `flutter analyze` → 0 issues

#### Test Engineer
- [ ] `test/holiday/korean_holiday_test.dart` — 음력 변환 + 명절 감지

#### Performance Engineer
- [ ] 명절 감지: 앱 시작 시 1회 (결과 캐싱)

---

### K-2. 디지털 족보 온보딩 (Digital Jokbo Importer)

> 기존 종이/엑셀/PDF 족보를 앱으로 가져오는 간편 온보딩.
> 사진 촬영 → 이름/세대 수동 입력 보조 → 노드 자동 생성. AI OCR 없이 사용자 직접 입력.

#### UX Designer
- [ ] 족보 가져오기 플로우: 사진 촬영 → 세대별 이름 입력 가이드 → 노드 자동 배치
- [ ] 팔고조도(八高祖圖) 시각화 — 부계/모계 양계 트리 모바일 UI

#### Architect
- [ ] 세대별 입력 위자드 (1세대→2세대→...→8세대)
- [ ] 자동 노드 배치 알고리즘 (세대별 x/y 좌표 계산)
- [ ] `JokboImportNotifier` — 위자드 상태 관리

#### Coder
- [ ] `lib/features/jokbo/presentation/jokbo_import_screen.dart` — 위자드 UI
- [ ] `lib/features/jokbo/widgets/generation_input_step.dart` — 세대별 입력
- [ ] `lib/features/jokbo/services/jokbo_layout_service.dart` — 자동 배치 계산
- [ ] 수익화: 프리미엄 (족보 완성 시 PDF/이미지 내보내기, 인쇄용 레이아웃)

#### Debugger
- [ ] `flutter analyze` → 0 issues

#### Test Engineer
- [ ] `test/jokbo/jokbo_layout_test.dart` — 좌표 배치 계산

#### Performance Engineer
- [ ] 다수 노드 일괄 생성: DB batch insert

---

### K-3. 효도 온도계 (Hyo-Do Thermometer)

> 부모님/조부모 노드와의 연락/기록 빈도 → "효도 온도" 수치화.
> 일주일 미연락 시 "따뜻하게 연락해보세요" 넛지.

#### UX Designer
- [ ] 효도 온도 대시보드 (부모/조부모 노드별 온도 게이지)
- [ ] 넛지 알림 UI (부드러운 톤 — "한 주가 지났어요, 안부를 전해보세요")
- [ ] 효도 온도 기반 주간 리포트

#### Architect
- [ ] 효도 온도 계산: 연락 빈도(기억 기록 빈도) + 온도 일기 기록 빈도 종합
- [ ] 앱 내 기록 빈도만 측정 (전화 기록 접근 없음 — 개인정보 안전)
- [ ] `HyodoNotifier` — 온도 계산 + 넛지 알림 트리거

#### Coder
- [ ] `lib/features/hyodo/providers/hyodo_notifier.dart`
- [ ] `lib/features/hyodo/presentation/hyodo_screen.dart` — 대시보드
- [ ] `lib/features/hyodo/widgets/hyodo_gauge.dart` — 온도 게이지 CustomPainter
- [ ] 넛지 로컬 알림 (7일 미기록 감지)
- [ ] 수익화: 프리미엄 (주간 리포트, 효도 리마인더 커스터마이징)

#### Debugger
- [ ] `flutter analyze` → 0 issues

#### Test Engineer
- [ ] `test/hyodo/hyodo_calculation_test.dart` — 온도 계산 로직

#### Performance Engineer
- [ ] 온도 계산: 최근 30일 기록만 조회 (전체 스캔 방지)

---

### K-4. 한국 성씨 클랜 탐색기 (Clan Explorer)

> 본관·성씨 입력 → 씨족 역사/유명 인물/발원지 정보. 정적 JSON 데이터.
> "나는 어느 씨족인가" 공유 카드 — 바이럴 요소.

#### UX Designer
- [ ] 성씨 검색 → 씨족 정보 카드 (본관, 시조, 유명 인물, 인구 통계)
- [ ] "나는 어느 씨족인가" 공유 카드 생성 (RepaintBoundary → 이미지)

#### Architect
- [ ] `assets/data/korean_clans.json` — 120개+ 성씨 데이터 (앱 번들 내)
- [ ] `ClanExplorerNotifier` — 검색 + 필터

#### Coder
- [ ] `lib/features/clan/presentation/clan_explorer_screen.dart`
- [ ] `lib/features/clan/widgets/clan_info_card.dart`
- [ ] `lib/features/clan/widgets/clan_share_card.dart` — 공유 카드 렌더링
- [ ] `assets/data/korean_clans.json` — 성씨 데이터 파일
- [ ] 수익화: 프리미엄 (씨족 상세 역사, 시조 묘소 지도 연동)

#### Debugger
- [ ] `flutter analyze` → 0 issues

#### Test Engineer
- [ ] `test/clan/clan_search_test.dart` — 검색 로직

#### Performance Engineer
- [ ] JSON 파싱: 앱 시작 시 1회 로드 + 메모리 캐싱

---

## Phase 5e — 소셜/공유 & 위젯

> 바이럴 성장 엔진 + 일상 접점 확대

---

### S-2. 초대 링크 가족 합류 (Family Invite Link)

> 6자리 초대 코드 또는 딥링크로 가족 구성원이 동일 트리에 합류.
> 카카오톡 공유 버튼 1탭 → 초대 링크 발송.

#### UX Designer
- [ ] 초대 코드 생성 화면 (6자리 코드 + QR코드)
- [ ] 초대 링크 카카오톡/문자 공유 (share_plus)
- [ ] 초대받은 사람: 앱 설치 → 코드 입력 → 트리 합류

#### Architect
- [ ] 초대 코드: 로컬 생성 (6자리 영숫자) + .rlink 파일에 코드 매핑
- [ ] Firebase Dynamic Links 또는 자체 딥링크 스키마
- [ ] `InviteNotifier` — 초대 생성/수락 플로우

#### Coder
- [ ] `lib/features/invite/providers/invite_notifier.dart`
- [ ] `lib/features/invite/presentation/invite_screen.dart`
- [ ] `lib/features/invite/widgets/invite_code_card.dart`
- [ ] 딥링크 핸들링 (app_router.dart)
- [ ] `pubspec.yaml` — 딥링크 관련 패키지

#### Debugger
- [ ] `flutter analyze` → 0 issues

#### Test Engineer
- [ ] `test/invite/invite_code_test.dart` — 코드 생성/검증

#### Performance Engineer
- [ ] 초대 코드 유효성 검증: 로컬 즉시 처리

---

### S-3. 연말 가족 리뷰 (Annual Family Wrapped)

> 매년 12월 자동 생성 — "올해 우리 가족 이야기" 리뷰.
> 기억 수, 가장 따뜻했던 순간, 새 가족 노드, 꽃다발 수 등 슬라이드쇼.

#### UX Designer
- [ ] Spotify Wrapped 스타일 풀스크린 슬라이드쇼 (5~8장)
- [ ] 공유 가능한 요약 이미지 생성
- [ ] "작년에 우리 가족이 이렇게 많은 기억을 남겼습니다. 내년엔 더 많이 남기세요."

#### Architect
- [ ] `AnnualReviewService` — 연간 데이터 집계 (기억 수/온도 평균/새 노드/꽃 수)
- [ ] 슬라이드 템플릿 정의 (StatCards + BestMoment + FamilyTree + Summary)

#### Coder
- [ ] `lib/features/wrapped/services/annual_review_service.dart`
- [ ] `lib/features/wrapped/presentation/wrapped_screen.dart` — 풀스크린 PageView
- [ ] `lib/features/wrapped/widgets/wrapped_slide.dart` — 슬라이드 위젯
- [ ] 공유 이미지 생성 (RepaintBoundary)
- [ ] 수익화: 프리미엄 (고품질 동영상 리뷰, 여러 해 비교 리뷰)

#### Debugger
- [ ] `flutter analyze` → 0 issues

#### Test Engineer
- [ ] `test/wrapped/annual_review_test.dart` — 데이터 집계 로직

#### Performance Engineer
- [ ] 연간 데이터 집계: 백그라운드 compute (isolate)

---

### S-4. 가족 기억 스냅샷 공유 (Memory Snapshot Share)

> 개별 기억 노드를 아름다운 포스터 형식으로 변환 → SNS 공유.
> "할아버지 이야기 — 1952년 부산 피란 시절" 포스터 자동 적용.

#### UX Designer
- [ ] 포스터 템플릿 4종 (빈티지/모던/감성/미니멀)
- [ ] 포스터에 "Re-Link에서 우리 가족 이야기를 기록하고 있어요" 배너

#### Architect
- [ ] `SnapshotShareService` — 기억 데이터 → 포스터 이미지 변환
- [ ] 기존 `ExportService` 패턴 재사용

#### Coder
- [ ] `lib/features/snapshot/presentation/snapshot_share_screen.dart`
- [ ] `lib/features/snapshot/widgets/poster_template.dart` — 4종 템플릿
- [ ] `lib/features/snapshot/services/snapshot_service.dart`
- [ ] 수익화: 프리미엄 (프리미엄 디자인 템플릿)

#### Debugger
- [ ] `flutter analyze` → 0 issues

#### Test Engineer
- [ ] `test/snapshot/snapshot_service_test.dart`

#### Performance Engineer
- [ ] 포스터 렌더링: UI 스레드 블로킹 방지

---

### W-1. 오늘의 가족 기억 위젯 (Today's Memory Widget)

> iOS/Android 홈 화면 위젯. 오늘 날짜 연관 기억(기념일, 기일, 과거 기록) 표시.
> 소형(사진+날짜) / 중형(사진+제목+이름) / 대형(사진+전체 내용 미리보기) 3종.

#### UX Designer
- [ ] 위젯 3종 크기별 레이아웃 설계
- [ ] 위젯 탭 → 앱 내 해당 기억 화면 딥링크

#### Architect
- [ ] `home_widget` 패키지 — iOS WidgetKit / Android AppWidget
- [ ] 위젯 데이터 갱신: 앱 포그라운드 진입 시 + 기억 CRUD 시
- [ ] SharedPreferences/UserDefaults로 위젯 데이터 공유

#### Coder
- [ ] `pubspec.yaml` — `home_widget` 패키지 추가
- [ ] `lib/core/services/widget/home_widget_service.dart`
- [ ] iOS WidgetKit Swift 코드 (소형/중형/대형)
- [ ] Android AppWidget Kotlin 코드
- [ ] 기억 CRUD 시 위젯 데이터 갱신 트리거
- [ ] 수익화: 프리미엄 (위젯 사용 = 프리미엄 기능)

#### Debugger
- [ ] `flutter analyze` → 0 issues

#### Test Engineer
- [ ] `test/widget/home_widget_service_test.dart`

#### Performance Engineer
- [ ] 위젯 데이터 갱신: 최소 필요 데이터만 공유 (이미지 경로 + 텍스트)

---

### W-2. 가족 생일 카운트다운 위젯 (Birthday Countdown Widget)

> 다음 가족 생일까지 D-Day 위젯. 생일 당일 특별 테마.
> iOS Live Activity (iOS 16+) 활용 시 잠금 화면 카운트다운.

#### UX Designer
- [ ] D-Day 위젯 디자인 (노드 사진 + 이름 + D-일수)
- [ ] 생일 당일: 축하 특별 테마 + "OOO의 생일입니다" 알림

#### Architect
- [ ] 생일 노드 필터링 (birthDate 기준 다음 생일 계산)
- [ ] 로컬 알림 스케줄링 (생일 당일 아침)

#### Coder
- [ ] `lib/features/birthday/providers/birthday_notifier.dart`
- [ ] `lib/features/birthday/widgets/birthday_countdown_widget.dart`
- [ ] 홈 위젯 연동 (home_widget)
- [ ] 생일 로컬 알림
- [ ] 수익화: 프리미엄 (음력 생일 지원, 생일 카드 자동 생성)

#### Debugger
- [ ] `flutter analyze` → 0 issues

#### Test Engineer
- [ ] `test/birthday/birthday_countdown_test.dart` — D-Day 계산 로직

#### Performance Engineer
- [ ] 생일 계산: 앱 시작 시 1회 (결과 캐싱)

---

## Phase 5f — 고급 기능

> 개발 기간 길지만 차별화 효과 높은 기능

---

### E-3. 가족 레시피 북 (Family Recipe Book)

> 특정 가족 노드와 연결된 음식 레시피 카드. "할머니표 된장찌개" 기록.
> 이미지 + 텍스트 + 노드 연결 데이터만 필요. 구현 매우 단순.

#### UX Designer
- [ ] 레시피 카드 UI (음식 사진 + 재료 + 조리법 + 연결 노드)
- [ ] 레시피 목록 (노드별 필터)
- [ ] 레시피 SNS 공유 (포스터 형식)

#### Architect
- [ ] `recipes` 테이블 (id, title, ingredients, instructions, photoPath, nodeId, createdAt)
- [ ] `RecipeRepository` — CRUD

#### Coder
- [ ] DB 테이블 + Repository + Notifier
- [ ] `lib/features/recipe/presentation/recipe_list_screen.dart`
- [ ] `lib/features/recipe/presentation/recipe_detail_screen.dart`
- [ ] `lib/features/recipe/widgets/add_recipe_sheet.dart`
- [ ] 수익화: 프리미엄 (레시피 북 PDF 인쇄용 내보내기)

#### Debugger
- [ ] `flutter analyze` → 0 issues

#### Test Engineer
- [ ] `test/recipe/recipe_repository_test.dart`

#### Performance Engineer
- [ ] 레시피 사진 썸네일 캐싱

---

### E-4. 보이스 유언 (Voice Legacy)

> 특정 가족 구성원에게 남기는 음성 메시지. 특정 조건(생일, 결혼식 등)에 공개.
> 기존 음성 캡슐 인프라 확장.

#### UX Designer
- [ ] 보이스 유언 녹음 플로우 (수신자 선택 → 조건 설정 → 녹음 → 봉인)
- [ ] 수신자별 유언 목록 (잠금 상태)
- [ ] 공개 조건: 날짜 / 이벤트(생일·결혼식) / 수동 공개

#### Architect
- [ ] `voice_legacy` 테이블 (id, fromNodeId, toNodeId, voicePath, openCondition, openDate, isOpened)
- [ ] `VoiceLegacyNotifier` — 녹음/봉인/공개 플로우

#### Coder
- [ ] DB 테이블 + Repository + Notifier
- [ ] `lib/features/voice_legacy/presentation/voice_legacy_screen.dart`
- [ ] `lib/features/voice_legacy/widgets/record_legacy_sheet.dart`
- [ ] 기존 RecorderController/PlayerController 재사용
- [ ] 공개 조건 로컬 알림 스케줄링

#### Debugger
- [ ] `flutter analyze` → 0 issues

#### Test Engineer
- [ ] `test/voice_legacy/voice_legacy_test.dart`

#### Performance Engineer
- [ ] 음성 파일 Opus 24kbps 압축 (기존 방식 유지)

---

### E-5. 가족 지도 (Family Map)

> 가족 구성원이 살았던 장소를 지도 위에 핀으로 시각화.
> Time Slider 연동 시 "1960년대 경상도 → 1980년대 서울 → 2000년대 캐나다" 경로 애니메이션.

#### UX Designer
- [ ] 지도 화면 + 가족 핀 (노드 아바타 마커)
- [ ] Time Slider 연동 → 연도별 이동 경로 애니메이션
- [ ] 핀 탭 → 해당 노드 상세

#### Architect
- [ ] `node_locations` 테이블 (nodeId, latitude, longitude, address, startYear, endYear)
- [ ] `flutter_map` + OpenStreetMap 타일 (Google Maps API 비용 없음)
- [ ] `FamilyMapNotifier` — 지도 데이터 + 필터

#### Coder
- [ ] `pubspec.yaml` — `flutter_map`, `latlong2` 패키지 추가
- [ ] `lib/features/family_map/presentation/family_map_screen.dart`
- [ ] `lib/features/family_map/widgets/family_pin_marker.dart`
- [ ] `lib/features/family_map/widgets/route_animation.dart` — 경로 애니메이션
- [ ] 5탭 네비게이션에 지도 탭 추가 or 설정에서 진입
- [ ] 수익화: 프리미엄 (지도 이미지 고해상도 내보내기, 가족 이동 경로 영상)

#### Debugger
- [ ] `flutter analyze` → 0 issues

#### Test Engineer
- [ ] `test/family_map/location_repository_test.dart`

#### Performance Engineer
- [ ] 지도 타일 캐싱 (오프라인 사용 대비)
- [ ] 마커 클러스터링 (노드 많을 때)

---

## Phase 5g — 인프라 & 전략 (상시 적용)

> 개발 과정에서 지속적으로 반영할 전략적 항목

---

### I-1. 완전한 프라이버시 선언 (Privacy-First Architecture)

- [ ] 앱스토어 설명에 프라이버시 선언 반영
- [ ] 랜딩페이지/SNS 바이오에 반영
- [ ] "Re-Link는 당신의 가족 데이터를 팔지 않습니다. 광고 타겟팅·AI 학습에 사용하지 않습니다."

---

### I-3. 사용자 피드백 즉시 반영 채널 (Open Dev Log)

- [ ] 앱 내 "개발자에게 직접 제안" 버튼 (메일 or 폼)
- [ ] 오픈 로드맵 공개 (Notion Public 또는 Linear)
- [ ] 크레딧에 사용자 아이디어 반영 시 이름 등재

---

### I-4. 오프라인 퍼스트 아키텍처 (Offline-First Architecture)

- [x] v1.0에서 이미 달성 (Drift SQLite + 로컬 파일 시스템)
- [ ] v2.0 모든 신규 기능에서 오프라인 퍼스트 원칙 유지 확인
- [ ] 인터넷 없이 모든 기능 완전 작동 검증

---

## v2.0 개발 우선순위 요약

| 순위 | Phase | 기능 | 예상 기간 | 우선도 |
|------|-------|------|-----------|--------|
| 1 | 5a | E-2. 온도 일기 | 1.5주 | 🔴 최우선 |
| 2 | 5a | G-2. 기억 스트릭 | 1주 | 🔴 최우선 |
| 3 | 5a | W-3. 오늘의 가족 질문 알림 | 1주 | 🔴 최우선 |
| 4 | 5a | E-6. 추억 꽃다발 | 1주 | 🔴 최우선 |
| 5 | 5a | S-1. 가족 트리 아트 카드 | 2주 | 🔴 최우선 |
| 6 | 5b | E-1. 기억 캡슐 | 2주 | 🟠 높음 |
| 7 | 5b | E-7. 마지막 페이지 | 2주 | 🟠 높음 |
| 8 | 5b | K-5. 가족 단어장 | 1.5주 | 🟠 높음 |
| 9 | 5c | G-1. 가족 나무 성장 | 2주 | 🟠 높음 |
| 10 | 5c | G-3. 세대 탐험가 배지 | 1.5주 | 🟡 중간 |
| 11 | 5c | G-4. 가족 챌린지 | 2주 | 🟡 중간 |
| 12 | 5d | K-1. 스마트 명절 허브 | 2주 | 🟠 높음 |
| 13 | 5d | K-2. 디지털 족보 온보딩 | 3주 | 🟡 중간 |
| 14 | 5d | K-3. 효도 온도계 | 2주 | 🟡 중간 |
| 15 | 5d | K-4. 성씨 클랜 탐색기 | 1.5주 | 🟡 중간 |
| 16 | 5e | S-2. 초대 링크 가족 합류 | 2주 | 🟠 높음 |
| 17 | 5e | S-3. 연말 가족 리뷰 | 2주 | 🟡 중간 |
| 18 | 5e | S-4. 기억 스냅샷 공유 | 2주 | 🟡 중간 |
| 19 | 5e | W-1. 오늘의 가족 기억 위젯 | 3주 | 🟠 높음 |
| 20 | 5e | W-2. 생일 카운트다운 위젯 | 1.5주 | 🟡 중간 |
| 21 | 5f | E-3. 가족 레시피 북 | 1.5주 | 🟢 보통 |
| 22 | 5f | E-4. 보이스 유언 | 2주 | 🟢 보통 |
| 23 | 5f | E-5. 가족 지도 | 3주 | 🟢 보통 |

---

## 진행 현황 요약

| Phase | 진행율 | 상태 |
|-------|--------|------|
| Phase 0 초기화 | 100% | ✅ 완료 |
| Phase 1 MVP | 100% | ✅ 완료 (Week 7–8 완료) |
| Phase 2 확장 | 90% | ✅ 완료 (복원 감지 화면 향후) |
| Phase 3 폴리시 | 80% | ✅ 완료 (히스토리/자동Ghost Phase 4 이동) |
| Phase 4a 화면 완성 | 100% | ✅ 완료 (Ghost자동생성/FamilyInvite/모든화면 완료) |
| Phase 4b 캔버스 최적화 | 100% | ✅ 완료 (QuadTree/LOD/HeroTransition/MemoryHero/Pseudo3D) |
| Phase 4c 디자인 & 품질 | 95% | ✅ 완료 (Glassmorphism2.0/ElderlyMode/Accessibility/Semantics) |
| Phase 4d 성능 & 테스트 | 80% | ✅ 완료 (패키지 정리/QuadTree캐싱/통합테스트, DevTools는 실디바이스) |
| Phase 4e 런치 준비 | 40% | 🔄 진행 중 (Android12스플래시/이용약관/Info.plist완료, TestFlight/스크린샷 대기) |
| Phase 4f UX 고도화 | 100% | ✅ 완료 (Spring/Haptic/VoiceSpeed/FocusPanel/GhostAnim/VibeMeter/MergePreview) |
| Phase 4g 실기기 테스트 | 80% | ✅ 버그 수정 + 실기기 설치 완료, 플로우 검증 진행 |
| Phase 4h 디자인 문서 반영 | 100% | ✅ 완료 (색상/타이포/글래스/반경/모션 전면 교체) |
| Phase 4i 화면별 UX 설계 | 100% | ✅ 완료 (온보딩/노드상세/TimeSlider토스트/Ghost 모두 완료) |
| Phase 4j 라이트모드 & 관계선 | 95% | ✅ 완료 (라이트모드/엣지관리/부부스냅/돌아가신분 — 빌드/실기기 잔여) |
| **전체 테스트** | **431/431** | ✅ 전체 통과 (22개 신규 추가) |
| **커버리지** | **81.1%+** | ✅ 목표 80% 달성 |

### v2.0 진행 현황

| Phase | 기능 수 | 상태 |
|-------|---------|------|
| Phase 5a v2.0 MVP 킬러 피처 | 5개 | ⏳ 계획 완료, v1.0 런치 후 착수 |
| Phase 5b 감성 기능 확장 | 3개 | ⏳ 계획 완료 |
| Phase 5c 게이미피케이션 엔진 | 3개 | ⏳ 계획 완료 |
| Phase 5d 한국 시장 특화 | 4개 | ⏳ 계획 완료 |
| Phase 5e 소셜/공유 & 위젯 | 5개 | ⏳ 계획 완료 |
| Phase 5f 고급 기능 | 3개 | ⏳ 계획 완료 |
| Phase 5g 인프라 & 전략 | 3개 | ⏳ 상시 적용 |
| **v2.0 전체** | **26개 기능** | ⏳ v1.0 런치 후 순차 착수 |
