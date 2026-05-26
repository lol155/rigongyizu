import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Shanghai'));
    } catch (_) {
      tz.setLocalLocation(tz.local);
    }
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings, iOS: DarwinInitializationSettings());
    await _plugin.initialize(settings: settings);
    _initialized = true;
  }

  static Future<void> showTestNotification() async {
    _ensureInitialized();
    const androidDetails = AndroidNotificationDetails(
      'test', '测试通知',
      importance: Importance.defaultImportance,
    );
    const details = NotificationDetails(android: androidDetails, iOS: DarwinNotificationDetails());
    await _plugin.show(id: 0, title: '日拱一卒', body: '通知功能已开启 ✅', notificationDetails: details);
  }

  static Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime time,
  }) async {
    _ensureInitialized();
    final scheduledDate = tz.TZDateTime.from(time, tz.local);
    final nextRun = scheduledDate.isBefore(tz.TZDateTime.now(tz.local))
        ? tz.TZDateTime.now(tz.local).add(const Duration(seconds: 1))
        : scheduledDate;
    const androidDetails = AndroidNotificationDetails(
      'reminders', '任务提醒',
      channelDescription: '任务开始前提醒',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails, iOS: DarwinNotificationDetails());
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: nextRun,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> scheduleMorningReminder({
    int hour = 8,
    int minute = 0,
    String title = '☀️ 晨间反思时间',
    String body = '新的一天，花3分钟规划今天吧！',
  }) async {
    await _scheduleDailyReminder(id: 9001, hour: hour, minute: minute, title: title, body: body);
  }

  static Future<void> scheduleEveningReminder({
    int hour = 21,
    int minute = 0,
    String title = '🌙 晚间复盘时间',
    String body = '今天过得怎么样？花3分钟复盘一下',
  }) async {
    await _scheduleDailyReminder(id: 9002, hour: hour, minute: minute, title: title, body: body);
  }

  static Future<void> ensureRecurringRemindersScheduled() async {
    _ensureInitialized();
    await scheduleMorningReminder();
    await scheduleEveningReminder();
  }

  @Deprecated('Use scheduleMorningReminder')
  static Future<void> showMorningReminder() async {
    await scheduleMorningReminder();
  }

  @Deprecated('Use scheduleEveningReminder')
  static Future<void> showEveningReminder() async {
    await scheduleEveningReminder();
  }

  static Future<void> showGoalDeadlineReminder(String goalTitle) async {
    await show(id: 9003, title: '🎯 目标即将到期', body: '「$goalTitle」即将到期，加油！');
  }

  static Future<void> show({required int id, required String title, required String body}) async {
    _ensureInitialized();
    const androidDetails = AndroidNotificationDetails(
      'reminders', '提醒',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails, iOS: DarwinNotificationDetails());
    await _plugin.show(id: id, title: title, body: body, notificationDetails: details);
  }

  static Future<void> _scheduleDailyReminder({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    _ensureInitialized();
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    const androidDetails = AndroidNotificationDetails(
      'reminders', '任务提醒',
      channelDescription: '任务开始前提醒',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails, iOS: DarwinNotificationDetails());
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancelAll() async {
    _ensureInitialized();
    await _plugin.cancelAll();
  }

  static void _ensureInitialized() {
    if (!_initialized) {
      throw StateError('通知服务尚未初始化');
    }
  }
}
