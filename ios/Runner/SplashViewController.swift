import Flutter
import UIKit

final class SplashViewController: UIViewController {
  private let adDisplaySeconds: TimeInterval = 1.2

  override func viewDidLoad() {
    super.viewDidLoad()
    buildNativeSplashView()
    showNativeSplashAdThenOpenFlutter()
  }

  private func buildNativeSplashView() {
    view.backgroundColor = UIColor(red: 0.086, green: 0.467, blue: 1, alpha: 1)

    let titleLabel = UILabel()
    titleLabel.text = "渔泡招聘"
    titleLabel.textColor = .white
    titleLabel.font = .boldSystemFont(ofSize: 28)
    titleLabel.textAlignment = .center
    titleLabel.translatesAutoresizingMaskIntoConstraints = false

    view.addSubview(titleLabel)
    NSLayoutConstraint.activate([
      titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])
  }

  private func showNativeSplashAdThenOpenFlutter() {
    // 模拟原生开屏广告位。真实应用等待 iOS 广告 SDK 返回成功、失败、跳过或超时。
    DispatchQueue.main.asyncAfter(deadline: .now() + adDisplaySeconds) {
      self.openFlutter()
    }
  }

  private func openFlutter() {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
      return
    }

    let flutterViewController = FlutterViewController(
      engine: appDelegate.mainFlutterEngine,
      nibName: nil,
      bundle: nil
    )
    flutterViewController.modalPresentationStyle = .fullScreen
    present(flutterViewController, animated: false)
  }
}
