# flutter_smart_dialog

Language: [English](https://github.com/CNAD666/flutter_smart_dialog/blob/master/docs/README-ZH.md) | [中文简体](https://github.com/CNAD666/flutter_smart_dialog/blob/master/docs/README-ZH.md)

An elegant Flutter Dialog solution.

# Preface

The Dialog that comes with the system actually pushes a new page, which has many advantages, but there are also some difficult problems to solve.

- **BuildContext is required.**

- - loading pop-up windows are generally encapsulated in the network framework, so it is troublesome to pass more context parameters. It is good to use fish_redux, and the context can be directly obtained at the effect layer, if you use **, you must upload the context to** or cubit in the view layer...

- **Unable to penetrate the dark background. Click the control behind the dialog box.**

- - This is really a headache. I have thought a lot of ways and haven't solved it on my own dialog box.

- **The Loading pop-up window written by the system comes with a Dialog box. In the case of network requests and jump pages, routing confusion may occur.**

- - Scenario Replay: The loading Library is encapsulated in the network layer. After a form is submitted on a page, the page is redirected. After the submission is completed, the page is redirected, loading is closed in an asynchronous callback (onError or onSuccess). When a jump operation is performed, the pop-up window is not closed. The delay is a little while, because the pop-up method is used, will pop up the redirected page
  - The above is a very common scenario, which is more difficult to predict when it comes to complex scenarios. The solution is as follows: locate whether the stack top of the page stack is a Loading Pop-up window, and select Pop-up, which is troublesome to implement.

`These pain points are all fatal`. Of course, there are other solutions, such:

- Top-level Stack usage for each page
- Use Overlay

Obviously, using Overlay is the best portability. Currently, many Toast and dialog third-party libraries use this solution, using some loading libraries, looking at the source code, penetrating the background solution, different from the expected effect, some dialog libraries have their own toast display, but toast display cannot coexist with dialog (toast is a special information display and should exist independently), I need to rely on one more Toast Library.

#  SmartDialog

**Based on the above problems that are difficult to solve, we can only implement them ourselves. It took some time to implement a Pub package. Basically, the pain points that should be solved have been solved, and there is no problem in actual business.**

##  Effect

- [Let me experience it](https://cnad666.github.io/flutter_use/web/index.html#/smartDialog)

![smartDialog](https://cdn.jsdelivr.net/gh/CNAD666/MyData/pic/flutter/blog/20201204145311.gif)

##  Introduced

```
dependencies:
  flutter_smart_dialog: ^0.1.6
```

##  Use

- Main portal configuration

- - You need to configure it at the main entrance so that you can use Dialog without passing BuildContext.
  - You only need to configure the builder parameter of MaterialApp

```
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

Use `FlutterSmartDialog` Wrap the child, and then you can use SmartDialog happily.

- Use Toast

- - msg: required information
  - time: Optional. The Duration type.
  - alignment: the toast position can be controlled.
  - If you want to use the fancy Toast effect in flowers, you can use the show method to customize it. It is easy to fry chicken. I am too lazy to write it. Copy my ToastWidget and change the properties.

```
SmartDialog.instance.showToast('test toast');
```

- Use Loading

```
//open loading
SmartDialog.instance.showLoading();

//delay off
await Future.delayed(Duration(seconds: 2));
SmartDialog.instance.dismiss();
```

- Custom dialog box

- - Use the SmartDialog.instance.show() method, which contains many parameters with the suffix 'Temp', which is consistent with the following parameters without the suffix 'Temp '.

```
SmartDialog.instance.show(
    alignmentTemp: Alignment.bottomCenter,
    clickBgDismissTemp: true,
    widget: Container(
      color: Colors.blue,
      height: 300,
    ),
);
```

- SmartDialog configuration parameters

| Parameter         | Description                                                  |
| ----------------- | ------------------------------------------------------------ |
| Alignment         | Controls the Alignment of custom controls on the screen. center: The custom control is located in the middle of the screen, and the animation defaults to fade and zoom. You can use isLoading to select animation<br/>Alignment.bottomCenter, Alignment.bottomLeft, Alignment.bottomRight: The custom control is located at the bottom of the screen. The animation defaults to displacement animation. From bottom to top, you can use animationDuration to set animation time<br/>Alignment.topCenter, Alignment.topLeft, Alignment.topRight: The custom control is located at the top of the screen. The animation defaults to displacement animation. From top to bottom, you can use animationDuration to set animation time<br/>Alignment.centerLeft: The custom control is located on the left side of the screen. By default, the animation is a displacement animation from left to right. You can use animationDuration to set the animation time<br/>Alignment.centerRight: The custom control is located on the left side of the screen. By default, the animation is a displacement animation from right to left. You can use animationDuration to set the animation time. |
| isPenetrate       | Default value: false; Specifies whether to penetrate the background of the mask. The control after the interaction mask. true: click to penetrate the background. false: cannot penetrate. Set the penetration mask to true, the background mask is automatically transparent (required) |
| clickBgDismiss    | Default value: false; Click mask to close the dialog --- true: click mask to close the dialog. false: Do not close the dialog. |
| maskColor         | Mask color                                                   |
| animationDuration | Animation time                                               |
| isUseAnimation    | Default value: true. Specifies whether to use animation.     |
| isLoading         | Default value: true; Whether to use the Loading animation; true: the content body uses the fade animation false: the content body uses the zoom animation, only for the control in the middle position |
| isExist           | Default value: false; Whether the main body SmartDialog(OverlayEntry) exists on the interface |
| isExistExtra      | Default value: false. Indicates whether the extra SmartDialog(OverlayEntry) exists on the interface |