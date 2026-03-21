import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/media/media_service.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../shared/repositories/profile_repository.dart';
import '../../../shared/repositories/settings_repository.dart';

/// 첫 실행 프로필 설정 화면 (로그인 불필요)
class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  String? _photoPath;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.bgBase, AppColors.bgSurface, AppColors.bgBase],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom -
                    AppSpacing.pagePadding * 2,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 타이틀
                Text(
                  '시작해 볼게요',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '내 프로필을 설정해 주세요\n별도 가입 없이 바로 시작됩니다',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.giant),

                // 프로필 사진
                GestureDetector(
                  onTap: _pickPhoto,
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.glassSurface,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2,
                          ),
                          image: _photoPath != null
                              ? DecorationImage(
                                  image: FileImage(File(_photoPath!)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _photoPath == null
                            ? Icon(Icons.person, size: 48, color: AppColors.textTertiary)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                          ),
                          child: Icon(Icons.camera_alt, size: 16, color: AppColors.onPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),

                // 이름 입력
                GlassCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  child: TextField(
                    controller: _nameController,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '이름을 입력하세요',
                      hintStyle: TextStyle(color: AppColors.textTertiary),
                      prefixIcon: Icon(Icons.person_outline, color: AppColors.primary),
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _save(),
                  ),
                ),
                const SizedBox(height: AppSpacing.massive),

                // 시작 버튼
                SizedBox(
                  width: double.infinity,
                  child: PrimaryGlassButton(
                    label: '가족 트리 시작하기',
                    isLoading: _saving,
                    onPressed: _save,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  '데이터는 내 기기에만 저장됩니다',
                  style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                ),
              ],
            ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickPhoto() async {
    final result = await ref.read(mediaServiceProvider).pickAndSaveAvatar();
    if (!mounted || result == null) return;
    setState(() => _photoPath = result);
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이름을 입력해 주세요')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(profileRepositoryProvider).saveProfile(
            name: name,
            photoPath: _photoPath,
          );
      await ref.read(settingsRepositoryProvider).setOnboardingDone();
      if (!mounted) return;
      context.go(AppRoutes.firstFamily);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
