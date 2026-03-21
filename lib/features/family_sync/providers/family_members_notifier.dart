import 'package:riverpod_annotation/riverpod_annotation.dart';

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
    // GET /family/members 호출 (추후 AuthHttpClient 연동)
    return [];
  }

  Future<String?> createInviteLink() async {
    // POST /family/invite → token
    // 반환: 'relink://invite/{token}'
    return null;
  }

  Future<bool> acceptInvite(String token) async {
    // POST /family/invite/{token}/accept
    return false;
  }

  Future<void> removeMember(String userId) async {
    // DELETE /family/members/{userId}
    ref.invalidateSelf();
  }

  Future<void> leaveGroup() async {
    // DELETE /family/leave
  }
}
