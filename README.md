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

- **Easily implement toast，loading，attach dialog，custome dialog**

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
      home: HomePage(),
      // here
      navigatorObservers: [FlutterSmartDialog.observer],
      // here
      builder: FlutterSmartDialog.init(
        //default toast widget
        toastBuilder: (String msg) => CustomToastWidget(msg: msg),
        //default loading widget
        loadingBuilder: (String msg) => CustomLoadingWidget(msg: msg),
      ),
    );
  }
}
````

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

# You may have questions

For details, please check： [Some Consideration Details](https://github.com/fluttercandies/flutter_smart_dialog/blob/master/docs/Some%20Consideration.md)

![initBack](https://raw.githubusercontent.com/xdd666t/MyData/master/pic/flutter/blog/20211103092132.gif)

![hardClose](https://raw.githubusercontent.com/xdd666t/MyData/master/pic/flutter/blog/20211103092201.gif)

# Attach Chapter

For details, please check： [Attach Chapter Details](https://github.com/fluttercandies/flutter_smart_dialog/blob/master/docs/Attach%20Chapter.md)

This is a very important function. I wanted to add it a long time ago, but it was busy and has been shelved; New Year's Day (2022.1.1) started, and it took some time to complete this function and related demos.

![attachLocation](https://raw.githubusercontent.com/xdd666t/MyData/master/pic/flutter/blog/20220103161314.gif)

![attachImitate](https://raw.githubusercontent.com/xdd666t/MyData/master/pic/flutter/blog/20220103161431.gif)

![attachGuide](https://raw.githubusercontent.com/xdd666t/MyData/master/pic/flutter/blog/20220103161443.gif)

# Dialog Chapter

For details, please check： [Dialog Chapter Details](https://github.com/fluttercandies/flutter_smart_dialog/blob/master/docs/Dialog%20Chapter.md)

![dialogLocation](https://raw.githubusercontent.com/xdd666t/MyData/master/pic/flutter/blog/20211103092433.gif)

![dialogPenetrate](https://raw.githubusercontent.com/xdd666t/MyData/master/pic/flutter/blog/20211103092442.gif)

![dialogStack](https://raw.githubusercontent.com/xdd666t/MyData/master/pic/flutter/blog/20211106214858.gif)

# Loading Chapter

For details, please check： [Loading Chapter Details](https://github.com/fluttercandies/flutter_smart_dialog/blob/master/docs/Loading%20Chapter.md)

![loadingOne](https://raw.githubusercontent.com/xdd666t/MyData/master/pic/flutter/blog/20211103092313.gif)

![loadingSmile](https://raw.githubusercontent.com/xdd666t/MyData/master/pic/flutter/blog/20211103092359.gif)

![loadingNormal](https://raw.githubusercontent.com/xdd666t/MyData/master/pic/flutter/blog/20211103092413.gif)

# Toast Chapter

For details, please check： [Toast Chapter Details](https://github.com/fluttercandies/flutter_smart_dialog/blob/master/docs/Toast%20Chapter.md)

![toastOne](https://raw.githubusercontent.com/xdd666t/MyData/master/pic/flutter/blog/20211103092214.gif)

![toastSmart](https://raw.githubusercontent.com/xdd666t/MyData/master/pic/flutter/blog/20211103092228.gif)

![toastCustom](https://raw.githubusercontent.com/xdd666t/MyData/master/pic/flutter/blog/20211103092253.gif)

