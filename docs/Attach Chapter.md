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
