[![pub](https://img.shields.io/pub/v/flutter_smart_dialog?label=pub&logo=dart)](https://pub.flutter-io.cn/packages/flutter_smart_dialog/install) [![stars](https://img.shields.io/github/stars/fluttercandies/flutter_smart_dialog?logo=github)](https://github.com/fluttercandies/flutter_smart_dialog)  [![issues](https://img.shields.io/github/issues/fluttercandies/flutter_smart_dialog?logo=github)](https://github.com/fluttercandies/flutter_smart_dialog/issues) [![commit](https://img.shields.io/github/last-commit/fluttercandies/flutter_smart_dialog?logo=github)](https://github.com/fluttercandies/flutter_smart_dialog/commits)

Language:  English | [中文](https://juejin.cn/post/7026150456673959943)

# Introduction

An elegant Flutter Dialog solution.

- [pub](https://pub.flutter-io.cn/packages/flutter_smart_dialog)，[github](https://github.com/fluttercandies/flutter_smart_dialog)，[web effect](https://xdd666t.github.io/flutter_use/web/index.html#/smartDialog)

# Some Effect

![attachLocationAndPoint](https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20220103160140.gif)

![attachHighlight](https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20220103160210.gif)

![dialogStack](https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20211216222718.gif)

![loadingSmile](https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20211103092359.gif)

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
  ..animationDuration = Duration(milliseconds: 260)
  ..isUseAnimation = true
  ..isLoading = true
  ..antiShake = false
  ..antiShakeTime = Duration(milliseconds: 300);
```

# Attach Chapter

This is a very important function. I wanted to add it a long time ago, but it was busy and has been shelved; New Year's Day (2022.1.1) started, and it took some time to complete this function and related demos.

## position

It is not difficult to locate the coordinates of the target widget; however, we must get the size of the custom widget that we passed in, so that the custom widget can be stacked to a more appropriate position of the target widget (by some calculations, get the center point)

- In fact, Flutter provides a very suitable component `CustomSingleChildLayout`, this component also provides offset coordinate function, logically very suitable
- However, `CustomSingleChildLayout` and `SizeTransition` animation controls have a footprint conflict, so you can only use the `AnimatedOpacity` fade animation
- Displacement animation can't be used, I can't bear it, I abandon `CustomSingleChildLayout`; after using various operations, I finally get the size of the custom widget, which achieves the effect perfectly

**Locate the dialog, use the showAttach method, the parameter comments are written in quite detail, if you don’t understand the usage, just look at the comments**

> **Powerful positioning function**

- The BuildContext of the target widget must be passed, and the coordinates and size of the target widget need to be calculated through this

```dart
var attach = (BuildContext context, AlignmentGeometry alignment) async {
  SmartDialog.showAttach(
    targetContext: context,
    isPenetrateTemp: true,
    alignmentTemp: alignment,
    clickBgDismissTemp: false,
    widget: Container(width: 100, height: 100, color: randomColor()),
  );
  await Future.delayed(Duration(milliseconds: 350));
};

//target widget
List<BuildContext> contextList = [];
List<Future Function()> funList = [
  () async => await attach(contextList[0], Alignment.topLeft),
  () async => await attach(contextList[1], Alignment.topCenter),
  () async => await attach(contextList[2], Alignment.topRight),
  () async => await attach(contextList[3], Alignment.centerLeft),
  () async => await attach(contextList[4], Alignment.center),
  () async => await attach(contextList[5], Alignment.centerRight),
  () async => await attach(contextList[6], Alignment.bottomLeft),
  () async => await attach(contextList[7], Alignment.bottomCenter),
  () async => await attach(contextList[8], Alignment.bottomRight),
];
var btn = ({
  required String title,
  required Function(BuildContext context) onTap,
}) {
  return Builder(builder: (context) {
    Color? color = title.contains('all') ? randomColor() : null;
    contextList.add(context);
    return Container(
      width: 130,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: ButtonStyleButton.allOrNull<Color>(color),
        ),
        onPressed: () => onTap(context),
        child: Text('$title'),
      ),
    );
  });
};

SmartDialog.show(
  isLoadingTemp: false,
  widget: Container(
    width: 700,
    padding: EdgeInsets.all(70),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: Colors.white,
    ),
    child: Wrap(
      spacing: 50,
      runSpacing: 50,
      alignment: WrapAlignment.spaceEvenly,
      children: [
        btn(title: 'topLeft', onTap: (context) => funList[0]()),
        btn(title: 'topCenter', onTap: (context) => funList[1]()),
        btn(title: 'topRight', onTap: (context) => funList[2]()),
        btn(title: 'centerLeft', onTap: (context) => funList[3]()),
        btn(title: 'center', onTap: (context) => funList[4]()),
        btn(title: 'centerRight', onTap: (context) => funList[5]()),
        btn(title: 'bottomLeft', onTap: (context) => funList[6]()),
        btn(title: 'bottomCenter', onTap: (context) => funList[7]()),
        btn(title: 'bottomRight', onTap: (context) => funList[8]()),
        btn(
          title: 'allOpen',
          onTap: (_) async {
            for (var item in funList) {
              await item();
            }
          },
        ),
        btn(
          title: 'allClose',
          onTap: (_) => SmartDialog.dismiss(status: SmartStatus.allAttach),
        ),
      ],
    ),
  ),
);
```

![attachLocation](https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20220103161314.gif)

- The animation effect and the show method are almost the same. For this consistent experience, a lot of targeted optimizations have been made internally

> **Custom coordinate points**

- In most cases, targetContext is basically used

```dart
SmartDialog.showAttach(
  targetContext: context,
  widget: Container(width: 100, height: 100, color: Colors.red),
);
```

- Of course, there are a few cases where custom coordinates need to be used. The target parameter is also provided here: if the target parameter is set, the targetContext will automatically become invalid
  - targetContext is very common to the scene, so it is set here as a required parameter, but you can set it to null

```dart
SmartDialog.showAttach(
  targetContext: null,
  target: Offset(100, 100);,
  widget: Container(width: 100, height: 100, color: Colors.red),
);
```

- It seems that the effect of custom coordinate points

```dart
var attach = (Offset offset) {
  var random = Random().nextInt(100) % 5;
  var alignment = Alignment.topCenter;
  if (random == 0) alignment = Alignment.topCenter;
  if (random == 1) alignment = Alignment.centerLeft;
  if (random == 2) alignment = Alignment.center;
  if (random == 3) alignment = Alignment.centerRight;
  if (random == 4) alignment = Alignment.bottomCenter;
  SmartDialog.showAttach(
    targetContext: null,
    target: offset,
    isPenetrateTemp: true,
    clickBgDismissTemp: false,
    alignmentTemp: alignment,
    keepSingle: true,
    widget: ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(width: 100, height: 100, color: randomColor()),
    ),
  );
};

SmartDialog.show(
  isLoadingTemp: false,
  widget: Container(
    width: 600,
    height: 400,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: Colors.white,
    ),
    child: GestureDetector(
      onTapDown: (detail) => attach(detail.globalPosition),
      child: Container(
        width: 500,
        height: 300,
        color: Colors.grey,
        alignment: Alignment.center,
        child: Text('click me', style: TextStyle(color: Colors.white)),
      ),
    ),
  ),
);
```

![attachPoint](https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20220103161412.gif)

> **Imitate DropdownButton**

- Actually imitating DropdownButton is not easy

  - First calculate the position of the DropdownButton control, and display the clicked fold control on its position
  - Need to handle the click event of the area outside the DropdownButton (click outside the area to close the DropdownButton)

  - You also need to listen to the return event and manually pop the routing event; for this type of event, you need to turn off the DropdownButton

- This thing needs to be customized, which is quite daunting; however, now you can use `SmartDialog.showAttach` to imitate one easily, and the above matters needing attention are all taken care of for you

```dart
//模仿DropdownButton
var imitate = (BuildContext context) {
  var list = ['小呆呆', '小菲菲', '小猪猪'];
  SmartDialog.showAttach(
    targetContext: context,
    isPenetrateTemp: true,
    widget: Container(
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, spreadRadius: 0.2)
        ],
      ),
      child: Column(
        children: List.generate(list.length, (index) {
          return Material(
            color: Colors.white,
            child: InkWell(
              onTap: () => SmartDialog.dismiss(),
              child: Container(
                height: 50,
                width: 100,
                alignment: Alignment.center,
                child: Text('${list[index]}'),
              ),
            ),
          );
        }),
      ),
    ),
  );
};

//imitate widget
var dropdownButton = ({String title = 'Dropdown'}) {
  return DropdownButton<String>(
    value: '1',
    items: [
      DropdownMenuItem(value: '1', child: Text('$title：小呆呆')),
      DropdownMenuItem(value: '2', child: Text('小菲菲')),
      DropdownMenuItem(value: '3', child: Text('小猪猪'))
    ],
    onChanged: (value) {},
  );
};
var imitateDropdownButton = () {
  return Builder(builder: (context) {
    return Stack(children: [
      dropdownButton(title: 'Attach'),
      GestureDetector(
        onTap: () => imitate(context),
        child: Container(height: 50, width: 140, color: Colors.transparent),
      )
    ]);
  });
};
SmartDialog.show(
  isLoadingTemp: false,
  widget: Container(
    width: 600,
    height: 400,
    alignment: Alignment.center,
    padding: EdgeInsets.symmetric(horizontal: 100),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: Colors.white,
    ),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [dropdownButton(), imitateDropdownButton()],
      ),
    ),
  ),
);
```

![attachImitate](https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20220103161431.gif)

## Highlight

This time, the function of highlighting a specific area of the mask has been added, which is a very practical function!

- You only need to set the `highlight` parameter

  - Define the highlighted area, it must be an impenetrable Widget, such as Contaienr, and a color must be set (the color value is not required)
    - It is also possible to use all kinds of weird pictures, so that you can display the highlighted areas of various complex graphics

  - The highlight type is Positioned, you can position the area that needs to be highlighted on the screen arbitrarily


```dart
SmartDialog.showAttach(
  targetContext: context,
  alignmentTemp: Alignment.bottomCenter,
  highlight: Positioned(
    right: 190,
    bottom: 190,
    child: Container(
      height: 120,
      width: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
    ),
  ),
  widget: Container(width: 100, height: 100, color: Colors.red),
);
```

> **Actual business scenario**

- Here are two common examples. The code is a little bit too much, so I won’t post it. If you’re interested, please check it out：[flutter_use](https://github.com/xdd666t/flutter_use)

![attachBusiness](https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20220103161437.gif)

The above two business scenarios are very common, we need the target widget above or below or a specific area, not covered by a mask

If you do it yourself, you can make it, but it will be very troublesome; now you can use the `highlight` parameter in `showAttach` to easily achieve this requirement

> **Guide Operation**

Guided operation is still very common on the app, you need to highlight the designated area, and then introduce its function

- Using the `highlight` parameter in `showAttach`, this requirement can also be easily achieved, let's see the effect
  - The code is also a little bit more, if you are interested, please check: [flutter_use](https://github.com/xdd666t/flutter_use)

![attachGuide](https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20220103161443.gif)

# Dialog

## Fancy

- alignmentTemp: The animation effect will be different if the parameter setting is different

```dart
var location = ({
  double width = double.infinity,
  double height = double.infinity,
}) {
  return Container(width: width, height: height, color: randomColor());
};

//left
SmartDialog.show(
  widget: location(width: 70),
  alignmentTemp: Alignment.centerLeft,
);
await Future.delayed(Duration(milliseconds: 500));
//top
SmartDialog.show(
  widget: location(height: 70),
  alignmentTemp: Alignment.topCenter,
);
await Future.delayed(Duration(milliseconds: 500));
//right
SmartDialog.show(
  widget: location(width: 70),
  alignmentTemp: Alignment.centerRight,
);
await Future.delayed(Duration(milliseconds: 500));
//bottom
SmartDialog.show(
  widget: location(height: 70),
  alignmentTemp: Alignment.bottomCenter,
);
await Future.delayed(Duration(milliseconds: 500));
//center
SmartDialog.show(
  widget: location(height: 100, width: 100),
  alignmentTemp: Alignment.center,
  isLoadingTemp: false,
);
```

![dialogLocation](https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20211103092433.gif)

- isPenetrateTemp: Interaction event penetration mask

```dart
SmartDialog.show(
    alignmentTemp: Alignment.centerRight,
    isPenetrateTemp: true,
    clickBgDismissTemp: false,
    widget: Container(
        width: 80,
        height: double.infinity,
        color: randomColor(),
    ),
);
```

![dialogPenetrate](https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20211103092442.gif)

## dialog stack

- This is a powerful and useful feature!
  - You can easily close a dialog at a fixed point

```dart
var stack = ({
  double width = double.infinity,
  double height = double.infinity,
  String? msg,
}) {
  return Container(
    width: width,
    height: height,
    color: randomColor(),
    alignment: Alignment.center,
    child: Text('dialog $msg', style: TextStyle(color: Colors.white)),
  );
};

//left
SmartDialog.show(
  tag: 'A',
  widget: stack(msg: 'A', width: 70),
  alignmentTemp: Alignment.centerLeft,
);
await Future.delayed(Duration(milliseconds: 500));
//top
SmartDialog.show(
  tag: 'B',
  widget: stack(msg: 'B', height: 70),
  alignmentTemp: Alignment.topCenter,
);
await Future.delayed(Duration(milliseconds: 500));
//right
SmartDialog.show(
  tag: 'C',
  widget: stack(msg: 'C', width: 70),
  alignmentTemp: Alignment.centerRight,
);
await Future.delayed(Duration(milliseconds: 500));
//bottom
SmartDialog.show(
  tag: 'D',
  widget: stack(msg: 'D', height: 70),
  alignmentTemp: Alignment.bottomCenter,
);
await Future.delayed(Duration(milliseconds: 500));

//center：the stack handler
SmartDialog.show(
  alignmentTemp: Alignment.center,
  isLoadingTemp: false,
  widget: Container(
    decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(15)),
    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
    child: Wrap(spacing: 20, children: [
      ElevatedButton(
        child: Text('close dialog A'),
        onPressed: () => SmartDialog.dismiss(tag: 'A'),
      ),
      ElevatedButton(
        child: Text('close dialog B'),
        onPressed: () => SmartDialog.dismiss(tag: 'B'),
      ),
      ElevatedButton(
        child: Text('close dialog C'),
        onPressed: () => SmartDialog.dismiss(tag: 'C'),
      ),
      ElevatedButton(
        child: Text('close dialog D'),
        onPressed: () => SmartDialog.dismiss(tag: 'D'),
      ),
    ]),
  ),
);
```

![dialogStack](https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20211106214858.gif)

# Loading Chapter

## Parameter Description

- maskWidgetTemp: powerful mask customization function😆, use your brain. . .

```dart
var maskWidget = Container(
  width: double.infinity,
  height: double.infinity,
  child: Opacity(
    opacity: 0.6,
    child: Image.network(
      'https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20211101103911.jpeg',
      fit: BoxFit.fill,
    ),
  ),
);
SmartDialog.showLoading(maskWidgetTemp: maskWidget);
```

![loadingOne](https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20211103092313.gif)

- maskColorTemp: support quick custom mask color

```dart
SmartDialog.showLoading(maskColorTemp: randomColor().withOpacity(0.3));

/// random color
Color randomColor() => Color.fromRGBO(
    Random().nextInt(256), Random().nextInt(256), Random().nextInt(256), 1);
```

![loadingTwo](https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20211103092325.gif)

- background: support loading background customization

```dart
SmartDialog.showLoading(background: randomColor());

/// random color
Color randomColor() => Color.fromRGBO(
    Random().nextInt(256), Random().nextInt(256), Random().nextInt(256), 1);
```

![loadingThree](https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20211103092331.gif)

- isLoadingTemp: Animation effect switch

```dart
SmartDialog.showLoading(isLoadingTemp: false);
```

![loadingFour](https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20211103092336.gif)

- isPenetrateTemp: Interaction events can penetrate the mask, which is a very useful function, which is very important for some special demand scenes

```dart
SmartDialog.showLoading(isPenetrateTemp: true);
```

![loadingFive](https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20211103092342.gif)

## Custom Loading

Use `showLoading` to easily customize the powerful loading dialog; I have limited brains, just demonstrate it briefly

> **Customize a loading layout**

```dart
class CustomLoading extends StatefulWidget {
  const CustomLoading({Key? key, this.type = 0}): super(key: key);

  final int type;

  @override
  _CustomLoadingState createState() => _CustomLoadingState();
}

class _CustomLoadingState extends State<CustomLoading>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reset();
        _controller.forward();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      // smile
      Visibility(visible: widget.type == 0, child: _buildLoadingOne()),

      // icon
      Visibility(visible: widget.type == 1, child: _buildLoadingTwo()),

      // normal
      Visibility(visible: widget.type == 2, child: _buildLoadingThree()),
    ]);
  }

  Widget _buildLoadingOne() {
    return Stack(alignment: Alignment.center, children: [
      RotationTransition(
        alignment: Alignment.center,
        turns: _controller,
        child: Image.network(
          'https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20211101174606.png',
          height: 110,
          width: 110,
        ),
      ),
      Image.network(
        'https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20211101181404.png',
        height: 60,
        width: 60,
      ),
    ]);
  }

  Widget _buildLoadingTwo() {
    return Stack(alignment: Alignment.center, children: [
      Image.network(
        'https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20211101162946.png',
        height: 50,
        width: 50,
      ),
      RotationTransition(
        alignment: Alignment.center,
        turns: _controller,
        child: Image.network(
          'https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20211101173708.png',
          height: 80,
          width: 80,
        ),
      ),
    ]);
  }

  Widget _buildLoadingThree() {
    return Center(
      child: Container(
        height: 120,
        width: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        alignment: Alignment.center,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          RotationTransition(
            alignment: Alignment.center,
            turns: _controller,
            child: Image.network(
              'https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20211101163010.png',
              height: 50,
              width: 50,
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 20),
            child: Text('loading...'),
          ),
        ]),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

> **Let's see the effect**

- Effect one

```dart
SmartDialog.showLoading(isLoadingTemp: false, widget: CustomLoading());
await Future.delayed(Duration(seconds: 2));
SmartDialog.dismiss();
```

![loadingSmile](https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20211103092359.gif)

- Effect two

```dart
SmartDialog.showLoading(
    isLoadingTemp: false,
    widget: CustomLoading(type: 1),
);
await Future.delayed(Duration(seconds: 2));
SmartDialog.dismiss();
```

![loadingIcon](https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20211103092408.gif)

- Effect three

```dart
SmartDialog.showLoading(widget: CustomLoading(type: 2));
await Future.delayed(Duration(seconds: 2));
SmartDialog.dismiss();
```

![loadingNormal](https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20211103092413.gif)

# Toast Chapter

## The particularity of toast

Strictly speaking, toast is a very special dialog, I think it should have the following characteristics

> **Toast messages should be displayed one by one, and subsequent messages should not top off the previous toast**

- This is a pit point. If the frame is not processed inside, it is easy to cause the back toast to directly top off the front toast.

![toastOne](https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20211103092214.gif)

> **Displayed on the top level of the page, should not be blocked by some other dialog**

- You can find layouts such as loading and dialog masks, none of which obscures the toast information

![toastTwo](https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20211103092219.gif)

> **Handle the occlusion of the keyboard**

- The keyboard is a bit tricky, it will directly obscure all layouts
  - when the keyboard is awakened, toast will dynamically adjust the distance between itself and the bottom of the screen
- This will have the effect that the keyboard will not block the toast

![toastSmart](https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20211103092228.gif)

## Custom Toast

- First, a custom toast

```dart
class CustomToast extends StatelessWidget {
  const CustomToast(this.msg, {Key? key}): super(key: key);

  final String msg;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: EdgeInsets.only(bottom: 30),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 7),
        decoration: BoxDecoration(
          color: _randomColor(),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          //icon
          Container(
            margin: EdgeInsets.only(right: 15),
            child: Icon(Icons.add_moderator, color: _randomColor()),
          ),

          //msg
          Text('$msg', style: TextStyle(color: Colors.white)),
        ]),
      ),
    );
  }

  Color _randomColor() {
    return Color.fromRGBO(
      Random().nextInt(256),
      Random().nextInt(256),
      Random().nextInt(256),
      1,
    );
  }
}
```

- use

```dart
SmartDialog.showToast('', widget: CustomToast('custom toast'));
```

- Effect

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
