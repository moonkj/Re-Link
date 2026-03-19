# Re-Link 개발 진행 현황

> 마지막 업데이트: 2026-03-19
> 현재 단계: Phase 1 MVP 시작 대기

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

---

## Phase 1 — MVP (Week 1–8)

### Week 1–2: 프로필 + 기본 구조

#### Coder
- [ ] 프로필 설정 화면 완성 (사진, 이름, 저장)
- [ ] 복원 감지 화면 (재설치 시 백업 발견)
- [ ] 프로필 편집 화면
- [ ] 하단 네비게이션 완성

---

### Week 3–4: 무한 캔버스 + 노드 CRUD

#### UX Designer
- [ ] 캔버스 인터랙션 설계
- [ ] 노드 추가/편집 바텀시트 설계
- [ ] Ghost Node 시각 가이드

#### Coder
- [ ] `genealogy_chart` 또는 `infinite_canvas` 통합
- [ ] 노드 기본 렌더링 (인물 카드)
- [ ] Ghost Node 렌더링 (점선, 반투명)
- [ ] 노드 드래그 & 위치 저장 (Drift 동기화)
- [ ] 노드 탭 → 상세 바텀시트
- [ ] 노드 추가 폼 (이름, 사진, 생년월일)
- [ ] 노드 편집 / 삭제
- [ ] 관계(Edge) 연결 UI
- [ ] `NodeNotifier` (Riverpod)

---

### Week 5–6: 기억 저장 (사진 / 음성 / 메모)

#### Coder
- [ ] 기억 추가 화면 (타입 선택: 사진/음성/메모)
- [ ] 사진 선택 → WebP 압축 → 로컬 저장
- [ ] 사진 갤러리 뷰 (노드별)
- [ ] 메모 작성 + 저장
- [ ] 음성 녹음 (`record` 패키지, Opus 24kbps)
- [ ] 음성 파형 시각화 (`audio_waveforms`)
- [ ] 음성 재생 UI
- [ ] 기억 리스트 (노드 상세 화면)
- [ ] 기억 삭제 (파일 + DB 동시 삭제)
- [ ] `MemoryRepository` + `MemoryNotifier`

---

### Week 7–8: 플랜 시스템 + AdMob

#### Coder
- [ ] `in_app_purchase` 초기화
- [ ] 상품 목록 조회 (BASIC ₩4,900, PREMIUM ₩14,900)
- [ ] 구매 플로우
- [ ] 구매 복원
- [ ] `PlanGuard` (노드/사진/음성 제한 체크)
- [ ] AdMob 배너 광고 (Free/Basic)
- [ ] AdMob 네이티브 광고 (Free/Basic)
- [ ] Premium 광고 제거

---

## Phase 2 — 확장 (Week 9–20)

### 클라우드 백업 연동
- [ ] iOS iCloud Drive 실제 업로드/다운로드
- [ ] Android Google Drive 실제 업로드/다운로드
- [ ] 자동 백업 스케줄 (백그라운드)
- [ ] 백업 목록 조회 + 선택 복원
- [ ] 오래된 백업 자동 삭제 (최대 5개)

### 가족 공유
- [ ] .rlink 파일 내보내기 (OS 공유시트)
- [ ] .rlink 파일 가져오기 (파일 앱 / 공유 수신)
- [ ] 트리 병합 미리보기 화면
- [ ] 충돌 해결 UI (같은 이름 노드)

### 음성 캡슐 고도화
- [ ] 녹음 시간 제한 (플랜별: 30분/300분)
- [ ] 음성 목록 관리
- [ ] 음성 파일 정리 (용량 표시)

---

## Phase 3 — 폴리시 (Week 21–28)

### 온도계 시스템 (Vibe Meter)
- [ ] 노드별 온도 설정 UI (6단계)
- [ ] 온도에 따른 노드 테두리 색상
- [ ] 온도 히스토리

### Ghost Node
- [ ] Ghost Node 자동 생성 (부모 없는 조상)
- [ ] 실제 인물 매핑 플로우

### 검색
- [ ] 노드 이름/태그 검색
- [ ] 기억 텍스트 검색

### 설정 화면
- [ ] 프로필 편집
- [ ] 백업 설정 (자동/수동, 주기)
- [ ] 데이터 내보내기 (JSON)
- [ ] 앱 정보 / 버전

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
- [ ] 콜드 스타트 < 2초
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
| Phase 1 MVP | 5% | 🔄 진행 중 |
| Phase 2 확장 | 0% | ⏳ 대기 |
| Phase 3 폴리시 | 0% | ⏳ 대기 |
| Phase 4 런치 | 0% | ⏳ 대기 |
