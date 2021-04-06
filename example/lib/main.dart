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
  final geofenceService = GeofenceService.instance;
  final activityController = StreamController<Activity>();
  final geofenceController = StreamController<Geofence>();

  final geofenceList = <Geofence>[
    Geofence(
      id: 'place_1',
      latitude: 35.105136,
      longitude: 129.037513,
      radius: [
        GeofenceRadius(id: 'radius_25m', length: 25),
        GeofenceRadius(id: 'radius_100m', length: 100)
      ]
    ),
    Geofence(
      id: 'place_2',
      latitude: 35.104971,
      longitude: 129.034851,
      radius: [
        GeofenceRadius(id: 'radius_25m', length: 25),
        GeofenceRadius(id: 'radius_100m', length: 100)
      ]
    ),
  ];

  void onGeofenceStatusChanged(
      Geofence geofence,
      GeofenceRadius geofenceRadius,
      GeofenceStatus geofenceStatus) {
    dev.log('geofence: ${geofence.toMap()}');
    dev.log('geofenceRadius: ${geofenceRadius.toMap()}');
    dev.log('geofenceStatus: ${geofenceStatus.toString()}\n');
    geofenceController.sink.add(geofence);
  }

  void onActivityChanged(
      Activity prevActivity,
      Activity currActivity) {
    dev.log('prevActivity: ${prevActivity.toMap()}');
    dev.log('currActivity: ${currActivity.toMap()}\n');
    activityController.sink.add(currActivity);
  }

  void onError(dynamic error) {
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
      geofenceService.addGeofenceStatusChangedListener(onGeofenceStatusChanged);
      geofenceService.addActivityChangedListener(onActivityChanged);
      geofenceService.addStreamErrorListener(onError);
      geofenceService.start(geofenceList).catchError(onError);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Use to run the geofence service in the background.
      // Declare between the [MaterialApp] and [Scaffold] widgets.
      home: WithForegroundService(
        geofenceService: geofenceService,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Geofence Service Example'),
            centerTitle: true
          ),
          body: buildContentView()
        ),
      ),
    );
  }

  @override
  void dispose() {
    activityController.close();
    geofenceController.close();
    super.dispose();
  }

  Widget buildContentView() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildActivityMonitor(),
          Expanded(child: buildGeofenceMonitor())
        ],
      ),
    );
  }
  
  Widget buildActivityMonitor() {
    return StreamBuilder<Activity>(
      stream: activityController.stream,
      builder: (context, snapshot) {
        final updatedTime = DateTime.now();
        final content = snapshot.data?.toMap().toString() ?? '';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('\tActivity (updated: $updatedTime)'),
            Card(color: Colors.lightGreen, child: Text(content))
          ]
        );
      }
    );
  }
  
  Widget buildGeofenceMonitor() {
    return StreamBuilder<Geofence>(
      stream: geofenceController.stream,
      builder: (context, snapshot) {
        final updatedTime = DateTime.now();
        final content = snapshot.data?.toMap().toString() ?? '';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('\tGeofence (updated: $updatedTime)'),
            Card(color: Colors.lightGreen, child: Text(content))
          ]
        );
      }
    );
  }
}
