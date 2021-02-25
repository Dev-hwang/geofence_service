import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:geofence_service/models/activity.dart';
import 'package:geofence_service/models/permission_result.dart';

/// ActivityRecognition
class ActivityRecognition {
  static final _mChannel = MethodChannel(
      'geofence_service/activity_recognition');
  static final _eChannel = EventChannel(
      'geofence_service/activity_recognition_updates');

  /// Return a stream that can receive activity.
  static Stream<Activity> getActivityStream() {
    return _eChannel.receiveBroadcastStream().map((value) {
      final activityDataMap = Map<String, dynamic>.from(jsonDecode(value));
      return Activity.fromMap(activityDataMap);
    });
  }

  /// Check the activity recognition permission and return the result.
  static Future<PermissionResult> checkPermission() async {
    String permissionResult = await _mChannel.invokeMethod(
        'checkActivityRecognitionPermission');
    return getPermissionResultFromString(permissionResult);
  }

  /// Request the activity recognition permission and return the result.
  static Future<PermissionResult> requestPermission() async {
    String permissionResult;
    if (Platform.isAndroid)
      permissionResult = await _mChannel.invokeMethod(
          'requestActivityRecognitionPermission');
    else
      permissionResult = await _mChannel.invokeMethod(
          'checkActivityRecognitionPermission');
    return getPermissionResultFromString(permissionResult);
  }
}
