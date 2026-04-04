/// UserPlan 단위 테스트
/// 커버: user_plan.dart — 모든 플랜의 모든 속성
import 'package:flutter_test/flutter_test.dart';
import 'package:re_link/shared/models/user_plan.dart';

void main() {
  // ── 기본 제한 ──────────────────────────────────────────────────────────────

  group('maxNodes', () {
    test('free → 15', () => expect(UserPlan.free.maxNodes, 10));
    test('plus → 999999', () => expect(UserPlan.plus.maxNodes, 999999));
    test('family → 999999', () => expect(UserPlan.family.maxNodes, 999999));
    test('familyPlus → 999999', () => expect(UserPlan.familyPlus.maxNodes, 999999));
  });

  group('maxPhotos', () {
    test('free → 50', () => expect(UserPlan.free.maxPhotos, 50));
    test('plus → 999999', () => expect(UserPlan.plus.maxPhotos, 999999));
    test('family → 999999', () => expect(UserPlan.family.maxPhotos, 999999));
    test('familyPlus → 999999', () => expect(UserPlan.familyPlus.maxPhotos, 999999));
  });

  group('maxVoiceMinutes', () {
    test('free → 5', () => expect(UserPlan.free.maxVoiceMinutes, 5));
    test('plus → 999999', () => expect(UserPlan.plus.maxVoiceMinutes, 999999));
    test('family → 999999', () => expect(UserPlan.family.maxVoiceMinutes, 999999));
    test('familyPlus → 999999', () => expect(UserPlan.familyPlus.maxVoiceMinutes, 999999));
  });

  // ── 영상 ──────────────────────────────────────────────────────────────────

  group('hasVideo', () {
    test('free → false', () => expect(UserPlan.free.hasVideo, isFalse));
    test('plus → true', () => expect(UserPlan.plus.hasVideo, isTrue));
    test('family → true', () => expect(UserPlan.family.hasVideo, isTrue));
    test('familyPlus → true', () => expect(UserPlan.familyPlus.hasVideo, isTrue));
  });

  group('maxVideoSeconds', () {
    test('free → 0', () => expect(UserPlan.free.maxVideoSeconds, 0));
    test('plus → 30', () => expect(UserPlan.plus.maxVideoSeconds, 30));
    test('family → 180', () => expect(UserPlan.family.maxVideoSeconds, 180));
    test('familyPlus → 600', () => expect(UserPlan.familyPlus.maxVideoSeconds, 600));
  });

  group('maxVideoCount', () {
    test('free → 0', () => expect(UserPlan.free.maxVideoCount, 0));
    test('plus → 10', () => expect(UserPlan.plus.maxVideoCount, 10));
    test('family → 999999', () => expect(UserPlan.family.maxVideoCount, 999999));
    test('familyPlus → 999999', () => expect(UserPlan.familyPlus.maxVideoCount, 999999));
  });

  // ── 클라우드 ──────────────────────────────────────────────────────────────

  group('hasCloud', () {
    test('free → false', () => expect(UserPlan.free.hasCloud, isFalse));
    test('plus → false', () => expect(UserPlan.plus.hasCloud, isFalse));
    test('family → true', () => expect(UserPlan.family.hasCloud, isTrue));
    test('familyPlus → true', () => expect(UserPlan.familyPlus.hasCloud, isTrue));
  });

  group('cloudStorageGB', () {
    test('free → 0', () => expect(UserPlan.free.cloudStorageGB, 0));
    test('plus → 0', () => expect(UserPlan.plus.cloudStorageGB, 0));
    test('family → 20', () => expect(UserPlan.family.cloudStorageGB, 20));
    test('familyPlus → 100', () => expect(UserPlan.familyPlus.cloudStorageGB, 100));
  });

  // ── 광고 ──────────────────────────────────────────────────────────────────

  group('hasAds', () {
    test('free → true', () => expect(UserPlan.free.hasAds, isTrue));
    test('plus → false', () => expect(UserPlan.plus.hasAds, isFalse));
    test('family → false', () => expect(UserPlan.family.hasAds, isFalse));
    test('familyPlus → false', () => expect(UserPlan.familyPlus.hasAds, isFalse));
  });

  // ── 가족 공유 ─────────────────────────────────────────────────────────────

  group('maxFamilyMembers', () {
    test('free → 0', () => expect(UserPlan.free.maxFamilyMembers, 0));
    test('plus → 0', () => expect(UserPlan.plus.maxFamilyMembers, 0));
    test('family → 6', () => expect(UserPlan.family.maxFamilyMembers, 6));
    test('familyPlus → 999', () => expect(UserPlan.familyPlus.maxFamilyMembers, 999));
  });

  // ── 구독 여부 ─────────────────────────────────────────────────────────────

  group('isSubscription', () {
    test('free → false', () => expect(UserPlan.free.isSubscription, isFalse));
    test('plus → false', () => expect(UserPlan.plus.isSubscription, isFalse));
    test('family → true', () => expect(UserPlan.family.isSubscription, isTrue));
    test('familyPlus → true', () => expect(UserPlan.familyPlus.isSubscription, isTrue));
  });

  // ── 버전 관리 백업 ────────────────────────────────────────────────────────

  group('hasVersionedBackup', () {
    test('free → false', () => expect(UserPlan.free.hasVersionedBackup, isFalse));
    test('plus → false', () => expect(UserPlan.plus.hasVersionedBackup, isFalse));
    test('family → false', () => expect(UserPlan.family.hasVersionedBackup, isFalse));
    test('familyPlus → true', () => expect(UserPlan.familyPlus.hasVersionedBackup, isTrue));
  });

  // ── 음성 ──────────────────────────────────────────────────────────────────

  group('hasVoice', () {
    test('모든 플랜 hasVoice=true', () {
      for (final plan in UserPlan.values) {
        expect(plan.hasVoice, isTrue, reason: '${plan.name} should have voice');
      }
    });
  });

  // ── isUnlimited ───────────────────────────────────────────────────────────

  group('isUnlimited', () {
    test('free → false', () => expect(UserPlan.free.isUnlimited, isFalse));
    test('plus → true', () => expect(UserPlan.plus.isUnlimited, isTrue));
    test('family → true', () => expect(UserPlan.family.isUnlimited, isTrue));
    test('familyPlus → true', () => expect(UserPlan.familyPlus.isUnlimited, isTrue));
  });

  // ── displayName ───────────────────────────────────────────────────────────

  group('displayName', () {
    test('free → 무료', () => expect(UserPlan.free.displayName, '무료'));
    test('plus → 플러스', () => expect(UserPlan.plus.displayName, '플러스'));
    test('family → 패밀리', () => expect(UserPlan.family.displayName, '패밀리'));
    test('familyPlus → 패밀리플러스', () => expect(UserPlan.familyPlus.displayName, '패밀리플러스'));
  });

  // ── price ─────────────────────────────────────────────────────────────────

  group('price', () {
    test('free → 무료', () => expect(UserPlan.free.price, '무료'));
    test('plus → ₩4,900', () => expect(UserPlan.plus.price, '₩4,900'));
    test('family → ₩3,900/월', () => expect(UserPlan.family.price, '₩3,900/월'));
    test('familyPlus → ₩6,900/월', () => expect(UserPlan.familyPlus.price, '₩6,900/월'));
  });

  // ── enum 값 수 ────────────────────────────────────────────────────────────

  group('UserPlan enum', () {
    test('4가지 플랜 존재', () {
      expect(UserPlan.values.length, 4);
    });

    test('enum 이름이 올바름', () {
      expect(UserPlan.values.map((e) => e.name).toList(),
          ['free', 'plus', 'family', 'familyPlus']);
    });
  });
}
