# Flutter 常用 Widget 选择、坑点与真实项目场景

本文整理 Flutter 常用组件的特点、相似组件区别、选择建议和使用坑点，并结合 `easy_job_module` 项目中的高频组件与真实业务场景补充说明。

统计 `easy_job_module/lib` 后，高频或项目特色组件包括：

```text
Text / TextSpan / RichText
SizedBox / Container / Padding
Column / Row / Stack / Positioned
Expanded / Flexible
GestureDetector / InkWell
Visibility / Offstage / Opacity
SingleChildScrollView / ListView / CustomScrollView
TabBar / TabBarView
TextField / TextEditingController / FocusNode
Obx
BasePage
SwipeBackListener
WebImageWidget
RefreshWidget / TableListWidget
```

其中 `BasePage`、`SwipeBackListener`、`WebImageWidget`、`Obx` 是 `easy_job_module` 里真实项目特征很明显的组件或封装。

## 1. 页面骨架类

### Scaffold

特点：

```text
提供 AppBar、body、bottomNavigationBar、floatingActionButton、drawer 等页面骨架。
适合一个完整页面的根布局。
```

常见场景：

```dart
Scaffold(
  appBar: AppBar(title: Text('标题')),
  body: ContentWidget(),
  bottomNavigationBar: BottomBar(),
)
```

坑点：

```text
不要在一个页面里嵌套多个 Scaffold，除非明确需要内层独立处理 drawer/snackbar/bottomSheet。
键盘弹起时 body 被顶起由 resizeToAvoidBottomInset 控制，表单页要特别关注。
自定义沉浸式状态栏时，需要配合 AnnotatedRegion 和 extendBodyBehindAppBar。
```

`easy_job_module` 场景：

项目没有到处直接裸写 `Scaffold`，而是封装了 `BasePage`。`BasePage` 内部统一处理：

```text
AppBar
返回按钮
右侧 actions
背景色
状态栏样式
bottomNavigationBar
resizeToAvoidBottomInset
```

来源：`easy_job_module/lib/ui/core/base/base_page.dart`

### AppBar

特点：

```text
页面顶部导航栏，支持 title、leading、actions、systemOverlayStyle。
```

坑点：

```text
滚动页面时 Material 3 默认可能出现 scrolledUnderElevation，需要显式设为 0。
沉浸式页面不要只改 AppBar 背景，还要处理状态栏图标颜色。
titleSpacing、centerTitle 在 Android/iOS 默认行为不同，真实项目建议统一配置。
```

`easy_job_module` 场景：

`BasePage` 里统一设置：

```text
toolbarHeight: 44
elevation: 0
scrolledUnderElevation: 0
centerTitle: true
```

这说明真实项目通常会用基础页面组件统一 AppBar 规范。

### SafeArea

特点：

```text
自动避开刘海、状态栏、底部手势区。
```

选择建议：

```text
普通页面内容需要避开系统区域，用 SafeArea。
自定义沉浸式头图、渐变背景、全屏广告页，不要简单套全屏 SafeArea，而应手动读取 MediaQuery.padding。
```

坑点：

```text
SafeArea 只能处理系统安全区，不能替你处理键盘高度。
全屏 Stack 页面里局部使用 SafeArea，避免背景也被挤下去。
```

`easy_job_module` 场景：

面试详情页、屏蔽机制介绍页使用 `MediaQuery.of(context).padding.top` 手动计算顶部区域，配合 `Stack` 和自定义导航栏实现沉浸式效果。

来源：

```text
easy_job_module/lib/ui/interview/interview_worker_detail/page/worker_interview_detail_page.dart
easy_job_module/lib/ui/setting/shield_company/page/shield_company_introduce_page.dart
```

## 2. 基础布局类

### Container

特点：

```text
组合型便利组件，可设置 padding、margin、alignment、width、height、color、decoration、constraints、transform。
```

适合：

```text
同时需要尺寸、背景、圆角、边框、内外边距时。
```

坑点：

```text
Container 很方便，但容易被滥用。
只需要间距用 Padding/SizedBox。
只需要背景和边框用 DecoratedBox。
只需要对齐用 Align。
同时设置 color 和 decoration.color 会冲突。
```

`easy_job_module` 场景：

项目里 `Container` 高频使用，常用于卡片背景、分割线、按钮点击区域和渐变背景。例如面试详情页用 `Container + BoxDecoration` 组织白色卡片和顶部渐变背景。

### SizedBox

特点：

```text
固定尺寸或占位空白。
```

适合：

```text
垂直/水平间距
固定宽高
SizedBox.shrink() 返回空组件
```

坑点：

```text
不要用 Container(width: x, height: y) 只做空白，SizedBox 更明确。
SizedBox.expand 会填满父约束，不适合无界约束场景。
```

`easy_job_module` 场景：

`SizedBox` 是项目最高频组件之一，大量用于 `Row/Column` 中的固定间距和空占位。项目中也常用 `SizedBox.shrink()` 表示不展示内容。

### Padding

特点：

```text
只负责内边距。
```

选择建议：

```text
只需要 padding 时优先 Padding。
同时需要背景/边框/尺寸时才考虑 Container。
```

坑点：

```text
列表 item 中多层 Padding 容易导致对齐不统一，真实项目应抽出 Cell 基础组件。
```

### DecoratedBox

特点：

```text
只负责 decoration，比 Container 更轻。
```

适合：

```text
只加背景、边框、渐变、圆角。
```

坑点：

```text
DecoratedBox 不提供 padding，需要外面再包 Padding。
```

选择：

```text
只装饰 -> DecoratedBox
装饰 + padding/尺寸/对齐 -> Container 或 DecoratedBox + Padding
```

## 3. 线性布局

### Column / Row

特点：

```text
Column 垂直排列。
Row 水平排列。
```

适合：

```text
表单纵向排布
卡片内图文横排
按钮组
标题 + 描述
```

坑点：

```text
Column 放在可滚动组件里时，主轴可能是无界约束，Expanded 会报错。
Row 内 Text 过长会溢出，需要 Expanded/Flexible + maxLines/overflow。
Column 默认 mainAxisSize 是 max，弹窗内容可能撑满，需要 mainAxisSize: MainAxisSize.min。
```

`easy_job_module` 场景：

`WorkerInterviewUserCard` 用：

```text
Row
  头像
  SizedBox
  Expanded
    Column
      公司名 Text
      招聘者名 Text
```

这里 `Expanded` 避免长公司名挤爆右侧布局，Text 使用 `maxLines: 1` 和 `overflow: TextOverflow.ellipsis`。

来源：`easy_job_module/lib/ui/interview/interview_worker_detail/widget/worker_interview_user_card.dart`

### Expanded / Flexible / Spacer

区别：

```text
Expanded
强制填满 Row/Column 剩余空间，等价于 Flexible(fit: FlexFit.tight)。

Flexible
允许子组件在剩余空间内自行决定大小，默认 loose。

Spacer
本质是 Expanded + 空白，用于占据剩余空间。
```

选择：

```text
希望 Text/List/内容撑满剩余空间 -> Expanded
希望组件最多占用剩余空间但不强制撑满 -> Flexible
只是推开两侧内容 -> Spacer
```

坑点：

```text
Expanded/Flexible 只能放在 Flex 家族组件的直接 children 中，即 Row/Column/Flex。
不能放在 Stack、ListView、Padding 的任意深层。
在 SingleChildScrollView 里的 Column 内直接使用 Expanded 常报无界高度错误。
```

## 4. 层叠与定位

### Stack / Positioned / Align

特点：

```text
Stack 层叠布局。
Positioned 在 Stack 中绝对定位。
Align 在父组件内按比例/方位对齐。
```

适合：

```text
角标
悬浮按钮
背景图上叠内容
沉浸式头部
表单错误边框覆盖
自定义浮层
```

坑点：

```text
Stack 不适合普通上下/左右布局，普通布局用 Column/Row。
Positioned 必须作为 Stack 的直接 child。
Stack 默认 size 由非 Positioned 子组件决定，全是 Positioned 时可能尺寸异常。
层叠内容要注意点击事件遮挡。
```

`easy_job_module` 场景 1：

面试详情页使用 `Stack + Positioned + Column` 实现顶部渐变背景、自定义状态栏导航、滚动内容和底部操作栏。

来源：`worker_interview_detail_page.dart`

`easy_job_module` 场景 2：

`ValidationErrorBorder` 使用 `Stack + Positioned + IgnorePointer + CustomPaint` 做错误边框覆盖，特点是不改变原组件布局、不拦截触摸。

来源：`easy_job_module/lib/ui/core/widget/validation_error_border.dart`

设计坑点：

```text
这类覆盖组件必须保证父级是 Stack，否则 Positioned 会报错。
用 IgnorePointer 避免覆盖层吃掉下层输入框或按钮事件。
```

## 5. 文本组件

### Text

特点：

```text
显示单一样式或整体样式文本。
```

常用属性：

```text
style
maxLines
overflow
textAlign
softWrap
strutStyle
```

坑点：

```text
Row 中长 Text 必须配合 Expanded/Flexible，否则容易溢出。
中文和数字混排时注意 lineHeight。
业务卡片里的 Text 要设置 maxLines 和 overflow，避免接口长文案撑坏布局。
```

`easy_job_module` 场景：

职位卡、用户卡、IM 会话列表大量使用 `Text(maxLines: 1, overflow: TextOverflow.ellipsis)` 控制长文案。

### RichText / TextSpan

特点：

```text
一段文本中需要多个样式、点击局部文本、图文混排时使用。
```

适合：

```text
协议文案
价格高亮
搜索关键字高亮
风险提示中的重点词
```

坑点：

```text
TextSpan 默认不继承当前 Theme 的 TextStyle，通常要给根 TextSpan 设置 style。
TextSpan 的 gesture recognizer 需要在 StatefulWidget 中手动 dispose，否则可能泄漏。
如果只是整段文本同一样式，不要用 RichText。
```

`easy_job_module` 场景：

项目中 `TextSpan` 高频，用于安全提示、订阅历史文案组合、标签 UI 状态等。例如面试安全区使用 `RichText + TextSpan` 表达不同颜色的说明文案。

来源：`easy_job_module/lib/ui/interview/interview_worker_detail/widget/worker_interview_safe_section.dart`

## 6. 图片组件

### Image.asset / Image.network / Image.file / Image.memory

区别：

```text
Image.asset
加载 Flutter assets。

Image.network
加载网络图片，基础能力简单。

Image.file
加载本地文件。

Image.memory
加载内存 bytes。
```

坑点：

```text
列表中直接 Image.network 大量加载，容易出现缓存、尺寸、重试、占位、动图解码等问题。
图片如果不设置 width/height 或 aspectRatio，加载前后可能造成布局跳动。
大图需要控制内存缓存尺寸，避免图片解码占用过大。
```

### CachedNetworkImage / 项目 WebImageWidget

真实项目一般不会到处直接使用 `Image.network`。`easy_job_module` 封装了 `WebImageWidget`：

```text
OSS 服务端裁剪
磁盘缓存尺寸控制
内存 cache 尺寸计算
默认图/错误图
失败重试
file:// 和本地文件兼容
模糊图片
GIF/APNG 禁止动画播放并取静态首帧
生命周期观察
```

来源：`easy_job_module/lib/ui/core/widget/web_image_widget.dart`

使用场景：

```text
头像
IM 会话图
职位卡图片
二维码预览
企业微信入口
CMS 图片
```

选择建议：

```text
静态本地图标 -> 生成的 assets image
普通远程业务图 -> WebImageWidget / CachedNetworkImage
列表中的远程图 -> 必须控制尺寸、默认图、错误图和缓存
动图头像/小图 -> 默认禁用动画，避免列表持续解码
```

坑点：

```text
图片 URL 变化时要重置重试、模糊、静态帧等状态。
Timer 重试必须在 dispose 取消。
ui.Image 需要 dispose。
CachedNetworkImage 的 cacheKey 要稳定，否则缓存失效。
尺寸变化时要重新计算 OSS URL 和缓存尺寸。
```

## 7. 点击与手势

### GestureDetector

特点：

```text
低层手势监听，支持 tap、pan、longPress、scale 等。
```

适合：

```text
自定义按钮
卡片点击
拖拽
侧滑监听
非 Material 点击区域
```

坑点：

```text
默认命中区域只包含有绘制内容的区域。空白区域也要可点时设置 behavior: HitTestBehavior.opaque。
没有 Material 水波纹和语义按钮效果。
多个手势嵌套可能进入手势竞技场，导致事件不符合预期。
```

`easy_job_module` 场景：

`WorkerInterviewUserCard` 用 `GestureDetector` 包裹整张用户卡，并设置 `behavior: HitTestBehavior.opaque`，确保 padding 空白也可点击。

`SwipeBackListener` 用 `GestureDetector(onPanStart/onPanEnd)` 识别左侧边缘水平滑动。

### InkWell / InkResponse

特点：

```text
Material 点击反馈组件，有水波纹。
```

选择：

```text
Material 风格按钮/列表 item -> InkWell
自定义无水波纹区域、拖拽、复杂手势 -> GestureDetector
```

坑点：

```text
InkWell 要有 Material 祖先，否则水波纹不显示。
圆角水波纹需要 Material/InkWell 的 borderRadius 或 clip 配合。
```

### IconButton / TextButton / ElevatedButton / OutlinedButton / FilledButton

选择：

```text
IconButton
只有图标的工具按钮。

TextButton
弱强调文字按钮。

OutlinedButton
中等强调、边框按钮。

ElevatedButton
带阴影的强调按钮，Material 3 后不一定是首选。

FilledButton
Material 3 推荐的主要操作按钮。
```

坑点：

```text
不要用 GestureDetector + Text 随手造所有按钮，否则可访问性、禁用态、点击反馈都要自己补。
按钮文案过长要考虑换行或最小宽度。
```

`easy_job_module` 场景：

项目更常用 `GestureDetector + Container/Text` 造业务样式按钮，比如邮箱页右上角“确定”和验证码按钮。这类写法能精确还原设计，但要自己处理点击区域和禁用态。

来源：`receiving_email_edit_page.dart`

## 8. 显示、隐藏与透明

### Visibility

特点：

```text
控制 child 是否可见，可选择是否保留空间、状态、动画、语义。
```

适合：

```text
根据状态显示 banner、错误提示、按钮。
```

坑点：

```text
默认 visible=false 时 child 会被替换，不保留状态。
如果需要保留状态，设置 maintainState 等属性。
频繁控制复杂子树显示时，要考虑是否会重复创建和销毁。
```

`easy_job_module` 场景：

收藏列表页使用 `Visibility` 控制顶部 banner 和空态区域显示。为了避免外层状态变化导致列表重建，页面把列表 Widget 缓存在 `late final Widget _jobListView` 中。

来源：`worker_collection_list_page.dart`

### Offstage

特点：

```text
隐藏 child，不绘制、不命中，但仍然 layout，通常保留状态。
```

适合：

```text
页面内部 tab 保活
测量不可见组件
临时隐藏但保留 State
```

坑点：

```text
Offstage 仍会 layout，复杂组件仍有成本。
不可见动画如果不处理，可能仍在 tick，需要配合 TickerMode。
```

### Opacity / AnimatedOpacity

特点：

```text
Opacity 控制透明度。
AnimatedOpacity 带隐式动画。
```

坑点：

```text
opacity=0 仍然占布局并可能响应点击，必要时配合 IgnorePointer。
Opacity 可能引入离屏渲染成本，列表里大量使用要谨慎。
```

选择：

```text
不显示且不占位 -> if / SizedBox.shrink / Visibility
不显示但占位 -> Visibility(maintainSize: true) 或 Opacity
不显示但保留状态 -> Offstage / IndexedStack / Visibility maintainState
需要淡入淡出 -> AnimatedOpacity
```

## 9. 滚动与列表

### SingleChildScrollView

特点：

```text
让一个完整 child 可滚动。
```

适合：

```text
内容较少的表单页、说明页、弹窗内容。
```

坑点：

```text
不要包大量列表 item，所有 child 会一次性构建。
内部 Column 使用 Expanded 会遇到无界高度问题。
```

`easy_job_module` 场景：

面试详情页内容块数量有限，使用 `SingleChildScrollView + Column` 包裹头部、用户卡、信息区、安全区。

### ListView

特点：

```text
列表滚动组件。
ListView.builder 按需构建，适合长列表。
ListView(children: ...) 适合少量固定项。
```

坑点：

```text
嵌套滚动时 shrinkWrap: true 会带来性能成本。
列表 item 需要稳定 key 时要显式提供。
列表中图片、RichText、复杂组件要避免反复创建重资源对象。
```

### CustomScrollView / Sliver

特点：

```text
组合多个 sliver，适合复杂滚动效果。
```

适合：

```text
吸顶头
大标题渐变
网格 + 列表混排
复杂沉浸式滚动页面
```

坑点：

```text
Sliver 和普通 Widget 不能直接混用，普通 Widget 要包 SliverToBoxAdapter。
学习成本高，不要为简单列表过度使用。
```

`easy_job_module` 场景：

屏蔽机制介绍页用 `CustomScrollView + SliverToBoxAdapter`，背景和动态导航栏用外层 `Stack` 叠加，实现顶部插画、渐变背景和滚动透明导航。

来源：`shield_company_introduce_page.dart`

### RefreshIndicator / 项目 CustomRefreshWidget

特点：

```text
RefreshIndicator 是 Flutter 官方下拉刷新。
真实项目常封装为 CustomRefreshWidget，以统一下拉、上拉加载、预加载、空态等行为。
```

`easy_job_module` 场景：

收藏列表页使用 `CustomRefreshWidget`，接入 refresh controller、上拉加载开关、onRefresh/onLoad，并将内部列表缓存起来减少重建。

来源：`worker_collection_list_page.dart`

## 10. Tab 与分页

### DefaultTabController / TabController

区别：

```text
DefaultTabController
适合简单页面，自动向子树提供 TabController。

TabController
适合需要监听 index、手动控制切换、与 VM/埋点联动的复杂页面。
```

### TabBar / TabBarView

特点：

```text
TabBar 是顶部 tab。
TabBarView 是对应页面容器，通常需要同一个 TabController。
```

坑点：

```text
TabBar tabs.length 必须等于 TabBarView children.length。
TabController 需要 dispose。
TabBarView 内页面如果要保活，需要 AutomaticKeepAliveClientMixin。
TabBarView 默认可横滑，和业务横向手势可能冲突。
```

`easy_job_module` 场景：

项目封装 `BaseNavTabWidget`，在 `BasePage` 的 title 区域放 `TabBar`，body 放 `TabBarView`，并暴露：

```text
onTabChange
indexChange
isScrollable
physics
showLeading
```

真实业务页 `WorkerCollectionListPage` 使用它实现“收藏职位 / 收藏老板”两个 tab，并在 tab change 时通知 VM。

来源：

```text
easy_job_module/lib/ui/core/widget/tab/base_nav_tab_widget.dart
easy_job_module/lib/ui/user_center/worker_collection_list/page/worker_collection_list_page.dart
```

### PageView

特点：

```text
横向或纵向分页。
```

适合：

```text
频道页
轮播
引导页
不固定数量子页
```

坑点：

```text
PageView.builder 适合动态数量。
大量页面要自己控制 VM/数据缓存范围。
和 TabBar 联动时要维护 index 同步。
```

选择：

```text
固定少量 tab -> TabBar + TabBarView
动态频道/分页 -> PageView.builder + 缓存池
App 一级多分支导航 -> StatefulShellRoute.indexedStack
```

## 11. 输入组件

### TextField

特点：

```text
基础输入框。
```

常用配套：

```text
TextEditingController
FocusNode
InputDecoration
TextInputType
TextInputFormatter
```

坑点：

```text
Controller 和 FocusNode 在 StatefulWidget 中创建后必须 dispose。
controller.addListener 里更新状态要避免循环 set text。
进入页面自动聚焦经常需要 addPostFrameCallback，iOS 上还可能需要延迟。
maxLength 默认显示计数器，不需要时设置 counterText: ''。
键盘类型只是提示，不是强校验，仍要做输入过滤和提交校验。
```

`easy_job_module` 场景：

`ReceivingEmailEditPage` 创建两个 `TextEditingController` 和两个 `FocusNode`，监听文本和焦点变化同步给 VM，并在 `dispose` 中释放。页面用 `addPostFrameCallback + Future.delayed` 延迟聚焦，注释明确是为了防止 iOS 问题。

来源：`receiving_email_edit_page.dart`

### TextFormField / Form

特点：

```text
带表单校验体系的输入组件。
```

适合：

```text
传统表单统一 validate/save/reset。
```

选择：

```text
简单输入或自定义 VM 校验 -> TextField
需要 FormState.validate 统一校验 -> TextFormField + Form
```

真实项目中，如果已经有 VM/UIState 管理错误状态，往往会更偏向 `TextField + 自定义错误 UI`。

## 12. 状态监听组件

### FutureBuilder

特点：

```text
监听单次 Future。
```

适合：

```text
简单异步读取，如一次性配置、文件读取、小 demo。
```

坑点：

```text
不要在 build 里直接创建 Future，否则每次 build 都重新请求。
复杂页面不要把网络请求散落在 FutureBuilder，应该放 VM。
```

### StreamBuilder

特点：

```text
监听连续 Stream。
```

适合：

```text
响应式 KV
WebSocket
数据库 watch
事件流
```

坑点：

```text
Stream 在 build 里反复 new 会导致重复订阅。
注意取消和广播流。
```

### ValueListenableBuilder / ListenableBuilder

特点：

```text
监听 ValueNotifier、AnimationController、ChangeNotifier。
```

适合：

```text
轻量局部状态
动画值
调试开关
```

`easy_job_module` 场景：

`main_init.dart` 使用 `ListenableBuilder` 包装 DebugBanner、StatsFl 等调试浮层开关，说明轻量全局调试状态可以不用复杂状态管理。

### Obx

特点：

```text
GetX 响应式组件，监听 Rx 变量。
```

适合：

```text
局部 UIState 响应
按钮 enable 状态
输入框清除按钮显示
列表加载完成状态
```

坑点：

```text
Obx 内只放真正依赖 Rx 的最小 UI 区域，避免大范围重建。
Obx 里如果读了过多 Rx，会造成不必要刷新。
不要在 Obx build 过程中做副作用，例如请求、弹窗、导航。
```

`easy_job_module` 场景：

邮箱编辑页用多个小 `Obx` 分别包裹：

```text
右上角确定按钮
邮箱输入框清除按钮状态
验证码输入框状态
发送验证码按钮倒计时
```

这种做法让每块 UI 只响应自己关心的状态。

来源：`receiving_email_edit_page.dart`

## 13. 剪裁、圆角与形状

### ClipRRect / ClipOval

特点：

```text
ClipRRect 矩形圆角裁剪。
ClipOval 圆形/椭圆裁剪。
```

适合：

```text
头像圆形裁剪
图片圆角
卡片内容裁剪
```

坑点：

```text
裁剪有性能成本，列表大量图片要谨慎。
如果只是背景圆角，不一定需要 ClipRRect，用 BoxDecoration borderRadius 即可。
图片圆角需要真正裁剪时才用 ClipRRect。
```

`easy_job_module` 场景：

面试用户卡片使用 `ClipOval + WebImageWidget` 做圆形头像。

## 14. 弹窗与浮层

### Dialog / showDialog

特点：

```text
标准弹窗路由。
```

适合：

```text
确认弹窗
表单弹窗
强阻断提示
```

坑点：

```text
context 要来自有效 Navigator。
弹窗内异步后关闭要判断 mounted。
复杂通用弹窗建议封装统一入口，统一埋点、按钮样式和防重复。
```

`easy_job_module` 场景：

项目有通用 popup 能力，如取消收藏弹窗、面试接受/拒绝弹窗、通用活动弹窗等，不直接在业务页面里散写所有 Dialog。

### Overlay / BotToast

特点：

```text
Overlay 适合浮在当前页面之上的内容。
BotToast 这类库封装了 toast/loading/自定义浮层。
```

坑点：

```text
OverlayEntry 要保存引用并 remove。
loading 要做并发计数，避免 A 请求结束关闭 B 请求 loading。
跨页面 overlay 要接 NavigatorObserver 或统一清理策略。
```

## 15. 自定义绘制

### CustomPaint

特点：

```text
自定义 Canvas 绘制。
```

适合：

```text
虚线边框
复杂背景
图表
路径动画
```

坑点：

```text
shouldRepaint 要准确比较字段，否则会过度重绘或不刷新。
绘制层不要拦截事件，覆盖在表单上方时配合 IgnorePointer。
```

`easy_job_module` 场景：

`ValidationErrorBorder` 用 `CustomPaint` 绘制虚线错误边框，作为覆盖层浮在 child 上方，不改变布局。

## 16. 项目基础组件

### BasePage

定位：

```text
真实项目页面骨架组件。
```

提供：

```text
统一 AppBar
默认返回按钮
右侧 actions
状态栏样式
背景色
底部按钮
键盘顶起策略
```

适合：

```text
业务二级页
普通表单页
详情页
设置页
```

坑点：

```text
基础页面组件不要塞业务逻辑。
返回行为要允许业务覆盖。
沉浸式页面可选择 showAppBar=false，然后手动处理状态栏样式。
```

### SwipeBackListener

定位：

```text
统一处理 Flutter 页面的侧滑返回、系统返回和原生返回协作。
```

实现点：

```text
GestureDetector 监听左侧边缘水平滑动。
PopScope 拦截系统返回。
平台适配器控制单 Flutter route 时是否禁用原生侧滑。
```

坑点：

```text
手势阈值要谨慎，避免和页面横滑组件冲突。
Pan 手势可能影响 PageView/横向列表。
PopScope canPop=false 后必须自己处理返回，否则 Android 返回键无效。
```

### WebImageWidget

定位：

```text
真实业务网络图片统一组件。
```

不要到处直接用 `Image.network`，原因是：

```text
图片尺寸、缓存、失败、重试、动图、默认图、OSS 裁剪都需要统一策略。
```

坑点：

```text
Timer、WidgetsBindingObserver、ui.Image 等资源必须释放。
didUpdateWidget 要处理 URL/尺寸变化。
列表中图片要控制解码尺寸和磁盘缓存尺寸。
```

## 17. 相似组件快速选择表

```text
Container vs Padding vs SizedBox vs DecoratedBox
只间距 -> Padding/SizedBox
只装饰 -> DecoratedBox
尺寸+装饰+对齐 -> Container

Column/Row vs Stack
线性排布 -> Column/Row
层叠/悬浮/覆盖 -> Stack

Expanded vs Flexible vs Spacer
强制填满 -> Expanded
可伸缩但不强制填满 -> Flexible
推开空间 -> Spacer

Text vs RichText
单一样式 -> Text
多样式/局部点击 -> RichText/TextSpan

GestureDetector vs InkWell
复杂手势/无 Material 效果 -> GestureDetector
标准点击反馈 -> InkWell

Visibility vs Offstage vs Opacity vs if
不构建 -> if
隐藏且可配置保留状态/空间 -> Visibility
隐藏但保留状态 -> Offstage
透明但仍占位 -> Opacity

SingleChildScrollView vs ListView
少量整体内容 -> SingleChildScrollView
长列表 -> ListView.builder

ListView vs CustomScrollView
普通列表 -> ListView
复杂 sliver 组合 -> CustomScrollView

DefaultTabController vs TabController
简单 tab -> DefaultTabController
需要监听/控制/埋点 -> TabController

TabBarView vs PageView
固定 tab -> TabBarView
动态分页/频道 -> PageView.builder

FutureBuilder vs StreamBuilder
一次性异步 -> FutureBuilder
连续变化 -> StreamBuilder

TextField vs TextFormField
自定义状态校验 -> TextField
Form 统一校验 -> TextFormField
```

## 18. 真实项目常见坑点清单

```text
1. Row 中 Text 不加 Expanded，接口长文案导致溢出。
2. SingleChildScrollView + Column 中使用 Expanded，出现无界高度错误。
3. 在 build 中创建 Future/Stream/Controller，导致重复请求或重复订阅。
4. TextEditingController、FocusNode、TabController、ScrollController 不 dispose。
5. GestureDetector 没设置 behavior，padding 空白区域点不到。
6. InkWell 没有 Material 祖先，水波纹不显示。
7. Visibility 默认不保留状态，隐藏再显示后子 State 丢失。
8. Opacity(opacity: 0) 仍然能响应点击，需要 IgnorePointer。
9. Stack 中 Positioned 不是直接 child，运行时报错。
10. 图片不设尺寸，加载前后布局跳动。
11. 列表大量动图持续播放，造成解码和帧调度压力。
12. RichText 的 TextSpan recognizer 不释放。
13. TabController length 和 TabBarView children 数量不一致。
14. PopScope 拦截返回后没有处理返回逻辑。
15. CustomPaint shouldRepaint 写错，导致重绘异常或不刷新。
16. Obx/BlocBuilder 包裹范围过大，引发大面积 rebuild。
17. 状态变化导致列表整体重建，滚动位置和曝光统计受影响。
18. 沉浸式页面只改 AppBar，不处理状态栏图标颜色。
```

## 19. 对 `yp_flutter_recruitment_demo` 的建议

当前 demo 已经有：

```text
MainTabScaffold
BaseVM
BotToast
Overlay 示例
固定 Tab 保活示例
动态 PageView 缓存示例
MMKV 响应式 KV 示例
```

后续可以继续补：

```text
BasePage
统一图片组件
统一输入框组件
统一列表刷新组件
统一弹窗组件
统一空态/错误态/加载态组件
```

这样 demo 会更接近 `easy_job_module` 这种真实业务工程：不是直接堆 Flutter 官方组件，而是在业务高频场景上沉淀项目组件。
