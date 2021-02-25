import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:geofence_service/model/activity.dart';
import 'package:geofence_service/model/error_codes.dart';
import 'package:geofence_service/model/geofence.dart';
import 'package:geofence_service/model/geofence_radius.dart';
import 'package:geofence_service/model/geofence_status.dart';
import 'package:geofence_service/model/permission_result.dart';
import 'package:geofence_service/service/activity_recognition.dart';
import 'package:geolocator/geolocator.dart';

export 'package:geofence_service/component/with_foreground_service.dart';
export 'package:geofence_service/model/activity.dart';
export 'package:geofence_service/model/activity_confidence.dart';
export 'package:geofence_service/model/activity_type.dart';
export 'package:geofence_service/model/error_codes.dart';
export 'package:geofence_service/model/geofence.dart';
export 'package:geofence_service/model/geofence_radius.dart';
export 'package:geofence_service/model/geofence_status.dart';

/// Callback function to notify geofence status changes.
typedef OnGeofenceStatusChanged = void Function(
    Geofence geofence,
    GeofenceRadius geofenceRadius,
    GeofenceStatus geofenceStatus);

/// Callback function to notify activity changes.
typedef OnActivityChanged = void Function(
    Activity prevActivity,
    Activity currActivity);

/// Class for creating and monitoring geofence.
class GeofenceService {
  /// Time interval to check geofence status in milliseconds.
  /// Default value is `5000`.
  final int interval;

  /// Geofence error range in meters.
  /// Default value is `100`.
  final int accuracy;

  /// Whether to allow mock locations.
  /// Default value is `false`.
  final bool allowMockLocations;

  GeofenceService({
    this.interval = 5000,
    this.accuracy = 100,
    this.allowMockLocations = false
  })  : assert(interval != null && interval >= 0),
        assert(accuracy != null && accuracy >= 0),
        assert(allowMockLocations != null);

  StreamSubscription<Position> _positionStream;
  StreamSubscription<Activity> _activityStream;
  Activity _activity;

  final _refGeofenceList = <Geofence>[];
  OnGeofenceStatusChanged _onGeofenceStatusChanged;
  OnActivityChanged _onActivityChanged;
  ValueChanged _onStreamError;

  bool _isRunningService = false;
  bool get isRunningService => _isRunningService;

  /// Start geofence service. Can be initialized with [geofenceList].
  Future<void> start([List<Geofence> geofenceList]) async {
    if (_isRunningService)
      return Future.error(ErrorCodes.ALREADY_STARTED);

    await _checkPermission();
    await _listenStream();

    _activity = Activity.unknown;
    if (geofenceList != null)
      _refGeofenceList.addAll(geofenceList);

    _isRunningService = true;
    // dev.log('GeofenceService started.');
  }

  /// Stop geofence service.
  Future<void> stop() async {
    await _cancelStream();

    _activity = null;
    _refGeofenceList.clear();

    _isRunningService = false;
    // dev.log('GeofenceService stopped.');
  }

  /// Pause geofence service.
  void pause() {
    _positionStream?.pause();
    _activityStream?.pause();
    // dev.log('GeofenceService paused.');
  }

  /// Resume geofence service.
  void resume() {
    _positionStream?.resume();
    _activityStream?.resume();
    // dev.log('GeofenceService resumed.');
  }

  /// Set callback function that receives geofence status changes.
  void setOnGeofenceStatusChanged(OnGeofenceStatusChanged callback) {
    _onGeofenceStatusChanged = callback;
  }

  /// Set callback function that receives activity changes.
  void setOnActivityChanged(OnActivityChanged callback) {
    _onActivityChanged = callback;
  }

  /// Set callback function that receives stream error.
  void setOnStreamError(ValueChanged callback) {
    _onStreamError = callback;
  }

  /// Add geofence.
  void addGeofence(Geofence geofence) {
    _refGeofenceList.add(geofence);
  }

  /// Add geofence list.
  void addGeofenceList(List<Geofence> geofenceList) {
    _refGeofenceList.addAll(geofenceList);
  }

  /// Remove geofence.
  void removeGeofence(Geofence geofence) {
    _refGeofenceList.remove(geofence);
  }

  /// Remove geofence list.
  void removeGeofenceList(List<Geofence> geofenceList) {
    for (int i=0; i<geofenceList.length; i++)
      removeGeofence(geofenceList[i]);
  }

  /// Remove geofence by [id].
  void removeGeofenceById(String id) {
    _refGeofenceList.removeWhere((geofence) => geofence.id == id);
  }

  /// Clear geofence list.
  void clearGeofenceList() {
    _refGeofenceList.clear();
  }

  Future<void> _checkPermission() async {
    // Check that location service is enabled.
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled)
      return Future.error(ErrorCodes.LOCATION_SERVICE_DISABLED);

    // Check whether to allow location permission.
    LocationPermission locationPermission = await Geolocator.checkPermission();
    if (locationPermission == LocationPermission.deniedForever)
      return Future.error(ErrorCodes.LOCATION_PERMISSION_PERMANENTLY_DENIED);

    if (locationPermission == LocationPermission.denied) {
      locationPermission = await Geolocator.requestPermission();
      if (locationPermission != LocationPermission.whileInUse &&
          locationPermission != LocationPermission.always)
        return Future.error(ErrorCodes.LOCATION_PERMISSION_DENIED);
    }

    // Check whether to allow activity recognition permission.
    PermissionResult permissionResult = await ActivityRecognition
        .checkPermission();
    if (permissionResult == PermissionResult.PERMANENTLY_DENIED)
      return Future.error(
          ErrorCodes.ACTIVITY_RECOGNITION_PERMISSION_PERMANENTLY_DENIED);

    if (permissionResult == PermissionResult.DENIED) {
      permissionResult = await ActivityRecognition
          .requestPermission();
      if (permissionResult != PermissionResult.GRANTED)
        return Future.error(ErrorCodes.ACTIVITY_RECOGNITION_PERMISSION_DENIED);
    }
  }

  Future<void> _listenStream() async {
    _positionStream = Geolocator.getPositionStream(
      desiredAccuracy: LocationAccuracy.best,
      intervalDuration: Duration(milliseconds: interval)
    ).handleError(_onStreamErrorReceive).listen(_onPositionReceive);

    _activityStream = ActivityRecognition.getActivityStream()
        .handleError(_onStreamErrorReceive).listen(_onActivityReceive);
  }

  Future<void> _cancelStream() async {
    await _positionStream?.cancel();
    _positionStream = null;

    await _activityStream?.cancel();
    _activityStream = null;
  }

  void _onPositionReceive(Position position) {
    if (position == null) return;
    if (!allowMockLocations && position.isMocked) return;
    if (position.accuracy > accuracy) return;

    // dev.log('dataList size >> ${_refGeofenceList.length}');
    // if (_refGeofenceList.isNotEmpty) {
    //   final jsonList = <Map>[];
    //   _refGeofenceList.forEach((data) => jsonList.add(data.toMap()));
    //   dev.log('dataList json >> $jsonList');
    // }

    double gDistance; //
    double rDistance; //
    Geofence geofence;
    GeofenceRadius geofenceRadius;
    GeofenceStatus geofenceStatus;
    for (int i=0; i<_refGeofenceList.length; i++) {
      geofence = _refGeofenceList[i];

      gDistance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          geofence.latitude,
          geofence.longitude);
      geofence.updateRemainingDistance(gDistance);

      for (int j=0; j<geofence.radius.length; j++) {
        geofenceRadius = geofence.radius[j];

        if (gDistance <= geofenceRadius.length)
          geofenceStatus = GeofenceStatus.ENTER;
        else
          geofenceStatus = GeofenceStatus.EXIT;

        rDistance = gDistance - geofenceRadius.length;
        geofenceRadius.updateRemainingDistance(rDistance);

        if (!geofenceRadius.updateStatus(geofenceStatus, _activity, position))
          continue;

        if (_onGeofenceStatusChanged != null)
          _onGeofenceStatusChanged(
              geofence, geofenceRadius, geofenceStatus);
      }
    }
  }

  void _onActivityReceive(Activity activity) {
    if (_activity == activity) return;

    if (_onActivityChanged != null)
      _onActivityChanged(_activity, activity);
    _activity = activity;
  }

  void _onStreamErrorReceive(dynamic error) {
    if (_onStreamError != null)
      _onStreamError(error);
  }
}
