# 纯 Flutter 大型业务架构示例

这个 demo 模拟大型招聘 App 的偏纯 Flutter 架构：Android/iOS 负责进程初始化、原生启动页、启动广告和 FlutterEngine 预热；Flutter 负责启动后的路由、业务页面、业务广告状态、埋点和失败兜底 UI。

## 启动边界

- Android: `MainApplication` 做轻量进程初始化，`SplashActivity` 展示原生启动/广告页并预热 FlutterEngine，`MainActivity` 复用 cached engine 承载 Flutter。
- iOS: `AppDelegate` 预热 `mainFlutterEngine`，`SplashViewController` 展示原生启动/广告页，然后打开复用 engine 的 `FlutterViewController`。
- Flutter: `lib/main.dart` 只初始化依赖并启动 `RecruitmentDemoApp`，首个 Flutter 业务路由是 `/launch`。

## 分层结构

```text
lib/
  adapter/              平台差异和原生能力适配，例如启动广告状态
  app/                  应用启动、依赖装配
  data/                 Data 层，先按层切，再按业务域切
    common/             网络、存储等共享数据基础设施
    launch/             启动配置数据域
    home/               首页数据域
    market/             集市数据域
    message/            消息数据域
    mine/               个人中心数据域
  routing/              全局路由基础设施
  shared/               跨业务域共享模型和组件
  ui/                   UI 层，先按层切，再按业务域/页面切
    core/               一级 tab shell、主题等 UI 基础设施
    launch/             Flutter 启动业务页
    home/
    market/
    message/
    mine/
```

## 依赖方向

```text
Page -> VM -> Repo -> RDS -> ApiClient
Page -> VM -> Repo -> Storage
Page -> VM -> Adapter
```

当前 demo 暂不引入 UseCase 和 Composer：

- `UseCase`: 等出现复杂业务流程、跨页面业务动作或跨域流程时再加。
- `Composer`: 等 Data 层出现同域多接口编排、数据聚合、排序过滤等场景时再加。
- `VMBlock`: 等单个 VM 变大后，用来拆分页面逻辑块。

## 路由设计

`/launch` 是 Flutter 启动业务页。四个一级 tab 使用 `StatefulShellRoute.indexedStack` 保持状态，二级页注册在 shell 外层，因此打开后不显示底部 tab。

```text
/launch
/home         -> /home/detail
/market       -> /market/detail
/message      -> /message/detail
/mine         -> /mine/detail
```

## 启动广告设计

启动广告优先由 Android/iOS 原生承接，因为广告 SDK 初始化、隐私合规、冷启动生命周期和超时兜底更贴近平台。Flutter 侧通过 `SplashAdAdapter` 接收广告状态或兜底超时，继续完成启动后的路由分发。

业务内广告可以由 Flutter 统一 API 调用，底层继续由 Android/iOS 原生 SDK 实现。
