import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import 'package:geofence_service/models/error_codes.dart';
import 'package:geofence_service/models/geofence.dart';
import 'package:geofence_service/models/geofence_radius.dart';
import 'package:geofence_service/models/geofence_radius_sort_type.dart';
import 'package:geofence_service/models/geofence_service_options.dart';
import 'package:geofence_service/models/geofence_status.dart';
import 'package:geofence_service/utils/location_utils.dart';
import 'package:location/location.dart';

export 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
export 'package:flutter_foreground_task/flutter_foreground_task.dart';
export 'package:geofence_service/models/error_codes.dart';
export 'package:geofence_service/models/geofence.dart';
export 'package:geofence_service/models/geofence_radius.dart';
export 'package:geofence_service/models/geofence_radius_sort_type.dart';
export 'package:geofence_service/models/geofence_service_options.dart';
export 'package:geofence_service/models/geofence_status.dart';
export 'package:geofence_service/utils/location_utils.dart';
export 'package:location/location.dart';

/// Function to notify geofence status changes.
typedef GeofenceStatusChanged = Future<void> Function(
    Geofence geofence,
    GeofenceRadius geofenceRadius,
    GeofenceStatus geofenceStatus,
    LocationData locationData);

/// Function to notify activity changes.
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

  final _location = Location();
  final _options = GeofenceServiceOptions();

  final _locationServiceStatusChangeEventChannel =
      const EventChannel('geofence_service/location_service_status');

  StreamSubscription<LocationData>? _locationDataSubscription;
  StreamSubscription<bool>? _locationServiceStatusSubscription;
  StreamSubscription<Activity>? _activitySubscription;
  Activity _activity = Activity.unknown;

  final _geofenceList = <Geofence>[];
  final _geofenceStatusChangeListeners = <GeofenceStatusChanged>[];
  final _locationDataChangeListeners = <ValueChanged<LocationData>>[];
  final _locationServiceStatusChangeListeners = <ValueChanged<bool>>[];
  final _activityChangeListeners = <ActivityChanged>[];
  final _streamErrorListeners = <ValueChanged>[];

  /// Setup [GeofenceService].
  /// Some options do not change while the service is running.
  GeofenceService setup(
      {int? interval,
      int? accuracy,
      int? loiteringDelayMs,
      int? statusChangeDelayMs,
      bool? useActivityRecognition,
      bool? allowMockLocations,
      bool? printDevLog,
      GeofenceRadiusSortType? geofenceRadiusSortType}) {
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
    _locationDataSubscription?.pause();
    _activitySubscription?.pause();
    _printDevLog('GeofenceService paused.');
  }

  /// Resume [GeofenceService].
  void resume() {
    _locationDataSubscription?.resume();
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

  /// Register a closure to be called when the [LocationData] changes.
  void addLocationDataChangeListener(ValueChanged<LocationData> listener) {
    _locationDataChangeListeners.add(listener);
    _printDevLog(
        'Added LocationDataChange listener. (size: ${_locationDataChangeListeners.length})');
  }

  /// Remove a previously registered closure from the list of closures that
  /// are notified when the [LocationData] changes.
  void removeLocationDataChangeListener(ValueChanged<LocationData> listener) {
    _locationDataChangeListeners.remove(listener);
    _printDevLog(
        'The LocationDataChange listener has been removed. (size: ${_locationDataChangeListeners.length})');
  }

  /// Register a closure to be called when the location service status changes.
  void addLocationServiceStatusChangeListener(ValueChanged<bool> listener) {
    _locationServiceStatusChangeListeners.add(listener);
    _printDevLog(
        'Added LocationServiceStatusChange listener. (size: ${_locationServiceStatusChangeListeners.length})');
  }

  /// Remove a previously registered closure from the list of closures that
  /// are notified when the location service status changes.
  void removeLocationServiceStatusChangeListener(ValueChanged<bool> listener) {
    _locationServiceStatusChangeListeners.remove(listener);
    _printDevLog(
        'The LocationServiceStatusChange listener has been removed. (size: ${_locationServiceStatusChangeListeners.length})');
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

  /// Add geofence.
  void addGeofence(Geofence geofence) {
    _geofenceList.add(geofence);
    _printDevLog(
        'Added Geofence(${geofence.id}) (size: ${_geofenceList.length})');
  }

  /// Add geofence list.
  void addGeofenceList(List<Geofence> geofenceList) {
    for (var i = 0; i < geofenceList.length; i++) addGeofence(geofenceList[i]);
  }

  /// Remove geofence.
  void removeGeofence(Geofence geofence) {
    _geofenceList.remove(geofence);
    _printDevLog(
        'The Geofence(${geofence.id}) has been removed. (size: ${_geofenceList.length})');
  }

  /// Remove geofence list.
  void removeGeofenceList(List<Geofence> geofenceList) {
    for (var i = 0; i < geofenceList.length; i++)
      removeGeofence(geofenceList[i]);
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
    // Check that the location service is enabled.
    final serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled)
      return Future.error(ErrorCodes.LOCATION_SERVICE_DISABLED);

    // Check whether to allow location permission.
    PermissionStatus permissionStatus = await _location.hasPermission();
    if (permissionStatus == PermissionStatus.deniedForever) {
      return Future.error(ErrorCodes.LOCATION_PERMISSION_PERMANENTLY_DENIED);
    } else if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await _location.requestPermission();
      if (permissionStatus == PermissionStatus.denied ||
          permissionStatus == PermissionStatus.deniedForever)
        return Future.error(ErrorCodes.LOCATION_PERMISSION_DENIED);
    }

    // Activity Recognition API 사용 안함
    if (_options.useActivityRecognition == false) return;

    // Check whether to allow activity recognition permission.
    PermissionRequestResult permissionResult =
        await FlutterActivityRecognition.instance.checkPermission();
    if (permissionResult == PermissionRequestResult.PERMANENTLY_DENIED) {
      return Future.error(
          ErrorCodes.ACTIVITY_RECOGNITION_PERMISSION_PERMANENTLY_DENIED);
    } else if (permissionResult == PermissionRequestResult.DENIED) {
      permissionResult =
          await FlutterActivityRecognition.instance.requestPermission();
      if (permissionResult != PermissionRequestResult.GRANTED)
        return Future.error(ErrorCodes.ACTIVITY_RECOGNITION_PERMISSION_DENIED);
    }
  }

  Future<void> _listenStream() async {
    _location.changeSettings(
        accuracy: LocationAccuracy.navigation, interval: _options.interval);
    _locationDataSubscription = _location.onLocationChanged
        .handleError(_handleStreamError)
        .listen(_onLocationDataReceive);

    _locationServiceStatusSubscription =
        _locationServiceStatusChangeEventChannel
            .receiveBroadcastStream()
            .map((event) => event == true)
            .listen(_onLocationServiceStatusChange);

    // Activity Recognition API 사용 안함
    if (_options.useActivityRecognition == false) return;

    _activitySubscription = FlutterActivityRecognition.instance.activityStream
        .handleError(_handleStreamError)
        .listen(_onActivityReceive);
  }

  Future<void> _cancelStream() async {
    await _locationDataSubscription?.cancel();
    _locationDataSubscription = null;

    await _locationServiceStatusSubscription?.cancel();
    _locationServiceStatusSubscription = null;

    await _activitySubscription?.cancel();
    _activitySubscription = null;
  }

  void _onLocationDataReceive(LocationData locationData) async {
    if (locationData.latitude == null || locationData.longitude == null) return;
    if ((locationData.isMock ?? false) && !_options.allowMockLocations) return;
    if ((locationData.accuracy ?? 0.0) > _options.accuracy) return;

    for (final listener in _locationDataChangeListeners) listener(locationData);

    // Pause the service and process the location data.
    _locationDataSubscription?.pause();

    double geoRemainingDistance;
    double radRemainingDistance;
    Geofence geofence;
    GeofenceRadius geofenceRadius;
    GeofenceStatus geofenceStatus;
    List<GeofenceRadius> geofenceRadiusList;

    final currTimestamp = (locationData.time == null)
        ? DateTime.now()
        : DateTime.fromMillisecondsSinceEpoch(locationData.time!.toInt());
    DateTime? radTimestamp;
    Duration diffTimestamp;

    for (var i = 0; i < _geofenceList.length; i++) {
      geofence = _geofenceList[i];

      // 지오펜스 남은 거리 계산 및 업데이트
      geoRemainingDistance = LocationUtils.distanceBetween(
          locationData.latitude!,
          locationData.longitude!,
          geofence.latitude,
          geofence.longitude);
      geofence.updateRemainingDistance(geoRemainingDistance);

      // 지오펜스 반경 미터 단위 정렬
      geofenceRadiusList = geofence.radius.toList();
      if (_options.geofenceRadiusSortType == GeofenceRadiusSortType.ASC)
        geofenceRadiusList.sort((a, b) => a.length.compareTo(b.length));
      else
        geofenceRadiusList.sort((a, b) => b.length.compareTo(a.length));

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
        if (radTimestamp != null &&
            diffTimestamp.inMilliseconds < _options.statusChangeDelayMs)
          continue;

        // 지오펜스 반경 상태 업데이트
        if (!geofenceRadius.updateStatus(
            geofenceStatus, _activity, locationData.speed, currTimestamp))
          continue;

        // 지오펜스 상태 변화 알림
        for (final listener in _geofenceStatusChangeListeners)
          await listener(geofence, geofenceRadius, geofenceStatus, locationData)
              .catchError(_handleStreamError);
      }
    }

    // Service resumes when the location data processing is complete.
    _locationDataSubscription?.resume();
  }

  void _onLocationServiceStatusChange(bool status) {
    for (final listener in _locationServiceStatusChangeListeners)
      listener(status);
  }

  void _onActivityReceive(Activity activity) {
    if (_activity == activity) return;

    for (final listener in _activityChangeListeners)
      listener(_activity, activity);
    _activity = activity;
  }

  void _handleStreamError(dynamic error) {
    for (final listener in _streamErrorListeners) listener(error);
  }

  void _printDevLog(String message) {
    if (kReleaseMode) return;
    if (!_options.printDevLog) return;

    final nowDateTime = DateTime.now().toString();
    dev.log('$nowDateTime\t$message');
  }
}
