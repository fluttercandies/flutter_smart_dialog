import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/widget/helper/smart_overlay_entry.dart';

import '../../../flutter_smart_dialog.dart';
import '../../helper/dialog_proxy.dart';
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
  bool visible = false;

  // bool _visible = false;
  // set visible(bool value) => _visible = value;
  // bool get visible => _visible || !kDebugMode;

  @override
  void initState() {
    widget.controller?._setListener(
      onShow: () {
        setState(() {
          visible = true;
        });
      },
      onDismiss: () => widgetsBinding.addPostFrameCallback((_) {
        setState(() {
          visible = SmartDialog.config.checkExist(dialogTypes: {
            SmartAllDialogType.custom,
            SmartAllDialogType.attach,
            SmartAllDialogType.notify,
            SmartAllDialogType.loading,
            SmartAllDialogType.toast,
          });

          if (!visible) {
            DialogProxy.instance.entryNotify.remove();
            DialogProxy.instance.entryLoading.remove();
          }
        });
      }),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!visible) {
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
