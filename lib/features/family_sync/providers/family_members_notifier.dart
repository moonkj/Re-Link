import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/services/auth/auth_http_client.dart';
import '../../../shared/models/user_plan.dart';
import '../../../shared/repositories/settings_repository.dart';
import '../../auth/providers/auth_notifier.dart';
import '../../invite/services/invite_service.dart';
import '../../subscription/providers/plan_notifier.dart';

part 'family_members_notifier.g.dart';

/// 초대 링크 생성 결과
class InviteLinkResult {
  const InviteLinkResult.success(this.link)
      : error = null,
        errorType = null;
  const InviteLinkResult.failure(this.error, this.errorType) : link = null;

  final String? link;
  final String? error;
  final InviteErrorType? errorType;

  bool get isSuccess => link != null;
}

enum InviteErrorType {
  notLoggedIn,
  noPlan,
  noGroup,
  serverUnavailable,
  serverError,
  unknown,
}

class FamilyMember {
  const FamilyMember({
    required this.id,
    required this.email,
    this.name,
    required this.isOwner,
    required this.joinedAt,
  });
  final String id;
  final String? email;
  final String? name;
  final bool isOwner;
  final DateTime joinedAt;
}

@riverpod
class FamilyMembersNotifier extends _$FamilyMembersNotifier {
  @override
  Future<List<FamilyMember>> build() async {
    // 로그인/플랜 체크 — 미충족 시 빈 목록 반환 (크래시 방지)
    final user = ref.read(authNotifierProvider).valueOrNull;
    if (user == null) {
      debugPrint('[FamilyMembers] 로그인 안됨 — 빈 목록 반환');
      return [];
    }
    final plan = ref.read(planNotifierProvider).valueOrNull ?? UserPlan.free;
    if (!plan.hasCloud) {
      debugPrint('[FamilyMembers] 패밀리 플랜 아님 — 빈 목록 반환');
      return [];
    }

    try {
      final authClient = ref.read(authHttpClientProvider);
      final response = await authClient.get('/family/members');

      if (response.statusCode != 200) {
        debugPrint('[FamilyMembers] GET /family/members → ${response.statusCode}');
        return [];
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;
      final membersJson = data['members'] as List<dynamic>;

      return membersJson.map((m) {
        final map = m as Map<String, dynamic>;
        final joinedAtMs = map['joined_at'] as int;
        return FamilyMember(
          id: map['id'] as String,
          email: map['email'] as String?,
          name: map['name'] as String?,
          isOwner: map['is_owner'] as bool,
          joinedAt: DateTime.fromMillisecondsSinceEpoch(joinedAtMs),
        );
      }).toList();
    } on SocketException catch (e) {
      debugPrint('[FamilyMembers] 네트워크 오류: $e');
      return [];
    } on TimeoutException catch (e) {
      debugPrint('[FamilyMembers] 타임아웃: $e');
      return [];
    } catch (e) {
      debugPrint('[FamilyMembers] 멤버 조회 오류: $e');
      return [];
    }
  }

  /// 초대 링크 생성 — 사전 조건 체크 포함
  Future<InviteLinkResult> createInviteLink() async {
    // 1. 로그인 체크
    final user = ref.read(authNotifierProvider).valueOrNull;
    if (user == null) {
      debugPrint('[FamilyMembers] createInviteLink: 로그인 안됨');
      return const InviteLinkResult.failure(
        '로그인이 필요합니다.\n설정 > 계정에서 로그인해주세요.',
        InviteErrorType.notLoggedIn,
      );
    }

    // 2. 플랜 체크
    final plan = ref.read(planNotifierProvider).valueOrNull ?? UserPlan.free;
    if (!plan.hasCloud) {
      debugPrint('[FamilyMembers] createInviteLink: 패밀리 플랜 아님 (현재: ${plan.displayName})');
      return const InviteLinkResult.failure(
        '가족 공유 기능은 패밀리 플랜 이상에서 사용할 수 있습니다.',
        InviteErrorType.noPlan,
      );
    }

    // 3. 서버 API 호출 (실패 시 로컬 초대 코드로 폴백)
    try {
      final authClient = ref.read(authHttpClientProvider);
      final response = await authClient.post('/family/invite', body: {}).timeout(
        const Duration(seconds: 5),
      );

      debugPrint('[FamilyMembers] POST /family/invite → ${response.statusCode}');

      if (response.statusCode == 401) {
        return const InviteLinkResult.failure(
          '인증이 만료되었습니다. 다시 로그인해주세요.',
          InviteErrorType.notLoggedIn,
        );
      }

      if (response.statusCode == 403) {
        return const InviteLinkResult.failure(
          '패밀리 플랜 이상이 필요합니다.',
          InviteErrorType.noPlan,
        );
      }

      if (response.statusCode == 404) {
        return const InviteLinkResult.failure(
          '가족 그룹이 없습니다.\n먼저 가족 그룹을 생성해주세요.',
          InviteErrorType.noGroup,
        );
      }

      if (response.statusCode == 409) {
        // 그룹 인원 초과
        String msg = '그룹 인원이 가득 찼습니다.';
        try {
          final body = jsonDecode(response.body) as Map<String, dynamic>;
          msg = body['message'] as String? ?? msg;
        } catch (_) {}
        return InviteLinkResult.failure(msg, InviteErrorType.serverError);
      }

      if (response.statusCode != 201) {
        String msg = '서버 오류가 발생했습니다 (${response.statusCode}).';
        try {
          final body = jsonDecode(response.body) as Map<String, dynamic>;
          msg = body['message'] as String? ?? msg;
        } catch (_) {}
        return InviteLinkResult.failure(msg, InviteErrorType.serverError);
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;
      final token = data['token'] as String?;

      if (token == null) {
        return const InviteLinkResult.failure(
          '서버 응답에 토큰이 없습니다.',
          InviteErrorType.serverError,
        );
      }
      return InviteLinkResult.success('relink://invite/accept?token=$token');
    } on SocketException catch (e) {
      debugPrint('[FamilyMembers] 서버 연결 실패 → 로컬 초대 코드 폴백: $e');
      return _createLocalInvite();
    } on TimeoutException catch (e) {
      debugPrint('[FamilyMembers] 서버 타임아웃 → 로컬 초대 코드 폴백: $e');
      return _createLocalInvite();
    } catch (e) {
      debugPrint('[FamilyMembers] createInviteLink 오류 → 로컬 폴백: $e');
      return _createLocalInvite();
    }
  }

  /// 서버 연결 실패 시 로컬 초대 코드로 폴백
  InviteLinkResult _createLocalInvite() {
    final code = InviteService.generateCode();
    // 설정에 저장
    ref.read(settingsRepositoryProvider).setInviteCode(code);
    debugPrint('[FamilyMembers] 로컬 초대 코드 생성: $code');
    return InviteLinkResult.success('relink://invite/accept?code=$code');
  }

  Future<bool> acceptInvite(String token) async {
    try {
      final authClient = ref.read(authHttpClientProvider);
      final response = await authClient.post(
        '/family/invite/$token/accept',
        body: {},
      );

      if (response.statusCode != 200) return false;

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;
      final groupId = data['group_id'] as String?;

      if (groupId == null) return false;

      await ref.read(settingsRepositoryProvider).setFamilyGroupId(groupId);
      ref.invalidateSelf();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> removeMember(String userId) async {
    try {
      final authClient = ref.read(authHttpClientProvider);
      await authClient.delete('/family/members/$userId');
    } catch (_) {
      // 실패 시 무시하고 목록 갱신
    } finally {
      ref.invalidateSelf();
    }
  }

  Future<void> leaveGroup() async {
    try {
      final authClient = ref.read(authHttpClientProvider);
      await authClient.delete('/family/leave');
    } catch (_) {
      // 실패 시 무시
    }
    await ref.read(settingsRepositoryProvider).clearAuthData();
  }
}
