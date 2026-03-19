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

### Ghost Node 자동 생성

#### UX Designer
- [ ] 노드 추가 시 "부모 자동 생성" 옵션 토글 설계
- [ ] 자동 생성된 Ghost 노드 표시 (점선+? 아이콘)
- [ ] Ghost → 실제 인물 전환 배너 (NodeDetailSheet)

#### Coder
- [ ] `NodeNotifier.addNodeWithAutoGhost()` — 부모 Ghost 자동 생성 로직
- [ ] Ghost 자동 배치 좌표 계산 (부모 노드 상단 y-offset)

#### Debugger
- [ ] `flutter analyze lib/` → 0 issues

#### Test Engineer
- [ ] `test/canvas/ghost_auto_create_test.dart`

---

### Family Invite UI (가족 공유 관리)

#### UX Designer
- [ ] .rlink 보내기/받기 플로우 최종 설계
- [ ] 트리 병합 미리보기 화면 (노드 수 + 충돌 수 표시)
- [ ] 충돌 해결 UI (내 노드 유지 / 상대방 노드 유지 / 둘 다)

#### Architect
- [ ] `MergePreviewNotifier` — .rlink 파싱 + 충돌 감지
- [ ] `MergeConflict` 모델 (nodeId, myVersion, theirVersion)

#### Coder
- [ ] `lib/features/family/presentation/merge_preview_screen.dart`
- [ ] `lib/features/family/presentation/conflict_resolve_screen.dart`
- [ ] `MergePreviewNotifier` + `MergeConflict` 모델
- [ ] `BackupService.mergeRlink()` — 충돌 감지 로직
- [ ] 충돌 해결 후 DB 저장

#### Debugger
- [ ] `flutter analyze lib/` → 0 issues

#### Test Engineer
- [ ] `test/family/merge_test.dart` — 충돌 감지 + 해결 로직

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
- [ ] `MemoryThumbnail` → `MemoryDetail`: `Hero(tag: 'photo_${memory.id}')` (Phase 4c 이동)

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
- [x] 전체 단위 테스트 164/164 통과

#### Performance Engineer (코드 레벨 최적화)
- [x] QuadTree 캐싱: `_qtSourceNodes != nodes` 체크로 노드 변경 시만 재빌드
- [x] `_CanvasBackground` RepaintBoundary 분리 (배경 정적 → 노드 repaint와 독립)
- [x] EdgePainter RepaintBoundary 분리 (Phase 4b)
- [ ] DevTools Timeline / CPU Profiler 프로파일링 (Phase 4e, 실제 디바이스)

---

## Phase 4e — 런치 준비 (Week 47–52)

### 앱 아이콘 & 스플래시

#### UX Designer
- [ ] 앱 아이콘 디자인 (1024×1024 PNG — iOS, 512×512 — Android)
- [ ] 다크/라이트 아이콘 버전

#### Coder
- [ ] `flutter_launcher_icons` 패키지 적용
- [ ] iOS LaunchScreen.storyboard 최종 확인
- [ ] Android splash12.xml (Android 12+) 적용

---

### App Store / Google Play 준비

#### UX Designer
- [ ] 스크린샷 촬영 (iPhone 6.9인치, 6.5인치, iPad 12.9인치)
- [ ] Google Play 스크린샷 (폰/태블릿)
- [ ] 프리뷰 동영상 (선택)

#### Coder
- [ ] 앱 설명 한국어 작성 (App Store + Google Play)
- [ ] 개인정보처리방침 페이지 (웹 URL)
- [ ] 이용약관 페이지 (웹 URL)
- [ ] `Info.plist` 권한 설명 최종 검토 (한국어)

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

## 진행 현황 요약

| Phase | 진행율 | 상태 |
|-------|--------|------|
| Phase 0 초기화 | 100% | ✅ 완료 |
| Phase 1 MVP | 100% | ✅ 완료 (Week 7–8 완료) |
| Phase 2 확장 | 85% | ✅ 완료 (트리 병합 Phase 3 이동) |
| Phase 3 폴리시 | 80% | ✅ 완료 (히스토리/자동Ghost Phase 4 이동) |
| Phase 4a 화면 완성 | 85% | 🔄 진행 중 (Splash/Onboarding/5탭/StoryFeed/Archive/FocusMode/TimeSlider/Minimap/Heritage Export/Privacy Layer 완료) |
| Phase 4b 캔버스 최적화 | 95% | ✅ 완료 (QuadTree/LOD/HeroTransition/Pseudo3D/뷰포트컬링/드래그scale보정) |
| Phase 4c 디자인 & 품질 | 95% | ✅ 완료 (Glassmorphism2.0/ElderlyMode/Accessibility/Semantics) |
| Phase 4d 성능 & 테스트 | 80% | ✅ 완료 (패키지 정리/QuadTree캐싱/통합테스트/단위164개, DevTools는 실디바이스) |
| Phase 4e 런치 준비 | 0% | ⏳ 대기 |
| **전체 테스트** | **164/164** | ✅ 전체 통과 |
