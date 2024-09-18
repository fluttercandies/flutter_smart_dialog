import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      builder: FlutterSmartDialog.init(),
      navigatorObservers: [FlutterSmartDialog.observer],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: Center(
          child: GestureDetector(
            onTap: () {
              SmartDialog.show(
                tag: '11',
                builder: (context) {
                  return Center(
                    child: Container(
                      height: 300,
                      width: 300,
                      color: Colors.blue,
                    ),
                  );
                },
                animationType: SmartAnimationType.centerFade_otherSlide,
                backType: SmartBackType.normal,
                keepSingle: true,
                debounce: true,
              );
            },
            child: Container(
              width: 200,
              height: 200,
              color: Colors.red,
            ),
          ),
        ),
      ),
    );
  }
}
