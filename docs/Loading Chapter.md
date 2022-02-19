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
