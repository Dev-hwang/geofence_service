## 3.5.0

* Upgrade dependencies.
* [[#4](https://github.com/Dev-hwang/flutter_location/issues/4)] Fix onRequestPermissionsResult implement issue.

## 3.4.8

* Upgrade dependencies.
* Downgrade Android minSdkVersion to 21.

## 3.4.7

* Upgrade dependencies.
* [[#42](https://github.com/Dev-hwang/flutter_foreground_task/issues/42)] Only minimize app on pop when there is no route to pop.

## 3.4.6

* [**iOS**] Fixed an issue where notifications not related to the service were removed.
* [**iOS**] Improved compatibility with other plugins that use notifications.
  - Additional settings are required, so please check the Readme-Getting started.

## 3.4.5

* [[#16](https://github.com/Dev-hwang/geofence_service/issues/16)] Add process exit code to prevent memory leak. 

## 3.4.4

* Upgrade dependencies.
* [**Bug**] Fixed an issue where lockMode(wakeLock, wifiLock) was not properly released when the service was forcibly shutdown.
* [**Bug**] Fixed an issue where foreground service notification UX was delayed on Android version 12.

## 3.4.3

* Upgrade dependencies.
* Bump Android minSdkVersion to 23.
* Bump Android compileSdkVersion to 31.

## 3.4.2

* Upgrade flutter_foreground_task: ^3.2.2
* [**Bug**] Fixed an issue where RemoteServiceException occurred intermittently.

## 3.4.1

* Upgrade flutter_foreground_task: ^3.2.0

## 3.4.0

* Upgrade flutter_foreground_task: ^3.0.0
* Changed parameter name of `WillStartForegroundTask` widget.

## 3.3.2

* Fix errorCodes parsing function not working properly.

## 3.3.1

* Upgrade fl_location: ^1.0.1

## 3.3.0

* Upgrade flutter_foreground_task: ^2.1.0
* [**BREAKING**] Replace plugin from `location` to `fl_location`.
* [**BREAKING**] Replace data model from `LocationData` to `Location`.
* Rename the listener function.
```text
addLocationDataChangeListener -> addLocationChangeListener
addLocationServiceStatusChangeListener -> addLocationServicesStatusChangeListener
removeLocationDataChangeListener -> removeLocationChangeListener
removeLocationServiceStatusChangeListener -> removeLocationServicesStatusChangeListener
```
* Rename the error code.
```text
LOCATION_SERVICE_DISABLED -> LOCATION_SERVICES_DISABLED
```
* Add `clearAllListeners` function.
* Add `foregroundServiceType` to android service tag.
* Fixed DWELL status change being delayed due to statusChangeDelayMs.

## 3.2.1

* Upgrade flutter_foreground_task: ^2.0.4

## 3.2.0

* [**BREAKING**] Replace plugin from `geolocator` to `location`.
* [**BREAKING**] Replace data model from `Position` to `LocationData`.
* Rename the listener function.
```text
addPositionChangeListener -> addLocationDataChangeListener
removePositionChangeListener -> removeLocationDataChangeListener
```
* Fix location permission request not working properly.
* Fix an issue that the location stream is not closed even when the service is stopped.

## 3.1.4

* Move component declaration inside the plugin. Check the readme for more details.
* Upgrade flutter_foreground_task: ^2.0.3
* Upgrade flutter_activity_recognition: ^1.1.2
```markdown
* Upgrade to `Activity Recognition Transition API`.
* Remove `ON_FOOT` activity type.
* Remove `TILTING` activity type.
* Fix `requestPermission` not working properly.
```

## 3.1.3

* Upgrade flutter_foreground_task: ^2.0.1

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
* Add `printDevLog` option.
* Rename the listener function.
```text
addGeofenceStatusChangedListener -> addGeofenceStatusChangeListener
addActivityChangedListener -> addActivityChangeListener
removeGeofenceStatusChangedListener -> removeGeofenceStatusChangeListener
removeActivityChangedListener -> removeActivityChangeListener
```
* Change the model's `toMap` function name to `toJson`.
* Update example
* Update README.md

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
