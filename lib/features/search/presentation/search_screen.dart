import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../shared/models/memory_model.dart';
import '../../../shared/models/node_model.dart';
import '../providers/search_notifier.dart';

/// 통합 검색 화면 (노드 + 기억)
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(searchNotifierProvider.notifier).search(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncResult = ref.watch(searchNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        backgroundColor: AppColors.bgElevated,
        elevation: 0,
        titleSpacing: 0,
        title: TextField(
          controller: _controller,
          autofocus: true,
          onChanged: _onChanged,
          style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
          decoration: InputDecoration(
            hintText: '인물 이름, 기억 내용 검색...',
            hintStyle: TextStyle(color: AppColors.textTertiary),
            border: InputBorder.none,
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: AppColors.textTertiary),
                    onPressed: () {
                      _controller.clear();
                      ref.read(searchNotifierProvider.notifier).clear();
                    },
                  )
                : null,
          ),
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      body: asyncResult.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(
          child: Text('검색 오류: $e',
              style: const TextStyle(color: AppColors.error)),
        ),
        data: (result) {
          if (_controller.text.isEmpty) return _EmptyPrompt();
          if (result.isEmpty) return _NoResult(query: _controller.text);
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            children: [
              if (result.nodes.isNotEmpty) ...[
                _SectionHeader(
                    label: '인물', count: result.nodes.length),
                const SizedBox(height: AppSpacing.sm),
                ...result.nodes.map((n) => _NodeResultTile(
                      node: n,
                      onTap: () => context.pop(),
                    )),
                const SizedBox(height: AppSpacing.lg),
              ],
              if (result.memories.isNotEmpty) ...[
                _SectionHeader(
                    label: '기억', count: result.memories.length),
                const SizedBox(height: AppSpacing.sm),
                ...result.memories.map((m) => _MemoryResultTile(
                      memory: m,
                      onTap: () {
                        context.pop();
                        context.push(AppRoutes.memoryPath(m.nodeId));
                      },
                    )),
              ],
            ],
          );
        },
      ),
    );
  }
}

// ── 섹션 헤더 ──────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.count});
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(51),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

// ── 노드 결과 타일 ─────────────────────────────────────────────────────────────

class _NodeResultTile extends StatelessWidget {
  const _NodeResultTile({required this.node, required this.onTap});
  final NodeModel node;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tempColor = AppColors.tempColor(node.temperature);
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 0, vertical: AppSpacing.xs),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: tempColor, width: 2),
          color: AppColors.glassSurface,
          image: node.photoPath != null
              ? DecorationImage(
                  image: FileImage(File(node.photoPath!)),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: node.photoPath == null
            ? Center(
                child: Text(
                  node.name.isNotEmpty ? node.name[0] : '?',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              )
            : null,
      ),
      title: Text(
        node.name,
        style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary),
      ),
      subtitle: node.nickname != null
          ? Text(node.nickname!,
              style: TextStyle(
                  fontSize: 13, color: AppColors.textSecondary))
          : null,
      trailing: node.isGhost
          ? Icon(Icons.help_outline,
              size: 16, color: AppColors.textTertiary)
          : Icon(Icons.chevron_right, color: AppColors.textTertiary),
      onTap: onTap,
    );
  }
}

// ── 기억 결과 타일 ─────────────────────────────────────────────────────────────

class _MemoryResultTile extends StatelessWidget {
  const _MemoryResultTile({required this.memory, required this.onTap});
  final MemoryModel memory;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = switch (memory.type) {
      MemoryType.photo => Icons.photo_outlined,
      MemoryType.voice => Icons.mic_outlined,
      MemoryType.note => Icons.notes_outlined,
    };
    final label = switch (memory.type) {
      MemoryType.photo => '사진',
      MemoryType.voice => '음성',
      MemoryType.note => '메모',
    };
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 0, vertical: AppSpacing.xs),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.glassSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Icon(icon, color: AppColors.secondary, size: 22),
      ),
      title: Text(
        memory.title ?? label,
        style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary),
      ),
      subtitle: memory.description != null
          ? Text(
              memory.description!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 13, color: AppColors.textSecondary),
            )
          : Text(label,
              style: TextStyle(
                  fontSize: 13, color: AppColors.textTertiary)),
      trailing:
          Icon(Icons.chevron_right, color: AppColors.textTertiary),
      onTap: onTap,
    );
  }
}

// ── 빈 상태 ───────────────────────────────────────────────────────────────────

class _EmptyPrompt extends StatelessWidget {
  const _EmptyPrompt();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 56, color: AppColors.textTertiary),
          const SizedBox(height: 12),
          Text(
            '인물 이름이나 기억 내용을\n검색해보세요',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _NoResult extends StatelessWidget {
  const _NoResult({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 56, color: AppColors.textTertiary),
          const SizedBox(height: 12),
          Text(
            '"$query" 검색 결과 없음',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
