import 'package:flutter/material.dart';
import 'package:geofence_service/models/activity.dart';
import 'package:geofence_service/models/geofence_status.dart';
import 'package:geolocator/geolocator.dart';

/// Data class to create radius of [Geofence].
class GeofenceRadius {
  /// Identifier for [GeofenceRadius].
  final String id;

  /// Custom data for [GeofenceRadius].
  final dynamic data;

  /// Radius length in meters.
  /// The best result should be set between 100 and 150 meters in radius.
  /// If Wi-FI is available, it can be set up to 20~40m.
  final double length;

  /// Geofence status of [GeofenceRadius].
  GeofenceStatus _status = GeofenceStatus.EXIT;

  /// Return the geofence status.
  GeofenceStatus get status => _status;

  /// Activity when geofence status changes.
  Activity _activity;

  /// Return the activity.
  Activity get activity => _activity;

  /// Speed when geofence status changes.
  double _speed;

  /// Return the speed.
  double get speed => _speed;

  /// Timestamp when geofence status changes.
  DateTime _timestamp;

  /// Return the timestamp.
  DateTime get timestamp => _timestamp;

  /// Remaining distance to destination.
  double _remainingDistance;

  /// Return the remaining distance.
  double get remainingDistance => _remainingDistance;

  GeofenceRadius({
    @required this.id,
    this.data,
    @required this.length
  })  : assert(id != null && id.isNotEmpty),
        assert(length != null && length > 0.0);

  /// Return the internal field of the class in map format.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'data': data,
      'length': length,
      'status': _status,
      'activity': _activity?.toMap(),
      'speed': _speed,
      'timestamp': _timestamp,
      'remainingDistance': _remainingDistance
    };
  }

  /// Update the remaining distance.
  void updateRemainingDistance(double distance) {
    if (distance < 0.0)
      _remainingDistance = 0.0;
    _remainingDistance = distance;
  }

  /// Update geofence status of [GeofenceRadius].
  /// If the status changes, it return true, otherwise it return false.
  bool updateStatus(
      GeofenceStatus status, Activity activity, Position position) {
    if ((status != null) && (status != _status)) {
      _status = status;
      _activity = activity;
      _speed = position.speed;
      _timestamp = position.timestamp;
      return true;
    }

    return false;
  }
}
