# Toast Chapter

## The particularity of toast

Strictly speaking, toast is a very special pop-up window, I think it should have the following characteristics

> **Toast messages should be displayed one by one, and subsequent messages should not top off the previous toast**

- This is a pit. If the inside of the frame is not processed, it is easy to cause the toast in the back to directly top off the toast in the front
  - Of course, the type parameter is provided internally, you can choose the display logic you want


![toastOne](https://raw.githubusercontent.com/xdd666t/MyData/master/pic/flutter/blog/20220103225022.gif)

> **Displayed on the top layer of the page, should not be blocked by some pop-up windows and the like**

- It can be found that the layout of loading and dialog masks, etc., do not block the toast information

![toastTwo](https://raw.githubusercontent.com/xdd666t/MyData/master/pic/flutter/blog/20220103225028.gif)

> **Handle the keyboard occlusion situation**

- The keyboard is a bit pitted, it will directly block all layouts, and it can only save the country with curves
  - A special treatment is made here, when the keyboard is invoked, the toast will dynamically adjust the distance between itself and the bottom of the screen
  - This will play a role, the keyboard will not block the toast effect

![toastSmart](https://raw.githubusercontent.com/xdd666t/MyData/master/pic/flutter/blog/20211103092228.gif)

## Custom Toast

> **Parameter description**

Some parameters of toast are not exposed, only msg is exposed

- For example: toast font size, font color, toast background color, etc., no parameters are provided
  - First, I feel that providing these parameters will make the overall parameter input very large, and the random flowers will gradually enter the charming eyes.
  - The second is that even if I provide a lot of parameters, it may not meet those strange aesthetics and needs
- Based on the above considerations, I directly provided a large number of low-level parameters
  - You can customize the toast as you like
    - Note, not only toast can be customized, such as: success prompt, failure prompt, warning prompt, etc.
    - Toast has done a lot of optimization, the `displayType` parameter allows you to have a variety of display logic, use your imagination
  - Note: the `builder` parameter is used, the `msg` parameter will be invalid

> **More powerful custom toast**

- First, a whole custom toast

````dart
class CustomToast extends StatelessWidget {
  const CustomToast(this.msg, {Key? key}) : super(key: key);

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
````

- use

````dart
SmartDialog.showToast('', builder: (_) => CustomToast('custom toast'));
````

- Effect

![toastCustom](https://raw.githubusercontent.com/xdd666t/MyData/master/pic/flutter/blog/20211103092253.gif)
