import 'package:flutter/material.dart';
import 'package:geofence_service/model/geofence_radius.dart';
import 'package:geofence_service/model/geofence_status.dart';

/// Data class to create geofence.
class Geofence {
  /// Identifier for [Geofence].
  final String id;

  /// Custom data for [Geofence].
  final dynamic data;

  /// The latitude of geofence center.
  final double latitude;

  /// The longitude of geofence center.
  final double longitude;

  /// The radius of geofence.
  final List<GeofenceRadius> radius;

  /// Return the geofence status.
  GeofenceStatus get status => _getStatus();

  /// Return the timestamp.
  DateTime get timestamp => _getTimestamp();

  /// Remaining distance to destination.
  double _remainingDistance;

  /// Return the remaining distance.
  double get remainingDistance => _remainingDistance;

  Geofence({
    @required this.id,
    this.data,
    @required this.latitude,
    @required this.longitude,
    @required this.radius
  })  : assert(id != null && id.isNotEmpty),
        assert(latitude != null),
        assert(longitude != null),
        assert(radius != null && radius.isNotEmpty);

  /// Return the internal field of the class in map format.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'data': data,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius.map((e) => e.toMap()).toList(),
      'status': status,
      'timestamp': timestamp,
      'remainingDistance': _remainingDistance
    };
  }

  /// Update the remaining distance.
  void updateRemainingDistance(double distance) {
    if (distance < 0.0)
      _remainingDistance = 0.0;
    _remainingDistance = distance;
  }

  /// Return the geofence status.
  GeofenceStatus _getStatus() {
    if (radius.where((e) => e.status == GeofenceStatus.ENTER).isNotEmpty)
      return GeofenceStatus.ENTER;
    else
      return GeofenceStatus.EXIT;
  }

  /// Return the timestamp.
  DateTime _getTimestamp() {
    final timestampList = <DateTime>[];
    DateTime timestamp;
    for (int i=0; i<radius.length; i++) {
      timestamp = radius[i].timestamp;
      if (timestamp != null)
        timestampList.add(timestamp);
    }

    timestampList.sort((a, b) => a.compareTo(b));
    if (timestampList.isEmpty)
      return null;

    if (_getStatus() == GeofenceStatus.ENTER)
      return timestampList.first;
    else
      return timestampList.last;
  }
}
