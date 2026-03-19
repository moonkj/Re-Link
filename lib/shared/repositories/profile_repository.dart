import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/app_database.dart';
import 'db_provider.dart';

part 'profile_repository.g.dart';

@riverpod
ProfileRepository profileRepository(Ref ref) =>
    ProfileRepository(ref.watch(appDatabaseProvider));

class ProfileRepository {
  ProfileRepository(this._db);
  final AppDatabase _db;

  Future<ProfileTableData?> getProfile() => _db.getProfile();

  Future<bool> hasProfile() async => (await _db.getProfile()) != null;

  Future<void> saveProfile({
    required String name,
    String? nickname,
    String? photoPath,
    DateTime? birthDate,
    String? bio,
  }) async {
    final now = DateTime.now();
    await _db.upsertProfile(ProfileTableCompanion(
      name: Value(name),
      nickname: Value(nickname),
      photoPath: Value(photoPath),
      birthDate: Value(birthDate),
      bio: Value(bio),
      updatedAt: Value(now),
    ));
  }

  Future<void> updatePhoto(String? photoPath) async {
    final profile = await _db.getProfile();
    if (profile == null) return;
    await _db.upsertProfile(ProfileTableCompanion(
      id: Value(profile.id),
      name: Value(profile.name),
      photoPath: Value(photoPath),
      updatedAt: Value(DateTime.now()),
    ));
  }
}
