This plugin is a geofence service with activity recognition API. It does not use the Geofence API implemented on the platform. Therefore, battery efficiency cannot be guaranteed. Instead, this plugin can provide more accurate and real-time geofancing by navigating your location while your app is alive.

[![pub package](https://img.shields.io/pub/v/geofence_service.svg)](https://pub.dev/packages/geofence_service)

## Features

* Geofence can have multiple radius.
* Get what activity took place when the device entered the radius.
* Listen to changes in user activity in real time.
* Service can be operated in the background using `WithForegroundService` widget.

## Getting started

To use this plugin, add `geofence_service` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/). For example:

```yaml
dependencies:
  geofence_service: ^2.0.5
```

After adding the `geofence_service` plugin to the flutter project, we need to specify the platform-specific permissions and services to use for this plugin to work properly.

### :baby_chick: Android

Since geofencing operates based on location, you need to add the following permission to the `AndroidManifest.xml` file. Open the `AndroidManifest.xml` file and specify it between the `<manifest>` and `<application>` tags.

```
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

In addition, if you want to run the service in the background, add the following permission. If your project supports Android 10, be sure to add the `ACCESS_BACKGROUND_LOCATION` permission.

```
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
```

And specify the service inside the `<application>` tag as follows.

```
<service
    android:name="com.pravera.geofence_service.foreground_service.ForegroundService"
    android:stopWithTask="true" />
```

The biggest feature of this plugin is that it can know user activity while geofencing. Please specify the permission usage in `<manifest>` tag.

```
<uses-permission android:name="com.google.android.gms.permission.ACTIVITY_RECOGNITION" />
<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION" />
```

And specify the service inside the `<application>` tag as follows.

```
<service
    android:name="com.pravera.geofence_service.activity_recognition.ActivityRecognitionIntentService"
    android:stopWithTask="true" />
```

### :baby_chick: iOS

Like Android platform, geofencing is based on location, so you need to specify location permission. Open the `ios/Runner/Info.plist` file and add the following permission inside the `<dict>` tag.

```
<key>NSLocationWhenInUseUsageDescription</key>
<string>Used to provide geofence service.</string>
```

If you want the geofence service to run in the background, add the following permissions.

```
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Used to provide geofence services in the background.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>Used to provide geofence services in the background.</string>
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>location</string>
</array>
```

To detect changes in user activity, add the following permissions.

```
<key>NSMotionUsageDescription</key>
<string>Used to recognize user activity information.</string>
```

## How to use

1. Create a geofence service instance. `GeofenceService` provide the following options:
* `interval`: Time interval to check geofence status in milliseconds. Default value is `5000`.
* `accuracy`: Geofence error range in meters. Default value is `100`.
* `useActivityRecognition`: Whether to use the activity recognition API. Default value is `true`.
* `allowMockLocations`: Whether to allow mock locations. Default value is `false`.

```dart
final geofenceService = GeofenceService.instance.setup(
  interval: 5000,
  accuracy: 100,
  useActivityRecognition: true,
  allowMockLocations: false
);
```

2. Create a geofence and radius. `Geofence` and `GeofenceRadius` provide the following options:
* `id`: String ID that identifies `Geofence` and `GeofenceRadius`.
* `data`: Custom data for `Geofence` and `GeofenceRadius`.
* `latitude`: The latitude of geofence center.
* `longitude`: The longitude of geofence center.
* `radius`: The radius of geofence.
* `length`: Radius length in meters. The best result should be set between 100 and 150 meters in radius. If Wi-FI is available, it can be set up to 20~40m.

```dart
final geofenceList = <Geofence>[
  Geofence(
    id: 'place_1',
    latitude: 35.105136,
    longitude: 129.037513,
    radius: [
      GeofenceRadius(id: 'radius_25m', length: 25),
      GeofenceRadius(id: 'radius_100m', length: 100)
    ]
  ),
  Geofence(
    id: 'place_2',
    latitude: 35.104971,
    longitude: 129.034851,
    radius: [
      GeofenceRadius(id: 'radius_25m', length: 25),
      GeofenceRadius(id: 'radius_100m', length: 100)
    ]
  ),
];
```

3. Register the callback function and start the geofence service.

```dart
void onGeofenceStatusChanged(
    Geofence geofence,
    GeofenceRadius geofenceRadius,
    GeofenceStatus geofenceStatus) {
  dev.log('geofence: ${geofence.toMap()}');
  dev.log('geofenceRadius: ${geofenceRadius.toMap()}');
  dev.log('geofenceStatus: ${geofenceStatus.toString()}\n');
}

void onActivityChanged(
    Activity prevActivity,
    Activity currActivity) {
  dev.log('prevActivity: ${prevActivity.toMap()}');
  dev.log('currActivity: ${currActivity.toMap()}\n');
}

void onError(dynamic error) {
  final errorCode = getErrorCodesFromError(error);
  if (errorCode == null) {
    dev.log('Undefined error: $error');
    return;
  }
  
  dev.log('ErrorCode: $errorCode');
}

@override
void initState() {
  super.initState();
  WidgetsBinding.instance?.addPostFrameCallback((_) {
    geofenceService.addGeofenceStatusChangedListener(onGeofenceStatusChanged);
    geofenceService.addActivityChangedListener(onActivityChanged);
    geofenceService.addStreamErrorListener(onError);
    geofenceService.start(geofenceList).catchError(onError);
  });
}
```

4. Add `WithForegroundService` widget for background execution on Android platform. `WithForegroundService` provide the following options:
* `geofenceService`: Geofence service in use on the current page.
* `notificationChannelId`: Channel ID for foreground service notification.
* `notificationChannelName`: Channel Name for foreground service notification.
* `notificationContentTitle`: Content Title for foreground service notification.
* `notificationContentText`: Content Text for foreground service notification.
* `child`: Child widget of current page.

```dart
@override
Widget build(BuildContext context) {
  return MaterialApp(
    // Use to run the geofence service in the background.
    // Declare between the [MaterialApp] and [Scaffold] widgets.
    home: WithForegroundService(
      geofenceService: geofenceService,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Geofence Service Example'),
          centerTitle: true
        ),
        body: buildContentView()
      ),
    ),
  );
}
```

5. To add or remove geofence while the service is running, use the following function:

```
geofenceService.addGeofence(object);
geofenceService.addGeofenceList(objectList);
geofenceService.removeGeofence(object);
geofenceService.removeGeofenceList(objectList);
geofenceService.removeGeofenceById(string);
geofenceService.clearGeofenceList();
```

6. When you are finished using the service, remove the callback listener and call the stop function.

```
geofenceService.removeGeofenceStatusChangedListener(onGeofenceStatusChanged);
geofenceService.removeActivityChangedListener(onActivityChanged);
geofenceService.removeStreamErrorListener(onError);
geofenceService.stop();
```

## Model

### :chicken: Geofence

| Property | Description |
|---|---|
| `id` | Identifier for `Geofence`. |
| `data` | Custom data for `Geofence`. |
| `latitude` | The latitude of geofence center. |
| `longitude` | The longitude of geofence center. |
| `radius` | The radius of geofence. |
| `status` | Geofence status of `Geofence`. |
| `timestamp` | Timestamp when geofence status changes. |
| `remainingDistance` | Remaining distance to destination. |

### :chicken: GeofenceRadius

| Property | Description |
|---|---|
| `id` | Identifier for `GeofenceRadius`. |
| `data` | Custom data for `GeofenceRadius`. |
| `length` | Radius length in meters. |
| `status` | Geofence status of `GeofenceRadius`. |
| `activity` | Activity when geofence status changes. |
| `speed` | Speed when geofence status changes. |
| `timestamp` | Timestamp when geofence status changes. |
| `remainingDistance` | Remaining distance to destination. |

### :chicken: GeofenceStatus

| Value | Description |
|---|---|
| `ENTER` | Occur when entering the geofence radius. |
| `EXIT` | Occur when exiting the geofence radius. |

### :chicken: Activity

| Property | Description |
|---|---|
| `type` | Type of activity recognized. |
| `confidence` | Confidence of activity recognized. |

### :chicken: ActivityType

| Value | Description |
|---|---|
| `IN_VEHICLE` |  |
| `ON_BICYCLE` |  |
| `ON_FOOT` |  |
| `RUNNING` |  |
| `STILL` |  |
| `TILTING` |  |
| `WALKING` |  |
| `UNKNOWN` |  |

### :chicken: ActivityConfidence

| Value | Description |
|---|---|
| `HIGH` |  |
| `MEDIUM` |  |
| `LOW` |  |

### :chicken: ErrorCodes

| Value | Description |
|---|---|
| `ALREADY_STARTED` | Occur when the service has already been started and the start function is called. |
| `LOCATION_SERVICE_DISABLED` | Occur when location service are disabled. When this error occur, you should notify the user and request activation. |
| `LOCATION_PERMISSION_DENIED` | Occur when location permission is denied. |
| `LOCATION_PERMISSION_PERMANENTLY_DENIED` | Occur when location permission is permanently denied. In this case, the user must manually set the permission. |
| `ACTIVITY_RECOGNITION_PERMISSION_DENIED` | Occur when activity recognition permission is denied. |
| `ACTIVITY_RECOGNITION_PERMISSION_PERMANENTLY_DENIED` | Occur when activity recognition permission is permanently denied. In this case, the user must manually set the permission. |
| `ACTIVITY_NOT_REGISTERED` | Occur when a channel is called when an activity object is not registered in the android platform. |
| `PERMISSION_REQUEST_CANCELLED` | Occur when permission is cancelled. |
| `ACTIVITY_UPDATES_REQUEST_FAILED` | Occur when activity updates request fails. |
| `ACTIVITY_UPDATES_REMOVE_FAILED` | Occur when activity updates remove fails. |
| `ACTIVITY_DATA_ENCODING_FAILED` | Occur when an error occurs in encoding the recognized activity data. |
