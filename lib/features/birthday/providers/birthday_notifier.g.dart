// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'birthday_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$birthdayNotifierHash() => r'8c82c04809172bb8c72320d32d68d61bec2dbb0c';

/// 가족 생일 목록 프로바이더 — 다음 생일 기준 정렬
///
/// Copied from [BirthdayNotifier].
@ProviderFor(BirthdayNotifier)
final birthdayNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      BirthdayNotifier,
      List<BirthdayEntry>
    >.internal(
      BirthdayNotifier.new,
      name: r'birthdayNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$birthdayNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$BirthdayNotifier = AutoDisposeAsyncNotifier<List<BirthdayEntry>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
