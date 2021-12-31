import 'package:flutter/material.dart';

class AttachDialogWidget extends StatefulWidget {
  const AttachDialogWidget({
    Key? key,
    required this.child,
    required this.duration,
  }) : super(key: key);

  final Duration duration;

  final Widget child;

  @override
  _AttachDialogWidgetState createState() => _AttachDialogWidgetState();
}

class _AttachDialogWidgetState extends State<AttachDialogWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctr;

  @override
  void initState() {
    _ctr = AnimationController(vsync: this, duration: widget.duration);
    _ctr.forward();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      axis: Axis.vertical,
      sizeFactor: CurvedAnimation(parent: _ctr, curve: Curves.linear),
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _ctr.dispose();

    super.dispose();
  }
}
