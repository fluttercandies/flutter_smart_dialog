import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SmartDialog.config.toast = SmartConfigToast(
      displayType: SmartToastType.last,
    );
    return MaterialApp(
      title: 'NestedScrollView 解决方案',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      builder: FlutterSmartDialog.init(),
      home: const NestedScrollSolution(),
    );
  }
}

class NestedScrollSolution extends StatefulWidget {
  const NestedScrollSolution({super.key});

  @override
  State createState() => _NestedScrollSolutionState();
}

class _NestedScrollSolutionState extends State {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          SmartDialog.showToast("已经是最大回合数");
        },
        child: const Icon(Icons.shopping_cart),
      ),
    );
  }
}
