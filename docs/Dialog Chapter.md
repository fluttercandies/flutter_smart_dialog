# Dialog Chapter

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
