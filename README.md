[![pub](https://img.shields.io/pub/v/flutter_smart_dialog?label=pub&logo=dart)](https://pub.flutter-io.cn/packages/flutter_smart_dialog/install) [![stars](https://img.shields.io/github/stars/fluttercandies/flutter_smart_dialog?logo=github)](https://github.com/fluttercandies/flutter_smart_dialog)  [![issues](https://img.shields.io/github/issues/fluttercandies/flutter_smart_dialog?logo=github)](https://github.com/fluttercandies/flutter_smart_dialog)

Language: [English](https://github.com/fluttercandies/flutter_smart_dialog/blob/master/README.md) | [中文简体](https://juejin.cn/post/6902331428072390663)

# Introduction

An elegant Flutter Dialog solution.

- [pub install](https://pub.dev/packages/flutter_smart_dialog/install)

```dart
dependencies:
  flutter_smart_dialog: any
```

# Advantage

- **Do not need BuildContext**
- **Can penetrate dark background, click on the page behind dialog**
- **Easily implement loading dialog**

# Effect

- [Click me to experience it](https://cnad666.github.io/flutter_use/web/index.html#/smartDialog)

![smartDialog](https://cdn.jsdelivr.net/gh/CNAD666/MyData/pic/flutter/blog/20201204145311.gif)

# Use

- Main entrance configuration
  - It needs to be configured in the main entrance, so that you can use Dialog without passing BuildContext
  - You only need to configure it in the builder parameters of MaterialApp

```dart
void main() {
  runApp(MyApp());
}

///flutter 2.0
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Container(),
      builder: (BuildContext context, Widget? child) {
        return FlutterSmartDialog(child: child);
      },
    );
  }
}

///flutter 1.x
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Container(),
      builder: (BuildContext context, Widget child) {
        return FlutterSmartDialog(child: child);
      },
    );
  }
}
```

Use `FlutterSmartDialog` to wrap the child, and then you can use SmartDialog happily

- Use Toast: Because of the special nature of toast, some optimizations have been made to toast separately here
  - time: optional, Duration type, default 1500ms
  - isDefaultDismissType: the type of toast disappearing, the default is true
    - true: default disappearing type, similar to android toast, toast displayed one by one
    - false: non-default disappearing type, multiple clicks, the toast will be displayed after the former toast
  - widget: toast can be customized
  - msg: mandatory message
  - alignment: optional, control toast position
  - If you want to use the fancy Toast effect, please use the showToast method to customize it. Fried chicken is simple, too lazy to write it yourself. Just copy my ToastWidget and change the attributes.

```dart
SmartDialog.showToast('test toast');
```

- Use Loading: Loading has many setting properties, please refer to the `SmartDialog configuration parameter description` below
  - msg: optional, the text message below the loading animation (default: loading...)

```dart
//open loading
SmartDialog.showLoading();

//delay off
await Future.delayed(Duration(seconds: 2));
SmartDialog.dismiss();
```

- Custom dialog
  - Use the SmartDialog.show() method, which contains many parameters with a suffix of  `Temp`, which are consistent with the following parameters without the suffix of `Temp`
  - Special attribute `isUseExtraWidget`: whether to use an additional overlay floating layer, it can be separated from the main floating layer; it can be separated from loading, dialog, etc. The built-in showToast turns on this configuration and can coexist with loading

```dart
SmartDialog.show(
    alignmentTemp: Alignment.bottomCenter,
    clickBgDismissTemp: true,
    widget: Container(
      color: Colors.blue,
      height: 300,
    ),
);
```

- SmartDialog configuration parameter description
  - In order to avoid exposing too many attributes in `instance`, causing inconvenience to use, many parameters here are managed by `config` attribute in `instance`
  - The attributes set by config are global. Using Config to manage these attributes is to facilitate the modification and management of these attributes, and also to make the SmartDialog class easier to maintain

| Parameters | Function description |
| ----------------- | ------------------------------------------------------------ |
| alignment | Control the position of the custom control on the screen<br/>**Alignment.center**: The custom control is located in the middle of the screen, and the animation defaults to: fade and zoom, you can use isLoading to select the animation<br/> **Alignment.bottomCenter, Alignment.bottomLeft, Alignment.bottomRight**: The custom control is located at the bottom of the screen, the animation defaults to displacement animation, bottom-up, you can use animationDuration to set the animation time<br/>**Alignment.topCenter, Alignment.topLeft, Alignment.topRight**: The custom control is located at the top of the screen, and the animation defaults to displacement animation. From top to bottom, you can use animationDuration to set the animation time<br/>**Alignment.centerLeft**: The custom control is located at On the left side of the screen, the animation defaults to displacement animation, from left to right, you can use animationDuration to set the animation time<br/> **Alignment.centerRight**: The custom control is located on the left side of the screen, and the animation defaults to displacement animation, from right to left. You can use animationDuration to set the animation time |
| isPenetrate | Default: false; whether to penetrate the background of the mask, control after interactive mask, true: click to penetrate the background, false: not penetrate; set the penetration mask to true, the background mask will automatically become transparent (Required) |
| clickBgDismiss | Default: true; click the mask, whether to close the dialog---true: click the mask to close the dialog, false: not close |
| maskColor | Mask color |
| maskWidget | Customize Mask |
| animationDuration | Animation time |
| isUseAnimation | Default: true; whether to use animation |
| isLoading | Default: true; whether to use Loading animation; true: use fade animation for content body false: use zoom animation for content body, only for the middle position dialog |
| isExist | Status calibration: whether loading and custom dialog exist on the interface |
| isExistMain | State calibration: whether the custom dialog exists on the interface (show) |
| isExistLoading | State calibration: whether loading exists on the interface (showLoading) |
| isExistToast | State calibration: whether toast exists on the interface (showToast) |

- Use of Config attribute, for example
  - The relevant attributes have been initialized internally; if you need to customize, you can initialize the attributes you want at the main entrance

```dart
SmartDialog.instance.config
    ..clickBgDismiss = true
    ..isLoading = true
    ..isUseAnimation = true
    ..animationDuration = Duration(milliseconds: 270)
    ..isPenetrate = false
    ..maskColor = Colors.black.withOpacity(0.1)
    ..alignment = Alignment.center;
```

- **Return to the event, close the pop-up window solution**

There is basically a problem when using Overlay's dependency library. It is difficult to monitor the return event, which makes it difficult to close the pop-up window layout when the return event is violated. After thinking of many ways, there is no way to solve the problem in the dependency library. Here is one `BaseScaffold`, use `BaseScaffold` on each page to solve the problem of closing Dialog in return event

- Flutter 2.0

```dart
typedef ScaffoldParamVoidCallback = void Function();

class BaseScaffold extends StatefulWidget {
  const BaseScaffold({
    Key? key,
    this.appBar,
    this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.floatingActionButtonAnimator,
    this.persistentFooterButtons,
    this.drawer,
    this.endDrawer,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    this.primary = true,
    this.drawerDragStartBehavior = DragStartBehavior.start,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.drawerScrimColor,
    this.drawerEdgeDragWidth,
    this.drawerEnableOpenDragGesture = true,
    this.endDrawerEnableOpenDragGesture = true,
    this.isTwiceBack = false,
    this.isCanBack = true,
    this.onBack,
  }) : super(key: key);

  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final FloatingActionButtonAnimator? floatingActionButtonAnimator;
  final List<Widget>? persistentFooterButtons;
  final Widget? drawer;
  final Widget? endDrawer;
  final Color? drawerScrimColor;
  final Color? backgroundColor;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final bool? resizeToAvoidBottomInset;
  final bool primary;
  final DragStartBehavior drawerDragStartBehavior;
  final double? drawerEdgeDragWidth;
  final bool drawerEnableOpenDragGesture;
  final bool endDrawerEnableOpenDragGesture;

  //custom param
  final bool isTwiceBack;
  final bool isCanBack;
  final ScaffoldParamVoidCallback? onBack;

  @override
  _BaseScaffoldState createState() => _BaseScaffoldState();
}

class _BaseScaffoldState extends State<BaseScaffold> {
  DateTime? _lastTime;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: widget.appBar,
        body: widget.body,
        floatingActionButton: widget.floatingActionButton,
        floatingActionButtonLocation: widget.floatingActionButtonLocation,
        floatingActionButtonAnimator: widget.floatingActionButtonAnimator,
        persistentFooterButtons: widget.persistentFooterButtons,
        drawer: widget.drawer,
        endDrawer: widget.endDrawer,
        bottomNavigationBar: widget.bottomNavigationBar,
        bottomSheet: widget.bottomSheet,
        backgroundColor: widget.backgroundColor,
        resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
        primary: widget.primary,
        drawerDragStartBehavior: widget.drawerDragStartBehavior,
        extendBody: widget.extendBody,
        extendBodyBehindAppBar: widget.extendBodyBehindAppBar,
        drawerScrimColor: widget.drawerScrimColor,
        drawerEdgeDragWidth: widget.drawerEdgeDragWidth,
        drawerEnableOpenDragGesture: widget.drawerEnableOpenDragGesture,
        endDrawerEnableOpenDragGesture: widget.endDrawerEnableOpenDragGesture,
      ),
      onWillPop: _dealWillPop,
    );
  }

  Future<bool> _dealWillPop() async {
    widget.onBack?.call();

    if (SmartDialog.instance.config.isExist) {
      SmartDialog.dismiss();
      return false;
    }

    if (!widget.isCanBack) {
      return false;
    }

    var now = DateTime.now();
    var condition =
        _lastTime == null || now.difference(_lastTime!) > Duration(seconds: 1);
    if (widget.isTwiceBack && condition) {
      _lastTime = now;
      SmartDialog.showToast("再点一次退出");
      return false;
    }
    return true;
  }
}
```

- Flutter 1.x

```dart
typedef ScaffoldParamVoidCallback = void Function();

class BaseScaffold extends StatefulWidget {
  const BaseScaffold({
    Key key,
    this.appBar,
    this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.floatingActionButtonAnimator,
    this.persistentFooterButtons,
    this.drawer,
    this.endDrawer,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    this.primary = true,
    this.drawerDragStartBehavior = DragStartBehavior.start,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.drawerScrimColor,
    this.drawerEdgeDragWidth,
    this.drawerEnableOpenDragGesture = true,
    this.endDrawerEnableOpenDragGesture = true,
    this.isTwiceBack = false,
    this.isCanBack = true,
    this.onBack,
  })  : assert(primary != null),
        assert(extendBody != null),
        assert(extendBodyBehindAppBar != null),
        assert(drawerDragStartBehavior != null),
        super(key: key);

  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final PreferredSizeWidget appBar;
  final Widget body;
  final Widget floatingActionButton;
  final FloatingActionButtonLocation floatingActionButtonLocation;
  final FloatingActionButtonAnimator floatingActionButtonAnimator;
  final List<Widget> persistentFooterButtons;
  final Widget drawer;
  final Widget endDrawer;
  final Color drawerScrimColor;
  final Color backgroundColor;
  final Widget bottomNavigationBar;
  final Widget bottomSheet;
  final bool resizeToAvoidBottomInset;
  final bool primary;
  final DragStartBehavior drawerDragStartBehavior;
  final double drawerEdgeDragWidth;
  final bool drawerEnableOpenDragGesture;
  final bool endDrawerEnableOpenDragGesture;

  final bool isTwiceBack;

  final bool isCanBack;

  final ScaffoldParamVoidCallback onBack;

  @override
  _BaseScaffoldState createState() => _BaseScaffoldState();
}

class _BaseScaffoldState extends State<BaseScaffold> {
  DateTime _lastPressedAt;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: widget.appBar,
        body: widget.body,
        floatingActionButton: widget.floatingActionButton,
        floatingActionButtonLocation: widget.floatingActionButtonLocation,
        floatingActionButtonAnimator: widget.floatingActionButtonAnimator,
        persistentFooterButtons: widget.persistentFooterButtons,
        drawer: widget.drawer,
        endDrawer: widget.endDrawer,
        bottomNavigationBar: widget.bottomNavigationBar,
        bottomSheet: widget.bottomSheet,
        backgroundColor: widget.backgroundColor,
        resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
        primary: widget.primary,
        drawerDragStartBehavior: widget.drawerDragStartBehavior,
        extendBody: widget.extendBody,
        extendBodyBehindAppBar: widget.extendBodyBehindAppBar,
        drawerScrimColor: widget.drawerScrimColor,
        drawerEdgeDragWidth: widget.drawerEdgeDragWidth,
        drawerEnableOpenDragGesture: widget.drawerEnableOpenDragGesture,
        endDrawerEnableOpenDragGesture: widget.endDrawerEnableOpenDragGesture,
      ),
      onWillPop: dealWillPop,
    );
  }

  Future<bool> dealWillPop() async {
    if (widget.onBack != null) {
      widget.onBack();
    }

    if (SmartDialog.instance.config.isExist) {
      SmartDialog.dismiss();
      return false;
    }

    if (!widget.isCanBack) {
      return false;
    }

    if (widget.isTwiceBack) {
      if (_lastPressedAt == null ||
          DateTime.now().difference(_lastPressedAt) > Duration(seconds: 1)) {
        _lastPressedAt = DateTime.now();

        SmartDialog.showToast("Click again to exit");
        return false;
      }
      return true;
    } else {
      return true;
    }
  }
}
```
