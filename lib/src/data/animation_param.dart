import 'package:flutter/material.dart';

/// example:
///
/// ```dart
/// SmartDialog.show(
///   animationTime: const Duration(milliseconds: 3000),
///   animationBuilder: (
///     AnimationController controller,
///     Widget child,
///     AnimationParam animationParam,
///   ) {
///     return RotationTransition(
///       turns: CurvedAnimation(parent: controller, curve: Curves.elasticIn),
///       child: child,
///     );
///   },
///   builder: (_) {
///     return Container(
///       color: Colors.white,
///       padding: const EdgeInsets.all(30),
///       child: const Text('custom animation dialog'),
///     );
///   },
/// );
/// ```
typedef AnimationBuilder = Widget Function(
  AnimationController controller,
  Widget child,
  AnimationParam animationParam,
);

/// advanced usage:
///
/// ```dart
/// SmartDialog.show(
///   animationTime: const Duration(milliseconds: 3000),
///   animationBuilder: (
///     AnimationController controller,
///     Widget child,
///     AnimationParam animationParam,
///   ) {
///     return CustomAnimation(child: child, animationParam: animationParam);
///   },
///   builder: (_) {
///     return Container(
///       color: Colors.white,
///       padding: const EdgeInsets.all(30),
///       child: const Text('custom animation dialog'),
///     );
///   },
/// );
///
/// class CustomAnimation extends StatefulWidget {
///   const CustomAnimation({
///     Key? key,
///     required this.child,
///     required this.animationParam,
///   }) : super(key: key);
///
///   final Widget child;
///
///   final AnimationParam animationParam;
///
///   @override
///   State<CustomAnimation> createState() => _CustomAnimationState();
/// }
///
/// class _CustomAnimationState extends State<CustomAnimation>
///     with TickerProviderStateMixin {
///   late AnimationController _controller;
///
///   @override
///   void initState() {
///     _controller = AnimationController(
///       vsync: this,
///       duration: widget.animationParam.animationTime,
///     );
///     widget.animationParam.onForward = () {
///       _controller.value = 0;
///       _controller.forward();
///     };
///     widget.animationParam.onDismiss = () {
///       _controller.reverse();
///     };
///     super.initState();
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return RotationTransition(
///       turns: CurvedAnimation(parent: _controller, curve: Curves.elasticIn),
///       child: widget.child,
///     );
///   }
///
///   @override
///   void dispose() {
///     _controller.dispose();
///     super.dispose();
///   }
/// }
/// ```
class AnimationParam {
  AnimationParam({
    required this.alignment,
    required this.animationTime,
    this.onForward,
    this.onDismiss,
  });

  /// showXxx#alignment
  Alignment alignment;

  /// showXxx#animationTime
  Duration animationTime;

  /// The animation starts callback, indicating that the dialog is about to open;
  /// if you use custom or multiple AnimationControllers, the animation should be run using forward() in this callback
  ///
  /// 动画开始回调, 表示该dialog即将打开; 如果使用自定义或多个AnimationController时,
  /// 应该在此回调中使用forward()运行动画
  VoidCallback? onForward;

  /// The animation end callback, indicates that the dialog is about to close,
  /// if you use custom or multiple AnimationController, you should use reverse() in this callback to reverse the animation
  ///
  /// 动画结束回调, 表示该dialog即将关闭; 如果使用自定义或多个AnimationController时,
  /// 应该在此回调中使用reverse()反转运行动画
  VoidCallback? onDismiss;
}
