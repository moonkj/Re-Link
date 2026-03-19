# Re-Link 개발 진행 현황

> 마지막 업데이트: 2026-03-19
> 현재 단계: Phase 0 — 프로젝트 초기화

---

## Phase 0 — 프로젝트 초기화

### 환경 설정
- [x] Flutter 3.41.2 설치 확인
- [x] Flutter 프로젝트 생성 (`flutter create . --org com.relink`)
- [x] `CLAUDE.md` 작성
- [x] `process.md` 작성 (이 파일)
- [x] Memory 시스템 구성 (MEMORY.md + 6개 메모리 파일)
- [ ] `.gitignore` 업데이트
- [ ] Git 저장소 초기화 (`git init`)
- [ ] `pubspec.yaml` 의존성 전체 업데이트
- [ ] `flutter pub get` 실행
- [ ] `lib/` 폴더 구조 생성

### 디자인 토큰 파일
- [ ] `lib/design/tokens/app_colors.dart`
- [ ] `lib/design/tokens/app_typography.dart`
- [ ] `lib/design/tokens/app_spacing.dart`
- [ ] `lib/design/tokens/app_radius.dart`
- [ ] `lib/design/tokens/app_shadows.dart`
- [ ] `lib/design/glass/app_glass.dart`
- [ ] `lib/design/motion/app_motion.dart`
- [ ] `lib/design/tokens/app_theme.dart`

### 핵심 설정 파일
- [ ] `lib/core/config/supabase_config.dart`
- [ ] `lib/core/config/env_config.dart`
- [ ] `lib/core/router/app_router.dart`
- [ ] `lib/app.dart`
- [ ] `lib/main.dart` (Supabase 초기화 포함)

---

## Phase 1 — MVP (Week 1–8)

### Week 1–2: Auth + 기본 구조

#### UX Designer
- [ ] 온보딩 화면 흐름 설계
- [ ] 로그인/회원가입 화면 와이어프레임
- [ ] 하단 네비게이션 구조 정의

#### Architect
- [ ] Auth 상태 관리 구조 설계 (Riverpod)
- [ ] go_router 라우트 맵 설계
- [ ] Supabase 테이블 스키마 v1 작성

#### Coder
- [ ] Supabase Auth 초기화
- [ ] Kakao OAuth 연동
- [ ] `AuthNotifier` (Riverpod)
- [ ] 로그인 화면 UI
- [ ] 온보딩 화면 UI
- [ ] `profiles` 테이블 연동 (upsert)

#### Debugger
- [ ] Auth 플로우 에러 처리
- [ ] 토큰 만료 처리
- [ ] `mounted` 체크 추가

#### Reviewer
- [ ] RLS 정책 확인
- [ ] 보안 취약점 검토

---

### Week 3–4: 무한 캔버스 + 노드 시스템

#### UX Designer
- [ ] 캔버스 화면 인터랙션 설계
- [ ] 노드 추가/편집 바텀시트 설계
- [ ] Ghost Node 시각 표현 가이드

#### Architect
- [ ] `nodes` 테이블 스키마
- [ ] `node_edges` 테이블 스키마 (Adjacency List)
- [ ] `NodeRepository` 인터페이스 설계
- [ ] 캔버스 상태 관리 설계

#### Coder
- [ ] `genealogy_chart` 또는 `infinite_canvas` 통합
- [ ] 노드 기본 렌더링 (인물 카드)
- [ ] Ghost Node 렌더링 (점선, 반투명)
- [ ] 노드 드래그 & 이동
- [ ] 노드 탭 → 상세 바텀시트
- [ ] 노드 추가 버튼 + 폼
- [ ] `NodeRepository` 구현
- [ ] `NodeNotifier` (Riverpod)
- [ ] Supabase CRUD 연동

#### Debugger
- [ ] 캔버스 성능 이슈 확인
- [ ] 노드 중복 렌더링 방지
- [ ] 에러 상태 처리

#### Performance Engineer
- [ ] `RepaintBoundary` 적용
- [ ] 노드 수 제한별 렌더 성능 측정

---

### Week 5–6: 기억 저장 (사진/메모)

#### UX Designer
- [ ] 기억 추가 화면 흐름
- [ ] 사진 갤러리 뷰 설계
- [ ] 메모 에디터 설계

#### Architect
- [ ] `memories` 테이블 스키마
- [ ] Supabase Storage 버킷 구조
- [ ] `MemoryRepository` 설계

#### Coder
- [ ] 사진 선택 (`image_picker`)
- [ ] 이미지 압축 (`flutter_image_compress`)
- [ ] Supabase Storage 업로드
- [ ] `cached_network_image` 적용
- [ ] 메모 작성 + 저장
- [ ] 기억 리스트 UI (노드별)
- [ ] `MemoryNotifier` (Riverpod)

#### Debugger
- [ ] 대용량 이미지 처리
- [ ] 업로드 실패 재시도 로직

#### Reviewer
- [ ] Storage RLS 정책 확인
- [ ] 파일 용량 제한 로직 (플랜별)

---

### Week 7–8: 플랜 시스템 + AdMob 기초

#### UX Designer
- [ ] 플랜 선택/구매 화면 설계
- [ ] 기능 제한 안내 UI (업그레이드 유도)
- [ ] 광고 위치 설계 (배너/네이티브)

#### Architect
- [ ] `purchases` 테이블 스키마
- [ ] 플랜별 제한 로직 설계
- [ ] `PlanNotifier` 구조 설계

#### Coder
- [ ] `in_app_purchase` 초기화
- [ ] 상품 목록 조회 (BASIC ₩4,900, PREMIUM ₩14,900)
- [ ] 구매 플로우 구현
- [ ] 구매 복원 기능
- [ ] `PlanGuard` (기능 제한 체크)
- [ ] AdMob 배너 광고 통합
- [ ] AdMob 네이티브 광고 통합
- [ ] Premium 광고 제거 로직

#### Debugger
- [ ] 구매 영수증 검증
- [ ] 광고 로드 실패 처리

#### Reviewer
- [ ] 앱스토어 인앱 구매 가이드라인 준수
- [ ] 구글 플레이 정책 검토

#### Performance Engineer
- [ ] MVP 빌드 크기 측정
- [ ] 초기 로딩 시간 측정

---

## Phase 2 — 확장 (Week 9–20)

### Week 9–11: AI 채팅 → 노드 생성

- [ ] OpenAI GPT-4.1-mini Supabase Edge Function 배포
- [ ] AI 채팅 화면 UI
- [ ] 대화 기반 노드 자동 생성
- [ ] AI 토큰 사용량 추적 (플랜별 제한)
- [ ] 오프라인 시 AI 기능 비활성화 안내

### Week 12–14: 음성 캡슐

- [ ] `record` 패키지 통합 (Opus 24kbps)
- [ ] `audio_waveforms` 파형 시각화
- [ ] 녹음 화면 UI
- [ ] 음성 파일 Supabase Storage 업로드
- [ ] 음성 재생 UI
- [ ] 녹음 시간 제한 (플랜별: 30분/300분)

### Week 15–17: 가족 공간

- [ ] `families` 테이블 + RLS
- [ ] `family_members` 테이블 + 초대 시스템
- [ ] 초대 링크 생성/공유
- [ ] Supabase Realtime 동기화
- [ ] 가족 공간 전환 UI
- [ ] 멤버 권한 관리 (owner/editor/viewer)

### Week 18–20: 오프라인 동기화

- [ ] Hive CE 캐시 레이어 구성
- [ ] 오프라인 큐 (Pending operations)
- [ ] 네트워크 복구 시 자동 동기화
- [ ] 충돌 해결 전략 구현
- [ ] `connectivity_plus` 상태 표시

---

## Phase 3 — 폴리시 (Week 21–28)

### 온도계 시스템 (Vibe Meter)

- [ ] 6단계 온도 레벨 정의 (Icy → Fire)
- [ ] 노드별 온도 수동 설정 UI
- [ ] 상호작용 기반 자동 온도 계산
- [ ] 온도 시각화 (노드 테두리 색상)
- [ ] 온도 히스토리 기록

### Ghost Node 완성

- [ ] Ghost Node 자동 감지 (부모 없는 조상)
- [ ] Ghost Node 연결 제안 AI
- [ ] 실제 인물 매핑 플로우

### 검색 + 필터

- [ ] 전체 텍스트 검색 (Supabase Full-text)
- [ ] 날짜 필터
- [ ] 태그 시스템
- [ ] 검색 결과 화면

### 설정 화면

- [ ] 프로필 편집
- [ ] 알림 설정
- [ ] 데이터 내보내기 (JSON)
- [ ] 계정 삭제
- [ ] 언어 설정

---

## Phase 4 — 런치 (Week 29–34)

### 앱스토어 준비

- [ ] 앱 아이콘 최종 제작
- [ ] 스플래시 화면
- [ ] 스크린샷 제작 (6.5인치, 5.5인치, 태블릿)
- [ ] 앱 설명 작성 (한국어/영어)
- [ ] 개인정보처리방침 페이지
- [ ] 이용약관 페이지

### 성능 최적화

- [ ] Flutter DevTools 프로파일링
- [ ] 메모리 누수 점검
- [ ] 앱 크기 최적화 (목표: iOS < 50MB, Android < 30MB)
- [ ] 콜드 스타트 시간 최적화 (목표: < 2초)
- [ ] 캔버스 60fps 렌더링 확인

### 출시

- [ ] TestFlight 베타 배포
- [ ] Google Play 내부 테스트
- [ ] 버그 수집 및 수정
- [ ] App Store Connect 심사 제출
- [ ] Google Play Console 심사 제출
- [ ] 출시 🎉

---

## 현재 진행 상황 요약

| Phase | 진행율 | 상태 |
|-------|--------|------|
| Phase 0 초기화 | 45% | 🔄 진행 중 |
| Phase 1 MVP | 0% | ⏳ 대기 |
| Phase 2 확장 | 0% | ⏳ 대기 |
| Phase 3 폴리시 | 0% | ⏳ 대기 |
| Phase 4 런치 | 0% | ⏳ 대기 |
