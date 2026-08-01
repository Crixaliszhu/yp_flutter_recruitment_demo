# 纯 Flutter 大型业务架构示例

这个 demo 模拟 `recruitment_android` 一类大型项目逐步跨端化后的 Flutter 形态：Android/iOS 只提供原生启动页和容器能力，首页、四个 tab、二级页、网络、缓存、路由和业务编排全部在 Flutter 内完成。

## 启动边界

- Android: `android/app/src/main/AndroidManifest.xml` 使用 `@style/LaunchTheme`，`launch_background.xml` 是蓝色原生启动页；Flutter 第一帧绘制后进入 `MainActivity` 承载的 Flutter 首页。
- iOS: `ios/Runner/Base.lproj/LaunchScreen.storyboard` 是蓝色原生 LaunchScreen；业务页面从 `lib/main.dart` 启动。
- Flutter: `lib/main.dart` 只做初始化，`AppBootstrap` 装配网络、存储、Repository、UseCase。

## 分层

```text
lib/
  app/                 应用启动、依赖装配
  core/
    network/           ApiClient、拦截器、mock transport
    storage/           KeyValueStorage，本地 KV 抽象
  routing/             全局路由表与 route path 常量
  shell/               4 tab 主壳
  shared/              跨业务可复用 UI/模型
  features/
    home/              首页域
    market/            集市域
    message/           消息域
    mine/              个人中心域
```

每个业务域都按 `data/domain/presentation` 拆分：

- `presentation`: Flutter 页面、组件、View 交互。
- `domain`: Repository 接口和 UseCase，承载业务动作。
- `data`: Repository 实现，组合网络、缓存、平台能力。

## 路由设计

`go_router` 负责全局路由，`StatefulShellRoute.indexedStack` 只承载四个一级 tab；二级页注册在 shell 外，打开后是完整独立页面，不显示底部 tab：

- `/home` -> `/home/detail`
- `/market` -> `/market/detail`
- `/message` -> `/message/detail`
- `/mine` -> `/mine/detail`

跨域跳转只依赖 `AppRoutes`，不要让 `home` 直接 import `message` 的页面实现。大型项目可继续演进为每个业务包暴露 `RouteEntry` 注册表。

## 网络库设计

`ApiClient` 封装 Dio：

- 统一 `baseUrl`、header、token 注入。
- 统一返回 `ApiResult<T>`。
- demo 使用 `MockApiTransport` 避免真实服务依赖；真实项目把 transport 替换为 Dio 请求即可。
- 业务层只依赖 Repository，不直接依赖 Dio。

## 存储设计

`KeyValueStorage` 是存储接口示例，当前 demo 用纯 Dart 内存实现，便于无插件环境直接运行：

- token、当前角色等简单状态走 KV。
- 复杂缓存可新增 `core/database`，例如 Drift/Isar。
- Android/iOS 生产环境可把实现替换为 `shared_preferences`、`flutter_secure_storage` 或数据库，调用方不用改。

## 已覆盖的业务交互

- 原生启动页后进入 Flutter 首页。
- 首页包含 4 个 tab：首页、集市、消息、个人中心。
- 每个 tab 都有按钮跳转自己的 Flutter 二级页。
- 四个二级页分属不同业务域，展示跨域隔离、路由跳转、本地存储和网络 mock。
