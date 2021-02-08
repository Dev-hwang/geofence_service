import Flutter
import UIKit

public class SwiftGeofenceServicePlugin: NSObject, FlutterPlugin {
  private var pluginMethodChannel: PluginMethodChannel? = nil
  private var pluginEventChannel: PluginEventChannel? = nil
  
  private let activityRecognitionManager = ActivityRecognitionManager()
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = SwiftGeofenceServicePlugin()
    instance.setupChannels(registrar.messenger())
  }
  
  private func setupChannels(_ messenger: FlutterBinaryMessenger) {
    pluginMethodChannel = PluginMethodChannel(messenger: messenger, activityRecognitionManager: activityRecognitionManager)
    pluginEventChannel = PluginEventChannel(messenger: messenger, activityRecognitionManager: activityRecognitionManager)
  }
}
