import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/widget/helper/smart_overlay_entry.dart';

import '../../../flutter_smart_dialog.dart';
import '../../helper/dialog_proxy.dart';
import '../../kit/typedef.dart';
import '../../kit/view_utils.dart';

part 'smart_overly_controller.dart';

class SmartOverlay extends StatefulWidget {
  const SmartOverlay({
    Key? key,
    required this.initType,
    this.controller,
  }) : super(key: key);

  final Set<SmartInitType> initType;
  final SmartOverlayController? controller;

  @override
  State<SmartOverlay> createState() => _SmartOverlayState();
}

class _SmartOverlayState extends State<SmartOverlay> {
  bool isDebugModel = /*false*/ kDebugMode;
  bool visible = true;

  @override
  void initState() {
    visible = !isDebugModel;
    if (isDebugModel) {
      widget.controller?._setListener(onShow: onShow, onDismiss: onDismiss);
    }
    super.initState();
  }

  Future<void> onShow() async {
    if (visible) {
      return;
    }

    var completer = Completer();
    ViewUtils.addSafeUse(() {
      setState(() => visible = true);
      completer.complete();
    });
    await completer.future;

    completer = Completer();
    widgetsBinding.addPostFrameCallback((timeStamp) {
      completer.complete();
    });
    await completer.future;
  }

  Future<void> onDismiss() async {
    if (!visible) {
      return;
    }

    var dialogExist = SmartDialog.config.checkExist(dialogTypes: {
      SmartAllDialogType.custom,
      SmartAllDialogType.attach,
      SmartAllDialogType.notify,
      SmartAllDialogType.loading,
      SmartAllDialogType.toast,
    });

    if (!dialogExist) {
      var completer = Completer();
      ViewUtils.addSafeUse(() {
        setState(() => visible = false);
        completer.complete();
      });
      await completer.future;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      DialogProxy.instance.entryNotify.remove();
      DialogProxy.instance.entryLoading.remove();
      return const SizedBox.shrink();
    }

    return Overlay(initialEntries: [
      if (visible)
        SmartOverlayEntry(
          builder: (BuildContext context) {
            if (widget.initType.contains(SmartInitType.custom)) {
              DialogProxy.contextCustom = context;
            }

            if (widget.initType.contains(SmartInitType.attach)) {
              DialogProxy.contextAttach = context;
            }

            if (widget.initType.contains(SmartInitType.notify)) {
              DialogProxy.contextNotify = context;
            }

            if (widget.initType.contains(SmartInitType.toast)) {
              DialogProxy.contextToast = context;
            }

            return const SizedBox.shrink();
          },
        ),

      if (visible && widget.initType.contains(SmartInitType.notify))
        DialogProxy.instance.entryNotify,

      // loading
      if (visible && widget.initType.contains(SmartInitType.loading))
        DialogProxy.instance.entryLoading,
    ]);
  }

  @override
  void dispose() {
    widget.controller?._clearListener();
    super.dispose();
  }
}
