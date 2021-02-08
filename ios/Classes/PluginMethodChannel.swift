//
//  PluginMethodChannel.swift
//  geofence_service
//
//  Created by WOO JIN HWANG on 2021/02/08.
//

import Foundation

class PluginMethodChannel {
  private let activityRecognitionManager: ActivityRecognitionManager
  private let activityRecognitionChannel: FlutterMethodChannel
  
  init(messenger: FlutterBinaryMessenger, activityRecognitionManager: ActivityRecognitionManager) {
    self.activityRecognitionManager = activityRecognitionManager
    self.activityRecognitionChannel = FlutterMethodChannel(
      name: "geofence_service/activity_recognition", binaryMessenger: messenger)
    self.activityRecognitionChannel.setMethodCallHandler(activityRecognitionMethodCallHandler)
  }
  
  private func activityRecognitionMethodCallHandler(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
      case "checkActivityRecognitionPermission":
        activityRecognitionManager.checkPermission { permissionResult in
          result(permissionResult.rawValue)
        }
        break
      default:
        result(FlutterMethodNotImplemented)
    }
  }
}
