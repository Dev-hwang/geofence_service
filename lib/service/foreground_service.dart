import 'dart:io';
import 'package:flutter/services.dart';

/// ForegroundService
class ForegroundService {
  static final _mChannel = MethodChannel(
      'geofence_service/foreground_service');

  /// Start foreground service. Only works on Android.
  static void start({
    String? notificationChannelId,
    String? notificationChannelName,
    String? notificationContentTitle,
    String? notificationContentText
  }) async {
    if (Platform.isAndroid)
      _mChannel.invokeMethod('startForegroundService', {
        'notificationChannelId': notificationChannelId,
        'notificationChannelName': notificationChannelName,
        'notificationContentTitle': notificationContentTitle,
        'notificationContentText': notificationContentText
      });
  }

  /// Stop foreground service. Only works on Android.
  static void stop() async {
    if (Platform.isAndroid)
      _mChannel.invokeMethod('stopForegroundService');
  }

  /// Minimize without closing the app. Only works on Android.
  static void minimizeApp() {
    if (Platform.isAndroid)
      _mChannel.invokeMethod('minimizeApp');
  }
}
