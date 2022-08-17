This plugin is a geofence service with activity recognition API. It does not use the Geofence API implemented on the platform. Therefore, battery efficiency cannot be guaranteed. Instead, this plugin can provide more accurate and realtime geo-fencing by navigating your location while your app is alive.

[![pub package](https://img.shields.io/pub/v/geofence_service.svg)](https://pub.dev/packages/geofence_service)

## Features

* `Geofence` can have multiple radius.
* `Geofence` can see what activity took place when the device entered the radius.
* `GeofenceService` can perform geo-fencing in real time and catch errors during operation.
* `GeofenceService` can be operated in the background using `WillStartForegroundTask` widget.

**WAIT**: This plugin performs geo-fencing based on a circular geofence. If you want to create a polygon geofence, this [plugin](https://pub.dev/packages/poly_geofence_service) is recommended.

## Getting started

To use this plugin, add `geofence_service` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/). For example:

```yaml
dependencies:
  geofence_service: ^3.5.0
```

After adding the `geofence_service` plugin to the flutter project, we need to specify the platform-specific permissions and services to use for this plugin to work properly.

### :baby_chick: Android

Since geo-fencing operates based on location, we need to add the following permission to the `AndroidManifest.xml` file. Open the `AndroidManifest.xml` file and specify it between the `<manifest>` and `<application>` tags.

```
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

If you want to run the service in the background, add the following permission. If your project supports Android 10, be sure to add the `ACCESS_BACKGROUND_LOCATION` permission.

```
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
```

And specify the service inside the `<application>` tag as follows.

```
<service
    android:name="com.pravera.flutter_foreground_task.service.ForegroundService"
    android:foregroundServiceType="location"
    android:stopWithTask="true" />
```

The biggest feature of this plugin is that it can know user activity while geo-fencing. Please specify the permission usage in `<manifest>` tag.

```
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="com.google.android.gms.permission.ACTIVITY_RECOGNITION" />
<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION" />
```

### :baby_chick: iOS

Like Android platform, geo-fencing is based on location, we need to add the following description. Open the `ios/Runner/Info.plist` file and specify it inside the `<dict>` tag.

```
<key>NSLocationWhenInUseUsageDescription</key>
<string>Used to provide geofence service.</string>
```

If you want to run the service in the background, add the following description.

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

To detect changes in user activity, add the following description.

```
<key>NSMotionUsageDescription</key>
<string>Used to recognize user activity information.</string>
```

(**Optional**) To display a notification when your app enters the background, you need to open the `ios/Runner/AppDelegate` file and set the following:

**Objective-C**:

```objectivec
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];

  // here
  if (@available(iOS 10.0, *)) {
    [UNUserNotificationCenter currentNotificationCenter].delegate = (id<UNUserNotificationCenterDelegate>) self;
  }

  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
```

**Swift**:

```swift
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // here
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

## How to use

1. Create a `GeofenceService` instance and set options. `GeofenceService.instance.setup()` provides the following options:
* `interval`: The time interval in milliseconds to check the geofence status. The default is `5000`.
* `accuracy`: Geo-fencing error range in meters. The default is `100`.
* `loiteringDelayMs`: Sets the delay between `GeofenceStatus.ENTER` and `GeofenceStatus.DWELL` in milliseconds. The default is `300000`.
* `statusChangeDelayMs`: Sets the status change delay in milliseconds. `GeofenceStatus.ENTER` and `GeofenceStatus.EXIT` events may be called frequently when the location is near the boundary of the geofence. Use this option to minimize event calls at this time. If the option value is too large, realtime geo-fencing is not possible, so use it carefully. The default is `10000`.
* `useActivityRecognition`: Whether to use the activity recognition API. The default is `true`.
* `allowMockLocations`: Whether to allow mock locations. The default is `false`.
* `printDevLog`: Whether to show the developer log. If this value is set to true, logs for geofence service activities (start, stop, etc.) can be viewed. It does not work in release mode. The default is `false`.
* `geofenceRadiusSortType`: Sets the sort type of the geofence radius. The default is `GeofenceRadiusSortType.DESC`.

```dart
// Create a [GeofenceService] instance and set options.
final _geofenceService = GeofenceService.instance.setup(
    interval: 5000,
    accuracy: 100,
    loiteringDelayMs: 60000,
    statusChangeDelayMs: 10000,
    useActivityRecognition: true,
    allowMockLocations: false,
    printDevLog: false,
    geofenceRadiusSortType: GeofenceRadiusSortType.DESC);
```

2. Create a `Geofence` and `GeofenceRadius` list. `Geofence` and `GeofenceRadius` provides the following parameters:
* `id`: Identifier for `Geofence` and `GeofenceRadius`.
* `data`: Custom data for `Geofence` and `GeofenceRadius`.
* `latitude`: The latitude of geofence center.
* `longitude`: The longitude of geofence center.
* `radius`: The radius of `Geofence`.
* `length`: The length of the radius in meters. The best result should be set between 100 and 150 meters in radius. If Wi-FI is available, it can be set up to 20~40m.

```dart
// Create a [Geofence] list.
final _geofenceList = <Geofence>[
  Geofence(
    id: 'place_1',
    latitude: 35.103422,
    longitude: 129.036023,
    radius: [
      GeofenceRadius(id: 'radius_100m', length: 100),
      GeofenceRadius(id: 'radius_25m', length: 25),
      GeofenceRadius(id: 'radius_250m', length: 250),
      GeofenceRadius(id: 'radius_200m', length: 200),
    ],
  ),
  Geofence(
    id: 'place_2',
    latitude: 35.104971,
    longitude: 129.034851,
    radius: [
      GeofenceRadius(id: 'radius_25m', length: 25),
      GeofenceRadius(id: 'radius_100m', length: 100),
      GeofenceRadius(id: 'radius_200m', length: 200),
    ],
  ),
];
```

3. Register the listener and call `GeofenceService.instance.start()`.

```dart
// This function is to be called when the geofence status is changed.
Future<void> _onGeofenceStatusChanged(
    Geofence geofence,
    GeofenceRadius geofenceRadius,
    GeofenceStatus geofenceStatus,
    Location location) async {
  print('geofence: ${geofence.toJson()}');
  print('geofenceRadius: ${geofenceRadius.toJson()}');
  print('geofenceStatus: ${geofenceStatus.toString()}');
  _geofenceStreamController.sink.add(geofence);
}

// This function is to be called when the activity has changed.
void _onActivityChanged(Activity prevActivity, Activity currActivity) {
  print('prevActivity: ${prevActivity.toJson()}');
  print('currActivity: ${currActivity.toJson()}');
  _activityStreamController.sink.add(currActivity);
}

// This function is to be called when the location has changed.
void _onLocationChanged(Location location) {
  print('location: ${location.toJson()}');
}

// This function is to be called when a location services status change occurs
// since the service was started.
void _onLocationServicesStatusChanged(bool status) {
  print('isLocationServicesEnabled: $status');
}

// This function is used to handle errors that occur in the service.
void _onError(error) {
  final errorCode = getErrorCodesFromError(error);
  if (errorCode == null) {
    print('Undefined error: $error');
    return;
  }
  
  print('ErrorCode: $errorCode');
}

@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _geofenceService.addGeofenceStatusChangeListener(_onGeofenceStatusChanged);
    _geofenceService.addLocationChangeListener(_onLocationChanged);
    _geofenceService.addLocationServicesStatusChangeListener(_onLocationServicesStatusChanged);
    _geofenceService.addActivityChangeListener(_onActivityChanged);
    _geofenceService.addStreamErrorListener(_onError);
    _geofenceService.start(_geofenceList).catchError(_onError);
  });
}
```

4. Add `WillStartForegroundTask` widget for background execution on Android platform. `WillStartForegroundTask` provides the following options:
* `onWillStart`: Called to ask if you want to start the foreground task.
* `notificationOptions`: Optional values for notification detail settings.
* `notificationTitle`: The title that will be displayed in the notification.
* `notificationText`: The text that will be displayed in the notification.
* `child`: A child widget that contains the `Scaffold` widget.

```dart
@override
Widget build(BuildContext context) {
  return MaterialApp(
    // A widget used when you want to start a foreground task when trying to minimize or close the app.
    // Declare on top of the [Scaffold] widget.
    home: WillStartForegroundTask(
      onWillStart: () async {
        // You can add a foreground task start condition.
        return _geofenceService.isRunningService;
      },
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'geofence_service_notification_channel',
        channelName: 'Geofence Service Notification',
        channelDescription: 'This notification appears when the geofence service is running in the background.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        isSticky: false,
      ),
      iosNotificationOptions: const IOSNotificationOptions(),
      notificationTitle: 'Geofence Service is running',
      notificationText: 'Tap to return to the app',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Geofence Service'),
          centerTitle: true,
        ),
        body: _buildContentView(),
      ),
    ),
  );
}
```

5. To add or remove `Geofence` while the service is running, use the following function:

```text
_geofenceService.addGeofence(Object);
_geofenceService.addGeofenceList(List);
_geofenceService.removeGeofence(Object);
_geofenceService.removeGeofenceList(List);
_geofenceService.removeGeofenceById(String);
_geofenceService.clearGeofenceList();
```

6. If you want to pause or resume the service, use the function below.

```text
_geofenceService.pause();
_geofenceService.resume();
```

7. When you are finished using the service, unregister the listener and call `GeofenceService.instance.stop()`.

```text
_geofenceService.removeGeofenceStatusChangeListener(_onGeofenceStatusChanged);
_geofenceService.removeLocationChangeListener(_onLocationChanged);
_geofenceService.removeLocationServicesStatusChangeListener(_onLocationServicesStatusChanged);
_geofenceService.removeActivityChangeListener(_onActivityChanged);
_geofenceService.removeStreamErrorListener(_onError);
_geofenceService.clearAllListeners();
_geofenceService.stop();
```

**Note**: When calling the stop function, the listener is not removed, but the added geofence is cleared.

## Models

### :chicken: Geofence

A model representing a geofence.

| Property | Description |
|---|---|
| `id` | Identifier for `Geofence`. |
| `data` | Custom data for `Geofence`. |
| `latitude` | The latitude of geofence center. |
| `longitude` | The longitude of geofence center. |
| `radius` | The radius of `Geofence`. |
| `status` | The status of `Geofence`. |
| `timestamp` | The timestamp of `Geofence`. |
| `remainingDistance` | The remaining distance to the destination. |

### :chicken: GeofenceRadius

A model representing the radius of `Geofence`.

| Property | Description |
|---|---|
| `id` | Identifier for `GeofenceRadius`. |
| `data` | Custom data for `GeofenceRadius`. |
| `length` | The length of the radius in meters. |
| `status` | The status of `GeofenceRadius`. |
| `activity` | The user activity when geofence status changes. |
| `speed` | The passing speed when geofence status changes. |
| `timestamp` | The timestamp when geofence status changes. |
| `remainingDistance` | The remaining distance to the radius. |

### :chicken: GeofenceStatus

Defines the type of the geofence status.

| Value | Description |
|---|---|
| `ENTER` | Occurs when entering the geofence radius. |
| `EXIT` | Occurs when exiting the geofence radius. |
| `DWELL` | Occurs when the loitering delay elapses after entering the geofence area. |

### :chicken: Activity

A model representing the user's activity.

| Property | Description |
|---|---|
| `type` | The type of activity recognized. |
| `confidence` | The confidence of activity recognized. |

### :chicken: ActivityType

Defines the type of activity.

| Value | Description |
|---|---|
| `IN_VEHICLE` | The device is in a vehicle, such as a car. |
| `ON_BICYCLE` | The device is on a bicycle. |
| `RUNNING` | The device is on a user who is running. This is a sub-activity of ON_FOOT. |
| `STILL` | The device is still (not moving). |
| `WALKING` | The device is on a user who is walking. This is a sub-activity of ON_FOOT. |
| `UNKNOWN` | Unable to detect the current activity. |

### :chicken: ActivityConfidence

Defines the confidence of activity.

| Value | Description |
|---|---|
| `HIGH` | High accuracy: 75~100 |
| `MEDIUM` | Medium accuracy: 50~75 |
| `LOW` | Low accuracy: 0~50 |

### :chicken: GeofenceRadiusSortType

Defines the sort type of the geofence radius. If you have set multiple radius for one geofence, multiple radius can come in at the same time. At this time, you can control the order in which the radius comes in by referring to the radius meters.

| Value | Description |
|---|---|
| `ASC` | Sort the meters in ascending order. |
| `DESC` | Sort the meters in descending order. |

### :chicken: ErrorCodes

Error codes that may occur in the service.

| Value | Description |
|---|---|
| `ALREADY_STARTED` | Occurs when the service has already been started but the start function is called. |
| `LOCATION_SERVICES_DISABLED` | Occurs when location services are disabled. When this error occurs, you should notify the user and request activation. |
| `LOCATION_PERMISSION_DENIED` | Occurs when location permission is denied. |
| `LOCATION_PERMISSION_PERMANENTLY_DENIED` | Occurs when location permission is permanently denied. In this case, the user must manually allow the permission. |
| `ACTIVITY_RECOGNITION_PERMISSION_DENIED` | Occurs when activity recognition permission is denied. |
| `ACTIVITY_RECOGNITION_PERMISSION_PERMANENTLY_DENIED` | Occurs when activity recognition permission is permanently denied. In this case, the user must manually allow the permission. |

## Support

If you find any bugs or issues while using the plugin, please register an issues on [GitHub](https://github.com/Dev-hwang/geofence_service/issues). You can also contact us at <hwj930513@naver.com>.
