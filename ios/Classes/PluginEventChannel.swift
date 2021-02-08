//
//  PluginEventChannel.swift
//  geofence_service
//
//  Created by WOO JIN HWANG on 2021/02/08.
//

import Foundation

class PluginEventChannel {
  private let activityRecognitionChannel: FlutterEventChannel
  
  init(messenger: FlutterBinaryMessenger, activityRecognitionManager: ActivityRecognitionManager) {
    self.activityRecognitionChannel = FlutterEventChannel(
      name: "geofence_service/activity_recognition_updates", binaryMessenger: messenger)
    self.activityRecognitionChannel.setStreamHandler(ActivityRecognitionStreamHandler(activityRecognitionManager))
  }
  
  private class ActivityRecognitionStreamHandler: NSObject, FlutterStreamHandler {
    private let jsonEncoder: JSONEncoder
    private let activityRecognitionManager: ActivityRecognitionManager
    
    init(_ activityRecognitionManager: ActivityRecognitionManager) {
      self.jsonEncoder = JSONEncoder()
      self.activityRecognitionManager = activityRecognitionManager
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
      activityRecognitionManager.startActivityUpdates { activityData in
        do {
          let activityDataJson = try self.jsonEncoder.encode(activityData)
          events(String(data: activityDataJson, encoding: .utf8))
        } catch {
          events(FlutterError(code: ErrorCodes.ACTIVITY_DATA_ENCODING_FAILED.rawValue, message: nil, details: nil))
        }
      }
      return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
      activityRecognitionManager.stopActivityUpdates()
      return nil
    }
  }
}
