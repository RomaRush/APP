import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';

@pragma('vm:entry-point')
class BackgroundService {
  static const String notificationChannelId = 'daylo_foreground';
  static const int notificationId = 888;

  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    /// OPTIONAL, can be disabled
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      notificationChannelId, // id
      'DAYLO Service', // title
      description: 'This channel is used for important notifications.', // description
      importance: Importance.low, // importance must be at least low to show notification
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        // this will be executed when app is in foreground or background in separated isolate
        onStart: onStart,

        // auto start service
        autoStart: true,
        isForegroundMode: true,

        notificationChannelId: notificationChannelId,
        initialNotificationTitle: 'DAYLO is active',
        initialNotificationContent: 'Running in background',
        foregroundServiceNotificationId: notificationId,
      ),
      iosConfiguration: IosConfiguration(
        // auto start service
        autoStart: true,

        // this will be executed when app is in foreground or background in separated isolate
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );

    service.startService();
  }

  // to ensure this is executed in main isolate
  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();

    return true;
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    // Only available for flutter 3.0.0 and later
    DartPluginRegistrant.ensureInitialized();

    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
      });

      service.on('setAsBackground').listen((event) {
        service.setAsBackgroundService();
      });
    }

    service.on('stopService').listen((event) {
      service.stopSelf();
    });

    // bring to foreground
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (service is AndroidServiceInstance) {
        if (await service.isForegroundService()) {
          // if you want to update notification content
          /*
          flutterLocalNotificationsPlugin.show(
            notificationId,
            'DAYLO',
            'Service is running: ${DateTime.now()}',
            const NotificationDetails(
              android: AndroidNotificationDetails(
                notificationChannelId,
                'DAYLO Service',
                icon: 'ic_bg_service_small',
                ongoing: true,
              ),
            ),
          );
          */
        }
      }

      /// you can do some sync here
      print('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');

      // test event
      service.invoke(
        'update',
        {
          "current_date": DateTime.now().toIso8601String(),
        },
      );
    });
  }
}
