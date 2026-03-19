# Re-Link — CLAUDE.md

## 프로젝트 개요
**Re-Link**는 가족 기억 저장소 앱입니다. 노드 기반 가족 트리를 통해 사진, 음성, 메모, AI 대화를 저장하고 공유합니다.

- **플랫폼**: iOS / Android (Flutter 3.41.2)
- **패키지명**: com.relink
- **Dart SDK**: ≥ 3.11.0

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

## 요금제 (1회성 구매 — 절대 구독 없음)

| 플랜 | 가격 | 노드 | 사진 | 음성 | AI | 광고 |
|------|------|------|------|------|-----|------|
| FREE | ₩0 | 30 | 50 | ❌ | 10회/월 | O (배너+네이티브) |
| BASIC | ₩4,900 | 200 | 500 | 30분 | 100회/월 | O (배너+네이티브) |
| PREMIUM | ₩14,900 | 무제한 | 무제한 | 300분 | 무제한 | ❌ 광고 없음 |

- BASIC → PREMIUM 업그레이드: ₩10,000 (차액 결제)
- 인앱 구매: `in_app_purchase` 패키지
- AdMob: 배너 + 네이티브 광고만 (전면광고 없음), Free/Basic에만 적용

---

## 기술 스택

### 핵심 패키지
```yaml
supabase_flutter: ^2.9.0       # Auth + DB + Realtime + Storage
flutter_riverpod: ^2.6.1       # 상태 관리
riverpod_annotation: ^2.6.1    # 코드 생성
go_router: ^14.8.1             # 라우팅
```

### 캔버스 / 차트
```yaml
# MVP: 패키지 활용
genealogy_chart: ^1.0.0
infinite_canvas: ^1.1.1
# Production: InteractiveViewer.builder + QuadTree 직접 구현
```

### 미디어
```yaml
record: ^6.2.0                 # 음성 녹음 (Opus 24kbps)
audio_waveforms: ^2.0.2        # 파형 시각화
image_picker: ^1.1.2           # 사진 선택
flutter_image_compress: ^2.3.0 # 이미지 압축
cached_network_image: ^3.4.1   # 이미지 캐싱
```

### UI / 디자인
```yaml
glassmorphism: ^3.0.0          # 글래스모피즘
flutter_svg: ^2.0.17           # SVG 아이콘
lottie: ^3.3.1                 # 애니메이션
google_fonts: ^6.2.1           # 폰트
```

### 광고 / 수익화
```yaml
google_mobile_ads: ^5.3.0      # AdMob
in_app_purchase: ^3.2.0        # 인앱 구매
```

### 유틸리티
```yaml
connectivity_plus: ^6.1.3      # 네트워크 상태
shared_preferences: ^2.3.5     # 로컬 저장
hive_ce: ^2.9.0                # 오프라인 캐시
flutter_secure_storage: ^9.2.4 # 보안 저장소
uuid: ^4.5.1                   # UUID 생성
intl: ^0.20.2                  # 날짜/숫자 포맷
```

---

## Supabase 설정

- **리전**: Seoul (ap-northeast-2)
- **Auth**: Kakao OAuth (소셜 로그인), Email/Password
- **Storage**: 기본 Supabase Storage (MVP) → Cloudflare R2 (Production)
- **Edge Functions**: AI Chat (GPT-4.1-mini 라우팅)
- **Realtime**: 가족 공간 실시간 동기화 (Presence + Broadcast)
- **RLS**: 모든 테이블에 Row Level Security 적용 필수

### 환경변수 (`.env` — git 제외)
```
SUPABASE_URL=https://[project].supabase.co
SUPABASE_ANON_KEY=[anon_key]
OPENAI_API_KEY=[key]  # Edge Function에서만 사용
ADMOB_APP_ID_IOS=[id]
ADMOB_APP_ID_ANDROID=[id]
```

---

## DB 구조

### 핵심 테이블
- `profiles` — 사용자 프로필, 플랜 정보
- `families` — 가족 공간
- `family_members` — 가족 구성원 (membership)
- `nodes` — 인물 노드 (Ghost Node 포함)
- `node_edges` — 노드 간 관계 (Adjacency List)
- `memories` — 기억 (사진/음성/메모/AI)
- `voice_capsules` — 음성 캡슐
- `purchases` — 구매 기록

### Ghost Node
- `is_ghost: true` 플래그로 표시
- UI: 점선 테두리, 반투명 처리
- 실제 인물 연결 시 Ghost → 일반 노드로 전환

---

## lib/ 폴더 구조

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── config/          # 환경설정, Supabase 초기화
│   ├── constants/       # 상수
│   ├── errors/          # 에러 처리
│   ├── extensions/      # Dart 확장
│   ├── router/          # go_router 설정
│   └── utils/           # 유틸리티
├── design/
│   ├── tokens/          # 디자인 토큰 (색상, 타이포, 간격, 반경)
│   ├── glass/           # 글래스모피즘 컴포넌트
│   └── motion/          # 애니메이션 상수
├── features/
│   ├── auth/            # 인증 (Kakao OAuth)
│   ├── canvas/          # 무한 캔버스 + 노드
│   ├── node/            # 노드 상세, CRUD
│   ├── memory/          # 기억 저장 (사진/음성/메모)
│   ├── ai_chat/         # AI 대화 → 노드 생성
│   ├── family/          # 가족 공간 관리
│   ├── vibe/            # 온도계 시스템
│   └── subscription/    # 인앱 구매, 플랜 관리
├── shared/
│   ├── models/          # 데이터 모델
│   ├── providers/       # Riverpod providers
│   ├── repositories/    # 데이터 레이어
│   ├── services/        # 외부 서비스 (Supabase, AI)
│   └── widgets/         # 공통 위젯
└── gen/                 # 코드 생성 파일 (*.g.dart)
```

---

## 코딩 컨벤션

### Flutter / Dart
- **상태관리**: Riverpod 3.0 (AsyncNotifier, @riverpod 애노테이션)
- **라우팅**: go_router (ShellRoute로 하단 네비게이션)
- **비동기**: `AsyncValue` 패턴으로 loading/error/data 처리
- **모델**: `freezed` 또는 수동 `copyWith` + `fromJson`/`toJson`
- **파일명**: `snake_case.dart`
- **클래스명**: `PascalCase`
- **상수**: `kConstantName` (k 접두사)

### 금지 사항
- `BuildContext` across async gaps (use `mounted` check)
- `setState` in Riverpod 프로젝트의 비즈니스 로직
- API 키 하드코딩
- `.env` 파일 git commit

### 성능 원칙
- `const` 위젯 최대 활용
- `RepaintBoundary`로 캔버스 영역 분리
- 이미지: WebP 변환 + 압축 (flutter_image_compress)
- 오프라인 우선: Hive 캐시 → Supabase 동기화

---

## 디자인 시스템 — Liquid Glass

### 핵심 색상 토큰
```dart
// Primary
static const Color primary = Color(0xFF6C63FF);      // 보라
static const Color secondary = Color(0xFF48CAE4);    // 청록
static const Color accent = Color(0xFFFF6B6B);       // 산호

// Glass
static const Color glassSurface = Color(0x1AFFFFFF); // 10% 흰
static const Color glassBorder = Color(0x33FFFFFF);  // 20% 흰

// Temperature (Vibe Meter)
static const Color tempIcy = Color(0xFF4FC3F7);      // 냉담 (얼음)
static const Color tempCool = Color(0xFF81C784);     // 쌀쌀
static const Color tempNeutral = Color(0xFFFFD54F);  // 보통
static const Color tempWarm = Color(0xFFFFB74D);     // 따뜻
static const Color tempHot = Color(0xFFFF7043);      // 뜨거움
static const Color tempFire = Color(0xFFE53935);     // 열정
```

### 글래스 카드 표준
- `blur: 20`, `opacity: 0.15`, `border-radius: 20`
- 그림자: `BoxShadow(blurRadius: 20, color: 0x1A000000)`

---

## 개발 단계

| 단계 | 기간 | 내용 |
|------|------|------|
| Phase 1 MVP | Week 1–8 | 캔버스, Auth, 기본 노드 CRUD, 기억 저장 |
| Phase 2 확장 | Week 9–20 | AI 채팅, 음성 캡슐, 가족 공간, 인앱 구매 |
| Phase 3 폴리시 | Week 21–28 | 온도계, Ghost Node, 오프라인 동기화 |
| Phase 4 런치 | Week 29–34 | 앱스토어 출시, 마케팅, 성능 최적화 |

---

## Git 규칙

- **브랜치**: `feat/`, `fix/`, `refactor/`, `chore/`
- **커밋**: `feat: 노드 추가 기능 구현`, `fix: 캔버스 스크롤 버그 수정`
- **`.gitignore`**: `.env`, `*.g.dart` (선택), `/build`, `/ios/Pods`
- **메인 브랜치**: `main` (배포), `develop` (개발)

---

## process.md 참조

개발 진행 상황은 `process.md`에서 체크박스로 추적합니다.
