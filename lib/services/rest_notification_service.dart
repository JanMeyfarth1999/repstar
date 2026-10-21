import 'package:timezone/timezone.dart' as timezone;
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;

/// Verwaltet die Benachrichtigungen für Satzpausen.
class RestNotificationService {
  RestNotificationService._();

  /// Alle Bildschirme verwenden denselben Dienst.
  static final RestNotificationService instance = RestNotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Eine feste Kennung für das jeweils aktuelle Pausensignal.
  static const int _restNotificationId = 1;

  /// Führt Änderungen nacheinander aus, auch bei schnellen Tastendrücken.
  Future<void> _pendingUpdate = Future<void>.value();

  /// Bereitet das Paket einmalig für Android und iOS vor.
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    // Dieser Dienst wird zunächst nur für die Handy-App eingerichtet.
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return;
    }

    // Lädt die Zeitdaten für später geplante Benachrichtigungen.
    tz.initializeTimeZones();

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('ic_stat_rest'),
      iOS: DarwinInitializationSettings(
        // Die Erlaubnis fragen wir später passend zum Pausentimer ab.
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _notifications.initialize(settings: settings);
    _isInitialized = true;
  }

  /// Fragt die benötigten Freigaben auf der jeweiligen Plattform ab.
  Future<bool> requestPermissions() async {
    await initialize();

    if (!_isInitialized) {
      return false;
    }

    final android = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (android != null) {
      final notificationsAllowed =
          await android.requestNotificationsPermission() ?? false;

      if (!notificationsAllowed) {
        return false;
      }

      // Die Systemeinstellungen nur öffnen, wenn die Freigabe noch fehlt.
      final exactAllowed =
          await android.canScheduleExactNotifications() ?? false;

      if (!exactAllowed) {
        await android.requestExactAlarmsPermission();
      }

      return await android.canScheduleExactNotifications() ?? false;
    }

    final ios = _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    if (ios != null) {
      return await ios.requestPermissions(
            alert: true,
            sound: true,
            badge: false,
          ) ??
          false;
    }

    return false;
  }

  /// Plant das Pausenende. Mit null wird das Signal nur gelöscht.
  Future<void> updateRestNotification(DateTime? endsAt) {
    final update = _pendingUpdate.then<void>((_) async {
      await initialize();

      if (!_isInitialized) {
        return;
      }

      // Ein bisheriges Signal zuerst entfernen.
      await _notifications.cancel(id: _restNotificationId);

      // Keine neue Benachrichtigung für eine bereits abgelaufene Pause.
      if (endsAt == null || !endsAt.isAfter(DateTime.now())) {
        return;
      }

      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          'repstar_rest_end',
          'Pausentimer',
          channelDescription: 'Signal am Ende einer Satzpause',
          icon: 'ic_stat_rest',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          presentBadge: false,
          sound: 'default',
        ),
      );

      await _notifications.zonedSchedule(
        id: _restNotificationId,
        title: 'Pause vorbei',
        body: 'Dein nächster Satz kann starten.',
        // UTC bildet denselben Zeitpunkt unabhängig von der Ortszeit ab.
        scheduledDate: timezone.TZDateTime.from(endsAt.toUtc(), timezone.UTC),
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    });

    // Ein fehlgeschlagener Auftrag darf spätere Änderungen nicht blockieren.
    _pendingUpdate = update.then<void>(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {},
    );

    // Der Aufrufer erhält Fehler trotzdem und kann sie sichtbar melden.
    return update;
  }
}
