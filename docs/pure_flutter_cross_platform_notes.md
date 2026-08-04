# 偏纯 Flutter 跨端业务项目知识整理

本文整理 `yp_flutter_recruitment_demo` 会话中讨论过的架构、路由、状态、网络、本地化、启动优化和 Dart 异步知识。当前项目定位是：Android/iOS 只承担启动容器、原生启动页、隐私合规、启动广告、FlutterEngine 预热和原生 SDK 能力接入；启动后的主要业务页面、路由和状态由 Flutter 承接。

## 1. 项目定位

偏纯 Flutter 跨端项目不是纯 Flutter Shell，也不是 Flutter Module 嵌入某个已有原生 App 的简单演示。它更像一个 App 壳层由原生控制、主体业务由 Flutter 实现的混合工程。

推荐职责边界：

```text
原生负责：
Application 初始化
隐私合规前置
原生启动页
启动广告
FlutterEngine 预热
广告 SDK 原生能力接入

Flutter 负责：
启动后的页面路由
业务页面
业务广告位调用
广告展示状态
埋点统一封装
接口失败兜底 UI
```

这种模式的核心收益是：原生控制冷启动、隐私合规和强平台 SDK，Flutter 保持业务开发跨端一致。

## 2. 启动流程

Android 系统启动应用时，仍然先读取 `AndroidManifest.xml`：

```text
1. 创建 manifest 中声明的 Application。
2. 执行 Application.onCreate。
3. 找到带 android.intent.action.MAIN 和 android.intent.category.LAUNCHER 的 Activity。
4. 启动该 Activity。
5. 原生启动页完成初始化、广告、预热后进入 Flutter 容器 Activity。
```

当前 Android 侧角色：

```text
MainApplication
进程级初始化入口，调用原生启动初始化器。

SplashActivity
原生启动页和启动广告承接页。

FlutterEngineManager
专门管理 FlutterEngine 创建、预热、缓存和插件注册。

MainActivity
承载 Flutter 页面，复用 cached engine。
```

`ensureFlutterEngine` 不应直接放在 `Application` 内。更合理的是抽到 `FlutterEngineManager`，避免 Application 承担太多业务和 Flutter 容器细节。

当前项目是单引擎模式：启动时预热一个主 FlutterEngine，后续 Flutter 主页面复用这个 engine。除非有强隔离、多 Flutter 任务栈或独立生命周期诉求，否则不要过早引入多引擎。

## 3. 启动速度与广告

如果启动页直接是 `FlutterActivity`，冷启动阶段需要初始化 Flutter 引擎、加载 Dart 代码和首帧渲染，容易出现白屏或首帧慢。

更推荐：

```text
原生 SplashActivity 展示静态启动页/广告
并行做 Application 初始化和隐私合规检查
异步预热 FlutterEngine
广告完成后进入复用 engine 的 Flutter 页面
```

启动广告通常优先原生实现，原因是：

```text
广告 SDK 往往强依赖 Android/iOS 生命周期。
隐私合规必须在 SDK 初始化前处理。
冷启动广告和超时兜底更贴近平台。
原生能并行预热 FlutterEngine，减少 Flutter 首屏白屏。
```

业务内广告位可以由 Flutter 封装统一 API，底层通过 MethodChannel/Pigeon 调用原生广告 SDK。

## 4. 分层架构

当前项目采用“业务域划分 + 数据层/业务 UI 层划分”的双重规则。

推荐目录：

```text
lib/
  adapter/              原生能力和平台差异适配
  app/                  应用启动、运行时基础能力
  data/                 Data 层
    common/             网络、存储等基础设施
    launch/
    home/
    market/
    message/
    mine/
  routing/              全局路由
  shared/               跨业务域共享模型和组件
  ui/                   UI 层
    core/               UI 基础设施，如 BaseVM、Shell
    launch/
    home/
    market/
    message/
    mine/
    demo/
```

依赖方向：

```text
Page -> VM -> Repo -> RDS -> ApiClient
Page -> VM -> Repo -> LDS -> Storage/Database
Page -> VM -> Adapter
```

设计原则：

```text
Page 构造函数只接收页面参数。
Page 在 initState 创建 VM。
VM 自己决定创建 Repo、UseCase 或其他依赖。
Repo 自己决定创建 RDS/LDS。
不要用一个全局 AppDependencies 暴露所有页面依赖。
```

教学 demo 也不应该传递错误理念。真实项目里不需要每新增一个页面就修改一个全局依赖容器。

## 5. UseCase、VMBlock、Composer

当前 demo 暂不默认引入 UseCase 和 Composer。

```text
Page -> VM -> Repo
```

在简单页面足够清晰。

UseCase 适合出现这些情况后再加：

```text
复杂业务流程
跨 Repo 协作
跨业务域动作
同一个业务动作被多个 VM 复用
```

VMBlock 适合 VM 膨胀后拆分页面内不同逻辑块，例如筛选、表单、分页、权限状态等。

Composer 暂不需要。它通常用于 Data 层内部的数据编排、聚合和转换；当前 demo 的 Repo 已经足够表达数据来源和业务模型转换。

## 6. 路由设计

当前项目使用 `go_router`，入口是 `MaterialApp.router()`。

```text
MaterialApp
传统 Navigator 1.0，偏命令式 push/pop。

MaterialApp.router
Router/Navigator 2.0，适合 deep link、多 tab 分支、声明式重定向和复杂路由。
```

当前路由结构：

```text
/launch

StatefulShellRoute.indexedStack
  /home
  /market
  /message
  /mine

/home/detail
/market/detail
/message/detail
/mine/detail
/demo/overlay
/demo/tabs/fixed
/demo/tabs/dynamic-pager
/demo/storage/mmkv
```

`/launch -> /home` 使用 `context.go()`，因为启动页不应该留在返回栈。

一级 tab 进入二级页使用 `context.push()`，因为详情页返回后应回到原 tab。

四个一级 tab 使用 `StatefulShellRoute.indexedStack`，目的是：

```text
每个 tab 是独立 branch。
切换 tab 时保留状态。
底部导航由 MainTabScaffold 统一维护。
```

二级页面注册在 Shell 外，因此二级页不会显示底部 tab。

页面参数通过 query 或 args 对象承接：

```dart
HomeDetailPage(
  args: HomeDetailArgs.fromQuery(state.uri.queryParameters),
)
```

页面构造函数不传 VM、Repo 或 UseCase。

## 7. 路由拆分

大型项目不要把所有路由都写在一个 `app_router.dart`。推荐按业务域拆：

```text
lib/ui/home/routing/home_routes.dart
lib/ui/market/routing/market_routes.dart
lib/ui/message/routing/message_routes.dart
lib/ui/mine/routing/mine_routes.dart
lib/ui/launch/routing/launch_routes.dart
lib/ui/demo/routing/demo_routes.dart
```

总路由只负责：

```text
initialLocation
observers
Shell/tab 结构
汇总各业务域 routes
```

业务域自己负责本域的 tab 页、二级页和参数解析。

## 8. 子 Tab 页面实现

不是所有带 tab 的页面都要用 `StatefulShellRoute.indexedStack`。

一级主导航适合 `StatefulShellRoute.indexedStack`。

固定少量业务子 tab，例如：

```text
关注
  我关注的
  关注我的
```

推荐：

```text
DefaultTabController
TabBar
TabBarView
AutomaticKeepAliveClientMixin
PageStorageKey
```

进入过一次的子 tab 会保留 VM、列表状态和滚动位置。

不固定数量子 tab，例如频道页：

```text
推荐、附近、兼职、全职、服务、工具、本地...
```

推荐：

```text
PageView.builder
父页面维护 Map<String, VM> 缓存池
预加载当前页左右 N 个
超出范围的 VM close
```

当前 demo 已加入：

```text
/demo/tabs/fixed
/demo/tabs/dynamic-pager
```

## 9. 状态管理

当前项目使用 `flutter_bloc`，VM 继承 `Cubit<UIState>`。

```text
Page
创建 VM

VM
调用 Repo，转换 ApiResult 为 UIState

UI
用 BlocBuilder/BlocSelector/BlocListener 响应状态
```

`BlocBuilder` 包裹的区域会响应 `emit` 后的状态变化。

复杂页面可以有一个主 UIState，主 UIState 内组合多个子状态：

```text
MarketDetailUS
  header
  price
  stock
  filter
```

局部刷新方案：

```text
BlocSelector
只监听某个子状态。

buildWhen
按 previous/current 判断是否 rebuild。
```

如果 UIState 中只有一个字段变化，是否整页重建取决于你把 `BlocBuilder` 包在哪里。Flutter 会重新执行该 builder 区域，但不代表原生 View 全量重绘；仍应通过局部 Builder 控制复杂页面刷新范围。

## 10. BaseVM 与安全 emit

页面关闭后 VM 会 `close()`。如果异步请求稍后返回并继续 `emit`，Bloc 会抛出：

```text
Cannot emit new states after calling close
```

当前项目新增 `BaseVM`：

```dart
abstract class BaseVM<S> extends Cubit<S> {
  BaseVM(super.initialState);

  void safeEmit(S state) {
    if (isClosed) {
      return;
    }
    emit(state);
  }
}
```

规范：

```text
业务 VM 继承 BaseVM。
VM 内尽量使用 safeEmit。
await 后如果只更新状态，可用 safeEmit 兜底。
await 后如果还有路由、弹窗、广告等待等副作用，仍需显式判断 isClosed。
```

请求是否取消要按业务语义决定：

```text
查询类请求：
页面关闭可考虑取消。

提交类请求：
页面关闭不一定代表业务要取消，谨慎使用 CancelToken。
```

## 11. Flutter 页面与布局

`StatelessWidget` 和 `StatefulWidget` 的区别：

```text
StatelessWidget
自身不持有可变状态，依赖外部入参和上层状态刷新。

StatefulWidget
拥有 State，可在 initState/dispose 中创建和释放 VM、Controller、Animation 等对象。
```

VM 创建放在 `initState`。

`initState` 与 `didChangeDependencies`：

```text
initState
State 生命周期只调用一次，适合创建 VM、Controller、一次性初始化。

didChangeDependencies
initState 后会调用，依赖的 InheritedWidget 变化时也会再调用，适合读取 Localizations、Theme、MediaQuery 或依赖 Provider 的对象。
```

布局选择：

```text
Column/Row
用于线性排布。

Stack
用于层叠排布、悬浮按钮、角标、覆盖层、背景上叠内容。
```

不要为了简单上下布局使用 Stack；Stack 更适合需要重叠、定位和覆盖的场景。

## 12. 网络库 Dio

Dio 是 Flutter/Dart 生态常用 HTTP 客户端，提供：

```text
GET/POST/PUT/DELETE/PATCH
BaseOptions
Interceptor
CancelToken
上传下载
超时控制
错误处理
HttpClientAdapter
```

项目网络链路：

```text
Page -> VM -> Repo -> RDS -> ApiClient -> Dio -> Interceptor -> HttpClientAdapter
```

不要让 Page 或 VM 直接使用 Dio。

`ApiClient` 负责项目级封装：

```text
get/post
通用 header
额外 header
loading 开关
错误 toast 开关
ApiResult<T>
mock adapter
```

`HttpClientAdapter` 是 Dio 真正执行请求的底层适配层。真实项目请求后端接口一般不需要手动设置 Adapter，Dio 默认已有真实网络实现。只有 mock、自签名证书、代理、证书锁定、自定义底层通道时才需要设置。

当前 demo 用 `MockDioAdapter` 是为了让请求仍然完整走 Dio 拦截器。

## 13. Token 动态更新

当前 `ApiClient` 通过 `TokenProvider` 动态读取 token：

```dart
tokenProvider: () => storage.getString(StorageKeys.accessToken)
```

请求拦截器每次 `onRequest` 都执行 `tokenProvider()`。

因此：

```text
token 更新后，新请求会使用新 token。
已经发出去的请求不会自动换 token。
```

不要在创建 `ApiClient` 时读取一次 token 并捕获旧值。

## 14. Loading、Toast 与 Overlay

当前项目接入 `bot_toast`。

```text
BotToastInit()
插入 MaterialApp.router builder。

BotToastNavigatorObserver()
插入 GoRouter observers。
```

网络 loading 通过 Dio 拦截器处理：

```text
onRequest
showLoading = true 时计数 +1

onResponse/onError
计数 -1

计数从 0 到 1
显示 loading

计数回到 0
关闭 loading
```

接口错误默认通用 toast，但调用方可通过 `allowErrorToast` 控制：

```text
allowErrorToast = true
默认 toast

allowErrorToast = false
静默失败，不干扰用户
```

Flutter 弹窗方式：

```text
showDialog
showModalBottomSheet
OverlayEntry
BotToast
Navigator route 弹窗
```

BotToast 本质上通过 Overlay 插入 toast/loading。多个 overlay 同时存在时不会天然“替换全部旧的”，取决于保存的 cancel function、配置和清理策略。loading 一般应集中管理，避免多请求互相关闭。

## 15. ApiResult

当前项目统一使用 `ApiResult<T>` 表达接口结果。

原则：

```text
不要使用 requireData() 强取数据。
Repo/VM 应明确处理成功和失败状态。
失败应保留为 ApiFail，不要随意 throw。
```

推荐：

```dart
if (result.isOK() && result.data != null) {
  safeEmit(successState);
} else {
  safeEmit(failureState);
}
```

或使用明确表达成功/失败的函数。

## 16. CancelToken

`CancelToken.cancel()` 的含义：

```text
标记请求已取消
通知 Dio 中断当前请求流程
尝试让底层连接/流停止
让 await 请求的代码收到 DioExceptionType.cancel
```

它不是业务意义上的“撤销接口”。如果服务端已经收到请求，客户端取消不代表服务端业务回滚。

查询类接口可以在 VM.close 时取消。提交类接口要谨慎。

即使使用 CancelToken，也仍建议保留 `safeEmit` 或 `isClosed` 保护，因为异步任务不一定都是 Dio 请求。

## 17. 数据序列化

Flutter/Dart 实体序列化常用：

```text
手写 fromJson/toJson
json_serializable + build_runner
freezed + json_serializable
```

大型项目推荐 `json_serializable`：

```dart
import 'package:json_annotation/json_annotation.dart';

part 'domain_summary.g.dart';

@JsonSerializable()
class DomainSummary {
  const DomainSummary(...);

  factory DomainSummary.fromJson(Map<String, Object?> json) =>
      _$DomainSummaryFromJson(json);

  Map<String, Object?> toJson() => _$DomainSummaryToJson(this);
}
```

`.g.dart` 是构建期生成的 Dart 源码，不是运行时动态生成。App 编译时会引用它。

Flutter App 项目通常建议提交 `.g.dart` 和 `pubspec.lock`，避免 CI 或新同事拉代码后必须先生成才能编译。

`dependencies` 与 `dev_dependencies`：

```text
dependencies
App 运行时需要的依赖，lib/ 中 import 的包通常放这里。

dev_dependencies
开发、测试、代码生成和 lint 使用的依赖。
```

例如：

```yaml
dependencies:
  json_annotation: 4.9.0

dev_dependencies:
  build_runner: 2.5.4
  json_serializable: 6.9.5
```

## 18. 本地数据方案

Flutter 本地化存储不是选一个库解决所有数据，而是按数据类型分层。

常见方式：

```text
Key-Value
shared_preferences、MMKV、DataStore 插件。

安全存储
flutter_secure_storage，底层 Android Keystore / iOS Keychain。

关系型数据库
sqflite、drift。

对象型/NoSQL 数据库
Hive、Isar、ObjectBox。

文件缓存
path_provider + dart:io。

图片缓存
cached_network_image、flutter_cache_manager。
```

推荐选择：

```text
token / refreshToken / 密钥
flutter_secure_storage

非敏感配置、高频 KV
MMKV / SharedPreferencesAsync / DataStore

职位列表、消息、聊天会话、缓存队列、搜索历史
drift

简单对象缓存
Hive / Isar

图片、广告素材、附件
文件缓存
```

`shared_preferences`：

```text
旧 SharedPreferences API 在 Android 上通常对应 Android SharedPreferences。
SharedPreferencesAsync/WithCache 可使用 DataStore Preferences 或 Android SharedPreferences，需看配置。
```

`flutter_secure_storage` 与 MMKV：

```text
敏感数据用 secure_storage。
非敏感高频 KV 用 MMKV。
不要把所有普通配置都塞进 secure_storage。
```

`sqflite` 与 `drift`：

```text
sqflite
更底层，直接写 SQL。

drift
SQLite 上层 ORM，类型安全、响应式、迁移能力更适合大型项目。
```

关系型与对象型区别：

```text
关系型数据库
表、列、SQL、join、聚合、分页、复杂查询强。

对象型数据库
直接保存对象，开发直观，复杂 join 和长期迁移要看具体库能力。
```

## 19. 响应式 KV 与 MMKV

如果非敏感 KV 需要响应式更新，`shared_preferences` 不太适合直接承担。

可选方案：

```text
Hive Box.watch()
MMKV + Flutter 层响应式封装
drift 单行配置表 watch
Bloc/Riverpod 包装普通 KV
```

当前 demo 接入 MMKV，并在 `KeyValueStorage` 内封装：

```text
setString/getString/watchString
setBool/getBool/watchBool
setInt/getInt/watchInt
setDouble/getDouble/watchDouble
remove
```

说明：

```text
MMKV 本身负责落盘。
Flutter 层 StreamController 负责通知本 isolate 内的监听者。
如果原生侧直接修改同一个 key，Flutter 自己封装的 Stream 不一定能感知，除非通过插件/Channel 通知回来。
```

当前 demo 示例路由：

```text
/demo/storage/mmkv
```

## 20. Dart 异步与多线程

要区分：

```text
async/await
异步挂起与恢复，不是多线程。

Future/Stream
异步结果和连续事件模型。

Isolate
Dart 真正的并发执行单元。
```

Flutter 主 isolate 负责：

```text
Dart 业务代码
Widget build
layout
paint 相关 Dart 逻辑
事件响应
动画调度
```

`await` 不会自动切 isolate。它会把 async 函数拆成可恢复状态机：

```text
遇到 await
当前函数挂起
await 后续逻辑注册为 continuation
Future 完成后再恢复执行
恢复仍在当前 isolate
```

CPU 密集任务：

```dart
final result = await heavyCpuTask();
```

如果 `heavyCpuTask` 的计算在主 isolate 执行，仍然会卡 UI。

要切走 CPU 任务，需要：

```dart
final result = await Isolate.run(() => heavyWork());
```

或 Flutter 的：

```dart
compute(...)
```

网络 I/O await 不会卡主 isolate，不是因为 await 自动切 isolate，而是：

```text
Dart 发起异步 I/O
dart:io / Dart VM / 操作系统 socket 机制处理等待
主 isolate 返回事件循环
网络完成事件投递回 Event Queue
Future complete
await 后续逻辑恢复
```

## 21. Microtask Queue 与 Event Queue

每个 isolate 有事件循环，常见两个队列：

```text
Microtask Queue
优先级高，会先清空。

Event Queue
普通事件队列，一次处理一个 event。
```

常见 microtask：

```text
scheduleMicrotask
Future.microtask
Future.value().then
await 已完成 Future 后续恢复
```

常见 event：

```text
Timer
Future()
Future.delayed
I/O 完成回调
用户点击
平台消息
帧调度
```

不要无限塞 microtask，否则 event queue 里的点击、绘制和 I/O 回调可能被饿死。

## 22. Future.wait 与 allSettled

`Future.wait()` 类似 JS `Promise.all`。

默认：

```text
任意一个 Future 失败，Future.wait 返回的 Future 会失败。
其他 Future 不会自动取消。
```

`eagerError` 控制失败时机：

```text
eagerError = true
第一个失败后立即失败。

eagerError = false
默认，等待所有 Future 完成后再返回第一个错误。
```

Dart 标准库没有直接等价于 `Promise.allSettled()` 的内置函数。

业务接口更推荐让每个 Future 返回 `ApiResult<T>`，这样：

```dart
final results = await Future.wait([
  homeRepo.fetchSummary(),
  marketRepo.fetchSummary(),
  messageRepo.fetchSummary(),
]);
```

只要 Repo 内部把失败转成 `ApiFail` 而不是 throw，`Future.wait` 本身就不会失败。

## 23. Flutter Engine 线程与 Isolate

Flutter 引擎层常见线程：

```text
Platform thread
处理平台消息、插件、Android/iOS 主线程交互。

UI thread
运行 Dart 主 isolate，执行 build/layout/paint 相关 Dart 逻辑。

Raster thread
栅格化 layer tree，生成 GPU 命令。

IO thread
资源加载、图片解码、GPU 资源上传等底层工作。
```

Isolate 是 Dart VM 概念：

```text
独立 Dart 堆
独立事件循环
独立消息队列
不能共享普通对象
通过 SendPort/ReceivePort 通信
```

Isolate 不是进程，也不完全等同于线程。更准确地说：

```text
Isolate 是 Dart 的隔离执行单元。
线程是操作系统调度单元。
一个 isolate 通常运行在线程上，由 Dart VM/Flutter Engine 调度。
```

它和 Android Handler/Looper 有相似点：都通过消息队列通信。但 Android 多线程可以共享对象，Dart isolate 默认不共享普通内存。

## 24. 版本号

`pubspec.yaml`：

```yaml
version: 1.0.0+1
```

含义：

```text
1.0.0
展示版本号。

+1
构建号。
```

Android：

```text
build-name -> versionName
build-number -> versionCode
```

iOS：

```text
build-name -> CFBundleShortVersionString
build-number -> CFBundleVersion
```

如果 Android `versionCode` 要用 `10100、10101、10102`，可以：

```bash
flutter build apk --build-name=1.1.0 --build-number=10100
```

或直接修改 `pubspec.yaml`：

```yaml
version: 1.1.0+10100
```

## 25. 其他工具文件

`devtools_options.yaml` 不是 Dart 类，而是 Flutter/Dart DevTools 的本地配置文件。

它通常不参与业务逻辑，也不影响线上运行。是否提交 Git 看团队是否需要统一 DevTools 扩展配置。

## 26. 当前 demo 已落地能力

当前项目已经演示：

```text
原生启动页 + Flutter 首页
单 FlutterEngine 预热与复用
四个一级 tab
二级页脱离底部 tab
go_router 路由
flutter_bloc VM/UIState
BaseVM safeEmit
Dio + ApiClient
loading interceptor + BotToast
通用错误 toast 拦截
Overlay 示例
固定 tab 保活示例
动态 PageView 缓存示例
MMKV 非敏感 KV + 响应式 watch 示例
```

后续如果要继续接近真实大型项目，可继续补：

```text
路由按业务域拆分
secure_storage 敏感数据
drift 结构化业务缓存
json_serializable 实体生成
登录态刷新和 401 统一处理
原生广告 SDK MethodChannel/Pigeon 接口
埋点统一封装
UseCase/VMBlock 复杂业务示例
```
