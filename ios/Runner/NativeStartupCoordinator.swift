import UIKit

final class NativeStartupCoordinator {
  private init() {}

  static func bootstrap(_ application: UIApplication) {
    // 生产应用通常在这里初始化隐私、崩溃、推送和广告 SDK。
    // 这里应保持轻量，重任务放到原生启动页展示后再开始。
  }
}
