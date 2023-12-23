import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () => _show(),
            child: const Text('show'),
          ),
        ),
      ),
      navigatorObservers: [FlutterSmartDialog.observer],
      builder: FlutterSmartDialog.init(),
    );
  }

  void _show() {
    SmartDialog.show(
      animationTime: const Duration(milliseconds: 3000),
      animationBuilder: (
        AnimationController controller,
        Widget child,
        AnimationParam animationParam,
      ) {
        return CustomAnimation(animationParam: animationParam, child: child);
      },
      builder: (_) {
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.all(30),
          child: const Text('custom animation dialog'),
        );
      },
    );
  }
}

class CustomAnimation extends StatefulWidget {
  const CustomAnimation({
    Key? key,
    required this.child,
    required this.animationParam,
  }) : super(key: key);

  final Widget child;

  final AnimationParam animationParam;

  @override
  State<CustomAnimation> createState() => _CustomAnimationState();
}

class _CustomAnimationState extends State<CustomAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  var needReverse = false;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationParam.animationTime,
    );
    widget.animationParam.onForward = () {
      _controller.value = 0;
      _controller.forward();
    };
    widget.animationParam.onDismiss = () {
      needReverse = true;
      setState(() {});
      _controller.reverse();
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return needReverse
        ? RotationTransition(
            turns:
                CurvedAnimation(parent: _controller, curve: Curves.elasticIn),
            child: widget.child,
          )
        : FadeTransition(
            opacity: CurvedAnimation(
              parent: _controller.view,
              curve: Curves.easeInOut,
            ),
            child: ScaleTransition(
              scale: _controller.drive(
                Tween<double>(begin: 1.5, end: 1.0)
                    .chain(CurveTween(curve: Curves.easeInOut)),
              ),
              child: widget.child,
            ),
          );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
