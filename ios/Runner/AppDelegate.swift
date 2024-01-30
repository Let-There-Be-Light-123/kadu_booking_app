import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
        GMSServices.provideAPIKey("AIzaSyB6Tu751DZ1ZP9iq3dQaZTC9hqf_bRNGcs")

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
