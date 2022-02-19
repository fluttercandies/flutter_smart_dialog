[![pub](https://img.shields.io/pub/v/flutter_smart_dialog?label=pub&logo=dart)](https://pub.flutter-io.cn/packages/flutter_smart_dialog/install) [![stars](https://img.shields.io/github/stars/fluttercandies/flutter_smart_dialog?logo=github)](https://github.com/fluttercandies/flutter_smart_dialog)  [![issues](https://img.shields.io/github/issues/fluttercandies/flutter_smart_dialog?logo=github)](https://github.com/fluttercandies/flutter_smart_dialog/issues) [![commit](https://img.shields.io/github/last-commit/fluttercandies/flutter_smart_dialog?logo=github)](https://github.com/fluttercandies/flutter_smart_dialog/commits)

Language:  English | [中文](https://juejin.cn/post/7026150456673959943)

# Introduction

An elegant Flutter Dialog solution.

- [pub](https://pub.flutter-io.cn/packages/flutter_smart_dialog)，[github](https://github.com/fluttercandies/flutter_smart_dialog)，[web effect](https://xdd666t.github.io/flutter_use/web/index.html#/smartDialog)

# Some Effect

![attachLocationAndPoint](https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20220103160140.gif)

![attachHighlight](https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20220103160210.gif)

![dialogStack](https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20211216222718.gif)

![loadingCustom](https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/202201140931573.gif)

![toastCustom](https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20211103092253.gif)

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
  - Use custom Loading: `SmartDialog.showLoading(widget: CustomLoadingWidget);`
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
        //default toast widget
        toastBuilder: (String msg, AlignmentGeometry alignment) {
          return CustomToastWidget(msg: msg, alignment: alignment);
        },
        //default loading widget
        loadingBuilder: (String msg, Color background) {
          return CustomLoadingWidget(msg: msg, background: background);
        },
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

# You may have questions

For details, please check： [Some Consideration Details]()

![initBack](https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20211103092132.gif)

![hardClose](https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20211103092201.gif)

# Attach Chapter

For details, please check： [Attach Chapter Details]()

This is a very important function. I wanted to add it a long time ago, but it was busy and has been shelved; New Year's Day (2022.1.1) started, and it took some time to complete this function and related demos.

![attachLocation](https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20220103161314.gif)

![attachImitate](https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20220103161431.gif)

![attachGuide](https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20220103161443.gif)

# Dialog Chapter

For details, please check： [Dialog Chapter Details]()

![dialogLocation](https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20211103092433.gif)

![dialogPenetrate](https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20211103092442.gif)

![dialogStack](https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20211106214858.gif)

# Loading Chapter

For details, please check： [Loading Chapter Details]()

![loadingOne](https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20211103092313.gif)

![loadingSmile](https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20211103092359.gif)

![loadingNormal](https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20211103092413.gif)

# Toast Chapter

For details, please check： [Toast Chapter Details]()

![toastOne](https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20211103092214.gif)

![toastSmart](https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20211103092228.gif)

![toastCustom](https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20211103092253.gif)

# Little tricks of anger

There is a scene that compares the egg cone

- We encapsulated a small component using StatefulWidget
- In a special situation, we need to trigger a method inside this component outside the component
- There are many implementation methods for this kind of scene, but it may be a little troublesome to make it

Here is a simple idea, which can be triggered very easily, a method inside the component

- Create a widget

```dart
class OtherTrick extends StatefulWidget {
  const OtherTrick({Key? key, this.onUpdate}): super(key: key);

  final Function(VoidCallback onInvoke)? onUpdate;

  @override
  _OtherTrickState createState() => _OtherTrickState();
}

class _OtherTrickState extends State<OtherTrick> {
  int _count = 0;

  @override
  void initState() {
    // here
    widget.onUpdate?.call(() {
      _count++;
      setState(() {});
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text('Counter: $_count', style: TextStyle(fontSize: 30.0)),
      ),
    );
  }
}
```

- Show this component and then trigger it externally

```dart
VoidCallback? callback;

// display
SmartDialog.show(
  alignmentTemp: Alignment.center,
  widget: OtherTrick(
    onUpdate: (VoidCallback onInvoke) => callback = onInvoke,
  ),
);

await Future.delayed(Duration(milliseconds: 500));

// handler
SmartDialog.show(
  alignmentTemp: Alignment.centerRight,
  maskColorTemp: Colors.transparent,
  widget: Container(
    height: double.infinity,
    width: 150,
    color: Colors.white,
    alignment: Alignment.center,
    child: ElevatedButton(
      child: Text('add'),
      onPressed: () => callback?.call(),
    ),
  ),
);
```

- Let's see the effect

![trick](https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20211103092459.gif)
