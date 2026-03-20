import 'package:flutter/material.dart';

/// 아트 카드 스타일 (4종)
enum ArtStyle {
  watercolor('수채화', Icons.water_drop_outlined),
  minimal('미니멀', Icons.crop_square_outlined),
  hanji('한지', Icons.description_outlined),
  modern('모던', Icons.auto_awesome_outlined);

  const ArtStyle(this.label, this.icon);
  final String label;
  final IconData icon;
}

/// 아트 카드 스타일별 색상 팔레트
class ArtPalette {
  const ArtPalette({
    required this.background,
    required this.nodeFill,
    required this.nodeStroke,
    required this.edgeColor,
    required this.textColor,
    required this.accentColor,
  });
  final Color background;
  final Color nodeFill;
  final Color nodeStroke;
  final Color edgeColor;
  final Color textColor;
  final Color accentColor;

  static ArtPalette forStyle(ArtStyle style) => switch (style) {
    ArtStyle.watercolor => const ArtPalette(
      background: Color(0xFFF5F0EB),
      nodeFill: Color(0x306EC6CA),
      nodeStroke: Color(0xFF6EC6CA),
      edgeColor: Color(0x804A9EBF),
      textColor: Color(0xFF3D3D3D),
      accentColor: Color(0xFFF4845F),
    ),
    ArtStyle.minimal => const ArtPalette(
      background: Color(0xFFFFFFFF),
      nodeFill: Color(0xFFF5F7FA),
      nodeStroke: Color(0xFF1A1A2E),
      edgeColor: Color(0xFF1A1A2E),
      textColor: Color(0xFF1A1A2E),
      accentColor: Color(0xFF6EC6CA),
    ),
    ArtStyle.hanji => const ArtPalette(
      background: Color(0xFFF5E6C8),
      nodeFill: Color(0x20704214),
      nodeStroke: Color(0xFF704214),
      edgeColor: Color(0xFF8B5E3C),
      textColor: Color(0xFF3E2723),
      accentColor: Color(0xFFC62828),
    ),
    ArtStyle.modern => const ArtPalette(
      background: Color(0xFF0D1117),
      nodeFill: Color(0xFF1E2840),
      nodeStroke: Color(0xFF6EC6CA),
      edgeColor: Color(0xFF4A9EBF),
      textColor: Color(0xFFFFFFFF),
      accentColor: Color(0xFFFF9970),
    ),
  };
}
