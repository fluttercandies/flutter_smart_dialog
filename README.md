[![pub](https://img.shields.io/pub/v/flutter_smart_dialog?label=pub&logo=dart)](https://pub.flutter-io.cn/packages/flutter_smart_dialog/install) [![stars](https://img.shields.io/github/stars/fluttercandies/flutter_smart_dialog?logo=github)](https://github.com/fluttercandies/flutter_smart_dialog)  [![issues](https://img.shields.io/github/issues/fluttercandies/flutter_smart_dialog?logo=github)](https://github.com/fluttercandies/flutter_smart_dialog/issues)

Language: [English](https://github.com/fluttercandies/flutter_smart_dialog/blob/master/README.md) | [中文简体](https://juejin.cn/post/7026150456673959943)

# Introduction

An elegant Flutter Dialog solution.

- [pub](https://pub.flutter-io.cn/packages/flutter_smart_dialog/install)，[github](https://github.com/fluttercandies/flutter_smart_dialog)，[click me to experience it](https://xdd666t.github.io/flutter_use/web/index.html#/smartDialog)

```dart
dependencies:
  flutter_smart_dialog: ^3.0.0
```

# Advantage

- **Do not need BuildContext**
- **Can penetrate dark background, click on the page behind dialog**
- **Support dialog stack，close the specified dialog**
- **Easily implement toast，loading dialog，custome dialog**

# Quick start

## Initialization

> **Initialization method 1:  Strong recommendation**😃

```dart
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: RouteConfig.main,
      getPages: RouteConfig.getPages,
      // here
      navigatorObservers: [FlutterSmartDialog.observer],
      // here
      builder: FlutterSmartDialog.init(),
    );
  }
}
```

> **Initialization Method 2: Compatible with the old version**❤

```dart
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // here
    FlutterSmartDialog.monitor();
    return MaterialApp(
      home: SmartDialogPage(),
      // here
      navigatorObservers: [FlutterSmartDialog.observer],
      /// here
      builder: (BuildContext context, Widget? child) {
        return FlutterSmartDialog(child: child);
      },
    );
  }
}
```

## Easy usage

- **toast usage**💬

```dart
SmartDialog.showToast('test toast');
```

![toastDefault](https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20211102232805.gif)

- **loading usage**⏳

```dart
SmartDialog.showLoading();
await Future.delayed(Duration(seconds: 2));
SmartDialog.dismiss(); 
```

![loadingDefault](https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20211102232815.gif)

- **dialog usage**🎨

```dart
var custom = Container(
    height: 80,
    width: 180,
    decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
    ),
    alignment: Alignment.center,
    child: Text('easy custom dialog', style: TextStyle(color: Colors.white)),
);
// here
SmartDialog.show(widget: custom, isLoadingTemp: false);
```

![dialogEasy](https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20211102232821.gif)
