import Flutter
import UIKit

public class SwiftGeofenceServicePlugin: NSObject, FlutterPlugin {
  private var methodCallHandler: MethodCallHandlerImpl? = nil
  private var locationServiceStatusStreamHandler: LocationServiceStatusStreamHandlerImpl? = nil
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = SwiftGeofenceServicePlugin()
    instance.setupChannels(registrar.messenger())
  }

  private func setupChannels(_ messenger: FlutterBinaryMessenger) {
    methodCallHandler = MethodCallHandlerImpl(messenger: messenger)
    locationServiceStatusStreamHandler = LocationServiceStatusStreamHandlerImpl(messenger: messenger)
  }
}
