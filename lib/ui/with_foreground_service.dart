import 'package:flutter/material.dart';
import 'package:geofence_service/geofence_service.dart';
import 'package:geofence_service/service/foreground_service.dart';

/// Use to run the geofence service in the background.
/// Declare between the [MaterialApp] and [Scaffold] widgets.
class WithForegroundService extends StatefulWidget {
  /// Geofence service in use on the current page.
  final GeofenceService geofenceService;

  /// Channel ID for foreground service notification.
  final String notificationChannelId;

  /// Channel Name for foreground service notification.
  final String notificationChannelName;

  /// Content Title for foreground service notification.
  final String notificationContentTitle;

  /// Content Text for foreground service notification.
  final String notificationContentText;

  /// Child widget of current page.
  final Widget child;

  WithForegroundService({
    Key key,
    @required this.geofenceService,
    this.notificationChannelId,
    this.notificationChannelName,
    this.notificationContentTitle,
    this.notificationContentText,
    @required this.child
  })  : assert(geofenceService != null),
        assert(child != null),
        super(key: key);

  @override
  _WithForegroundServiceState createState() => _WithForegroundServiceState();
}

class _WithForegroundServiceState extends State<WithForegroundService>
    with WidgetsBindingObserver {

  void _startForegroundService() {
    ForegroundService.start(
      notificationChannelId: widget.notificationChannelId,
      notificationChannelName: widget.notificationChannelName,
      notificationContentTitle: widget.notificationContentTitle,
      notificationContentText: widget.notificationContentText
    );
  }

  void _stopForegroundService() {
    ForegroundService.stop();
  }

  Future<bool> _onWillPop() async {
    if (widget.geofenceService.isRunningService) {
      ForegroundService.minimizeApp();
      return false;
    }

    return true;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (widget.geofenceService.isRunningService) {
      switch (state) {
        case AppLifecycleState.resumed:
          _stopForegroundService();
          break;
        case AppLifecycleState.inactive:
          _startForegroundService();
          break;
        case AppLifecycleState.paused:
          _startForegroundService();
          break;
        case AppLifecycleState.detached:
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: widget.child
    );
  }
}
