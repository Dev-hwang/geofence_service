1. As it changes from existing `IntentService` to `JobIntentService`, you need to add below permission.

```
<uses-permission android:name="android.permission.WAKE_LOCK" />
```

2. The package name of Foreground Service and Activity Recognition has been changed on the Android platform.

```
<!-- Deprecated: Version 2.1.4 or earlier
<service
    android:name="com.pravera.geofence_service.foreground_service.ForegroundService"
    android:stopWithTask="true" /> 

<service
    android:name="com.pravera.geofence_service.activity_recognition.ActivityRecognitionIntentService"
    android:stopWithTask="true" />
-->

<service
    android:name="com.pravera.flutter_foreground_task.service.ForegroundService"
    android:stopWithTask="true" />

<receiver
    android:name="com.pravera.flutter_activity_recognition.service.ActivityRecognitionIntentReceiver" />

<service
    android:name="com.pravera.flutter_activity_recognition.service.ActivityRecognitionIntentService"
    android:permission="android.permission.BIND_JOB_SERVICE"
    android:stopWithTask="true" />
```

3. `Position` added to `GeofenceStatusChanged` callback function.

```dart
Future<void> _onGeofenceStatusChanged(
    Geofence geofence,
    GeofenceRadius geofenceRadius,
    GeofenceStatus geofenceStatus,
    Position position) async {
  dev.log('geofence: ${geofence.toMap()}');
  dev.log('geofenceRadius: ${geofenceRadius.toMap()}');
  dev.log('geofenceStatus: ${geofenceStatus.toString()}\n');
  _geofenceStreamController.sink.add(geofence);
}
```

4. The `WithForegroundService` widget was removed and the `WillStartForegroundTask` widget with improved performance was added.

```dart
@override
Widget build(BuildContext context) {
  return MaterialApp(
    // A widget used when you want to start a foreground task when trying to minimize or close the app.
    // Declare on top of the [Scaffold] widget.
    home: WillStartForegroundTask(
      onWillStart: () {
        // You can add a foreground task start condition.
        return _geofenceService.isRunningService;
      },
      notificationOptions: NotificationOptions(
        channelId: 'geofence_service_notification_channel',
        channelName: 'Geofence Service Notification',
        channelDescription: 'This notification appears when the geofence service is running in the background.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW
      ),
      notificationTitle: 'Geofence Service is running',
      notificationText: 'Tap to return to the app',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Geofence Service'),
          centerTitle: true
        ),
        body: _buildContentView()
      ),
    ),
  );
}
```
