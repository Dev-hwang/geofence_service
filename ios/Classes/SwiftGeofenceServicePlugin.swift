import Flutter
import UIKit

public class SwiftGeofenceServicePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = SwiftGeofenceServicePlugin()
    instance.setupChannels(registrar.messenger())
  }
  
  private func setupChannels(_ messenger: FlutterBinaryMessenger) {

  }
}
