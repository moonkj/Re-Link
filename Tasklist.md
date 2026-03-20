# Tasklist — 미구현 기능 구현 (2026-03-21)

> 모드: 에이전트 팀 병렬 실행 (팀리더 + 4 Teammates)
> 런치 준비(Phase 4e)는 제외 — 코드 구현 가능 항목만

---

## Batch 1 — ✅ 완료

### Teammate1 — Privacy Layer (생체인증) ✅
- [x] `lib/core/services/privacy/privacy_service.dart` — local_auth 래퍼
- [x] `lib/shared/widgets/private_blur_overlay.dart` — 공통 블러 위젯
- [x] Settings Privacy 토글 → 실제 local_auth 연동
- [x] isPrivate 기억 블러 처리 (MemoryScreen/StoryFeed/Archive)
- [x] 기억 상세 접근 시 생체인증 게이팅 (MemoryDetailSheet)
- [x] flutter analyze → 0 errors

### Teammate2 — 로컬 알림 시스템 ✅
- [x] `lib/core/services/notification/notification_service.dart` — 통합 알림 서비스 (382줄)
- [x] main.dart — 알림 초기화
- [x] Daily Prompt 매일 아침 8시 알림 연동
- [x] 기억 캡슐 열림 날짜 알림
- [x] 생일 카운트다운 D-Day + D-1 알림
- [x] 효도 7일 넛지 (주간 일요일 10시)
- [x] 보이스 유언 공개 조건 알림
- [x] 마지막 페이지 기일 매년 반복 알림
- [x] 온보딩 Step 3 알림 권한 요청 + 셀레브레이션 UI
- [x] flutter analyze → 0 errors

### Teammate3 — 감성 기능 UI 완성 ✅
- [x] 기억 캡슐 봉인 애니메이션 (`seal_animation.dart`, 333줄)
- [x] 추모 슬라이드쇼 (`memorial_slideshow.dart`, 327줄)
- [x] 음력 기일 계산 로직 (`lunar_calendar.dart`, 2024-2035 정적 테이블)
- [x] 가족 단어장 음성 녹음 연동 (RecorderController + PlayerController)
- [x] 복원 감지 화면 (`restore_detect_screen.dart`)
- [x] flutter analyze → 0 errors

### Teammate4 — 캔버스/공유/게이미피케이션 완성 ✅
- [x] 나무 성장 SNS 공유 카드 (`tree_share_card.dart`, 302줄)
- [x] 배지 캔버스 노드 아이콘 표시 (_BadgeIcon, Detail/Zoom LOD만)
- [x] 명절 허브 조상 노드 하이라이트 (glow, computeHolidayGlowNodeIds)
- [x] 효도 온도계 주간 리포트 (HyodoWeeklyReport + 7일 막대 그래프)
- [x] 레시피 SNS 공유 (share_plus 텍스트)
- [x] 초대 딥링크 핸들링 (relink://invite/{code} + iOS/Android 설정)
- [x] flutter analyze → 0 errors

---

## 검증 결과 (Batch 1 + 2 통합)
- flutter analyze: **0 errors** (33 info/warning 기존)
- flutter test: **809/809 전체 통과**
- 신규 테스트: 352개 (13파일 + lunar_calendar)

---

## Batch 2 — 테스트 일괄 ✅ 완료 (352개 신규 테스트)

| 파일 | 테스트 수 |
|------|----------|
| capsule_repository_test | 15 |
| capsule_open_logic_test | 12 |
| memorial_repository_test | 14 |
| glossary_repository_test | 26 |
| tree_growth_test | 37 |
| badge_condition_test | 32 |
| jokbo_layout_test | 17 |
| hyodo_calculation_test | 45 |
| clan_search_test | 26 |
| invite_code_test | 24 |
| wrapped_annual_review_test | 15 |
| snapshot_service_test | 15 |
| recipe_repository_test | 15 |
| voice_legacy_test | 22 |
| lunar_calendar_test | 37 |
