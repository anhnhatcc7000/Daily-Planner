import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notifications_tut/models/task.model.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> onDidReceiveNotification(
      NotificationResponse notificationResponse) async {
    print("Notification receive");
  }

  static Future<void> init() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings("app_icon_r");
    const DarwinInitializationSettings iOSInitializationSettings =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
      iOS: iOSInitializationSettings,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotification,
      onDidReceiveBackgroundNotificationResponse: onDidReceiveNotification,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> scheduleNotification(Task task) async {
    DateTime? reminderDateTime = task.getReminderDateTime();

    if (reminderDateTime != null) {
      print("Reminder DateTime: $reminderDateTime");

      if (reminderDateTime.isAfter(DateTime.now())) {
        final tz.TZDateTime scheduledDate =
            tz.TZDateTime.from(reminderDateTime, tz.local);
        print("Scheduled TZDateTime: $scheduledDate");

        await flutterLocalNotificationsPlugin.zonedSchedule(
          task.id!,
          'Nhiệm vụ: ${task.content}', 
          'Nhiệm vụ đã tới, hoàn thành ngay nào!',
          scheduledDate, 
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'task_id', 
              'Nhiệm vụ',
              importance: Importance.max,
              priority: Priority.high,
              icon: "app_icon_r",
              showWhen:
                  true, 
            ),
          ),
          androidScheduleMode: AndroidScheduleMode
              .exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.wallClockTime,
        );

        print("Notification scheduled successfully.");
      } else {
        print(
            "Reminder time is in the past. No notification will be scheduled.");
      }
    } else {
      print("Error: reminderDateTime is null.");
    }
  }
}
