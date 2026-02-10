import 'package:flutter_foreground_task/flutter_foreground_task.dart';

class SosForegroundService {
  static void init() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'sos_channel',
        channelName: 'SOS Active',
        channelDescription: 'Keeps SOS countdown active',
        channelImportance: NotificationChannelImportance.HIGH,
        priority: NotificationPriority.HIGH,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
        ),
      ),

      // ✅ REQUIRED even for Android
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: true,
      ),

      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 5000,
        isOnceEvent: false,
        autoRunOnBoot: false,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  static Future<void> start() async {
    await FlutterForegroundTask.startService(
      notificationTitle: 'SOS Countdown Active',
      notificationText: 'Emergency SOS will trigger shortly',
    );
  }

  static Future<void> stop() async {
    await FlutterForegroundTask.stopService();
  }
}
