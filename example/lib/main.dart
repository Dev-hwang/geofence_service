import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:geofence_service/geofence_service.dart';

void main() => runApp(ExampleApp());

class ExampleApp extends StatefulWidget {
  @override
  _ExampleAppState createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  final _activityStreamController = StreamController<Activity>();
  final _geofenceStreamController = StreamController<Geofence>();

  // Create a [GeofenceService] instance and set options.
  final _geofenceService = GeofenceService.instance.setup(
    interval: 5000,
    accuracy: 100,
    useActivityRecognition: true,
    allowMockLocations: false,
    geofenceRadiusSortType: GeofenceRadiusSortType.DESC
  );

  // Create a [Geofence] list.
  final _geofenceList = <Geofence>[
    Geofence(
      id: 'place_1',
      latitude: 35.103422,
      longitude: 129.036023,
      radius: [
        GeofenceRadius(id: 'radius_100m', length: 100),
        GeofenceRadius(id: 'radius_25m', length: 25),
        GeofenceRadius(id: 'radius_250m', length: 250),
        GeofenceRadius(id: 'radius_200m', length: 200)
      ]
    ),
    Geofence(
      id: 'place_2',
      latitude: 35.104971,
      longitude: 129.034851,
      radius: [
        GeofenceRadius(id: 'radius_25m', length: 25),
        GeofenceRadius(id: 'radius_100m', length: 100),
        GeofenceRadius(id: 'radius_200m', length: 200)
      ]
    ),
  ];

  Future<void> _onGeofenceStatusChanged(
      Geofence geofence,
      GeofenceRadius geofenceRadius,
      GeofenceStatus geofenceStatus,
      Position position) async {
    dev.log('geofence: ${geofence.toMap()}');
    dev.log('geofenceRadius: ${geofenceRadius.toMap()}');
    dev.log('geofenceStatus: ${geofenceStatus.toString()}\n');
    _geofenceStreamController.sink.add(geofence);
  }

  void _onActivityChanged(
      Activity prevActivity,
      Activity currActivity) {
    dev.log('prevActivity: ${prevActivity.toMap()}');
    dev.log('currActivity: ${currActivity.toMap()}\n');
    _activityStreamController.sink.add(currActivity);
  }

  void _onError(dynamic error) {
    final errorCode = getErrorCodesFromError(error);
    if (errorCode == null) {
      dev.log('Undefined error: $error');
      return;
    }

    dev.log('ErrorCode: $errorCode');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _geofenceService.addGeofenceStatusChangedListener(_onGeofenceStatusChanged);
      _geofenceService.addActivityChangedListener(_onActivityChanged);
      _geofenceService.addStreamErrorListener(_onError);
      _geofenceService.start(_geofenceList).catchError(_onError);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // A widget used when you want to start a foreground task when trying to minimize or close the app.
      // Declare on top of the [Scaffold] widget.
      home: WillStartForegroundTask(
        onWillStart: () {
          // You can add a foreground task start condition.
          return _geofenceService.isRunningService;
        },
        notificationOptions: NotificationOptions(
          channelId: 'geofence_service_notification_channel',
          channelName: 'Geofence Service Notification',
          channelDescription: 'This notification appears when the geofence service is running in the background.',
          channelImportance: NotificationChannelImportance.LOW,
          priority: NotificationPriority.LOW
        ),
        notificationTitle: 'Geofence Service is running',
        notificationText: 'Tap to return to the app',
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Geofence Service'),
            centerTitle: true
          ),
          body: _buildContentView()
        ),
      ),
    );
  }

  @override
  void dispose() {
    _activityStreamController.close();
    _geofenceStreamController.close();
    super.dispose();
  }

  Widget _buildContentView() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(8.0),
      children: [
        _buildActivityMonitor(),
        SizedBox(height: 20.0),
        _buildGeofenceMonitor()
      ],
    );
  }
  
  Widget _buildActivityMonitor() {
    return StreamBuilder<Activity>(
      stream: _activityStreamController.stream,
      builder: (context, snapshot) {
        final updatedDateTime = DateTime.now();
        final content = snapshot.data?.toMap().toString() ?? '';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('•\t\tActivity (updated: $updatedDateTime)'),
            SizedBox(height: 10.0),
            Text(content)
          ]
        );
      }
    );
  }
  
  Widget _buildGeofenceMonitor() {
    return StreamBuilder<Geofence>(
      stream: _geofenceStreamController.stream,
      builder: (context, snapshot) {
        final updatedDateTime = DateTime.now();
        final content = snapshot.data?.toMap().toString() ?? '';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('•\t\tGeofence (updated: $updatedDateTime)'),
            SizedBox(height: 10.0),
            Text(content)
          ]
        );
      }
    );
  }
}
