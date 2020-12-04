# flutter_smart_dialog

语言: [English](https://github.com/CNAD666/flutter_smart_dialog/blob/master/docs/README-ZH.md) | [中文简体](https://github.com/CNAD666/flutter_smart_dialog/blob/master/docs/README-ZH.md)

一个更优雅的Flutter Dialog解决方案

# 前言

系统自带的Dialog实际上就是Push了一个新页面，这样存在很多好处，但是也存在一些很难解决的问题

- **必须传BuildContext**
  - loading弹窗一般都封装在网络框架中，多传个context参数就很头疼；用fish_redux还好，effect层直接能拿到context，要是用bloc还得在view层把context传到bloc或者cubit里面。。。
- **无法穿透暗色背景，点击dialog后面的控件**
  - 这个是真头痛，想了很多办法都没在自带dialog上面解决
- **系统自带Dialog写成的Loading弹窗，在网络请求和跳转页面的情况，会存在路由混乱的情况**
  - 情景复盘：loading库封装在网络层，某个页面提交完表单，要跳转页面，提交操作完成，进行页面跳转，loading关闭是在异步回调中进行（onError或者onSuccess），会出现执行了跳转操作时，弹窗还未关闭，延时一小会关闭，因为用的都是pop页面方法，会把跳转的页面pop掉
  - 上面是一种很常见的场景，涉及到复杂场景更加难以预测，解决方法也有：定位页面栈的栈顶是否是Loading弹窗，选择性Pop，实现麻烦

`上面这些痛点，简直个个致命`，当然，还存在一些其它的解决方案，例如：

- 每个页面顶级使用Stack
- 使用Overlay

很明显，使用Overlay可移植性最好，目前很多Toast和dialog三方库便是使用该方案，使用了一些loading库，看了其中源码，穿透背景解决方案，和预期想要的效果大相径庭、一些dialog库自带toast显示，但是toast显示却又不能和dialog共存（toast属于特殊的信息展示，理应能独立存在），导致我需要多依赖一个Toast库

# SmartDialog

**基于上面那些难以解决的问题，只能自己去实现，花了一些时间，实现了一个Pub包，基本该解决的痛点都已解决了，用于实际业务没什么问题**

## 效果

- [点我体验一下](https://cnad666.github.io/flutter_use/web/index.html#/smartDialog)

![smartDialog](https://cdn.jsdelivr.net/gh/CNAD666/MyData/pic/flutter/blog/20201204145311.gif)

## 引入

```dart
dependencies:
  flutter_smart_dialog: ^0.1.6
```

## 使用

- 主入口配置
  - 在主入口这地方需要配置，这样就可以不传BuildContext使用Dialog
  - 只需要在MaterialApp的builder参数处配置下即可

```dart
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SmartDialogPage(),
      builder: (BuildContext context, Widget child) {
        return Material(
          type: MaterialType.transparency,
          child: FlutterSmartDialog(child: child),
        );
      },
    );
  }
}
```

使用`FlutterSmartDialog`包裹下child即可，下面就可以愉快的使用SmartDialog了

- 使用Toast
  - msg：必传信息
  - time：可选，Duration类型
  - alignment：可控制toast位置
  - 如果想使用花里花哨的Toast效果，使用show方法定制就行了，炒鸡简单喔，懒得写，抄下我的ToastWidget，改下属性即可

```dart
SmartDialog.instance.showToast('test toast');
```

- 使用Loading

```dart
//open loading
SmartDialog.instance.showLoading();

//delay off
await Future.delayed(Duration(seconds: 2));
SmartDialog.instance.dismiss();
```

- 自定义dialog
  - 使用SmartDialog.instance.show()方法即可，里面含有众多'Temp'为后缀的参数，和下述无'Temp'为后缀的参数功能一致

```dart
SmartDialog.instance.show(
    alignmentTemp: Alignment.bottomCenter,
    clickBgDismissTemp: true,
    widget: Container(
      color: Colors.blue,
      height: 300,
    ),
);
```

- SmartDialog配置参数说明

| 参数              | 功能说明                                                     |
| ----------------- | ------------------------------------------------------------ |
| alignment         | 控制自定义控件位于屏幕的位置                                                                                                                                                                         Alignment.center: 自定义控件位于屏幕中间，且是动画默认为：渐隐和缩放，可使用isLoading选择动画                              Alignment.bottomCenter、Alignment.bottomLeft、Alignment.bottomRight：自定义控件位于屏幕底部，动画默认为位移动画，自下而上，可使用animationDuration设置动画时间                                                                                                                                                                                 Alignment.topCenter、Alignment.topLeft、Alignment.topRight：自定义控件位于屏幕顶部，动画默认为位移动画，自上而下，可使用animationDuration设置动画时间                                                                                                                                                      Alignment.centerLeft：自定义控件位于屏幕左边，动画默认为位移动画，自左而右，可使用animationDuration设置动画时间   Alignment.centerRight：自定义控件位于屏幕左边，动画默认为位移动画，自右而左，可使用animationDuration设置动画时间 |
| isPenetrate       | 默认:false；是否穿透遮罩背景,交互遮罩之后控件，true：点击能穿透背景，false：不能穿透；穿透遮罩设置为true，背景遮罩会自动变成透明（必须） |
| clickBgDismiss    | 默认：false；点击遮罩，是否关闭dialog---true：点击遮罩关闭dialog，false：不关闭 |
| maskColor         | 遮罩颜色                                                     |
| animationDuration | 动画时间                                                     |
| isUseAnimation    | 默认：true；是否使用动画                                     |
| isLoading         | 默认：true；是否使用Loading动画；true:内容体使用渐隐动画  false：内容体使用缩放动画，仅仅针对中间位置的控件 |
| isExist           | 默认：false；主体SmartDialog（OverlayEntry）是否存在在界面上 |
| isExistExtra      | 默认：false；额外SmartDialog（OverlayEntry）是否存在在界面上 |

|      |      |
| ---- | ---- |
|      |      |
|      |      |
|      |      |
|      |      |
|      |      |
|      |      |
|      |      |
|      |      |
|      |      |