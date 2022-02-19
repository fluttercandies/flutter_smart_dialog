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
