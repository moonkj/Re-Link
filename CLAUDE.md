# Re-Link — CLAUDE.md

## 프로젝트 개요
**Re-Link**는 가족 기억 저장소 앱입니다. 노드 기반 가족 트리를 통해 사진, 음성, 메모를 저장합니다.

- **플랫폼**: iOS / Android (Flutter 3.41.2)
- **패키지명**: com.relink
- **Dart SDK**: ≥ 3.11.0
- **아키텍처**: 로컬 퍼스트 — 서버 없음, 기기 저장 + iCloud/Google Drive 백업

---

## 필수 워크플로우 — 7단계 (모든 작업 필수)

> **모든 기능 개발, 버그 수정, 리팩토링 시 아래 7단계를 반드시 순서대로 수행한다.**

| 단계 | 역할 | 수행 내용 |
|------|------|-----------|
| 1 | **UX Designer** | 사용자 흐름, 화면 구조, 인터랙션 설계 |
| 2 | **Architect** | 파일 구조, 상태 관리, 데이터 모델 설계 |
| 3 | **Coder** | 실제 코드 구현 (완전 실행 가능한 코드) |
| 4 | **Debugger** | 컴파일 에러, 로직 오류 검토 및 수정 |
| 5 | **Test Engineer** | 단위/통합 테스트 (선택, 중요 기능 필수) |
| 6 | **Reviewer** | 코드 품질, 보안, Flutter 베스트 프랙티스 검토 |
| 7 | **Performance Engineer** | 빌드 크기, 렌더 성능, 메모리 최적화 |

---

## 핵심 아키텍처 — 로컬 퍼스트

```
서버 없음 (Supabase ❌ / 백엔드 ❌)

📱 기기 내 저장
├── Drift SQLite (relink.db)   — 노드, 기억, 프로필, 설정
└── File System (Documents/)   — 사진(WebP), 음성(Opus .m4a)

☁️ 클라우드 백업 (자동/수동)
├── iOS  → iCloud Drive (/Re-Link/*.rlink)
└── Android → Google Drive (appDataFolder/*.rlink)

🔗 가족 공유
└── .rlink 파일 내보내기 → OS 공유시트 (AirDrop / 카카오 등)
```

### .rlink 백업 형식
```
backup_YYYYMMDD_HHMMSS.rlink (ZIP 압축)
├── manifest.json   (버전, 날짜, 노드수, 체크섬)
├── relink.db       (Drift SQLite 전체)
└── media/          (사진 + 음성 전체)
```

---

## 요금제 (4-Tier: 1회성 + 구독 혼합)

| | 무료 | 플러스 | 패밀리 | 패밀리플러스 |
|--|--|--|--|--|
| **가격** | ₩0 | ₩4,900 (1회) | ₩3,900/월, ₩37,900/년(20%↓) | ₩6,900/월, ₩61,900/년(25%↓) |
| **노드** | 15 | 무제한 | 무제한 | 무제한 |
| **사진** | 50 | 무제한 | 무제한 | 무제한 |
| **음성** | 5분 | 무제한 | 무제한 | 무제한 |
| **영상** | ❌ | 30초x10개 | 3분x무제한 | 10분x무제한 |
| **클라우드** | ❌ | ❌ | 20GB | 100GB |
| **가족공유** | ❌ | ❌ | 6명 | 무제한(999) |
| **광고** | O (배너+네이티브) | ❌ 없음 | ❌ 없음 | ❌ 없음 |

### 연간 결제 할인
- 패밀리: ₩3,900/월 → ₩37,900/년 (20% 할인, 월 ₩3,158)
- 패밀리플러스: ₩6,900/월 → ₩61,900/년 (25% 할인, 월 ₩5,158)

### 서버 아키텍처 (패밀리/패밀리플러스 전용)
```
Cloudflare R2      — 미디어 파일 저장 (사진/음성/영상)
Cloudflare Workers — API 엣지 서버 (인증, 동기화)
Cloudflare D1      — 메타데이터 동기화 DB
```
- 클라우드 동기화는 패밀리/패밀리플러스 구독자만 사용 가능
- 무료/플러스 사용자는 기존 로컬 퍼스트 + .rlink 백업 유지

### 구매 방식
- 무료 / 플러스: 인앱 구매 (`in_app_purchase`, 1회성)
- 패밀리 / 패밀리플러스: 인앱 구독 (`in_app_purchase`, 월/연)
- AdMob: 배너 + 네이티브만 (전면광고 없음), 무료 플랜에만 적용
- **AI 기능 없음** — 서버 비용 절감, 1인 개발자 운영 최적화

---

## 기술 스택

### 핵심 패키지
```yaml
# 상태 관리
flutter_riverpod: ^2.6.1
riverpod_annotation: ^2.6.1

# 라우팅
go_router: ^14.8.1

# 로컬 DB
drift: ^2.22.0
drift_flutter: ^0.2.4
sqlite3_flutter_libs: ^0.5.28

# 백업
archive: ^4.0.4       # ZIP 압축
encrypt: ^5.0.3       # AES-256
icloud_storage: ^2.0.0
googleapis: ^13.2.0
google_sign_in: ^6.2.2
```

### 미디어
```yaml
record: ^6.2.0                 # 음성 녹음 (Opus 24kbps)
audio_waveforms: ^2.0.2        # 파형 시각화
image_picker: ^1.1.2           # 사진 선택
flutter_image_compress: ^2.3.0 # WebP 압축
```

---

## DB 구조 (Drift SQLite)

```
profile            — 내 프로필 (단일 row)
nodes              — 인물 노드
node_edges         — 노드 관계 (Adjacency List)
memories           — 기억 메타데이터 (사진/음성/메모/영상)
settings           — 앱 설정 (key-value, ~40개 키)
temperature_logs   — 온도 다이어리
bouquets           — 마음 꽃다발
capsules           — 기억 캡슐
capsule_items      — 캡슐-기억 연결
memorial_messages  — 추모 메시지
recipes            — 가족 레시피
node_locations     — 가족 지도 위치
voice_legacy       — 보이스 유언
then_now           — 과거 vs 현재 비교
family_events      — 가족 일정
sync_queue         — 클라우드 동기화 큐
media_upload_queue — R2 미디어 업로드 큐
```

### Ghost Node
- `is_ghost: true` 플래그로 표시
- UI: 점선 테두리, 반투명 처리
- 실제 인물 연결 시 Ghost → 일반 노드 전환

---

## lib/ 폴더 구조

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── config/          # 환경설정 (env_config)
│   ├── constants/       # 상수 (app_constants)
│   ├── database/        # Drift DB 정의
│   │   ├── app_database.dart
│   │   └── tables/      (profile, nodes, edges, memories, settings)
│   ├── errors/          # 에러 처리
│   ├── router/          # go_router
│   ├── services/
│   │   ├── auth/        # AuthService, AuthHttpClient, KakaoAuthHelper, TokenStorage
│   │   ├── backup/      # BackupService (.rlink 생성/복원)
│   │   ├── cloud/       # iCloud / Google Drive 백업
│   │   ├── media/       # 사진/음성/영상 파일 관리
│   │   ├── plan/        # PlanService (IAP 인앱구매)
│   │   ├── sync/        # SyncService, R2MediaService, MediaCacheService
│   │   └── notification/ # 로컬 알림
│   └── utils/
├── design/
│   ├── tokens/          # 색상, 타이포, 간격, 반경, 그림자, 테마
│   ├── glass/           # GlassCard, GlassButton
│   └── motion/          # 애니메이션 상수
├── features/
│   ├── profile_setup/   # 첫 실행 프로필 설정
│   ├── onboarding/      # 온보딩 3단계 + 첫 가족 추가
│   ├── auth/            # 로그인 (Apple/Google/카카오)
│   ├── canvas/          # 무한 캔버스 + 노드 + 관계선
│   ├── node/            # 노드 상세, CRUD
│   ├── memory/          # 기억 (사진/음성/메모/영상)
│   ├── archive/         # 기억 아카이브 (5탭 필터)
│   ├── story/           # 스토리 피드
│   ├── family/          # 가족 공유 (.rlink 병합)
│   ├── family_hub/      # 가족 허브 (생일/일정/클라우드)
│   ├── family_sync/     # 클라우드 동기화 + 멤버 관리
│   ├── family_map/      # 가족 지도 (FlutterMap)
│   ├── invite/          # 초대 코드 + .rlink 공유
│   ├── explore_hub/     # 탐색 허브 (특별 기능 모음)
│   ├── capsule/         # 기억 캡슐 (타임캡슐)
│   ├── voice_legacy/    # 보이스 유언
│   ├── temperature/     # 온도 다이어리
│   ├── hyodo/           # 효도 온도계 대시보드
│   ├── vibe/            # 온도계 시스템 (프로바이더)
│   ├── bouquet/         # 마음 꽃다발 리포트
│   ├── birthday/        # 생일/이벤트 대시보드
│   ├── memorial/        # 추모 공간
│   ├── recipe/          # 가족 레시피
│   ├── badges/          # 뱃지 컬렉션 (20개)
│   ├── streak/          # 연속 기록 뱃지
│   ├── wrapped/         # 연말 가족 리뷰
│   ├── search/          # 통합 검색
│   ├── snapshot/        # 기억 포스터 공유
│   ├── then_now/        # 과거 vs 현재 비교
│   ├── clan/            # 성씨 탐색기
│   ├── art_card/        # 아트 카드 (4세대 트리)
│   ├── export/          # 족보 이미지 내보내기
│   ├── holiday/         # 의례 가이드
│   ├── tree_growth/     # 나무 성장 오버레이
│   ├── prompt/          # 일일 프롬프트 카드
│   ├── changelog/       # 변경 로그 모달
│   ├── settings/        # 앱 설정 + 관리자 콘솔
│   ├── backup/          # 백업/복원 화면
│   └── subscription/    # 인앱 구매 (4-Tier)
├── shared/
│   ├── models/          # NodeModel, MemoryModel, UserPlan
│   ├── repositories/    # DB 접근 레이어
│   └── widgets/         # 공통 위젯
└── gen/                 # 코드 생성 (*.g.dart)
```

---

## 코딩 컨벤션

### Flutter / Dart
- **상태관리**: Riverpod 3.0 (`AsyncNotifier`, `@riverpod`)
- **라우팅**: go_router (`ShellRoute` 하단 네비게이션)
- **비동기**: `AsyncValue` 패턴
- **파일명**: `snake_case.dart`
- **클래스명**: `PascalCase`
- **상수**: `kConstantName`

### 금지 사항
- `BuildContext` across async gaps (`mounted` 체크 필수)
- `setState` in 비즈니스 로직
- API 키 하드코딩
- Supabase / 외부 서버 의존성 추가

### 성능 원칙
- `const` 위젯 최대 활용
- `RepaintBoundary` 캔버스 분리
- 이미지: WebP + 압축 (flutter_image_compress)
- Drift isolate 기반 비동기 쿼리

---

## 디자인 시스템 — Liquid Glass

### 핵심 색상
```dart
static const Color primary = Color(0xFF6C63FF);      // 보라
static const Color secondary = Color(0xFF48CAE4);    // 청록
static const Color accent = Color(0xFFFF6B6B);       // 산호
static const Color glassSurface = Color(0x1AFFFFFF); // 10% 흰
static const Color glassBorder = Color(0x33FFFFFF);  // 20% 흰
```

### 온도 (Vibe Meter, 6단계)
```dart
static const Color tempIcy     = Color(0xFF4FC3F7); // 냉담
static const Color tempCool    = Color(0xFF81C784); // 쌀쌀
static const Color tempNeutral = Color(0xFFFFD54F); // 보통
static const Color tempWarm    = Color(0xFFFFB74D); // 따뜻
static const Color tempHot     = Color(0xFFFF7043); // 뜨거움
static const Color tempFire    = Color(0xFFE53935); // 열정
```

### 글래스 카드 표준
- `blur: 20`, `opacity: 0.15`, `border-radius: 20`

---

## 개발 단계

| 단계 | 내용 | 상태 |
|------|------|------|
| Phase 0-10 | 초기화, MVP, DB 스키마, 디자인 토큰, 캔버스, 프로필, 노드 CRUD | ✅ 완료 |
| Phase 11-20 | 기억, 백업, 클라우드, 가족 공유, 온도계, Ghost Node, 검색, 설정 | ✅ 완료 |
| Phase 21-25 | 서버 배포, 백업 디버깅, 가족지도, 족보, 캡슐/유언 | ✅ 완료 |
| Phase 26-32 | 6차 전체 리뷰, 65개 화면 100% 구현, 잔여 이슈 정리 | ✅ 완료 |
| Phase 33+ | 앱스토어 출시 준비, 성능 최적화, 런치 | 🔜 예정 |

### 현재 구현 완료 현황 (Phase 32 기준)
- **화면**: 65개 전체 구현 (STUB/PARTIAL 0개)
- **DB**: 17테이블, 스키마 v10, 10단계 마이그레이션
- **서비스**: 인증, 백업, 미디어, 클라우드 동기화, IAP 전체 구현
- **코드 품질**: TODO/FIXME/UnimplementedError 0개
- **flutter analyze**: error 0개

---

## Git 규칙
- **브랜치**: `feat/`, `fix/`, `refactor/`, `chore/`
- **커밋**: `feat: 노드 추가 기능 구현`
- **메인 브랜치**: `main`
- **`.gitignore`**: `.env`, `*.g.dart` (선택), `/build`, `/ios/Pods`

## process.md 참조
개발 진행 상황은 `process.md`에서 체크박스로 추적합니다.
