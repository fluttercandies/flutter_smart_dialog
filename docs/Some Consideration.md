# Questions you may have

When initializing the framework, compared to before, I actually asked everyone to write one more parameter (without setting the custom default toast and loading styles), I feel very guilty 😩

Closing a page is inherently a more complex situation involving

- Physical return button
- AppBar's back button
- Manual pop

In order to monitor these situations, a route monitoring parameter was added as a last resort.

> **Entity return key**

The monitoring of the return button is very important and can basically cover most situations

![initBack](https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20220103224708.gif)

> **pop route**

Although the monitoring of the return button can cover most scenarios, some manual pop scenarios require additional parameter monitoring

- do not add `FlutterSmartDialog.observer`
  - If the penetration parameter is turned on (you can interact with the page after the pop-up window), then manually close the page
  - This is an embarrassing situation

![initPopOne](https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20220103225804.gif)

- Add `FlutterSmartDialog.observer`, it can be handled reasonably
  - Of course, the transition animation here also provides parameter control whether to enable 😉

![initPopTwo](https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20220103225825.gif)

> **About FlutterSmartDialog.init()**

This method will not occupy your builder parameters. The builder is called back from init, and you can continue to use it with confidence.

- For example: continue to set Bloc global instance 😄

````dart
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
````

> **Super useful parameter: backDismiss**

- This parameter is set to true by default, and the pop-up window will be closed by default when returning; if it is set to false, the page will not be closed
  - This makes it very easy to make an emergency pop-up window that prohibits the user's next action
- Let's look at a scenario: Suppose an open source author decides to abandon the software and does not allow users to use the software's pop-up window

````dart
SmartDialog.show(
  backDismiss: false,
  clickMaskDismiss: false,
  builder: (_) {
    return Container(
      height: 480,
      width: 500,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        child: Wrap(
          direction: Axis.vertical,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 10,
          children: [
            // title
            Text(
              'Extraordinary announcement',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            // content
            Text('I studied the following cheats day and night, and finally managed to catch a rich woman'),
            Image.network(
              'https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20211102213746.jpeg',
              height: 200,
              width: 400,
            ),
            Text('I thought about it for three seconds, and with a \'heavy\' mind, decided to abandon this open source software'),
            Text('My future life is a rich woman and a distant place, I have no \'energy\' to maintain this open source software'),
            Text('Everyone's hair, goodbye in the rivers and lakes!'),
            // button (only method of close the dialog)
            ElevatedButton(
              onPressed: () => SmartDialog.dismiss(),
              child: Text('Goodbye!'),
            )
          ],
        ),
      ),
    );
  },
);
````

![hardClose](https://cdn.jsdelivr.net/gh/xdd666t/MyData@master/pic/flutter/blog/20220103225957.gif)

It can be seen from the above renderings that

- Click on the mask to close the popup
- Clicking the back button does not close the popup
- Only click our own button to close the pop-up window. The logic of clicking the button can be directly written as closing the app, etc.

Only two simple parameter settings are needed to achieve such a great emergency pop-up window

> **Set global parameters**

The global parameters of SmartDialog have a reasonable default value

In order to cope with changing scenarios, you can modify the global parameters that meet your own requirements

- Set the data that meets your requirements, put it in the app entry and initialize it
  - Note: If there are no special requirements, you can not initialize global parameters (there are default values inside)

````dart
SmartDialog.config
  ..custom = SmartConfigCustom()
  ..attach = SmartConfigAttach()
  ..loading = SmartConfigLoading()
  ..toast = SmartConfigToast();
````

- The comments of the code are very well written. If you don't understand a certain parameter, just click in and take a look.
