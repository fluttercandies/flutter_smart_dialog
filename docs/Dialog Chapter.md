# Dialog articles

## bells and whistles

> The dialog pops up from different positions, and the animation is different

![image-20211031221419600](https://raw.githubusercontent.com/xdd666t/MyData/master/pic/flutter/blog/20220103224824.png)

- alignment: If this parameter is set differently, the animation effect will be different

````dart
void _dialogLocation() async {
  locationDialog({
    required AlignmentGeometry alignment,
    double width = double.infinity,
    double height = double.infinity,
  }) async {
    SmartDialog.show(
      alignment: alignment,
      builder: (_) => Container(width: width, height: height, color: randomColor()),
    );
    await Future.delayed(Duration(milliseconds: 500));
  }

  //left
  await locationDialog(width: 70, alignment: Alignment.centerLeft);
  //top
  await locationDialog(height: 70, alignment: Alignment.topCenter);
  //right
  await locationDialog(width: 70, alignment: Alignment.centerRight);
  //bottom
  await locationDialog(height: 70, alignment: Alignment.bottomCenter);
  //center
  await locationDialog(height: 100, width: 100, alignment: Alignment.center);
}
````

![dialogLocation](https://raw.githubusercontent.com/xdd666t/MyData/master/pic/flutter/blog/20220103224832.gif)

- usePenetrate: Interaction events penetrate the mask

````dart
SmartDialog.show(
  alignment: Alignment.centerRight,
  usePenetrate: true,
  clickMaskDismiss: false,
  builder: (_) {
    return Container(
      width: 80,
      height: double.infinity,
      color: randomColor(),
    );
  },
);
````

![dialogPenetrate](https://raw.githubusercontent.com/xdd666t/MyData/master/pic/flutter/blog/20220103224839.gif)

## dialog stack

- This is a powerful and practical function: you can easily close a pop-up window at a fixed point

````dart
void _dialogStack() async {
  stackDialog({
    required AlignmentGeometry alignment,
    required String tag,
    double width = double.infinity,
    double height = double.infinity,
  }) async {
    SmartDialog.show(
      tag: tag,
      alignment: alignment,
      builder: (_) {
        return Container(
          width: width,
          height: height,
          color: randomColor(),
          alignment: Alignment.center,
          child: Text('dialog $tag', style: TextStyle(color: Colors.white)),
        );
      },
    );
    await Future.delayed(Duration(milliseconds: 500));
  }

  //left
  await stackDialog(tag: 'A', width: 70, alignment: Alignment.centerLeft);
  //top
  await stackDialog(tag: 'B', height: 70, alignment: Alignment.topCenter);
  //right
  await stackDialog(tag: 'C', width: 70, alignment: Alignment.centerRight);
  //bottom
  await stackDialog(tag: 'D', height: 70, alignment: Alignment.bottomCenter);

  //center: the stack handler
  SmartDialog.show(
    alignment: Alignment.center,
    builder: (_) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
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
      );
    },
  );
}
````

![dialogStack](https://raw.githubusercontent.com/xdd666t/MyData/master/pic/flutter/blog/20220103224848.gif)
