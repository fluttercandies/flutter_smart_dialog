import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const DemoPage(),
      navigatorObservers: [FlutterSmartDialog.observer],
      builder: FlutterSmartDialog.init(),
    );
  }
}

/// @Describe: 测试
///
/// @Author: LiWeNHuI
/// @Date: 2024/6/28

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  /// 构造
  static Widget structure(BuildContext context) {
    return const DemoPage();
  }

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TextButton(onPressed: _show, child: const Text('Test')),
          TextButton(onPressed: _showToast, child: const Text('ShowToast')),
          TextButton(onPressed: _showLoading, child: const Text('ShowLoading')),
        ],
      ),
    );
  }

  Future<void> _showToast() async {
    await SmartDialog.showToast(
      'message',
      alignment: Alignment.center,
      debounce: true,
      displayType: SmartToastType.last,
    );
  }

  Future<void> _showLoading() async {
    await SmartDialog.showLoading<void>(
      maskColor: Colors.transparent,
      clickMaskDismiss: false,
      displayTime: const Duration(milliseconds: 1500),
      backType: SmartBackType.block,
    );
  }

  Future<void> _show() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return Dialog(
          insetPadding:
              const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: PopScope(
            canPop: false,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);

                    SmartDialog.dismiss<void>(status: SmartStatus.toast);
                    SmartDialog.dismiss<void>(status: SmartStatus.loading);

                    SmartDialog.show<void>(
                      builder: (_) => Container(
                        alignment: Alignment.bottomCenter,
                        width: 200,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 24,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xA6000000),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          constraints: const BoxConstraints(maxWidth: 420),
                          margin: const EdgeInsets.fromLTRB(30, 140, 30, 140),
                          child: const Text('Demo'),
                        ),
                      ),
                      clickMaskDismiss: false,
                      animationBuilder: (_, Widget child, ___) =>
                          TestAnimation(animationParam: ___, child: child),
                      displayTime: const Duration(milliseconds: 2300),
                      backType: SmartBackType.block,
                      keepSingle: true,
                    );
                  },
                  child: const Text('Show'),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class TestAnimation extends StatefulWidget {
  const TestAnimation({
    super.key,
    required this.child,
    required this.animationParam,
  });

  /// 子布局
  final Widget child;

  /// 动画参数
  final AnimationParam animationParam;

  @override
  State<TestAnimation> createState() => _TestAnimationState();
}

class _TestAnimationState extends State<TestAnimation>
    with TickerProviderStateMixin {
  /// 缩放+显隐动画控制器
  late AnimationController controller;

  /// 缩放动画
  late Animation<double> _scaleAnimation;

  /// 旋转动画控制器
  late AnimationController bodyController;

  /// 旋转动画是否开始
  bool isStart = false;

  @override
  void initState() {
    controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..addListener(() {
        if (controller.value > .3 && !isStart) {
          isStart = true;

          bodyController.forward();
        }
      });

    bodyController = AnimationController(
      duration: const Duration(milliseconds: 8000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: .5, end: 1).animate(controller);

    animationParam
      ..onForward = () {
        controller.forward();
      }
      ..onDismiss = () {
        controller.reverse();
      };

    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    bodyController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        FadeTransition(
          opacity: CurvedAnimation(parent: controller, curve: Curves.linear),
          child: ScaleTransition(scale: _scaleAnimation, child: _buildBody),
        ),
        widget.child,
      ],
    );
  }

  Widget get _buildBody {
    final Stack child = Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      children: <Widget>[
        RotationTransition(
          turns: CurvedAnimation(parent: bodyController, curve: Curves.linear),
          child: const FlutterLogo(size: 120),
        ),
      ],
    );

    return Container(constraints: const BoxConstraints.expand(), child: child);
  }

  AnimationParam get animationParam => widget.animationParam;
}
