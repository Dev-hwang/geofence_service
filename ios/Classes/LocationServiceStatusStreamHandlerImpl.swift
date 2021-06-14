//
//  LocationServiceStatusStreamHandlerImpl.swift
//  geofence_service
//
//  Created by WOO JIN HWANG on 2021/06/14.
//

import Foundation
import CoreLocation

class LocationServiceStatusStreamHandlerImpl {
  private let eventChannel: FlutterEventChannel
  
  init(messenger: FlutterBinaryMessenger) {
    self.eventChannel = FlutterEventChannel(
      name: "geofence_service/location_service_status", binaryMessenger: messenger)
    self.eventChannel.setStreamHandler(LocationServiceStatusStreamHandler())
  }
  
  private class LocationServiceStatusStreamHandler: NSObject, FlutterStreamHandler, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var eventSink: FlutterEventSink?
    
    private var locationServiceStatus = true
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
      eventSink = events
      locationManager.delegate = self
      return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
      locationManager.delegate = nil
      eventSink = nil
      return nil
    }
    
    public func checkLocationServiceStatusChange() {
      let status = CLLocationManager.locationServicesEnabled()
      if (status != locationServiceStatus) {
        locationServiceStatus = status
        eventSink?(locationServiceStatus)
      }
    }
    
    @available(iOS, introduced: 4.2, deprecated: 14.0)
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
      checkLocationServiceStatusChange()
    }
    
    @available(iOS 14.0, *)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
      checkLocationServiceStatusChange()
    }
  }
}
