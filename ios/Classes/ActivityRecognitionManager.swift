//
//  ActivityRecognitionManager.swift
//  geofence_service
//
//  Created by WOO JIN HWANG on 2021/02/02.
//

import CoreMotion
import Foundation

typealias ActivityDataHandler = (ActivityData) -> Void
typealias PermissionResultHandler = (PermissionResult) -> Void

class ActivityRecognitionManager {
  private let motionActivityManager = CMMotionActivityManager()
  private var isRunningActivityUpdates = false
  
  public func checkPermission(handler: @escaping PermissionResultHandler) {
    let nowDate = Date()
    motionActivityManager.queryActivityStarting(from: nowDate, to: nowDate, to: .main) { (activities, error) in
      if let error = error, (error as NSError).code == CMErrorMotionActivityNotAuthorized.rawValue {
        handler(PermissionResult.PERMANENTLY_DENIED)
        return
      }

      handler(PermissionResult.GRANTED)
    }
  }

  public func startActivityUpdates(handler: @escaping ActivityDataHandler) {
    if (isRunningActivityUpdates) {
      NSLog("Activity updates already started.")
      stopActivityUpdates()
    }

    motionActivityManager.startActivityUpdates(to: .main) { (activity) in
      guard let activity = activity else { return }
      handler(ActivityData(from: activity))
    }
    isRunningActivityUpdates = true
  }
  
  public func stopActivityUpdates() {
    motionActivityManager.stopActivityUpdates()
    isRunningActivityUpdates = false
  }
}
