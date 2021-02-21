# flutter_smart_dialog

语言: [English](https://github.com/fluttercandies/flutter_smart_dialog/blob/master/README.md) | [中文简体](https://juejin.cn/post/6902331428072390663)

An elegant Flutter Dialog solution.

# Preface

The Dialog that comes with the system actually pushes a new page, which has many benefits, but there are also some difficult problems to solve

- **Must pass BuildContext**
  - Loading pop- ups are usually encapsulated in the network framework, and it is a headache to pass more context parameters; it is good to use fish_redux, the effect layer can directly get the context, if you use bloc, you have to pass the context to bloc or cubit in the view layer . . .
- **Cannot penetrate dark background, click on the page behind dialog**
  - This is a real headache. I have thought of a lot of ways, but failed to solve this problem on the built- in dialog.
- **The loading pop- up window written by Dialog comes with the system. In the case of network requests and page jumps, there will be routing confusion **
  - Scenario review: The loading library is generally encapsulated in the network layer. After a page is submitted, the page needs to be jumped. The submission operation is completed and the page jumps. The loading is closed in an asynchronous callback (onError or onSuccess), and it will appear When the jump operation is performed, the pop- up window has not been closed, and will be closed after a short delay, because the pop page method is used, and the jumped page will be popped.
  - The above is a very common scenario. It is more difficult to predict when it comes to complex scenarios. There are also solutions: locate whether the top of the page stack is the Loading pop- up window, select Pop, and troublesome implementation

`The above pain points are all fatal`, of course, there are some other solutions, such as:

- Use Stack at the top of the page
- Use Overlay

Obviously, the use of Overlay is the most portable. At present, many toast and dialog three- party libraries use this solution. Some loading libraries are used. After reading the source code, the penetration background solution is very different from the expected effect. The dialog library comes with toast display, but toast display cannot coexist with dialog (toast is a special information display and should be able to exist independently), so I need to rely on one more Toast library

# SmartDialog

**Based on the above difficult problems, I can only implement it myself. It took some time to implement a Pub package. Basically, the pain points that should be solved have been solved, and there is no problem in actual business **

## Effect

- [Click me to experience it](https://cnad666.github.io/flutter_use/web/index.html#/smartDialog)

![smartDialog](https://cdn.jsdelivr.net/gh/CNAD666/MyData/pic/flutter/blog/20201204145311.gif)

## Introduction

- **Pub**: [View flutter_smart_dialog plug- in version](https://pub.flutter- io.cn/packages/flutter_smart_dialog/install)

```dart
dependencies:
  flutter_smart_dialog: any
```

## Use

- Main entrance configuration
  - It needs to be configured in the main entrance, so that you can use Dialog without passing BuildContext
  - You only need to configure it in the builder parameters of MaterialApp

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
    - false: non- default disappearing type, multiple clicks, the toast will be displayed after the former toast
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
  - Use the SmartDialog.show() method, which contains many parameters with a suffix of'Temp', which are consistent with the following parameters without the suffix of'Temp'
  - Special attribute `isUseExtraWidget`: whether to use an additional overlay floating layer, it can be separated from the main floating layer; it can be separated from loading, dialog, etc. The built- in showToast turns on this configuration and can coexist with loading

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
| - - - - - - - - - - - - - - - - -  | - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  |
| alignment | Control the position of the custom control on the screen<br/>**Alignment.center**: The custom control is located in the middle of the screen, and the animation defaults to: fade and zoom, you can use isLoading to select the animation<br/> **Alignment.bottomCenter, Alignment.bottomLeft, Alignment.bottomRight**: The custom control is located at the bottom of the screen, the animation defaults to displacement animation, bottom- up, you can use animationDuration to set the animation time<br/>**Alignment.topCenter, Alignment.topLeft, Alignment.topRight**: The custom control is located at the top of the screen, and the animation defaults to displacement animation. From top to bottom, you can use animationDuration to set the animation time<br/>**Alignment.centerLeft**: The custom control is located at On the left side of the screen, the animation defaults to displacement animation, from left to right, you can use animationDuration to set the animation time<br/> **Alignment.centerRight**: The custom control is located on the left side of the screen, and the animation defaults to displacement animation, from right to left. You can use animationDuration to set the animation time |
| isPenetrate | Default: false; whether to penetrate the background of the mask, control after interactive mask, true: click to penetrate the background, false: not penetrate; set the penetration mask to true, the background mask will automatically become transparent (Required) |
| clickBgDismiss | Default: true; click the mask, whether to close the dialog- - - true: click the mask to close the dialog, false: not close |
| maskColor | Mask color |
| animationDuration | Animation time |
| isUseAnimation | Default: true; whether to use animation |
| isLoading | Default: true; whether to use Loading animation; true: use fade animation for content body false: use zoom animation for content body, only for the middle position control |
| isExist | Default: false; Whether the main SmartDialog (OverlayEntry) exists on the interface |
| isExistExtra | Default: false; whether additional SmartDialog (OverlayEntry) exists on the interface |

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

- **Return to the event, close the pop- up window solution**

There is basically a problem when using Overlay's dependency library. It is difficult to monitor the return event, which makes it difficult to close the pop- up window layout when the return event is violated. After thinking of many ways, there is no way to solve the problem in the dependency library. Here is one `BaseScaffold`, use `BaseScaffold` on each page to solve the problem of closing Dialog in return event

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
        this.resizeToAvoidBottomPadding,
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
    }): assert(primary != null),
    assert(extendBody != null),
    assert(extendBodyBehindAppBar != null),
    assert(drawerDragStartBehavior != null),
    super(key: key);

    ///Properties of System Scaffold
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
    final bool resizeToAvoidBottomPadding;
    final bool resizeToAvoidBottomInset;
    final bool primary;
    final DragStartBehavior drawerDragStartBehavior;
    final double drawerEdgeDragWidth;
    final bool drawerEnableOpenDragGesture;
    final bool endDrawerEnableOpenDragGesture;

    ///Added attributes
    ///Click the back button to prompt whether to exit the page, click twice quickly to exit the page
    final bool isTwiceBack;

    ///Is it possible to return
    final bool isCanBack;

    ///Monitor return event
    final ScaffoldParamVoidCallback onBack;

    @override
    _BaseScaffoldState createState() => _BaseScaffoldState();
}

class _BaseScaffoldState extends State<BaseScaffold> {
    //Last click time
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
                resizeToAvoidBottomPadding: widget.resizeToAvoidBottomPadding,
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

    ///Control back button
    Future<bool> _dealWillPop() async {
        if (widget.onBack != null) {
            widget.onBack();
        }

        //Handle popup issues
        if (SmartDialog.instance.config.isExist) {
            SmartDialog.dismiss();
            return false;
        }

        //If you can't return, the logic behind will not go
        if (!widget.isCanBack) {
            return false;
        }

        if (widget.isTwiceBack) {
            if (_lastPressedAt == null ||
                DateTime.now().difference(_lastPressedAt)> Duration(seconds: 1)) {
                //The time between two clicks exceeds 1 second
                _lastPressedAt = DateTime.now();

                //Pop up prompt
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

