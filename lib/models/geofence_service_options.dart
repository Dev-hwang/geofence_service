import 'package:geofence_service/models/geofence_radius_sort_type.dart';

/// Options for [GeofenceService].
class GeofenceServiceOptions {
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

  /// Whether to show the developer log.
  /// If this value is set to true, logs for geofence service activities (start, stop, etc.) can be viewed.
  /// It does not work in release mode.
  /// The default is `false`.
  bool _printDevLog = false;

  /// Sets the sort type of the geofence radius.
  /// The default is `GeofenceRadiusSortType.DESC`.
  GeofenceRadiusSortType _geofenceRadiusSortType = GeofenceRadiusSortType.DESC;

  int get interval => _interval;
  set interval(int? value) => _interval = value ?? _interval;

  int get accuracy => _accuracy;
  set accuracy(int? value) => _accuracy = value ?? _accuracy;

  int get loiteringDelayMs => _loiteringDelayMs;
  set loiteringDelayMs(int? value) =>
      _loiteringDelayMs = value ?? _loiteringDelayMs;

  int get statusChangeDelayMs => _statusChangeDelayMs;
  set statusChangeDelayMs(int? value) =>
      _statusChangeDelayMs = value ?? _statusChangeDelayMs;

  bool get useActivityRecognition => _useActivityRecognition;
  set useActivityRecognition(bool? value) =>
      _useActivityRecognition = value ?? _useActivityRecognition;

  bool get allowMockLocations => _allowMockLocations;
  set allowMockLocations(bool? value) =>
      _allowMockLocations = value ?? _allowMockLocations;

  bool get printDevLog => _printDevLog;
  set printDevLog(bool? value) => _printDevLog = value ?? _printDevLog;

  GeofenceRadiusSortType get geofenceRadiusSortType => _geofenceRadiusSortType;
  set geofenceRadiusSortType(GeofenceRadiusSortType? value) =>
      _geofenceRadiusSortType = value ?? _geofenceRadiusSortType;
}
