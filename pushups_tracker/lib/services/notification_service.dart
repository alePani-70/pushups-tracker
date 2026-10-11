import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  /// Reserved id for the single "rest is over" alert.
  static const int restEndId = 900001;

  /// Day-before reminders use `dayBeforeIdBase + slot.id`.
  static const int dayBeforeIdBase = 1000000;

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _plugin.initialize(initSettings);
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    if (Platform.isIOS) {
      final result = await _plugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return result ?? false;
    } else if (Platform.isAndroid) {
      final androidPlugin =
          _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final result = await androidPlugin?.requestNotificationsPermission();
      return result ?? false;
    }
    return false;
  }

  static const _workoutDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'pushups_workout_channel',
      'Workout Reminders',
      channelDescription: 'Reminders for upcoming pushup workouts and tests',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  static const _restDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'pushups_rest_channel',
      'Rest Timer',
      channelDescription: 'Alert when the rest between sets is over',
      importance: Importance.max,
      priority: Priority.max,
      category: AndroidNotificationCategory.alarm,
      enableVibration: true,
      playSound: true,
      timeoutAfter: 60000,
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    ),
  );

  Future<void> scheduleWorkoutReminder({
    required int id,
    required DateTime scheduledDate,
    required String title,
    required String body,
    String? payload,
  }) =>
      _schedule(id: id, at: scheduledDate, title: title, body: body, details: _workoutDetails, payload: payload);

  /// One-off alert at the end of the current rest. Replaces any previous one.
  Future<void> scheduleRestEnd({required DateTime at, required String body}) => _schedule(
        id: restEndId,
        at: at,
        title: '⏱ Rest over',
        body: body,
        details: _restDetails,
        payload: 'rest_end',
      );

  Future<void> cancelRestEnd() => _plugin.cancel(restEndId);

  Future<void> _schedule({
    required int id,
    required DateTime at,
    required String title,
    required String body,
    required NotificationDetails details,
    String? payload,
  }) async {
    // zonedSchedule throws for dates in the past; silently skip those.
    if (!at.isAfter(DateTime.now())) return;
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(at, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  Future<void> cancelReminder(int id) => _plugin.cancel(id);

  Future<void> cancelAll() => _plugin.cancelAll();

  Future<List<PendingNotificationRequest>> getPendingNotifications() => _plugin.pendingNotificationRequests();
}
