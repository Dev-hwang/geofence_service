## 3.1.2

* Upgrade geolocator: ^7.2.0+1

## 3.1.1

* Upgrade geolocator: ^7.1.1
* Upgrade flutter_foreground_task: ^2.0.0

## 3.1.0

* Upgrade geolocator: ^7.1.0
* Upgrade flutter_activity_recognition: ^1.0.2
* Add `addPositionChangeListener` function.
* Add `removePositionChangeListener` function.
* Add `addLocationServiceStatusChangeListener` function.
* Add `removeLocationServiceStatusChangeListener` function.
> A service has been added to check the location service status change while the geofence service is running. 
You need to add the code below to your android manifest file. See the Getting started section of the readme for details.
```xml
<service
    android:name="com.pravera.geofence_service.service.LocationProviderIntentService"
    android:permission="android.permission.BIND_JOB_SERVICE"
    android:stopWithTask="true" />
```
* Add `printDevLog` option.
* Change the model's `toMap` function name to `toJson`.
* Update example
* Update README.md
* Rename the listener function.
```text
// addGeofenceStatusChangedListener(_onGeofenceStatusChanged);
// addActivityChangedListener(_onActivityChanged);
// removeGeofenceStatusChangedListener(onGeofenceStatusChanged);
// removeActivityChangedListener(onActivityChanged);

addGeofenceStatusChangeListener(_onGeofenceStatusChanged);
addActivityChangeListener(_onActivityChanged);
removeGeofenceStatusChangeListener(onGeofenceStatusChanged);
removeActivityChangeListener(onActivityChanged);
```

## 3.0.4

* Upgrade flutter_foreground_task: ^1.0.8

## 3.0.3

* Add `GeofenceStatus.DWELL` that occurs when loitering within a geofence radius.
* Add `loiteringDelayMs` options.
* Add `statusChangeDelayMs` options.

## 3.0.0

* [**BREAKING**] Remove the activity_recognition package inside the plugin, and add the `flutter_activity_recognition: ^1.0.0` plugin.
* [**BREAKING**] Remove the foreground_service package inside the plugin, and add the `flutter_foreground_task: ^1.0.7` plugin.
* Updates Comment and Documentation.
* Android SDK target upgrade.
* Please refer to the [upgrade guide](https://github.com/Dev-hwang/geofence_service/blob/master/UPGRADE_GUIDE.md) for details.

## 2.1.4

* Upgrade geolocator: ^7.0.3

## 2.1.3

* Upgrade geolocator: ^7.0.2

## 2.1.2

* Add future-async to `GeofenceStatusChangedCallback`.
* Add `geofenceRadiusSortType` options.

## 2.1.0

* Apply singleton pattern. Now access the `GeofenceService` through the `instance` field. Use the `setup` function to set options.
* Remove `setOnGeofenceStatusChanged` function.
* Remove `setOnActivityChanged` function.
* Remove `setOnStreamError` function.
* Add `addGeofenceStatusChangedListener` function.
* Add `addActivityChangedListener` function.
* Add `addStreamErrorListener` function.
* Add `removeGeofenceStatusChangedListener` function.
* Add `removeActivityChangedListener` function.
* Add `removeStreamErrorListener` function.
* Example updates.
* README updates.

## 2.0.5

* Prevent RemoteServiceException.

## 2.0.4

* Fix foreground service duplicate call issues.
* Fix foreground service start and stop timing issues.
* Change the `serviceId` value of the foreground service. [1 >> 1000]

## 2.0.1

* Add `useActivityRecognition` option to selectively use the activity recognition API.
* Example updates.
* README updates.

## 2.0.0

* Migrate null safety.

## 1.0.4

* Upgrade geolocator: ^7.0.1

## 1.0.3

* Modify package name.
* Add method to get activity with unknown type.
* Add null check for geofenceList of start function.

## 1.0.1

* README updates.
* Add data field for inserting custom data.

## 1.0.0

* Initial release.
