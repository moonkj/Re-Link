import 'dart:io';
import 'package:flutter/material.dart';
import '../../../design/tokens/app_colors.dart';

/// 수평 드래그 디바이더로 두 사진을 비교하는 슬라이더 위젯
class ComparisonSlider extends StatefulWidget {
  const ComparisonSlider({
    super.key,
    required this.beforeImagePath,
    required this.afterImagePath,
    this.beforeLabel = '그때',
    this.afterLabel = '지금',
    this.initialRatio = 0.5,
    this.dividerWidth = 3.0,
    this.handleSize = 40.0,
  });

  final String beforeImagePath;
  final String afterImagePath;
  final String beforeLabel;
  final String afterLabel;
  final double initialRatio;
  final double dividerWidth;
  final double handleSize;

  @override
  State<ComparisonSlider> createState() => _ComparisonSliderState();
}

class _ComparisonSliderState extends State<ComparisonSlider> {
  late double _ratio;

  @override
  void initState() {
    super.initState();
    _ratio = widget.initialRatio;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final dividerX = width * _ratio;

        return GestureDetector(
          onHorizontalDragUpdate: (details) {
            setState(() {
              _ratio = (details.localPosition.dx / width).clamp(0.05, 0.95);
            });
          },
          child: Stack(
            children: [
              // 오른쪽 이미지 (After / 지금) — 전체 배경
              Positioned.fill(
                child: Image.file(
                  File(widget.afterImagePath),
                  fit: BoxFit.cover,
                ),
              ),

              // 왼쪽 이미지 (Before / 그때) — ClipRect로 잘라서 표시
              Positioned.fill(
                child: ClipRect(
                  clipper: _LeftClipper(dividerX),
                  child: Image.file(
                    File(widget.beforeImagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // "그때" 라벨 (좌측 상단)
              Positioned(
                top: 16,
                left: 16,
                child: _Label(text: widget.beforeLabel),
              ),

              // "지금" 라벨 (우측 상단)
              Positioned(
                top: 16,
                right: 16,
                child: _Label(text: widget.afterLabel),
              ),

              // 수직 디바이더 라인
              Positioned(
                left: dividerX - widget.dividerWidth / 2,
                top: 0,
                bottom: 0,
                child: Container(
                  width: widget.dividerWidth,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(80),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),

              // 그랩 핸들 (원형)
              Positioned(
                left: dividerX - widget.handleSize / 2,
                top: height / 2 - widget.handleSize / 2,
                child: Container(
                  width: widget.handleSize,
                  height: widget.handleSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: AppColors.primary,
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(60),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.swap_horiz_rounded,
                    size: 22,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 왼쪽 영역만 보여주는 CustomClipper
class _LeftClipper extends CustomClipper<Rect> {
  const _LeftClipper(this.dividerX);
  final double dividerX;

  @override
  Rect getClip(Size size) => Rect.fromLTRB(0, 0, dividerX, size.height);

  @override
  bool shouldReclip(covariant _LeftClipper oldClipper) =>
      oldClipper.dividerX != dividerX;
}

/// 반투명 라벨 칩
class _Label extends StatelessWidget {
  const _Label({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(140),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
