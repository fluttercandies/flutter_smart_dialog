# Loading articles

## Pit Avoidance Guide

- After loading is turned on, it can be turned off using the following methods
  - SmartDialog.dismiss(): can close loading and dialog
  - status is set to SmartStatus.loading: just turn off loading

````dart
// easy close
SmartDialog.dismiss();
// exact close
SmartDialog.dismiss(status: SmartStatus.loading);
````

- Generally speaking, the loading pop-up window is encapsulated in the network library, and automatically opens and closes with the request status
  - Based on this scenario, I suggest: when using dismiss, add the status parameter and set it to: SmartStatus.loading
- pit ratio scene
  - When the network request is loaded, the loading is also turned on. At this time, it is easy to touch the back button by mistake and close the loading
  - When the network request ends, the dismiss method will be called automatically
  - Because loading has been closed, assuming that the page has a SmartDialog pop-up window at this time, dismiss without setting status will close the SmartDialog pop-up window
  - Of course, this situation is easy to solve, encapsulate the loading of the network library, use: `SmartDialog.dismiss(status: SmartStatus.loading);` to close it
- The `status` parameter is a parameter designed to accurately close the corresponding type of pop-up window, which can play a huge role in some special scenarios
  - If you understand the meaning of this parameter, then you must be confident about when to add the `status` parameter

## Parameter Description

The parameters are very detailed in the comments, so I won't go into details, let's see the effect

- maskWidget: Powerful mask customization function 😆, use your brains. . .

````dart
var maskWidget = Container(
  width: double.infinity,
  height: double.infinity,
  child: Opacity(
    opacity: 0.6,
    child: Image.network(
      'https://raw.githubusercontent.com/xdd666t/MyData/master/pic/flutter/blog/20211101103911.jpeg',
      fit: BoxFit.fill,
    ),
  ),
);
SmartDialog.showLoading(maskWidget: maskWidget);
````

![loadingOne](https://raw.githubusercontent.com/xdd666t/MyData/master/pic/flutter/blog/20220103224902.gif)

- maskColor: supports quick custom mask color

````dart
SmartDialog.showLoading(maskColor: randomColor().withOpacity(0.3));

/// random color
Color randomColor() => Color.fromRGBO(Random().nextInt(256), Random().nextInt(256), Random().nextInt(256), 1);
````

![loadingTwo](https://raw.githubusercontent.com/xdd666t/MyData/master/pic/flutter/blog/20220103224910.gif)

- animationType: animation effect switching

````dart
SmartDialog.showLoading(animationType: SmartAnimationType.scale);
````

![loadingFour](https://raw.githubusercontent.com/xdd666t/MyData/master/pic/flutter/blog/20220103224929.gif)

- usePenetrate: Interaction events can penetrate the mask, which is a very useful function and is critical for some special demand scenarios

````dart
SmartDialog.showLoading(usePenetrate: true);
````

![loadingFive](https://raw.githubusercontent.com/xdd666t/MyData/master/pic/flutter/blog/20220103224945.gif)

## Custom Loading

Use `showLoading` to easily customize a powerful loading pop-up window; I have limited brains, so I will simply demonstrate

> **Customize a loading layout**

````dart
class CustomLoading extends StatefulWidget {
  const CustomLoading({Key? key, this.type = 0}) : super(key: key);

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
          'https://raw.githubusercontent.com/xdd666t/MyData/master/pic/flutter/blog/20211101174606.png',
          height: 110,
          width: 110,
        ),
      ),
      Image.network(
        'https://raw.githubusercontent.com/xdd666t/MyData/master/pic/flutter/blog/20211101181404.png',
        height: 60,
        width: 60,
      ),
    ]);
  }

  Widget _buildLoadingTwo() {
    return Stack(alignment: Alignment.center, children: [
      Image.network(
        'https://raw.githubusercontent.com/xdd666t/MyData/master/pic/flutter/blog/20211101162946.png',
        height: 50,
        width: 50,
      ),
      RotationTransition(
        alignment: Alignment.center,
        turns: _controller,
        child: Image.network(
          'https://raw.githubusercontent.com/xdd666t/MyData/master/pic/flutter/blog/20211101173708.png',
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
              'https://raw.githubusercontent.com/xdd666t/MyData/master/pic/flutter/blog/20211101163010.png',
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
````

> **Let's see the effect**

- effect one

````dart
SmartDialog.showLoading(
  animationType: SmartAnimationType.scale,
  builder: (_) => CustomLoading(),
);
await Future.delayed(Duration(seconds: 2));
SmartDialog.dismiss();
````

![loadingSmile](https://raw.githubusercontent.com/xdd666t/MyData/master/pic/flutter/blog/20220103224959.gif)

- Effect two

````dart
SmartDialog.showLoading(
  animationType: SmartAnimationType.scale,
  builder: (_) => CustomLoading(type: 1),
);
await Future.delayed(Duration(seconds: 2));
SmartDialog.dismiss();
````

![loadingIcon](https://raw.githubusercontent.com/xdd666t/MyData/master/pic/flutter/blog/20220103225006.gif)

- Effect three

````dart
SmartDialog.showLoading(builder: (_) => CustomLoading(type: 2));
await Future.delayed(Duration(seconds: 2));
SmartDialog.dismiss();
````

![loadingNormal](https://raw.githubusercontent.com/xdd666t/MyData/master/pic/flutter/blog/20220103225013.gif)
