import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

part 'notification_service.g.dart';

// ══════════════════════════════════════════════════════════════════════════════
// ── 알림 ID 관리 ─────────────────────────────────────────────────────────────
// ══════════════════════════════════════════════════════════════════════════════

/// 알림 ID 상수 — 고정 ID 영역으로 충돌 방지
///
/// [baseId] 부터 시작하는 범위 예약:
///   dailyPrompt      : 1000
///   capsule          : 2000 ~ 2999 (개별 캡슐 id.hashCode % 1000 + 2000)
///   birthdayDDay     : 3000 ~ 3999
///   birthdayDMinus1  : 4000 ~ 4999
///   hyodoNudge       : 5000
///   voiceLegacy      : 6000 ~ 6999
///   memorialAnniv    : 7000 ~ 7999
enum NotificationId {
  dailyPrompt(1000),
  capsuleBase(2000),
  birthdayDDayBase(3000),
  birthdayDMinus1Base(4000),
  hyodoNudge(5000),
  voiceLegacyBase(6000),
  memorialAnnivBase(7000);

  const NotificationId(this.baseId);
  final int baseId;

  /// 동적 ID 생성 (개별 항목 구분)
  int forItem(String itemId) => baseId + (itemId.hashCode.abs() % 999) + 1;
}

// ══════════════════════════════════════════════════════════════════════════════
// ── Android 채널 정의 ────────────────────────────────────────────────────────
// ══════════════════════════════════════════════════════════════════════════════

class _Channels {
  static const daily = AndroidNotificationChannel(
    're_link_daily',
    '일일 알림',
    description: '매일 오전 가족 질문 알림',
    importance: Importance.defaultImportance,
  );

  static const event = AndroidNotificationChannel(
    're_link_event',
    '이벤트 알림',
    description: '생일, 기일, 캡슐 열림 등 이벤트 알림',
    importance: Importance.high,
  );

  static const nudge = AndroidNotificationChannel(
    're_link_nudge',
    '넛지 알림',
    description: '가족 온도 리마인더',
    importance: Importance.low,
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// ── NotificationService ──────────────────────────────────────────────────────
// ══════════════════════════════════════════════════════════════════════════════

@Riverpod(keepAlive: true)
NotificationService notificationService(Ref ref) => NotificationService();

/// 로컬 알림 통합 서비스
///
/// - Android: 3개 채널 (daily / event / nudge)
/// - iOS: 카테고리 매핑, 권한 요청
/// - timezone 기반 정확한 시간 스케줄링
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // ── 초기화 ──────────────────────────────────────────────────────────────────

  /// 알림 시스템 초기화
  ///
  /// 앱 시작 시 1회 호출. timezone 초기화 + 플랫폼별 설정.
  Future<void> init() async {
    if (_initialized) return;

    // timezone 초기화 (flutter_local_notifications 필수)
    tz.initializeTimeZones();
    // 한국 시간대 설정 (KST, Asia/Seoul)
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false, // 온보딩에서 수동 요청
      requestBadgePermission: false,
      requestSoundPermission: false,
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Android 채널 생성
    if (Platform.isAndroid) {
      final androidPlugin =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(_Channels.daily);
        await androidPlugin.createNotificationChannel(_Channels.event);
        await androidPlugin.createNotificationChannel(_Channels.nudge);
      }
    }

    _initialized = true;
    debugPrint('[NotificationService] initialized');
  }

  /// 알림 탭 핸들러 — 기본적으로 앱을 포그라운드로 가져옴
  void _onNotificationTap(NotificationResponse response) {
    debugPrint('[NotificationService] tapped: ${response.payload}');
    // 딥링크가 필요한 경우 payload로 라우팅 가능
  }

  // ── 권한 요청 ───────────────────────────────────────────────────────────────

  /// iOS/Android 13+ 알림 권한 요청
  ///
  /// Returns `true` if permission is granted.
  Future<bool> requestPermission() async {
    if (Platform.isIOS) {
      final iosPlugin =
          _plugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      final granted = await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    if (Platform.isAndroid) {
      final androidPlugin =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final granted =
          await androidPlugin?.requestNotificationsPermission();
      return granted ?? false;
    }

    return false;
  }

  // ── 스케줄링 API ───────────────────────────────────────────────────────────

  /// 매일 특정 시각에 반복 알림
  Future<void> scheduleDailyAt({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String channelId = 're_link_daily',
    String? payload,
  }) async {
    await _ensureInit();
    final scheduledDate = _nextInstanceOfTime(hour, minute);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      _details(channelId: channelId),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
    debugPrint(
      '[NotificationService] scheduleDailyAt id=$id at $hour:$minute',
    );
  }

  /// 특정 날짜/시각에 1회 알림
  Future<void> scheduleAt({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
    String channelId = 're_link_event',
    String? payload,
  }) async {
    await _ensureInit();

    // 과거 시각이면 스킵
    final scheduledDate = tz.TZDateTime.from(dateTime, tz.local);
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
      debugPrint('[NotificationService] scheduleAt skipped (past): $dateTime');
      return;
    }

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      _details(channelId: channelId),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
    debugPrint('[NotificationService] scheduleAt id=$id at $dateTime');
  }

  /// 매주 특정 요일/시각에 반복 알림
  Future<void> scheduleWeekly({
    required int id,
    required String title,
    required String body,
    required int dayOfWeek, // 1=Mon ... 7=Sun (ISO 8601)
    required int hour,
    required int minute,
    String channelId = 're_link_nudge',
    String? payload,
  }) async {
    await _ensureInit();
    final scheduledDate = _nextInstanceOfWeekday(dayOfWeek, hour, minute);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      _details(channelId: channelId),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: payload,
    );
    debugPrint(
      '[NotificationService] scheduleWeekly id=$id day=$dayOfWeek $hour:$minute',
    );
  }

  /// 매년 특정 날짜 반복 알림 (생일, 기일)
  Future<void> scheduleYearly({
    required int id,
    required String title,
    required String body,
    required int month,
    required int day,
    int hour = 9,
    int minute = 0,
    String channelId = 're_link_event',
    String? payload,
  }) async {
    await _ensureInit();
    final scheduledDate = _nextInstanceOfDate(month, day, hour, minute);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      _details(channelId: channelId),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
      payload: payload,
    );
    debugPrint(
      '[NotificationService] scheduleYearly id=$id $month/$day $hour:$minute',
    );
  }

  /// 알림 취소
  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
    debugPrint('[NotificationService] cancel id=$id');
  }

  /// 모든 알림 취소
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
    debugPrint('[NotificationService] cancelAll');
  }

  // ── 헬퍼 ───────────────────────────────────────────────────────────────────

  Future<void> _ensureInit() async {
    if (!_initialized) await init();
  }

  /// Android NotificationDetails 생성
  NotificationDetails _details({required String channelId}) {
    String channelName;
    Importance importance;
    switch (channelId) {
      case 're_link_daily':
        channelName = '일일 알림';
        importance = Importance.defaultImportance;
        break;
      case 're_link_event':
        channelName = '이벤트 알림';
        importance = Importance.high;
        break;
      case 're_link_nudge':
        channelName = '넛지 알림';
        importance = Importance.low;
        break;
      default:
        channelName = '알림';
        importance = Importance.defaultImportance;
    }

    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        importance: importance,
        priority: importance == Importance.high
            ? Priority.high
            : Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  /// 다음 [hour]:[minute] 시각의 TZDateTime 반환
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day,
        hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  /// 다음 [dayOfWeek] (ISO 8601: 1=Mon ... 7=Sun) [hour]:[minute]
  tz.TZDateTime _nextInstanceOfWeekday(int dayOfWeek, int hour, int minute) {
    var scheduled = _nextInstanceOfTime(hour, minute);
    // DateTime.weekday: 1=Mon ... 7=Sun (ISO 8601과 동일)
    while (scheduled.weekday != dayOfWeek) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  /// 다음 [month]/[day] 일자의 TZDateTime 반환
  tz.TZDateTime _nextInstanceOfDate(int month, int day, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, month, day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = tz.TZDateTime(tz.local, now.year + 1, month, day, hour,
          minute);
    }
    return scheduled;
  }
}
