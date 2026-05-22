import UIKit
<<<<<<< HEAD
=======
import Flutter
>>>>>>> origin/main
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
<<<<<<< HEAD
      GMSServices.provideAPIKey("AIzaSyBqNtak41OqQ8GXrzGNb0Q2FR7usVjFGJw")
=======
    GMSServices.provideAPIKey("AIzaSyBqNtak41OqQ8GXrzGNb0Q2FR7usVjFGJw")
    GeneratedPluginRegistrant.register(with: self)

>>>>>>> origin/main
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
