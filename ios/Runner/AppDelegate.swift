import UIKit
import Flutter
import GoogleMaps
import UIKit
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyDqJB00PNv89PvcwyGkk7Wo0tN8-oO7uyA")
    GeneratedPluginRegistrant.register(with: self)
    if #available(iOS 10.0, *) {
         UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
       }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
// @UIApplicationMain
// class AppDelegate: UIResponder, UIApplicationDelegate {

//   var window: UIWindow?

//   func application(_ application: UIApplication,
//     didFinishLaunchingWithOptions launchOptions:
//       [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
//     FirebaseApp.configure()
//     return true
//   }
// }
