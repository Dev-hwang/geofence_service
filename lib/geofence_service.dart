import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import 'package:geofence_service/models/error_codes.dart';
import 'package:geofence_service/models/geofence.dart';
import 'package:geofence_service/models/geofence_radius.dart';
import 'package:geofence_service/models/geofence_radius_sort_type.dart';
import 'package:geofence_service/models/geofence_status.dart';
import 'package:geolocator/geolocator.dart';

export 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
export 'package:flutter_foreground_task/flutter_foreground_task.dart';
export 'package:geofence_service/models/error_codes.dart';
export 'package:geofence_service/models/geofence.dart';
export 'package:geofence_service/models/geofence_radius.dart';
export 'package:geofence_service/models/geofence_radius_sort_type.dart';
export 'package:geofence_service/models/geofence_status.dart';
export 'package:geolocator/geolocator.dart';

/// Function to notify geofence status changes.
typedef GeofenceStatusChanged = Future<void> Function(
    Geofence geofence,
    GeofenceRadius geofenceRadius,
    GeofenceStatus geofenceStatus,
    Position position);

/// Function to notify activity changes.
typedef ActivityChanged = void Function(
    Activity prevActivity,
    Activity currActivity);

/// A class provides geofence management and geo-fencing.
class GeofenceService {
  GeofenceService._internal();

  /// Instance of [GeofenceService].
  static final instance = GeofenceService._internal();

  /// Whether the service is running.
  bool _isRunningService = false;

  /// Returns whether the service is running.
  bool get isRunningService => _isRunningService;

  /// The time interval in milliseconds to check the geofence status.
  /// The default is `5000`.
  int _interval = 5000;

  /// Geo-fencing error range in meters.
  /// The default is `100`.
  int _accuracy = 100;

  /// Sets the delay between [GeofenceStatus.ENTER] and [GeofenceStatus.DWELL] in milliseconds.
  /// The default is `300000`.
  int _loiteringDelayMs = 300000;

  /// Sets the status change delay in milliseconds.
  /// [GeofenceStatus.ENTER] and [GeofenceStatus.EXIT] events may be called frequently
  /// when the location is near the boundary of the geofence. Use this option to minimize event calls at this time.
  /// If the option value is too large, realtime geo-fencing is not possible, so use it carefully.
  /// The default is `10000`.
  int _statusChangeDelayMs = 10000;

  /// Whether to use the activity recognition API.
  /// The default is `true`.
  bool _useActivityRecognition = true;

  /// Whether to allow mock locations.
  /// The default is `false`.
  bool _allowMockLocations = false;

  /// Sets the sort type of the geofence radius.
  /// The default is `GeofenceRadiusSortType.DESC`.
  GeofenceRadiusSortType _geofenceRadiusSortType = GeofenceRadiusSortType.DESC;

  StreamSubscription<Position>? _positionStream;
  StreamSubscription<Activity>? _activityStream;
  Activity _activity = Activity.unknown;

  final _geofenceList = <Geofence>[];
  final _geofenceStatusChangedListeners = <GeofenceStatusChanged>[];
  final _activityChangedListeners = <ActivityChanged>[];
  final _streamErrorListeners = <ValueChanged>[];

  /// Setup [GeofenceService].
  /// Some options do not change while the service is running.
  GeofenceService setup({
    int? interval,
    int? accuracy,
    int? loiteringDelayMs,
    int? statusChangeDelayMs,
    bool? useActivityRecognition,
    bool? allowMockLocations,
    GeofenceRadiusSortType? geofenceRadiusSortType
  }) {
    _interval = interval ?? _interval;
    _accuracy = accuracy ?? _accuracy;
    _loiteringDelayMs = loiteringDelayMs ?? _loiteringDelayMs;
    _statusChangeDelayMs = statusChangeDelayMs ?? _statusChangeDelayMs;
    _useActivityRecognition = useActivityRecognition ?? _useActivityRecognition;
    _allowMockLocations = allowMockLocations ?? _allowMockLocations;
    _geofenceRadiusSortType = geofenceRadiusSortType ?? _geofenceRadiusSortType;

    return this;
  }

  /// Start [GeofenceService].
  /// It can be initialized with [geofenceList].
  Future<void> start([List<Geofence>? geofenceList]) async {
    if (_isRunningService)
      return Future.error(ErrorCodes.ALREADY_STARTED);

    await _checkPermissions();
    await _listenStream();

    _activity = Activity.unknown;
    if (geofenceList != null)
      _geofenceList.addAll(geofenceList);

    _isRunningService = true;
    if (!kReleaseMode) dev.log('GeofenceService started.');
  }

  /// Stop [GeofenceService].
  Future<void> stop() async {
    await _cancelStream();

    _activity = Activity.unknown;
    _geofenceList.clear();

    _isRunningService = false;
    if (!kReleaseMode) dev.log('GeofenceService stopped.');
  }

  /// Pause [GeofenceService].
  void pause() {
    _positionStream?.pause();
    _activityStream?.pause();
    // if (!kReleaseMode) dev.log('GeofenceService paused.');
  }

  /// Resume [GeofenceService].
  void resume() {
    _positionStream?.resume();
    _activityStream?.resume();
    // if (!kReleaseMode) dev.log('GeofenceService resumed.');
  }

  /// Register a closure to be called when the [GeofenceStatus] changes.
  void addGeofenceStatusChangedListener(GeofenceStatusChanged listener) {
    _geofenceStatusChangedListeners.add(listener);
  }

  /// Remove a previously registered closure from the list of closures that
  /// are notified when the [GeofenceStatus] changes.
  void removeGeofenceStatusChangedListener(GeofenceStatusChanged listener) {
    _geofenceStatusChangedListeners.remove(listener);
  }

  /// Register a closure to be called when the [Activity] changes.
  void addActivityChangedListener(ActivityChanged listener) {
    _activityChangedListeners.add(listener);
  }

  /// Remove a previously registered closure from the list of closures that
  /// are notified when the [Activity] changes.
  void removeActivityChangedListener(ActivityChanged listener) {
    _activityChangedListeners.remove(listener);
  }

  /// Register a closure to be called when a stream error occurs.
  void addStreamErrorListener(ValueChanged listener) {
    _streamErrorListeners.add(listener);
  }

  /// Remove a previously registered closure from the list of closures that
  /// are notified when a stream error occurs.
  void removeStreamErrorListener(ValueChanged listener) {
    _streamErrorListeners.remove(listener);
  }

  /// Add geofence.
  void addGeofence(Geofence geofence) {
    _geofenceList.add(geofence);
  }

  /// Add geofence list.
  void addGeofenceList(List<Geofence> geofenceList) {
    _geofenceList.addAll(geofenceList);
  }

  /// Remove geofence.
  void removeGeofence(Geofence geofence) {
    _geofenceList.remove(geofence);
  }

  /// Remove geofence list.
  void removeGeofenceList(List<Geofence> geofenceList) {
    for (int i=0; i<geofenceList.length; i++)
      removeGeofence(geofenceList[i]);
  }

  /// Remove geofence by [id].
  void removeGeofenceById(String id) {
    _geofenceList.removeWhere((geofence) => geofence.id == id);
  }

  /// Clear geofence list.
  void clearGeofenceList() {
    _geofenceList.clear();
  }

  Future<void> _checkPermissions() async {
    // Check that the location service is enabled.
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

    // Activity Recognition API 사용 안함
    if (_useActivityRecognition == false) return;

    // Check whether to allow activity recognition permission.
    PermissionRequestResult arPermission = await FlutterActivityRecognition.instance.checkPermission();
    if (arPermission == PermissionRequestResult.PERMANENTLY_DENIED)
      return Future.error(ErrorCodes.ACTIVITY_RECOGNITION_PERMISSION_PERMANENTLY_DENIED);

    if (arPermission == PermissionRequestResult.DENIED) {
      arPermission = await FlutterActivityRecognition.instance.requestPermission();
      if (arPermission != PermissionRequestResult.GRANTED)
        return Future.error(ErrorCodes.ACTIVITY_RECOGNITION_PERMISSION_DENIED);
    }
  }

  Future<void> _listenStream() async {
    _positionStream = Geolocator.getPositionStream(
      desiredAccuracy: LocationAccuracy.best,
      intervalDuration: Duration(milliseconds: _interval)
    ).handleError(_handleStreamError).listen(_onPositionReceive);

    // Activity Recognition API 사용 안함
    if (_useActivityRecognition == false) return;

    _activityStream = FlutterActivityRecognition.instance.getActivityStream()
        .handleError(_handleStreamError).listen(_onActivityReceive);
  }

  Future<void> _cancelStream() async {
    await _positionStream?.cancel();
    _positionStream = null;

    await _activityStream?.cancel();
    _activityStream = null;
  }

  void _onPositionReceive(Position position) async {
    if (!_allowMockLocations && position.isMocked) return;
    if (position.accuracy > _accuracy) return;

    // Pause the service and process the position.
    pause();

    double geoRemainingDistance;
    double radRemainingDistance;
    Geofence geofence;
    GeofenceRadius geofenceRadius;
    GeofenceStatus geofenceStatus;
    List<GeofenceRadius> geofenceRadiusList;

    final currTimestamp = position.timestamp ?? DateTime.now();
    DateTime? radTimestamp;
    Duration diffTimestamp;

    for (int i=0; i<_geofenceList.length; i++) {
      geofence = _geofenceList[i];

      // 지오펜스 남은 거리 계산 및 업데이트
      geoRemainingDistance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          geofence.latitude,
          geofence.longitude);
      geofence.updateRemainingDistance(geoRemainingDistance);

      // 지오펜스 반경 미터 단위 정렬
      geofenceRadiusList = geofence.radius.toList();
      if (_geofenceRadiusSortType == GeofenceRadiusSortType.ASC)
        geofenceRadiusList.sort((a, b) => a.length.compareTo(b.length));
      else
        geofenceRadiusList.sort((a, b) => b.length.compareTo(a.length));

      // 지오펜스 반경 처리 시작
      for (int j=0; j<geofenceRadiusList.length; j++) {
        geofenceRadius = geofenceRadiusList[j];

        // 지오펜스 반경 상태 업데이트 시간차 계산
        radTimestamp = geofenceRadius.timestamp;
        diffTimestamp = currTimestamp.difference(radTimestamp ?? currTimestamp);

        // 지오펜스 반경 상태 결정
        if (geoRemainingDistance <= geofenceRadius.length) {
          geofenceStatus = GeofenceStatus.ENTER;

          if ((diffTimestamp.inMilliseconds > _loiteringDelayMs
              && geofenceRadius.status == GeofenceStatus.ENTER)
              || geofenceRadius.status == GeofenceStatus.DWELL) {
            geofenceStatus = GeofenceStatus.DWELL;
          }
        } else {
          geofenceStatus = GeofenceStatus.EXIT;
        }

        // 지오펜스 반경 남은 거리 계산 및 업데이트
        radRemainingDistance = geoRemainingDistance - geofenceRadius.length;
        geofenceRadius.updateRemainingDistance(radRemainingDistance);

        // 상태 변경이 빈번하게 발생하지 않도록 딜레이 적용
        if (radTimestamp != null
            && diffTimestamp.inMilliseconds < _statusChangeDelayMs) continue;

        // 지오펜스 반경 상태 업데이트
        if (!geofenceRadius.updateStatus(geofenceStatus, _activity, position))
          continue;

        // 지오펜스 상태 변화 알림
        for (final listener in _geofenceStatusChangedListeners)
          await listener(geofence, geofenceRadius, geofenceStatus, position)
              .catchError(_handleStreamError);
      }
    }

    // Service resumes when position processing is complete.
    resume();
  }

  void _onActivityReceive(Activity activity) {
    if (_activity == activity) return;

    for (final listener in _activityChangedListeners)
      listener(_activity, activity);
    _activity = activity;
  }

  void _handleStreamError(dynamic error) {
    for (final listener in _streamErrorListeners)
      listener(error);
  }
}
