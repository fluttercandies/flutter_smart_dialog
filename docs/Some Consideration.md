# You may have questions

> **About FlutterSmartDialog.init()**

This method does not take up your builder parameters. The builder is called back in init

- For example: continue to set Bloc global instance 😄

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage,
      navigatorObservers: [FlutterSmartDialog.observer],
      builder: FlutterSmartDialog.init(builder: _builder),
    );
  }
}

Widget _builder(BuildContext context, Widget? child) {
  return MultiBlocProvider(
    providers: [
      BlocProvider.value(value: BlocSpanOneCubit()),
    ],
    child: child!,
  );
}
```

> **Entity Return Key**

The monitoring of the back button is very important and can basically cover most situations

![initBack](https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20211103092132.gif)

> **pop routing**

Although the monitoring of the return button can cover most scenes, some manual pop scenes need to add parameter monitoring

- Do not add `FlutterSmartDialog.observer`
  - If the penetration parameter is turned on (you can interact with the page after the dialog), then manually close the page
  - There will be such an embarrassing situation

![initPopOne](https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20211103092147.gif)

- Add `FlutterSmartDialog.observer`, it can be handled more reasonably

  ![initPopTwo](https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20211103092153.gif)

> **Super practical parameter: backDismiss**

- This parameter is set to `true` by default, and the dialog will be closed by default when returning; if it is set to `false`, the page will not be closed
  - In this way, an emergency dialog can be made very easily, prohibiting the user's next operation
- Let’s look at a scenario: Suppose an open source author decides to abandon the software and does not allow users to use the software’s dialog

![hardClose](https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20211103092201.gif)

> **Set Global Parameters**

you can modify the global parameters that meet your own requirements

```dart
SmartDialog.config
  ..alignment = Alignment.center
  ..isPenetrate = false
  ..clickBgDismiss = true
  ..maskColor = Colors.black.withOpacity(0.35)
  ..maskWidget = null
  ..animationTime = Duration(milliseconds: 260)
  ..isUseAnimation = true
  ..isLoading = true
  ..debounce = false
  ..debounceTime = Duration(milliseconds: 300);
```
