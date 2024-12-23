import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:medication/models/medication.dart';
import 'package:medication/services/notification_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:timezone/data/latest.dart' as tz;

@GenerateMocks([FlutterLocalNotificationsPlugin])
import 'notification_service_test.mocks.dart';

void main() {
  late NotificationService notificationService;
  late MockFlutterLocalNotificationsPlugin mockNotificationsPlugin;

  setUp(() {
    tz.initializeTimeZones();
    mockNotificationsPlugin = MockFlutterLocalNotificationsPlugin();
    NotificationService.resetInstance();
    notificationService = NotificationService.test(mockNotificationsPlugin);
  });

  group('NotificationService', () {
    test('should initialize notifications correctly', () async {
      when(mockNotificationsPlugin.initialize(
        any,
        onDidReceiveNotificationResponse:
            anyNamed('onDidReceiveNotificationResponse'),
        onDidReceiveBackgroundNotificationResponse:
            anyNamed('onDidReceiveBackgroundNotificationResponse'),
      )).thenAnswer((_) async => true);

      when(mockNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>())
          .thenReturn(null);

      when(mockNotificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>())
          .thenReturn(null);

      await notificationService.init();

      verify(mockNotificationsPlugin.initialize(
        any,
        onDidReceiveNotificationResponse:
            anyNamed('onDidReceiveNotificationResponse'),
        onDidReceiveBackgroundNotificationResponse:
            anyNamed('onDidReceiveBackgroundNotificationResponse'),
      )).called(1);
    });

    test('should schedule medication notification correctly', () async {
      final medication = Medication(
        id: 1,
        name: 'Test Med',
        type: 'Tablet',
        dosage: 1,
        reminderTimes: [const TimeOfDay(hour: 8, minute: 0)],
        frequencyType: 'Every Day',
        selectedDays: [1, 2, 3, 4, 5, 6, 7],
        duration: '1 Month',
        hasAlarm: true,
        snoozeTime: '5 min',
        remainingQuantity: 30,
      );

      final scheduledDate = DateTime.now().add(const Duration(days: 1));

      when(mockNotificationsPlugin.zonedSchedule(
        any,
        any,
        any,
        any,
        any,
        androidScheduleMode: anyNamed('androidScheduleMode'),
        uiLocalNotificationDateInterpretation:
            anyNamed('uiLocalNotificationDateInterpretation'),
        matchDateTimeComponents: anyNamed('matchDateTimeComponents'),
      )).thenAnswer((_) async {
        return null;
      });

      await notificationService.scheduleMedicationNotification(
        medication,
        scheduledDate,
        1,
      );

      verify(mockNotificationsPlugin.zonedSchedule(
        any,
        any,
        any,
        any,
        any,
        androidScheduleMode: anyNamed('androidScheduleMode'),
        uiLocalNotificationDateInterpretation:
            anyNamed('uiLocalNotificationDateInterpretation'),
        matchDateTimeComponents: anyNamed('matchDateTimeComponents'),
      )).called(1);
    });

    test('should cancel notification correctly', () async {
      when(mockNotificationsPlugin.cancel(any)).thenAnswer((_) async {
        return null;
      });

      await notificationService.cancelNotification(1);

      verify(mockNotificationsPlugin.cancel(1)).called(1);
    });

    test('should cancel all notifications correctly', () async {
      when(mockNotificationsPlugin.cancelAll()).thenAnswer((_) async {
        return null;
      });

      await notificationService.cancelAllNotifications();

      verify(mockNotificationsPlugin.cancelAll()).called(1);
    });
  });
}
