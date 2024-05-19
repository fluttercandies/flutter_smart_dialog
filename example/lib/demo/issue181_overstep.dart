import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // home: const _TestingDialog(),
      home: const DialogTestPage(),
      navigatorObservers: [FlutterSmartDialog.observer],
      builder: FlutterSmartDialog.init(),
    );
  }
}

class DialogTestPage extends StatelessWidget {
  const DialogTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          SmartDialog.show(
            clickMaskDismiss: false,
            builder: (_) => const _TestingDialog(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _TestingDialog extends StatefulWidget {
  const _TestingDialog();

  @override
  State<_TestingDialog> createState() => _TestingDialogState();
}

class _TestingDialogState extends State<_TestingDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  Tween<double> tween = Tween(begin: 0, end: 50);

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        animationController.forward();
      });
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            // 这里,点击事件也可以传递到遮罩
            SizedBox(height: MediaQuery.of(context).size.height,width: MediaQuery.of(context).size.width),
            Container(height: 300, color: Colors.blue),
            AnimatedBuilder(
              animation: animationController,
              builder: (_, child) {
                return Transform.translate(
                  offset:
                      Offset(0, -(100 + tween.evaluate(animationController))),
                  child: child,
                );
              },
              child: Container(
                height: 200,
                width: 200,
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        SmartDialog.dismiss();
                        debugPrint("111111111111");
                      },
                      child: const Row(children: [
                        Icon(Icons.close),
                        Text('<-用不了的'),
                      ]),
                    ),
                    InkWell(
                      onTap: () {
                        SmartDialog.dismiss();
                        debugPrint("2222222222222");
                      },
                      child: const Row(children: [
                        Icon(Icons.close),
                        Text('<-能用的'),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
