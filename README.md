[![pub](https://img.shields.io/pub/v/flutter_smart_dialog?label=pub&logo=dart)](https://pub.dev/packages/flutter_smart_dialog/install) [![stars](https://img.shields.io/github/stars/fluttercandies/flutter_smart_dialog?logo=github)](https://github.com/fluttercandies/flutter_smart_dialog)  [![issues](https://img.shields.io/github/issues/fluttercandies/flutter_smart_dialog?logo=github)](https://github.com/fluttercandies/flutter_smart_dialog/issues) [![commit](https://img.shields.io/github/last-commit/fluttercandies/flutter_smart_dialog?logo=github)](https://github.com/fluttercandies/flutter_smart_dialog/commits)

Feature and Usage（Must read！）：[super detailed guide](https://xdd666t.github.io/flutter_use/web/index.html#/smartDialog)

功能和用法（必看！）： [超详细指南](https://xdd666t.github.io/flutter_use/web/index.html#/smartDialog)

***

Language:  English | [中文](https://juejin.cn/post/7026150456673959943)

Migrate doc：[3.x migrate 4.0](https://github.com/fluttercandies/flutter_smart_dialog/blob/master/docs/3.x%20migrate%204.0.md) | [3.x 迁移 4.0](https://juejin.cn/post/7093867453012246565)

Flutter 2：Please use `flutter_smart_dialog: 4.2.5`

# Introduction

An elegant Flutter Dialog solution.

# Some Effect

![attachLocationAndPoint](https://raw.githubusercontent.com/xdd666t/MyData/master/pic/flutter/blog/20220103160140.gif)

![attachHighlight](https://raw.githubusercontent.com/xdd666t/MyData/master/pic/flutter/blog/20220103160210.gif)

![dialogStack](https://raw.githubusercontent.com/xdd666t/MyData/master/pic/flutter/blog/20211216222718.gif)

![loadingCustom](https://raw.githubusercontent.com/xdd666t/MyData/master/pic/flutter/blog/202201140931573.gif)

![toastCustom](https://raw.githubusercontent.com/xdd666t/MyData/master/pic/flutter/blog/20211103092253.gif)

# Advantage

- **Do not need BuildContext**
- **Can penetrate dark background, click on the page behind dialog**
- **Support dialog stack，close the specified dialog**

- **Support positioning widget, display the specified location dialog**
- **Support highlight feature，dissolve the specified location mask**

- **Easily implement toast，loading，attach dialog，custome dialog，custome notify**

# Quick start

## Install

- **latest version：[install pub](https://pub.flutter-io.cn/packages/flutter_smart_dialog/install)**

## Initialization

> **initialization**

```dart
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage,
      // here
      navigatorObservers: [FlutterSmartDialog.observer],
      // here
      builder: FlutterSmartDialog.init(),
    );
  }
}
```

> **Advanced initialization: configure global custom Loading and Toast**

SmartDialog's showLoading and showToast provide a default style. Of course, custom param are definitely supported.

- SmartDialog custom Loading or Toast is very simple: However, when using it, it may make you feel a little troublesome
- for example
  - Use custom Loading: `SmartDialog.showLoading(builder: (_) => CustomLoadingWidget);`
  - The effect we want must be like this:  `SmartDialog.showLoading();`
- In view of the above considerations, I added the function of setting custom default Loading and Toast styles at the entrance

Let me show you the following

- The entry needs to be configured: implement toastBuilder and loadingBuilder, and pass in custom Toast and Loading


````dart
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage,
      // here
      navigatorObservers: [FlutterSmartDialog.observer],
      // here
      builder: FlutterSmartDialog.init(
        //custom default toast widget
        toastBuilder: (String msg) => CustomToastWidget(msg: msg),
        //custom default loading widget
        loadingBuilder: (String msg) => CustomLoadingWidget(msg: msg),
        //custom default notify widget
        notifyStyle: FlutterSmartNotifyStyle(
          successBuilder: (String msg) => CustomSuccessWidget(msg: msg),
          failureBuilder: (String msg) => CustomFailureWidget(msg: msg),
          warningBuilder: (String msg) => CustomWarningWidget(msg: msg),
          alertBuilder: (String msg) => CustomAlertWidget(msg: msg),
          errorBuilder: (String msg) => CustomErrorWidget(msg: msg),
        ),
      ),
    );
  }
}
````

- SmartDialog supports default global configuration

```dart
SmartDialog.config
  ..custom = SmartConfigCustom(
    maskColor: Colors.black.withOpacity(0.35),
    useAnimation: true,
  )
  ..attach = SmartConfigAttach(
    animationType: SmartAnimationType.scale,
    usePenetrate: false,
  )
  ..loading = SmartConfigLoading(
    clickMaskDismiss: false,
    leastLoadingTime: const Duration(milliseconds: 0),
  )
  ..toast = SmartConfigToast(
    intervalTime: const Duration(milliseconds: 100),
    displayTime: const Duration(milliseconds: 2000),
  );
```

## Easy usage

- **toast usage**💬

```dart
SmartDialog.showToast('test toast');
```

![toastDefault](https://raw.githubusercontent.com/xdd666t/MyData/master/pic/flutter/blog/20211102232805.gif)

- **loading usage**⏳

```dart
SmartDialog.showLoading();
await Future.delayed(Duration(seconds: 2));
SmartDialog.dismiss(); 
```

![loadingDefault](https://raw.githubusercontent.com/xdd666t/MyData/master/pic/flutter/blog/20211102232815.gif)

- **dialog usage**🎨

```dart
SmartDialog.show(builder: (context) {
  return Container(
    height: 80,
    width: 180,
    decoration: BoxDecoration(
      color: Colors.black,
      borderRadius: BorderRadius.circular(10),
    ),
    alignment: Alignment.center,
    child:
    Text('easy custom dialog', style: TextStyle(color: Colors.white)),
  );
});
```

![dialogEasy](https://raw.githubusercontent.com/xdd666t/MyData/master/pic/flutter/blog/20211102232821.gif)