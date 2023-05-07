import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/util/view_utils.dart';

part 'smart_dialog_controller.dart';

abstract class DialogScopeAction {
  void setController(SmartDialogController? controller);

  void replaceBuilder(Widget? child);
}

class DialogScopeInfo {
  DialogScopeAction? action;
}

class DialogScope extends StatefulWidget {
  DialogScope({
    Key? key,
    required this.controller,
    required this.builder,
  }) : super(key: key);

  final SmartDialogController? controller;

  final WidgetBuilder builder;

  final DialogScopeInfo info = DialogScopeInfo();

  @override
  State<DialogScope> createState() => _DialogScopeState();
}

class _DialogScopeState extends State<DialogScope>
    implements DialogScopeAction {
  VoidCallback? _callback;
  Widget? _child;

  @override
  void initState() {
    widget.info.action = this;
    setController(widget.controller);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _child ?? widget.builder(context);
  }

  @override
  void setController(SmartDialogController? controller) {
    controller?._setListener(_callback = () {
      ViewUtils.addSafeUse(() {
        if (mounted) {
          setState(() {});
        }
      });
    });
  }

  @override
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
