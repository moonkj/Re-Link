import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/services/auth/auth_http_client.dart';
import '../../../shared/repositories/settings_repository.dart';

part 'family_members_notifier.g.dart';

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
    try {
      final authClient = ref.read(authHttpClientProvider);
      final response = await authClient.get('/family/members');

      if (response.statusCode != 200) return [];

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
    } catch (_) {
      return [];
    }
  }

  Future<String?> createInviteLink() async {
    try {
      final authClient = ref.read(authHttpClientProvider);
      final response = await authClient.post('/family/invite', body: {});

      if (response.statusCode != 201) return null;

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;
      final token = data['token'] as String?;

      if (token == null) return null;
      return 'relink://invite/accept?token=$token';
    } catch (_) {
      return null;
    }
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
