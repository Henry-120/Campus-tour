import UIKit
import Flutter
import GoogleMaps
import MessageUI

@main
@objc class AppDelegate: FlutterAppDelegate, MFMessageComposeViewControllerDelegate {
  private static let messageChannelName = "tw.edu.ncu.campustour/message_compose"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyBqNtak41OqQ8GXrzGNb0Q2FR7usVjFGJw")
    GeneratedPluginRegistrant.register(with: self)
    registerMessageComposerChannel()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func registerMessageComposerChannel() {
    guard let registrar = registrar(forPlugin: "EmergencySmsComposer") else { return }
    let channel = FlutterMethodChannel(
      name: Self.messageChannelName,
      binaryMessenger: registrar.messenger()
    )
    channel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "composeEmergencySms" else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard let self else {
        result(false)
        return
      }
      self.presentMessageComposer(arguments: call.arguments, result: result)
    }
  }

  private func presentMessageComposer(arguments: Any?, result: @escaping FlutterResult) {
    guard MFMessageComposeViewController.canSendText() else {
      result(false)
      return
    }
    guard
      let values = arguments as? [String: Any],
      let recipient = values["recipient"] as? String,
      let body = values["body"] as? String,
      isValidSmsRecipient(recipient),
      !body.isEmpty,
      body.count <= 2_000,
      let presenter = topViewController()
    else {
      result(FlutterError(
        code: "INVALID_SMS_REQUEST",
        message: "The SMS draft request is invalid.",
        details: nil
      ))
      return
    }

    let composer = MFMessageComposeViewController()
    composer.messageComposeDelegate = self
    composer.recipients = [recipient]
    composer.body = body
    presenter.present(composer, animated: true) {
      result(true)
    }
  }

  private func isValidSmsRecipient(_ recipient: String) -> Bool {
    guard !recipient.isEmpty, recipient.count <= 32 else { return false }
    let allowed = CharacterSet(charactersIn: "+-.0123456789")
    return recipient.unicodeScalars.allSatisfy { allowed.contains($0) }
  }

  private func topViewController() -> UIViewController? {
    let scenes = UIApplication.shared.connectedScenes.compactMap {
      $0 as? UIWindowScene
    }
    let root = scenes
      .flatMap(\.windows)
      .first(where: \.isKeyWindow)?
      .rootViewController
      ?? window?.rootViewController
    return topViewController(from: root)
  }

  private func topViewController(from controller: UIViewController?) -> UIViewController? {
    if let presented = controller?.presentedViewController {
      return topViewController(from: presented)
    }
    if let navigation = controller as? UINavigationController {
      return topViewController(from: navigation.visibleViewController)
    }
    if let tabs = controller as? UITabBarController {
      return topViewController(from: tabs.selectedViewController)
    }
    return controller
  }

  func messageComposeViewController(
    _ controller: MFMessageComposeViewController,
    didFinishWith result: MessageComposeResult
  ) {
    controller.dismiss(animated: true)
  }
}
