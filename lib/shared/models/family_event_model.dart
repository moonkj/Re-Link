import 'package:flutter/material.dart';

/// 가족 일정 도메인 모델
class FamilyEventModel {
  final String id;
  final String title;
  final String? description;
  final DateTime eventDate;
  final bool isYearly;
  final Color color;
  final String? nodeId;
  final DateTime createdAt;

  const FamilyEventModel({
    required this.id,
    required this.title,
    this.description,
    required this.eventDate,
    this.isYearly = false,
    this.color = const Color(0xFF8B5CF6),
    this.nodeId,
    required this.createdAt,
  });

  /// 다음 일정까지 남은 일수 (매년 반복 일정은 올해/내년 기준)
  int get daysUntil {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (isYearly) {
      var next = DateTime(now.year, eventDate.month, eventDate.day);
      if (next.isBefore(today)) {
        next = DateTime(now.year + 1, eventDate.month, eventDate.day);
      }
      return next.difference(today).inDays;
    }

    final eventDay =
        DateTime(eventDate.year, eventDate.month, eventDate.day);
    return eventDay.difference(today).inDays;
  }

  /// 오늘인지 여부
  bool get isToday => daysUntil == 0;

  /// 다음 일정 날짜
  DateTime get nextEventDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (isYearly) {
      var next = DateTime(now.year, eventDate.month, eventDate.day);
      if (next.isBefore(today)) {
        next = DateTime(now.year + 1, eventDate.month, eventDate.day);
      }
      return next;
    }
    return eventDate;
  }

  FamilyEventModel copyWith({
    String? title,
    String? description,
    DateTime? eventDate,
    bool? isYearly,
    Color? color,
    String? nodeId,
  }) {
    return FamilyEventModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      eventDate: eventDate ?? this.eventDate,
      isYearly: isYearly ?? this.isYearly,
      color: color ?? this.color,
      nodeId: nodeId ?? this.nodeId,
      createdAt: createdAt,
    );
  }

  /// hex → Color 변환
  static Color colorFromHex(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 7) buffer.write('FF');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Color → hex 변환
  static String colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
  }
}
