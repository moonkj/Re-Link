import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design/glass/app_glass.dart';
import '../../../design/tokens/app_colors.dart';
import '../../../design/tokens/app_spacing.dart';
import '../../../shared/models/temperature_log_model.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../providers/temperature_diary_notifier.dart';
import '../widgets/quick_temp_entry.dart';

/// 기간 필터 종류
enum _Period { day, week, month }

/// 온도 일기 그래프 화면
class TemperatureDiaryScreen extends ConsumerStatefulWidget {
  const TemperatureDiaryScreen({
    super.key,
    required this.nodeId,
    required this.nodeName,
  });

  final String nodeId;
  final String nodeName;

  @override
  ConsumerState<TemperatureDiaryScreen> createState() =>
      _TemperatureDiaryScreenState();
}

class _TemperatureDiaryScreenState
    extends ConsumerState<TemperatureDiaryScreen> {
  _Period _period = _Period.week;
  List<TemperatureLog> _filteredLogs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final now = DateTime.now();
    final from = switch (_period) {
      _Period.day => DateTime(now.year, now.month, now.day),
      _Period.week => now.subtract(const Duration(days: 7)),
      _Period.month => now.subtract(const Duration(days: 30)),
    };
    final logs = await ref
        .read(temperatureDiaryNotifierProvider.notifier)
        .loadForNode(widget.nodeId, from: from);
    if (!mounted) return;
    setState(() {
      _filteredLogs = logs;
      _loading = false;
    });
  }

  void _changePeriod(_Period period) {
    if (_period == period) return;
    setState(() => _period = period);
    _loadData();
  }

  Future<void> _openQuickEntry() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuickTempEntry(
        nodeId: widget.nodeId,
        nodeName: widget.nodeName,
      ),
    );
    if (result == true) {
      _loadData();
    }
  }

  Future<void> _deleteLog(TemperatureLog log) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgElevated,
        title: Text('기록 삭제',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          '이 온도 기록을 삭제하시겠습니까?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('삭제', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!mounted) return;
    await ref
        .read(temperatureDiaryNotifierProvider.notifier)
        .deleteLog(log.id);
    if (!mounted) return;
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '${widget.nodeName}와의 온도 그래프',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: AppColors.primary),
            onPressed: _openQuickEntry,
            tooltip: '온도 기록 추가',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── 기간 선택기 ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: _PeriodSelector(
                selected: _period,
                onChanged: _changePeriod,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // ── 그래프 ─────────────────────────────────────────────────
            Expanded(
              flex: 3,
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : _filteredLogs.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(AppSpacing.xxl),
                          child: EmptyStateWidget(
                            icon: Icons.show_chart,
                            title: '아직 기록이 없습니다',
                            subtitle:
                                '온도를 기록하면 관계 변화를\n그래프로 확인할 수 있습니다.',
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                          ),
                          child: GlassCard(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.md,
                              AppSpacing.lg,
                              AppSpacing.lg,
                              AppSpacing.md,
                            ),
                            child: CustomPaint(
                              size: Size.infinite,
                              painter: _TemperatureGraphPainter(
                                logs: _filteredLogs,
                                period: _period,
                              ),
                            ),
                          ),
                        ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── 로그 목록 ──────────────────────────────────────────────
            if (!_loading && _filteredLogs.isNotEmpty)
              Expanded(
                flex: 2,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  itemCount: _filteredLogs.length,
                  itemBuilder: (context, index) {
                    final log = _filteredLogs[index];
                    return _LogListItem(
                      log: log,
                      onDelete: () => _deleteLog(log),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── Period Selector ────────────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({
    required this.selected,
    required this.onChanged,
  });

  final _Period selected;
  final ValueChanged<_Period> onChanged;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.xs),
      child: Row(
        children: _Period.values.map((p) {
          final isSelected = selected == p;
          final label = switch (p) {
            _Period.day => '일',
            _Period.week => '주',
            _Period.month => '월',
          };
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(p),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withAlpha(30)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary.withAlpha(80)
                        : Colors.transparent,
                  ),
                ),
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w400,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── Log List Item ──────────────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _LogListItem extends StatelessWidget {
  const _LogListItem({
    required this.log,
    required this.onDelete,
  });

  final TemperatureLog log;
  final VoidCallback onDelete;

  static const _tempLabels = ['냉담', '쌀쌀', '보통', '따뜻', '뜨거움', '열정'];

  @override
  Widget build(BuildContext context) {
    final tempColor = AppColors.tempColor(log.temperature);
    final dateStr =
        '${log.date.year}.${log.date.month.toString().padLeft(2, '0')}.${log.date.day.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            // 온도 뱃지
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: tempColor.withAlpha(30),
              ),
              child: Center(
                child: Text(
                  '${log.temperature}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: tempColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _tempLabels[log.temperature],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        dateStr,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      if (log.emotionLabel != null) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: tempColor.withAlpha(20),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            log.emotionLabel!,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: tempColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // 삭제 버튼
            GestureDetector(
              onTap: onDelete,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── Temperature Graph Painter ──────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _TemperatureGraphPainter extends CustomPainter {
  _TemperatureGraphPainter({
    required this.logs,
    required this.period,
  });

  final List<TemperatureLog> logs;
  final _Period period;

  @override
  void paint(Canvas canvas, Size size) {
    if (logs.isEmpty) return;

    // 좌측 여백 (Y축 라벨), 하단 여백 (X축 라벨)
    const leftPadding = 30.0;
    const bottomPadding = 28.0;
    const topPadding = 8.0;
    const rightPadding = 8.0;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - bottomPadding - topPadding;

    // 로그를 날짜 오름차순으로 정렬
    final sorted = List<TemperatureLog>.from(logs)
      ..sort((a, b) => a.date.compareTo(b.date));

    // 시간 범위 계산
    final now = DateTime.now();
    final startDate = switch (period) {
      _Period.day => DateTime(now.year, now.month, now.day),
      _Period.week => now.subtract(const Duration(days: 7)),
      _Period.month => now.subtract(const Duration(days: 30)),
    };
    final totalDuration = now.difference(startDate).inMilliseconds.toDouble();

    // ── Y축 그리드 + 라벨 ────────────────────────────────────────────
    final yLabelStyle = TextStyle(
      fontSize: 10,
      color: AppColors.textTertiary,
    );
    final gridPaint = Paint()
      ..color = AppColors.glassBorder
      ..strokeWidth = 0.5;

    const tempLabels = ['냉담', '쌀쌀', '보통', '따뜻', '뜨거움', '열정'];
    for (var i = 0; i <= 5; i++) {
      final y = topPadding + chartHeight - (i / 5) * chartHeight;
      // 그리드 선
      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(size.width - rightPadding, y),
        gridPaint,
      );
      // 라벨
      final span = TextSpan(text: tempLabels[i], style: yLabelStyle);
      final tp = TextPainter(
        text: span,
        textAlign: TextAlign.right,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: leftPadding - 4);
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }

    // ── X축 라벨 ─────────────────────────────────────────────────────
    final xLabelStyle = TextStyle(
      fontSize: 10,
      color: AppColors.textTertiary,
    );
    final xLabelCount = switch (period) {
      _Period.day => 4,
      _Period.week => 7,
      _Period.month => 5,
    };
    for (var i = 0; i <= xLabelCount; i++) {
      final fraction = i / xLabelCount;
      final x = leftPadding + fraction * chartWidth;
      final labelDate = startDate.add(
        Duration(
          milliseconds:
              (totalDuration * fraction).round(),
        ),
      );
      final label = period == _Period.day
          ? '${labelDate.hour}:00'
          : '${labelDate.month}/${labelDate.day}';
      final span = TextSpan(text: label, style: xLabelStyle);
      final tp = TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(x - tp.width / 2, size.height - bottomPadding + 8),
      );
    }

    if (sorted.length < 2) {
      // 단일 포인트 — 점만 찍기
      if (sorted.length == 1) {
        final log = sorted[0];
        final timeFraction = log.date.difference(startDate).inMilliseconds /
            totalDuration;
        final x = leftPadding + timeFraction.clamp(0.0, 1.0) * chartWidth;
        final y = topPadding +
            chartHeight -
            (log.temperature / 5) * chartHeight;
        final dotPaint = Paint()
          ..color = AppColors.tempColor(log.temperature);
        canvas.drawCircle(Offset(x, y), 6, dotPaint);
        canvas.drawCircle(
          Offset(x, y),
          4,
          Paint()..color = Colors.white,
        );
      }
      return;
    }

    // ── 데이터 포인트 좌표 계산 ──────────────────────────────────────
    final points = <Offset>[];
    final tempValues = <int>[];
    for (final log in sorted) {
      final timeFraction =
          log.date.difference(startDate).inMilliseconds / totalDuration;
      final x = leftPadding + timeFraction.clamp(0.0, 1.0) * chartWidth;
      final y =
          topPadding + chartHeight - (log.temperature / 5) * chartHeight;
      points.add(Offset(x, y));
      tempValues.add(log.temperature);
    }

    // ── 그라디언트 채우기 영역 ───────────────────────────────────────
    final fillPath = Path()..moveTo(points[0].dx, topPadding + chartHeight);
    for (var i = 0; i < points.length; i++) {
      if (i == 0) {
        fillPath.lineTo(points[i].dx, points[i].dy);
      } else {
        // 부드러운 곡선
        final prev = points[i - 1];
        final curr = points[i];
        final cpX = (prev.dx + curr.dx) / 2;
        fillPath.cubicTo(cpX, prev.dy, cpX, curr.dy, curr.dx, curr.dy);
      }
    }
    fillPath.lineTo(points.last.dx, topPadding + chartHeight);
    fillPath.close();

    final fillGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColors.primary.withAlpha(40),
        AppColors.primary.withAlpha(5),
      ],
    );
    final fillPaint = Paint()
      ..shader = fillGradient.createShader(
        Rect.fromLTWH(leftPadding, topPadding, chartWidth, chartHeight),
      );
    canvas.drawPath(fillPath, fillPaint);

    // ── 라인 그리기 ──────────────────────────────────────────────────
    final linePath = Path();
    for (var i = 0; i < points.length; i++) {
      if (i == 0) {
        linePath.moveTo(points[i].dx, points[i].dy);
      } else {
        final prev = points[i - 1];
        final curr = points[i];
        final cpX = (prev.dx + curr.dx) / 2;
        linePath.cubicTo(cpX, prev.dy, cpX, curr.dy, curr.dx, curr.dy);
      }
    }

    final lineGradient = LinearGradient(
      colors: [AppColors.tempIcy, AppColors.tempFire],
    );
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..shader = lineGradient.createShader(
        Rect.fromLTWH(leftPadding, topPadding, chartWidth, chartHeight),
      );
    canvas.drawPath(linePath, linePaint);

    // ── 데이터 포인트 (점) ───────────────────────────────────────────
    for (var i = 0; i < points.length; i++) {
      final tempColor = AppColors.tempColor(tempValues[i]);
      // 외곽 원
      canvas.drawCircle(points[i], 5, Paint()..color = tempColor);
      // 내부 흰 점
      canvas.drawCircle(points[i], 3, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant _TemperatureGraphPainter old) =>
      old.logs != logs || old.period != period;
}
