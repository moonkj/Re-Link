import 'dart:io';

import 'package:flutter/material.dart';

/// 포스터 스타일 4종
enum PosterStyle {
  vintage('빈티지'),
  modern('모던'),
  emotional('감성'),
  minimal('미니멀');

  const PosterStyle(this.label);
  final String label;
}

/// 포스터 카드 — RepaintBoundary 내부에 배치하여 캡처
class PosterCard extends StatelessWidget {
  const PosterCard({
    super.key,
    required this.style,
    required this.title,
    required this.nodeName,
    this.description,
    this.photoPath,
    this.dateTaken,
  });

  final PosterStyle style;
  final String title;
  final String nodeName;
  final String? description;
  final String? photoPath;
  final DateTime? dateTaken;

  String _formatDate(DateTime dt) =>
      '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';

  String _excerpt(String text, [int maxLen = 100]) =>
      text.length > maxLen ? '${text.substring(0, maxLen)}…' : text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1080 / 3, // 360pt — 캡처 시 3× → 1080px
      height: 1350 / 3, // 450pt — 캡처 시 3× → 1350px
      child: switch (style) {
        PosterStyle.vintage => _VintagePoster(card: this),
        PosterStyle.modern => _ModernPoster(card: this),
        PosterStyle.emotional => _EmotionalPoster(card: this),
        PosterStyle.minimal => _MinimalPoster(card: this),
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── Vintage — 세피아 톤, 필름 스트립 보더, 스크립트 타이틀 ──────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _VintagePoster extends StatelessWidget {
  const _VintagePoster({required this.card});
  final PosterCard card;

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFF5E6D3);
    const textColor = Color(0xFF4A3728);
    const accentColor = Color(0xFFAA8866);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Stack(
        children: [
          // 필름 스트립 데코 — 좌우
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 12,
            child: _FilmStrip(color: accentColor.withAlpha(60)),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 12,
            child: _FilmStrip(color: accentColor.withAlpha(60)),
          ),

          // 본문
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 스크립트 타이틀
                Text(
                  'Memories',
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w300,
                    color: accentColor,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 6),
                Container(height: 0.5, width: 40, color: accentColor.withAlpha(100)),
                const SizedBox(height: 12),

                // 사진
                if (card.photoPath != null) ...[
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: Image.file(
                        File(card.photoPath!),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        cacheWidth: 800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ] else
                  const Spacer(),

                // 제목
                Text(
                  card.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // 이름 + 날짜
                Text(
                  '— ${card.nodeName}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: textColor.withAlpha(180),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                if (card.dateTaken != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    card._formatDate(card.dateTaken!),
                    style: TextStyle(fontSize: 10, color: textColor.withAlpha(140)),
                  ),
                ],

                // 설명
                if (card.description != null && card.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    card._excerpt(card.description!),
                    style: TextStyle(
                      fontSize: 11,
                      color: textColor.withAlpha(160),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: 8),
                // 워터마크
                Text(
                  'Re-Link에서 우리 가족 이야기를 기록하고 있어요',
                  style: TextStyle(
                    fontSize: 8,
                    color: accentColor.withAlpha(100),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 필름 스트립 데코레이션
class _FilmStrip extends StatelessWidget {
  const _FilmStrip({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        20,
        (i) => Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 2),
            decoration: BoxDecoration(
              color: i.isEven ? color : Colors.transparent,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── Modern — 클린 화이트, 기하학적 악센트 ─────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _ModernPoster extends StatelessWidget {
  const _ModernPoster({required this.card});
  final PosterCard card;

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFFFFFFF);
    const textColor = Color(0xFF1A1A1A);
    const accentColor = Color(0xFF6EC6CA);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 기하학 악센트 — 작은 사각형
            Row(
              children: [
                Container(width: 8, height: 8, color: accentColor),
                const SizedBox(width: 6),
                Container(width: 16, height: 2, color: accentColor.withAlpha(120)),
              ],
            ),
            const SizedBox(height: 16),

            // 사진
            if (card.photoPath != null) ...[
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: Image.file(
                    File(card.photoPath!),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    cacheWidth: 800,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ] else
              const Spacer(),

            // 제목
            Text(
              card.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textColor,
                height: 1.3,
                letterSpacing: -0.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            // 구분선
            Container(height: 1, width: 24, color: accentColor),
            const SizedBox(height: 8),

            // 이름
            Text(
              card.nodeName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: textColor.withAlpha(180),
              ),
            ),

            // 날짜
            if (card.dateTaken != null) ...[
              const SizedBox(height: 2),
              Text(
                card._formatDate(card.dateTaken!),
                style: TextStyle(
                  fontSize: 10,
                  color: textColor.withAlpha(130),
                  letterSpacing: 0.5,
                ),
              ),
            ],

            // 설명
            if (card.description != null && card.description!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                card._excerpt(card.description!),
                style: TextStyle(
                  fontSize: 11,
                  color: textColor.withAlpha(160),
                  height: 1.6,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 12),

            // 워터마크
            Text(
              'Re-Link에서 우리 가족 이야기를 기록하고 있어요',
              style: TextStyle(
                fontSize: 8,
                color: textColor.withAlpha(80),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── Emotional — 핑크→라벤더 그라디언트, 인용부호, 드리미 ────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _EmotionalPoster extends StatelessWidget {
  const _EmotionalPoster({required this.card});
  final PosterCard card;

  @override
  Widget build(BuildContext context) {
    const textColor = Color(0xFFFFFFFF);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF8B4C8), // 핑크
            Color(0xFFD4A5E5), // 라벤더
            Color(0xFFB8C6F0), // 연보라-파랑
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),

            // 사진 (원형 마스크)
            if (card.photoPath != null) ...[
              Expanded(
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      File(card.photoPath!),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      cacheWidth: 800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ] else
              const Spacer(),

            // 인용부호 + 제목
            Text(
              '"',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w300,
                color: textColor.withAlpha(180),
                height: 0.6,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              card.title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: textColor,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),

            // 이름
            Text(
              '— ${card.nodeName}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: textColor.withAlpha(200),
              ),
            ),

            // 날짜
            if (card.dateTaken != null) ...[
              const SizedBox(height: 2),
              Text(
                card._formatDate(card.dateTaken!),
                style: TextStyle(fontSize: 10, color: textColor.withAlpha(160)),
              ),
            ],

            // 설명
            if (card.description != null && card.description!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                '「${card._excerpt(card.description!, 80)}」',
                style: TextStyle(
                  fontSize: 11,
                  color: textColor.withAlpha(200),
                  height: 1.6,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 12),

            // 워터마크
            Text(
              'Re-Link에서 우리 가족 이야기를 기록하고 있어요',
              style: TextStyle(
                fontSize: 8,
                color: textColor.withAlpha(100),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── Minimal — 퓨어 화이트, 싱글 악센트 라인, 큰 여백 ──────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _MinimalPoster extends StatelessWidget {
  const _MinimalPoster({required this.card});
  final PosterCard card;

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFFFFFFF);
    const textColor = Color(0xFF2C2C2C);
    const lineColor = Color(0xFF6EC6CA);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 사진
            if (card.photoPath != null) ...[
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: Image.file(
                    File(card.photoPath!),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    cacheWidth: 800,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ] else
              const Spacer(),

            // 악센트 라인
            Container(height: 2, width: 32, color: lineColor),
            const SizedBox(height: 12),

            // 제목
            Text(
              card.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),

            // 이름 + 날짜
            Row(
              children: [
                Text(
                  card.nodeName,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: textColor.withAlpha(150),
                  ),
                ),
                if (card.dateTaken != null) ...[
                  Text(
                    '  ·  ',
                    style: TextStyle(fontSize: 11, color: textColor.withAlpha(100)),
                  ),
                  Text(
                    card._formatDate(card.dateTaken!),
                    style: TextStyle(
                      fontSize: 11,
                      color: textColor.withAlpha(130),
                    ),
                  ),
                ],
              ],
            ),

            // 설명
            if (card.description != null && card.description!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                card._excerpt(card.description!),
                style: TextStyle(
                  fontSize: 11,
                  color: textColor.withAlpha(140),
                  height: 1.6,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 16),

            // 워터마크
            Text(
              'Re-Link에서 우리 가족 이야기를 기록하고 있어요',
              style: TextStyle(
                fontSize: 8,
                color: textColor.withAlpha(70),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
