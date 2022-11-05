import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/util/view_utils.dart';

part 'smart_dialog_controller.dart';

class DialogScope extends StatefulWidget {
  DialogScope({
    Key? key,
    required this.controller,
    required this.builder,
  }) : super(key: key);

  final SmartDialogController? controller;

  final WidgetBuilder builder;

  final dialogScopeState = _DialogScopeState();

  @override
  State<DialogScope> createState() => dialogScopeState;
}

class _DialogScopeState extends State<DialogScope> {
  VoidCallback? _callback;
  Widget? _child;

  @override
  void initState() {
    setController(widget.controller);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _child ?? widget.builder(context);
  }

  void setController(SmartDialogController? _controller) {
    _controller?._setListener(_callback = () {
      ViewUtils.addSafeUse(() {
        if (mounted) {
          setState(() {});
        }
      });
    });
  }

  void replaceBuilder(Widget? child) {
    _child = child;
  }

  @override
  void dispose() {
    if (_callback == widget.controller?._callback) {
      widget.controller?._dismiss();
    }

    super.dispose();
  }
}
