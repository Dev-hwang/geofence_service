/// Defines the type of the geofence status.
enum GeofenceStatus {
  /// Occurs when entering the geofence radius.
  ENTER,

  /// Occurs when exiting the geofence radius.
  EXIT,

  /// Occurs when the loitering delay elapses after entering the geofence area.
  DWELL
}
