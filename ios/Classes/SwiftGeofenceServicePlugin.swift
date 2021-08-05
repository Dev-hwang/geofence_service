import Flutter
import UIKit

public class SwiftGeofenceServicePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = SwiftGeofenceServicePlugin()
    instance.initServices()
    instance.initChannels(registrar.messenger())
  }

  private func initServices() {
    // initServices
  }

  private func initChannels(_ messenger: FlutterBinaryMessenger) {
    // initChannels
  }
}
