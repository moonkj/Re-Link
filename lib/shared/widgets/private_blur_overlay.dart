import 'dart:ui';
import 'package:flutter/material.dart';
import '../../design/tokens/app_colors.dart';
import '../../design/tokens/app_spacing.dart';

/// 비공개 기억 블러 오버레이
///
/// [child]를 감싸서 블러 처리 + 잠금 아이콘을 표시합니다.
/// [onTap] 콜백으로 탭 시 인증 흐름을 트리거합니다.
/// [message]로 오버레이 텍스트를 커스텀할 수 있습니다.
class PrivateBlurOverlay extends StatelessWidget {
  const PrivateBlurOverlay({
    super.key,
    required this.child,
    required this.onTap,
    this.message = '비공개 기억',
    this.blurSigma = 15.0,
    this.borderRadius = BorderRadius.zero,
    this.showMessage = true,
    this.iconSize = 24.0,
  });

  /// 블러 처리할 원본 콘텐츠
  final Widget child;

  /// 오버레이 탭 시 콜백 (인증 시도)
  final VoidCallback onTap;

  /// 잠금 아이콘 아래 표시할 메시지
  final String message;

  /// 블러 강도 (기본 15)
  final double blurSigma;

  /// 클리핑 모서리 반경
  final BorderRadius borderRadius;

  /// 메시지 표시 여부 (그리드 썸네일 등 작은 영역에서는 false)
  final bool showMessage;

  /// 잠금 아이콘 크기
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            // 원본 콘텐츠 (블러 처리됨)
            child,

            // 블러 필터
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: blurSigma,
                  sigmaY: blurSigma,
                ),
                child: Container(
                  color: AppColors.bgBase.withAlpha(60),
                ),
              ),
            ),

            // 잠금 아이콘 + 메시지
            Positioned.fill(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: iconSize * 2,
                      height: iconSize * 2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accent.withAlpha(30),
                      ),
                      child: Icon(
                        Icons.lock_rounded,
                        color: AppColors.accent,
                        size: iconSize,
                      ),
                    ),
                    if (showMessage) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        message,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
