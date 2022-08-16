import 'dart:async';
import 'dart:developer' as dev;

import 'package:fl_location/fl_location.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import 'package:geofence_service/errors/error_codes.dart';
import 'package:geofence_service/models/geofence.dart';
import 'package:geofence_service/models/geofence_radius.dart';
import 'package:geofence_service/models/geofence_radius_sort_type.dart';
import 'package:geofence_service/models/geofence_service_options.dart';
import 'package:geofence_service/models/geofence_status.dart';

export 'package:fl_location/fl_location.dart';
export 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
export 'package:flutter_foreground_task/flutter_foreground_task.dart';
export 'package:geofence_service/errors/error_codes.dart';
export 'package:geofence_service/models/geofence.dart';
export 'package:geofence_service/models/geofence_radius.dart';
export 'package:geofence_service/models/geofence_radius_sort_type.dart';
export 'package:geofence_service/models/geofence_service_options.dart';
export 'package:geofence_service/models/geofence_status.dart';

/// Callback function to handle geofence status changes.
typedef GeofenceStatusChanged = Future<void> Function(
    Geofence geofence,
    GeofenceRadius geofenceRadius,
    GeofenceStatus geofenceStatus,
    Location location);

/// Callback function to handle location changes.
typedef LocationChanged = void Function(Location location);

/// Callback function to handle activity changes.
typedef ActivityChanged = void Function(
    Activity prevActivity, Activity currActivity);

/// A class provides geofence management and geo-fencing.
class GeofenceService {
  GeofenceService._internal();

  /// Instance of [GeofenceService].
  static final instance = GeofenceService._internal();

  /// Whether the service is running.
  bool _isRunningService = false;

  /// Returns whether the service is running.
  bool get isRunningService => _isRunningService;

  final GeofenceServiceOptions _options = GeofenceServiceOptions();

  StreamSubscription<Location>? _locationSubscription;
  StreamSubscription<bool>? _locationServicesStatusSubscription;
  StreamSubscription<Activity>? _activitySubscription;
  Activity _activity = Activity.unknown;

  final _geofenceList = <Geofence>[];
  final _geofenceStatusChangeListeners = <GeofenceStatusChanged>[];
  final _locationChangeListeners = <LocationChanged>[];
  final _locationServicesStatusChangeListeners = <ValueChanged<bool>>[];
  final _activityChangeListeners = <ActivityChanged>[];
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
    bool? printDevLog,
    GeofenceRadiusSortType? geofenceRadiusSortType,
  }) {
    _options.interval = interval;
    _options.accuracy = accuracy;
    _options.loiteringDelayMs = loiteringDelayMs;
    _options.statusChangeDelayMs = statusChangeDelayMs;
    _options.useActivityRecognition = useActivityRecognition;
    _options.allowMockLocations = allowMockLocations;
    _options.printDevLog = printDevLog;
    _options.geofenceRadiusSortType = geofenceRadiusSortType;

    return this;
  }

  /// Start [GeofenceService].
  /// It can be initialized with [geofenceList].
  Future<void> start([List<Geofence>? geofenceList]) async {
    if (_isRunningService) return Future.error(ErrorCodes.ALREADY_STARTED);

    await _checkPermissions();
    await _listenStream();

    _activity = Activity.unknown;
    if (geofenceList != null) _geofenceList.addAll(geofenceList);

    _isRunningService = true;
    _printDevLog('GeofenceService started.');
  }

  /// Stop [GeofenceService].
  /// Note that the registered geofence list is cleared when this function is called.
  Future<void> stop() async {
    await _cancelStream();

    _activity = Activity.unknown;
    _geofenceList.clear();

    _isRunningService = false;
    _printDevLog('GeofenceService stopped.');
  }

  /// Pause [GeofenceService].
  void pause() {
    _locationSubscription?.pause();
    _activitySubscription?.pause();
    _printDevLog('GeofenceService paused.');
  }

  /// Resume [GeofenceService].
  void resume() {
    _locationSubscription?.resume();
    _activitySubscription?.resume();
    _printDevLog('GeofenceService resumed.');
  }

  /// Register a closure to be called when the [GeofenceStatus] changes.
  void addGeofenceStatusChangeListener(GeofenceStatusChanged listener) {
    _geofenceStatusChangeListeners.add(listener);
    _printDevLog(
        'Added GeofenceStatusChange listener. (size: ${_geofenceStatusChangeListeners.length})');
  }

  /// Remove a previously registered closure from the list of closures that
  /// are notified when the [GeofenceStatus] changes.
  void removeGeofenceStatusChangeListener(GeofenceStatusChanged listener) {
    _geofenceStatusChangeListeners.remove(listener);
    _printDevLog(
        'The GeofenceStatusChange listener has been removed. (size: ${_geofenceStatusChangeListeners.length})');
  }

  /// Register a closure to be called when the [Activity] changes.
  void addActivityChangeListener(ActivityChanged listener) {
    _activityChangeListeners.add(listener);
    _printDevLog(
        'Added ActivityChange listener. (size: ${_activityChangeListeners.length})');
  }

  /// Remove a previously registered closure from the list of closures that
  /// are notified when the [Activity] changes.
  void removeActivityChangeListener(ActivityChanged listener) {
    _activityChangeListeners.remove(listener);
    _printDevLog(
        'The ActivityChange listener has been removed. (size: ${_activityChangeListeners.length})');
  }

  /// Register a closure to be called when the [Location] changes.
  void addLocationChangeListener(LocationChanged listener) {
    _locationChangeListeners.add(listener);
    _printDevLog(
        'Added LocationChange listener. (size: ${_locationChangeListeners.length})');
  }

  /// Remove a previously registered closure from the list of closures that
  /// are notified when the [Location] changes.
  void removeLocationChangeListener(LocationChanged listener) {
    _locationChangeListeners.remove(listener);
    _printDevLog(
        'The LocationChange listener has been removed. (size: ${_locationChangeListeners.length})');
  }

  /// Register a closure to be called when the location services status changes.
  void addLocationServicesStatusChangeListener(ValueChanged<bool> listener) {
    _locationServicesStatusChangeListeners.add(listener);
    _printDevLog(
        'Added LocationServicesStatusChange listener. (size: ${_locationServicesStatusChangeListeners.length})');
  }

  /// Remove a previously registered closure from the list of closures that
  /// are notified when the location services status changes.
  void removeLocationServicesStatusChangeListener(ValueChanged<bool> listener) {
    _locationServicesStatusChangeListeners.remove(listener);
    _printDevLog(
        'The LocationServicesStatusChange listener has been removed. (size: ${_locationServicesStatusChangeListeners.length})');
  }

  /// Register a closure to be called when a stream error occurs.
  void addStreamErrorListener(ValueChanged listener) {
    _streamErrorListeners.add(listener);
    _printDevLog(
        'Added StreamError listener. (size: ${_streamErrorListeners.length})');
  }

  /// Remove a previously registered closure from the list of closures that
  /// are notified when a stream error occurs.
  void removeStreamErrorListener(ValueChanged listener) {
    _streamErrorListeners.remove(listener);
    _printDevLog(
        'The StreamError listener has been removed. (size: ${_streamErrorListeners.length})');
  }

  /// Clears all listeners registered with the service.
  void clearAllListeners() {
    _geofenceStatusChangeListeners.clear();
    _locationChangeListeners.clear();
    _locationServicesStatusChangeListeners.clear();
    _activityChangeListeners.clear();
    _streamErrorListeners.clear();
  }

  /// Add geofence.
  void addGeofence(Geofence geofence) {
    _geofenceList.add(geofence);
    _printDevLog(
        'Added Geofence(${geofence.id}) (size: ${_geofenceList.length})');
  }

  /// Add geofence list.
  void addGeofenceList(List<Geofence> geofenceList) {
    for (var i = 0; i < geofenceList.length; i++) {
      addGeofence(geofenceList[i]);
    }
  }

  /// Remove geofence.
  void removeGeofence(Geofence geofence) {
    _geofenceList.remove(geofence);
    _printDevLog(
        'The Geofence(${geofence.id}) has been removed. (size: ${_geofenceList.length})');
  }

  /// Remove geofence list.
  void removeGeofenceList(List<Geofence> geofenceList) {
    for (var i = 0; i < geofenceList.length; i++) {
      removeGeofence(geofenceList[i]);
    }
  }

  /// Remove geofence by [id].
  void removeGeofenceById(String id) {
    _geofenceList.removeWhere((geofence) => geofence.id == id);
    _printDevLog(
        'The Geofence($id) has been removed. (size: ${_geofenceList.length})');
  }

  /// Clear geofence list.
  void clearGeofenceList() {
    _geofenceList.clear();
    _printDevLog('The GeofenceList has been cleared.');
  }

  Future<void> _checkPermissions() async {
    // Check whether location services are enabled.
    if (!await FlLocation.isLocationServicesEnabled) {
      return Future.error(ErrorCodes.LOCATION_SERVICES_DISABLED);
    }

    // Check whether to allow location permission.
    var locationPermission = await FlLocation.checkLocationPermission();
    if (locationPermission == LocationPermission.deniedForever) {
      return Future.error(ErrorCodes.LOCATION_PERMISSION_PERMANENTLY_DENIED);
    } else if (locationPermission == LocationPermission.denied) {
      locationPermission = await FlLocation.requestLocationPermission();
      if (locationPermission == LocationPermission.denied ||
          locationPermission == LocationPermission.deniedForever) {
        return Future.error(ErrorCodes.LOCATION_PERMISSION_DENIED);
      }
    }

    // Activity Recognition API 사용 안함
    if (_options.useActivityRecognition == false) return;

    // Check whether to allow activity recognition permission.
    var activityPermission =
        await FlutterActivityRecognition.instance.checkPermission();
    if (activityPermission == PermissionRequestResult.PERMANENTLY_DENIED) {
      return Future.error(
          ErrorCodes.ACTIVITY_RECOGNITION_PERMISSION_PERMANENTLY_DENIED);
    } else if (activityPermission == PermissionRequestResult.DENIED) {
      activityPermission =
          await FlutterActivityRecognition.instance.requestPermission();
      if (activityPermission != PermissionRequestResult.GRANTED) {
        return Future.error(ErrorCodes.ACTIVITY_RECOGNITION_PERMISSION_DENIED);
      }
    }
  }

  Future<void> _listenStream() async {
    _locationSubscription = FlLocation.getLocationStream(
      accuracy: LocationAccuracy.navigation,
      interval: _options.interval,
    ).handleError(_handleStreamError).listen(_onLocationReceive);

    _locationServicesStatusSubscription =
        FlLocation.getLocationServicesStatusStream()
            .map((event) => event == LocationServicesStatus.enabled)
            .listen(_onLocationServicesStatusChange);

    // Activity Recognition API 사용 안함
    if (_options.useActivityRecognition == false) return;

    _activitySubscription = FlutterActivityRecognition.instance.activityStream
        .handleError(_handleStreamError)
        .listen(_onActivityReceive);
  }

  Future<void> _cancelStream() async {
    await _locationSubscription?.cancel();
    _locationSubscription = null;

    await _locationServicesStatusSubscription?.cancel();
    _locationServicesStatusSubscription = null;

    await _activitySubscription?.cancel();
    _activitySubscription = null;
  }

  void _onLocationReceive(Location location) async {
    if (location.isMock && !_options.allowMockLocations) return;
    if (location.accuracy > _options.accuracy) return;

    for (final listener in _locationChangeListeners) {
      listener(location);
    }

    // Pause the service and process the location.
    _locationSubscription?.pause();

    double geoRemainingDistance;
    double radRemainingDistance;
    Geofence geofence;
    GeofenceRadius geofenceRadius;
    GeofenceStatus geofenceStatus;
    List<GeofenceRadius> geofenceRadiusList;

    final currTimestamp = location.timestamp;
    DateTime? radTimestamp;
    Duration diffTimestamp;

    for (var i = 0; i < _geofenceList.length; i++) {
      geofence = _geofenceList[i];

      // 지오펜스 남은 거리 계산 및 업데이트
      geoRemainingDistance = LocationUtils.distanceBetween(location.latitude,
          location.longitude, geofence.latitude, geofence.longitude);
      geofence.updateRemainingDistance(geoRemainingDistance);

      // 지오펜스 반경 미터 단위 정렬
      geofenceRadiusList = geofence.radius.toList();
      if (_options.geofenceRadiusSortType == GeofenceRadiusSortType.ASC) {
        geofenceRadiusList.sort((a, b) => a.length.compareTo(b.length));
      } else {
        geofenceRadiusList.sort((a, b) => b.length.compareTo(a.length));
      }

      // 지오펜스 반경 처리 시작
      for (var j = 0; j < geofenceRadiusList.length; j++) {
        geofenceRadius = geofenceRadiusList[j];

        // 지오펜스 반경 상태 업데이트 시간차 계산
        radTimestamp = geofenceRadius.timestamp;
        diffTimestamp = currTimestamp.difference(radTimestamp ?? currTimestamp);

        // 지오펜스 반경 상태 결정
        if (geoRemainingDistance <= geofenceRadius.length) {
          geofenceStatus = GeofenceStatus.ENTER;

          if ((diffTimestamp.inMilliseconds > _options.loiteringDelayMs &&
                  geofenceRadius.status == GeofenceStatus.ENTER) ||
              geofenceRadius.status == GeofenceStatus.DWELL) {
            geofenceStatus = GeofenceStatus.DWELL;
          }
        } else {
          geofenceStatus = GeofenceStatus.EXIT;
        }

        // 지오펜스 반경 남은 거리 계산 및 업데이트
        radRemainingDistance = geoRemainingDistance - geofenceRadius.length;
        geofenceRadius.updateRemainingDistance(radRemainingDistance);

        // 상태 변경이 빈번하게 발생하지 않도록 딜레이 적용
        if (geofenceStatus != GeofenceStatus.DWELL &&
            radTimestamp != null &&
            diffTimestamp.inMilliseconds < _options.statusChangeDelayMs) {
          continue;
        }

        // 지오펜스 반경 상태 업데이트
        if (!geofenceRadius.updateStatus(
            geofenceStatus, _activity, location.speed, currTimestamp)) {
          continue;
        }

        // 지오펜스 상태 변화 알림
        for (final listener in _geofenceStatusChangeListeners) {
          await listener(geofence, geofenceRadius, geofenceStatus, location)
              .catchError(_handleStreamError);
        }
      }
    }

    // Service resumes when the location processing is complete.
    _locationSubscription?.resume();
  }

  void _onLocationServicesStatusChange(bool status) {
    for (final listener in _locationServicesStatusChangeListeners) {
      listener(status);
    }
  }

  void _onActivityReceive(Activity activity) {
    if (_activity == activity) return;

    for (final listener in _activityChangeListeners) {
      listener(_activity, activity);
    }
    _activity = activity;
  }

  void _handleStreamError(dynamic error) {
    for (final listener in _streamErrorListeners) {
      listener(error);
    }
  }

  void _printDevLog(String message) {
    if (kReleaseMode) return;
    if (!_options.printDevLog) return;

    final nowDateTime = DateTime.now().toString();
    dev.log('$nowDateTime\t$message');
  }
}
