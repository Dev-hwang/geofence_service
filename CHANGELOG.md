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

* Upgrade geolocator dependency.

## 1.0.3

* Modify package name.
* Add method to get activity with unknown type.
* Add null check for geofenceList of start function.

## 1.0.1

* README updates.
* Add data field for inserting custom data.

## 1.0.0

* Initial release.
