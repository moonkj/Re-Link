import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/services/privacy/privacy_service.dart';
import '../../../core/utils/path_utils.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_radius.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../design/glass/app_glass.dart';
import '../../../shared/models/memory_model.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/private_blur_overlay.dart';
import '../../../core/router/app_router.dart';
import '../providers/story_feed_notifier.dart';

/// Story Feed 화면 (이야기 탭)
class StoryFeedScreen extends ConsumerStatefulWidget {
  const StoryFeedScreen({super.key});

  @override
  ConsumerState<StoryFeedScreen> createState() => _StoryFeedScreenState();
}

class _StoryFeedScreenState extends ConsumerState<StoryFeedScreen> {
  Future<void> _onPrivateTap(MemoryModel memory) async {
    final privacy = ref.read(privacyServiceProvider);
    final enabled = await privacy.isEnabled();
    if (!mounted) return;
    if (enabled) {
      final authed = await privacy.authenticate();
      if (!mounted) return;
      if (!authed) return;
    }
    if (!mounted) return;
    context.push(AppRoutes.memoryPath(memory.nodeId));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(storyFeedNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.bgBase,
            floating: true,
            centerTitle: true,
            title: Text(
              '이야기',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 22,
              ),
            ),
          ),
          if (state.isLoading)
            SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            )
          else if (state.items.isEmpty)
            SliverFillRemaining(
              child: EmptyStateWidget(
                icon: Icons.auto_stories_outlined,
                title: '아직 이야기가 없어요',
                subtitle: '가족 구성원을 추가하고\n첫 기억을 남겨보세요',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              sliver: SliverList.builder(
                itemCount: state.items.length,
                itemBuilder: (_, i) {
                  final item = state.items[i];
                  if (item.memory.isPrivate) {
                    return _PrivateStoryCard(
                      item: item,
                      onTap: () => _onPrivateTap(item.memory),
                    );
                  }
                  return _StoryCard(item: item);
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// 기억 스토리 카드
class _StoryCard extends StatelessWidget {
  const _StoryCard({required this.item});
  final StoryFeedItem item;

  @override
  Widget build(BuildContext context) {
    final memory = item.memory;
    final dateStr = DateFormat('yyyy년 M월 d일').format(
      memory.dateTaken ?? memory.createdAt,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        onTap: () => context.push(AppRoutes.memoryPath(memory.nodeId)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 헤더: 노드 이름 + 날짜 ───────────────────────────────────
            Row(
              children: [
                // 노드 미니 아바타
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withAlpha(60),
                    image: item.nodePhotoPath != null
                        ? DecorationImage(
                            image: PathUtils.resolveFileImage(item.nodePhotoPath) ?? FileImage(File(item.nodePhotoPath!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: item.nodePhotoPath == null
                      ? Center(
                          child: Text(
                            item.nodeName.isNotEmpty ? item.nodeName[0] : '?',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onPrimary,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.nodeName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        dateStr,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                // 타입 아이콘
                _MemoryTypeChip(type: memory.type),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // ── 콘텐츠 ──────────────────────────────────────────────────
            switch (memory.type) {
              MemoryType.photo => _PhotoContent(memory: memory),
              MemoryType.voice => _VoiceContent(memory: memory),
              MemoryType.note => _NoteContent(memory: memory),
              MemoryType.video => const SizedBox.shrink(),
            },
          ],
        ),
      ),
    );
  }
}

/// 비공개 기억 스토리 카드 — 블러 처리
class _PrivateStoryCard extends StatelessWidget {
  const _PrivateStoryCard({required this.item, required this.onTap});
  final StoryFeedItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final memory = item.memory;
    final dateStr = DateFormat('yyyy년 M월 d일').format(
      memory.dateTaken ?? memory.createdAt,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 헤더: 노드 이름 + 날짜 ───────────────────────────────────
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withAlpha(60),
                    image: item.nodePhotoPath != null
                        ? DecorationImage(
                            image: PathUtils.resolveFileImage(item.nodePhotoPath) ?? FileImage(File(item.nodePhotoPath!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: item.nodePhotoPath == null
                      ? Center(
                          child: Text(
                            item.nodeName.isNotEmpty ? item.nodeName[0] : '?',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onPrimary,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.nodeName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        dateStr,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                // 잠금 칩
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.radiusSm,
                    color: AppColors.accent.withAlpha(30),
                  ),
                  child: const Icon(Icons.lock, size: 16, color: AppColors.accent),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // ── 블러 콘텐츠 ──────────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: PrivateBlurOverlay(
                onTap: onTap,
                borderRadius: BorderRadius.circular(10),
                message: '비공개 기억입니다\n탭하여 인증 후 보기',
                blurSigma: 20,
                child: SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: Container(
                    color: AppColors.glassSurface,
                    child: Center(
                      child: Icon(
                        switch (memory.type) {
                          MemoryType.photo => Icons.photo_outlined,
                          MemoryType.voice => Icons.mic_outlined,
                          MemoryType.note => Icons.note_outlined,
                          MemoryType.video => Icons.videocam_outlined,
                        },
                        size: 40,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemoryTypeChip extends StatelessWidget {
  const _MemoryTypeChip({required this.type});
  final MemoryType type;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (type) {
      MemoryType.photo => (Icons.photo_outlined, AppColors.secondary),
      MemoryType.voice => (Icons.mic_outlined, AppColors.accent),
      MemoryType.note => (Icons.note_outlined, AppColors.primary),
      MemoryType.video => (Icons.videocam_outlined, AppColors.primary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: AppRadius.radiusSm,
        color: color.withAlpha(30),
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }
}

class _PhotoContent extends StatelessWidget {
  const _PhotoContent({required this.memory});
  final MemoryModel memory;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (memory.thumbnailPath != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(
              PathUtils.resolveFile(memory.thumbnailPath) ?? File(memory.thumbnailPath!),
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
              cacheWidth: 400,
            ),
          ),
        if (memory.description != null) ...[
          const SizedBox(height: 8),
          Text(
            memory.description!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ],
    );
  }
}

class _VoiceContent extends StatelessWidget {
  const _VoiceContent({required this.memory});
  final MemoryModel memory;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.accent.withAlpha(40),
          ),
          child: const Icon(Icons.play_arrow, color: AppColors.accent, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                memory.title ?? '음성 기억',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              if (memory.formattedDuration != null)
                Text(
                  memory.formattedDuration!,
                  style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NoteContent extends StatelessWidget {
  const _NoteContent({required this.memory});
  final MemoryModel memory;

  @override
  Widget build(BuildContext context) {
    return Text(
      memory.description ?? memory.title ?? '',
      maxLines: 4,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 14,
        color: AppColors.textSecondary,
        height: 1.5,
      ),
    );
  }
}
