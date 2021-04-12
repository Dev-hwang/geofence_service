import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geofence_service/models/activity.dart';
import 'package:geofence_service/models/error_codes.dart';
import 'package:geofence_service/models/geofence.dart';
import 'package:geofence_service/models/geofence_radius.dart';
import 'package:geofence_service/models/geofence_status.dart';
import 'package:geofence_service/models/permission_result.dart';
import 'package:geofence_service/service/activity_recognition.dart';
import 'package:geolocator/geolocator.dart';

export 'package:geofence_service/ui/with_foreground_service.dart';
export 'package:geofence_service/models/activity.dart';
export 'package:geofence_service/models/activity_confidence.dart';
export 'package:geofence_service/models/activity_type.dart';
export 'package:geofence_service/models/error_codes.dart';
export 'package:geofence_service/models/geofence.dart';
export 'package:geofence_service/models/geofence_radius.dart';
export 'package:geofence_service/models/geofence_status.dart';

/// Callback function to notify geofence status changes.
typedef GeofenceStatusChangedCallback = Future<void> Function(
    Geofence geofence,
    GeofenceRadius geofenceRadius,
    GeofenceStatus geofenceStatus);

/// Callback function to notify activity changes.
typedef ActivityChangedCallback = void Function(
    Activity prevActivity,
    Activity currActivity);

/// Class for creating and monitoring geofence.
class GeofenceService {
  GeofenceService._internal();
  static final instance = GeofenceService._internal();

  /// Time interval to check geofence status in milliseconds.
  /// Default value is `5000`.
  int _interval = 5000;

  /// Geofence error range in meters.
  /// Default value is `100`.
  int _accuracy = 100;

  /// Whether to use the activity recognition API.
  /// Default value is `true`.
  bool _useActivityRecognition = true;

  /// Whether to allow mock locations.
  /// Default value is `false`.
  bool _allowMockLocations = false;

  StreamSubscription<Position>? _positionStream;
  StreamSubscription<Activity>? _activityStream;
  Activity _activity = Activity.unknown;

  final _refGeofenceList = <Geofence>[];
  final _geofenceStatusChangedListeners = <GeofenceStatusChangedCallback>[];
  final _activityChangedListeners = <ActivityChangedCallback>[];
  final _streamErrorListeners = <ValueChanged>[];

  bool _isRunningService = false;
  bool get isRunningService => _isRunningService;

  /// Setup geofence service.
  GeofenceService setup({
    int? interval,
    int? accuracy,
    bool? useActivityRecognition,
    bool? allowMockLocations
  }) {
    _interval = interval ?? _interval;
    _accuracy = accuracy ?? _accuracy;
    _useActivityRecognition = useActivityRecognition ?? _useActivityRecognition;
    _allowMockLocations = allowMockLocations ?? _allowMockLocations;

    return this;
  }

  /// Start geofence service. Can be initialized with [geofenceList].
  Future<void> start([List<Geofence>? geofenceList]) async {
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

    _activity = Activity.unknown;
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

  /// Register a closure to be called when the [GeofenceStatus] changes.
  void addGeofenceStatusChangedListener(GeofenceStatusChangedCallback listener) {
    _geofenceStatusChangedListeners.add(listener);
  }

  /// Remove a previously registered closure from the list of closures that are notified when the [GeofenceStatus] changes.
  void removeGeofenceStatusChangedListener(GeofenceStatusChangedCallback listener) {
    _geofenceStatusChangedListeners.remove(listener);
  }

  /// Register a closure to be called when the [Activity] changes.
  void addActivityChangedListener(ActivityChangedCallback listener) {
    _activityChangedListeners.add(listener);
  }

  /// Remove a previously registered closure from the list of closures that are notified when the [Activity] changes.
  void removeActivityChangedListener(ActivityChangedCallback listener) {
    _activityChangedListeners.remove(listener);
  }

  /// Register a closure to be called when a stream error occurs.
  void addStreamErrorListener(ValueChanged listener) {
    _streamErrorListeners.add(listener);
  }

  /// Remove a previously registered closure from the list of closures that are notified when a stream error occurs.
  void removeStreamErrorListener(ValueChanged listener) {
    _streamErrorListeners.remove(listener);
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

    if (_useActivityRecognition == false)
      return;

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
      intervalDuration: Duration(milliseconds: _interval)
    ).handleError(_onStreamErrorReceive).listen(_onPositionReceive);

    if (_useActivityRecognition == false)
      return;

    _activityStream = ActivityRecognition.getActivityStream()
        .handleError(_onStreamErrorReceive).listen(_onActivityReceive);
  }

  Future<void> _cancelStream() async {
    await _positionStream?.cancel();
    _positionStream = null;

    await _activityStream?.cancel();
    _activityStream = null;
  }

  void _onPositionReceive(Position position) async {
    // if (position == null) return;
    if (!_allowMockLocations && position.isMocked) return;
    if (position.accuracy > _accuracy) return;

    // dev.log('dataList size >> ${_refGeofenceList.length}');
    // if (_refGeofenceList.isNotEmpty) {
    //   final jsonList = <Map>[];
    //   _refGeofenceList.forEach((data) => jsonList.add(data.toMap()));
    //   dev.log('dataList json >> $jsonList');
    // }

    // Pause the service to process listeners.
    pause();

    double gDistance;
    double rDistance;
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

        for (final listener in _geofenceStatusChangedListeners)
          await listener(geofence, geofenceRadius, geofenceStatus)
              .catchError(_onStreamErrorReceive);
      }
    }

    // Service resumes when listener processing is complete.
    resume();
  }

  void _onActivityReceive(Activity activity) {
    if (_activity == activity) return;

    for (final listener in _activityChangedListeners)
      listener(_activity, activity);
    _activity = activity;
  }

  void _onStreamErrorReceive(dynamic error) {
    for (final listener in _streamErrorListeners)
      listener(error);
  }
}
