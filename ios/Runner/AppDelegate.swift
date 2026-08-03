import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  lazy var mainFlutterEngine = FlutterEngine(name: "main_engine")

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    NativeStartupCoordinator.bootstrap(application)
    mainFlutterEngine.run()
    GeneratedPluginRegistrant.register(with: mainFlutterEngine)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
