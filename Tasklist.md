# Tasklist — 연결선 버그 수정 + Phase 5a 계속

> 마지막 업데이트: 2026-03-20
> 모드: 에이전트 팀 과학적 토론 (4명 병렬)

---

## ✅ 긴급: 연결선(Edge) 깨짐 버그 — 수정 완료

### 증상
- iPad 실기기에서 자녀(child) 연결선이 엉뚱한 위치로 그려짐
- 배우자(spouse) 수평선은 정상

### 과학적 토론 결과

| 팀원 | 가설 | 결론 |
|------|------|------|
| Teammate1 | T-shape 로직이 일반 parent-child 엣지 깨뜨림 | ✅ **확정** — 방향성 단방향 체크 + parent 타입 무시 |
| Teammate2 | 부부 쌍 감지 오류 | ⚠️ **부분 확인** — 감지 자체 정상, 자녀 매칭이 단방향 |
| Teammate3 | 좌표/변환 불일치 | ✅ **확인** — 수평 브랜치가 coupleMid.dx 미포함 |
| Teammate4 | Phase 5a 코드 간섭 | ❌ **반박** — 완전 분리된 레이어 |

### 근본 원인 (3가지)
1. `fromNodeId`만 체크하여 역방향 child 엣지 누락 → 정규화 방식으로 수정
2. `RelationType.parent` 엣지 완전 무시 → parent 타입도 정규화에 포함
3. 수평 브랜치가 `coupleMid.dx` 미포함 → allXs에 coupleMid.dx 추가

### 수정 작업
- [x] EdgePainter 정규화 로직 적용 (`_NormalizedChildEdge`)
- [x] 양방향 child 매칭 + parent 타입 포함
- [x] 동일 자녀 중복 방지 (`seenChildIds`)
- [x] 수평 브랜치 coupleMid.dx 포함
- [x] flutter analyze 0 issues
- [x] flutter test 431/431 통과
- [ ] iPad 재설치 검증

---

## Phase 5a 남은 항목
- [ ] S-1 아트 카드 공유 (5번째 기능)
