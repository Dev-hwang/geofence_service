//
//  ActivityStatus.swift
//  geofence_service
//
//  Created by WOO JIN HWANG on 2021/02/02.
//

import CoreMotion
import Foundation

struct ActivityData: Codable {
  let type: String
  let confidence: String
  
  init(from activity: CMMotionActivity) {
    switch true {
      case activity.automotive:
        self.type = "IN_VEHICLE"
      case activity.cycling:
        self.type = "ON_BICYCLE"
      case activity.running:
        self.type = "RUNNING"
      case activity.stationary:
        self.type = "STILL"
      case activity.walking:
        self.type = "WALKING"
      default:
        self.type = "UNKNOWN"
    }
    
    switch activity.confidence {
      case .high:
        self.confidence = "HIGH"
      case .medium:
        self.confidence = "MEDIUM"
      default:
        self.confidence = "LOW"
    }
  }
}
