/// Defines the sort type of the geofence radius.
/// If you have set multiple radius for one geofence, multiple radius can come in at the same time.
/// At this time, you can control the order in which the radius comes in by referring to the radius meters.
enum GeofenceRadiusSortType {
  /// Sort the meters in ascending order.
  ASC,

  /// Sort the meters in descending order.
  DESC
}
