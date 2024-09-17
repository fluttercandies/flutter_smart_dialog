import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:visibility_detector/visibility_detector.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
      navigatorObservers: [FlutterSmartDialog.observer],
      builder: FlutterSmartDialog.init(), //这里注释掉就不会有问题
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final int _counter = 0;

  void _incrementCounter() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Page1()),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("rebuild");
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: VisibilityDetector(
              key: const Key("rec"),
              onVisibilityChanged: (VisibilityInfo visibilityInfo) {
                var visiblePercentage = visibilityInfo.visibleFraction * 100;
                if (visiblePercentage == 100.0) {
                  debugPrint("推荐页面111");
                }
              },
              child: PageView(
                physics: const NeverScrollableScrollPhysics(),
                children: <Widget>[
                  VisibilityDetector(
                    key: const Key("reca"),
                    onVisibilityChanged: (VisibilityInfo visibilityInfo) {
                      var visiblePercentage =
                          visibilityInfo.visibleFraction * 100;
                      if (visiblePercentage == 100.0) {
                        debugPrint("首页首页");
                      }
                    },
                    child: SizedBox(
                      width: 300,
                      // color: Colors.red,
                      child: Column(
                        children: [
                          const Text(
                            'You have pushed the button this many times:',
                          ),
                          InkWell(
                            onTap: () {
                              _incrementCounter();
                            },
                            child: const Text("dfdfd"),
                          )
                        ],
                      ),
                    ),
                  ),
                  Text(
                    '$_counter',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
            ),
          ),
          Container(width: 200, height: 40, color: Colors.red)
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class Page1 extends StatelessWidget {
  const Page1({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return PageView(
      children: const [
        Center(
          child: Text(
            "page1",
            style: TextStyle(color: Colors.red),
          ),
        )
      ],
    );
  }
}
