import 'package:flutter/material.dart';

import '../config/enum_config.dart';
import '../kit/typedef.dart';
import 'animation_param.dart';
import 'attach_model.dart';

class SmartShowParamBase {
  SmartShowParamBase({
    required this.widget,
    required this.alignment,
    required this.clickMaskDismiss,
    required this.animationType,
    required this.nonAnimationTypes,
    required this.animationBuilder,
    required this.usePenetrate,
    required this.useAnimation,
    required this.animationTime,
    required this.maskColor,
    required this.maskWidget,
    required this.onDismiss,
    required this.onMask,
  });

  final Widget widget;
  final Alignment alignment;
  final bool clickMaskDismiss;
  final SmartAnimationType animationType;
  final List<SmartNonAnimationType> nonAnimationTypes;
  final AnimationBuilder? animationBuilder;
  final bool usePenetrate;
  final bool useAnimation;
  final Duration animationTime;
  final Color maskColor;
  final Widget? maskWidget;
  final VoidCallback? onDismiss;
  final VoidCallback? onMask;

  SmartShowParamBase copyWith({
    Widget? widget,
    Alignment? alignment,
    bool? clickMaskDismiss,
    SmartAnimationType? animationType,
    List<SmartNonAnimationType>? nonAnimationTypes,
    AnimationBuilder? animationBuilder,
    bool? usePenetrate,
    bool? useAnimation,
    Duration? animationTime,
    Color? maskColor,
    Widget? maskWidget,
    VoidCallback? onDismiss,
    VoidCallback? onMask,
  }) {
    return SmartShowParamBase(
      widget: widget ?? this.widget,
      alignment: alignment ?? this.alignment,
      clickMaskDismiss: clickMaskDismiss ?? this.clickMaskDismiss,
      animationType: animationType ?? this.animationType,
      nonAnimationTypes: nonAnimationTypes ?? this.nonAnimationTypes,
      animationBuilder: animationBuilder ?? this.animationBuilder,
      usePenetrate: usePenetrate ?? this.usePenetrate,
      useAnimation: useAnimation ?? this.useAnimation,
      animationTime: animationTime ?? this.animationTime,
      maskColor: maskColor ?? this.maskColor,
      maskWidget: maskWidget ?? this.maskWidget,
      onDismiss: onDismiss ?? this.onDismiss,
      onMask: onMask ?? this.onMask,
    );
  }
}

class SmartShowCustomParam extends SmartShowParamBase {
  SmartShowCustomParam({
    required Widget widget,
    required Alignment alignment,
    required bool clickMaskDismiss,
    required SmartAnimationType animationType,
    required List<SmartNonAnimationType> nonAnimationTypes,
    required AnimationBuilder? animationBuilder,
    required bool usePenetrate,
    required bool useAnimation,
    required Duration animationTime,
    required Color maskColor,
    required Widget? maskWidget,
    required VoidCallback? onDismiss,
    required VoidCallback? onMask,
    required this.debounce,
    required this.displayTime,
    required this.tag,
    required this.keepSingle,
    required this.permanent,
    required this.useSystem,
    required this.bindPage,
    required this.bindWidget,
    required this.ignoreArea,
    required this.backType,
    required this.onBack,
  }) : super(
          widget: widget,
          alignment: alignment,
          clickMaskDismiss: clickMaskDismiss,
          animationType: animationType,
          nonAnimationTypes: nonAnimationTypes,
          animationBuilder: animationBuilder,
          usePenetrate: usePenetrate,
          useAnimation: useAnimation,
          animationTime: animationTime,
          maskColor: maskColor,
          maskWidget: maskWidget,
          onDismiss: onDismiss,
          onMask: onMask,
        );

  final bool debounce;
  final Duration? displayTime;
  final String? tag;
  final bool keepSingle;
  final bool permanent;
  final bool useSystem;
  final bool bindPage;
  final BuildContext? bindWidget;
  final Rect? ignoreArea;
  final SmartBackType? backType;
  final SmartOnBack? onBack;

  @override
  SmartShowCustomParam copyWith({
    Widget? widget,
    Alignment? alignment,
    bool? clickMaskDismiss,
    SmartAnimationType? animationType,
    List<SmartNonAnimationType>? nonAnimationTypes,
    AnimationBuilder? animationBuilder,
    bool? usePenetrate,
    bool? useAnimation,
    Duration? animationTime,
    Color? maskColor,
    Widget? maskWidget,
    VoidCallback? onDismiss,
    VoidCallback? onMask,
    bool? debounce,
    Duration? displayTime,
    String? tag,
    bool? keepSingle,
    bool? permanent,
    bool? useSystem,
    bool? bindPage,
    BuildContext? bindWidget,
    Rect? ignoreArea,
    SmartBackType? backType,
    SmartOnBack? onBack,
  }) {
    return SmartShowCustomParam(
      widget: widget ?? this.widget,
      alignment: alignment ?? this.alignment,
      clickMaskDismiss: clickMaskDismiss ?? this.clickMaskDismiss,
      animationType: animationType ?? this.animationType,
      nonAnimationTypes: nonAnimationTypes ?? this.nonAnimationTypes,
      animationBuilder: animationBuilder ?? this.animationBuilder,
      usePenetrate: usePenetrate ?? this.usePenetrate,
      useAnimation: useAnimation ?? this.useAnimation,
      animationTime: animationTime ?? this.animationTime,
      maskColor: maskColor ?? this.maskColor,
      maskWidget: maskWidget ?? this.maskWidget,
      onDismiss: onDismiss ?? this.onDismiss,
      onMask: onMask ?? this.onMask,
      debounce: debounce ?? this.debounce,
      displayTime: displayTime ?? this.displayTime,
      tag: tag ?? this.tag,
      keepSingle: keepSingle ?? this.keepSingle,
      permanent: permanent ?? this.permanent,
      useSystem: useSystem ?? this.useSystem,
      bindPage: bindPage ?? this.bindPage,
      bindWidget: bindWidget ?? this.bindWidget,
      ignoreArea: ignoreArea ?? this.ignoreArea,
      backType: backType ?? this.backType,
      onBack: onBack ?? this.onBack,
    );
  }
}

class SmartShowAttachParam extends SmartShowCustomParam {
  SmartShowAttachParam({
    required Widget widget,
    required Alignment alignment,
    required bool clickMaskDismiss,
    required SmartAnimationType animationType,
    required List<SmartNonAnimationType> nonAnimationTypes,
    required AnimationBuilder? animationBuilder,
    required bool usePenetrate,
    required bool useAnimation,
    required Duration animationTime,
    required Color maskColor,
    required Widget? maskWidget,
    required VoidCallback? onDismiss,
    required VoidCallback? onMask,
    required bool debounce,
    required Duration? displayTime,
    required String? tag,
    required bool keepSingle,
    required bool permanent,
    required bool useSystem,
    required bool bindPage,
    required BuildContext? bindWidget,
    required Rect? ignoreArea,
    required SmartBackType? backType,
    required SmartOnBack? onBack,
    required this.targetContext,
    required this.targetBuilder,
    required this.replaceBuilder,
    required this.adjustBuilder,
    required this.scalePointBuilder,
    required this.maskIgnoreArea,
    required this.highlightBuilder,
  }) : super(
          widget: widget,
          alignment: alignment,
          clickMaskDismiss: clickMaskDismiss,
          animationType: animationType,
          nonAnimationTypes: nonAnimationTypes,
          animationBuilder: animationBuilder,
          usePenetrate: usePenetrate,
          useAnimation: useAnimation,
          animationTime: animationTime,
          maskColor: maskColor,
          maskWidget: maskWidget,
          onDismiss: onDismiss,
          onMask: onMask,
          debounce: debounce,
          displayTime: displayTime,
          tag: tag,
          keepSingle: keepSingle,
          permanent: permanent,
          useSystem: useSystem,
          bindPage: bindPage,
          bindWidget: bindWidget,
          ignoreArea: ignoreArea,
          backType: backType,
          onBack: onBack,
        );

  final BuildContext? targetContext;
  final Offset Function(Offset targetOffset, Size targetSize)? targetBuilder;
  final Widget Function(
    Offset targetOffset,
    Size targetSize,
    Offset selfOffset,
    Size selfSize,
  )? replaceBuilder;
  final AttachAdjustParam Function(AttachParam attachParam)? adjustBuilder;
  final Offset Function(Size selfSize)? scalePointBuilder;
  final Rect? maskIgnoreArea;
  final Positioned Function(Offset targetOffset, Size targetSize)?
      highlightBuilder;

  @override
  SmartShowAttachParam copyWith({
    Widget? widget,
    Alignment? alignment,
    bool? clickMaskDismiss,
    SmartAnimationType? animationType,
    List<SmartNonAnimationType>? nonAnimationTypes,
    AnimationBuilder? animationBuilder,
    bool? usePenetrate,
    bool? useAnimation,
    Duration? animationTime,
    Color? maskColor,
    Widget? maskWidget,
    VoidCallback? onDismiss,
    VoidCallback? onMask,
    bool? debounce,
    Duration? displayTime,
    String? tag,
    bool? keepSingle,
    bool? permanent,
    bool? useSystem,
    bool? bindPage,
    BuildContext? bindWidget,
    Rect? ignoreArea,
    SmartBackType? backType,
    SmartOnBack? onBack,
    BuildContext? targetContext,
    Offset Function(Offset targetOffset, Size targetSize)? targetBuilder,
    Widget Function(
      Offset targetOffset,
      Size targetSize,
      Offset selfOffset,
      Size selfSize,
    )? replaceBuilder,
    AttachAdjustParam Function(AttachParam attachParam)? adjustBuilder,
    Offset Function(Size selfSize)? scalePointBuilder,
    Rect? maskIgnoreArea,
    Positioned Function(Offset targetOffset, Size targetSize)? highlightBuilder,
  }) {
    return SmartShowAttachParam(
      widget: widget ?? this.widget,
      alignment: alignment ?? this.alignment,
      clickMaskDismiss: clickMaskDismiss ?? this.clickMaskDismiss,
      animationType: animationType ?? this.animationType,
      nonAnimationTypes: nonAnimationTypes ?? this.nonAnimationTypes,
      animationBuilder: animationBuilder ?? this.animationBuilder,
      usePenetrate: usePenetrate ?? this.usePenetrate,
      useAnimation: useAnimation ?? this.useAnimation,
      animationTime: animationTime ?? this.animationTime,
      maskColor: maskColor ?? this.maskColor,
      maskWidget: maskWidget ?? this.maskWidget,
      onDismiss: onDismiss ?? this.onDismiss,
      onMask: onMask ?? this.onMask,
      debounce: debounce ?? this.debounce,
      displayTime: displayTime ?? this.displayTime,
      tag: tag ?? this.tag,
      keepSingle: keepSingle ?? this.keepSingle,
      permanent: permanent ?? this.permanent,
      useSystem: useSystem ?? this.useSystem,
      bindPage: bindPage ?? this.bindPage,
      bindWidget: bindWidget ?? this.bindWidget,
      ignoreArea: ignoreArea ?? this.ignoreArea,
      backType: backType ?? this.backType,
      onBack: onBack ?? this.onBack,
      targetContext: targetContext ?? this.targetContext,
      targetBuilder: targetBuilder ?? this.targetBuilder,
      replaceBuilder: replaceBuilder ?? this.replaceBuilder,
      adjustBuilder: adjustBuilder ?? this.adjustBuilder,
      scalePointBuilder: scalePointBuilder ?? this.scalePointBuilder,
      maskIgnoreArea: maskIgnoreArea ?? this.maskIgnoreArea,
      highlightBuilder: highlightBuilder ?? this.highlightBuilder,
    );
  }
}

class SmartShowNotifyParam extends SmartShowParamBase {
  SmartShowNotifyParam({
    required Widget widget,
    required Alignment alignment,
    required bool clickMaskDismiss,
    required SmartAnimationType animationType,
    required List<SmartNonAnimationType> nonAnimationTypes,
    required AnimationBuilder? animationBuilder,
    required bool usePenetrate,
    required bool useAnimation,
    required Duration animationTime,
    required Color maskColor,
    required Widget? maskWidget,
    required VoidCallback? onDismiss,
    required VoidCallback? onMask,
    required this.debounce,
    required this.displayTime,
    required this.tag,
    required this.keepSingle,
    required this.backType,
    required this.onBack,
  }) : super(
          widget: widget,
          alignment: alignment,
          clickMaskDismiss: clickMaskDismiss,
          animationType: animationType,
          nonAnimationTypes: nonAnimationTypes,
          animationBuilder: animationBuilder,
          usePenetrate: usePenetrate,
          useAnimation: useAnimation,
          animationTime: animationTime,
          maskColor: maskColor,
          maskWidget: maskWidget,
          onDismiss: onDismiss,
          onMask: onMask,
        );

  final bool debounce;
  final Duration? displayTime;
  final String? tag;
  final bool keepSingle;
  final SmartBackType backType;
  final SmartOnBack? onBack;

  @override
  SmartShowNotifyParam copyWith({
    Widget? widget,
    Alignment? alignment,
    bool? clickMaskDismiss,
    SmartAnimationType? animationType,
    List<SmartNonAnimationType>? nonAnimationTypes,
    AnimationBuilder? animationBuilder,
    bool? usePenetrate,
    bool? useAnimation,
    Duration? animationTime,
    Color? maskColor,
    Widget? maskWidget,
    VoidCallback? onDismiss,
    VoidCallback? onMask,
    bool? debounce,
    Duration? displayTime,
    String? tag,
    bool? keepSingle,
    SmartBackType? backType,
    SmartOnBack? onBack,
  }) {
    return SmartShowNotifyParam(
      widget: widget ?? this.widget,
      alignment: alignment ?? this.alignment,
      clickMaskDismiss: clickMaskDismiss ?? this.clickMaskDismiss,
      animationType: animationType ?? this.animationType,
      nonAnimationTypes: nonAnimationTypes ?? this.nonAnimationTypes,
      animationBuilder: animationBuilder ?? this.animationBuilder,
      usePenetrate: usePenetrate ?? this.usePenetrate,
      useAnimation: useAnimation ?? this.useAnimation,
      animationTime: animationTime ?? this.animationTime,
      maskColor: maskColor ?? this.maskColor,
      maskWidget: maskWidget ?? this.maskWidget,
      onDismiss: onDismiss ?? this.onDismiss,
      onMask: onMask ?? this.onMask,
      debounce: debounce ?? this.debounce,
      displayTime: displayTime ?? this.displayTime,
      tag: tag ?? this.tag,
      keepSingle: keepSingle ?? this.keepSingle,
      backType: backType ?? this.backType,
      onBack: onBack ?? this.onBack,
    );
  }
}

class SmartShowLoadingParam extends SmartShowParamBase {
  SmartShowLoadingParam({
    required Widget widget,
    required Alignment alignment,
    required bool clickMaskDismiss,
    required SmartAnimationType animationType,
    required List<SmartNonAnimationType> nonAnimationTypes,
    required AnimationBuilder? animationBuilder,
    required bool usePenetrate,
    required bool useAnimation,
    required Duration animationTime,
    required Color maskColor,
    required Widget? maskWidget,
    required VoidCallback? onDismiss,
    required VoidCallback? onMask,
    required this.displayTime,
    required this.backType,
    required this.onBack,
  }) : super(
          widget: widget,
          alignment: alignment,
          clickMaskDismiss: clickMaskDismiss,
          animationType: animationType,
          nonAnimationTypes: nonAnimationTypes,
          animationBuilder: animationBuilder,
          usePenetrate: usePenetrate,
          useAnimation: useAnimation,
          animationTime: animationTime,
          maskColor: maskColor,
          maskWidget: maskWidget,
          onDismiss: onDismiss,
          onMask: onMask,
        );

  final Duration? displayTime;
  final SmartBackType backType;
  final SmartOnBack? onBack;

  @override
  SmartShowLoadingParam copyWith({
    Widget? widget,
    Alignment? alignment,
    bool? clickMaskDismiss,
    SmartAnimationType? animationType,
    List<SmartNonAnimationType>? nonAnimationTypes,
    AnimationBuilder? animationBuilder,
    bool? usePenetrate,
    bool? useAnimation,
    Duration? animationTime,
    Color? maskColor,
    Widget? maskWidget,
    VoidCallback? onDismiss,
    VoidCallback? onMask,
    Duration? displayTime,
    SmartBackType? backType,
    SmartOnBack? onBack,
  }) {
    return SmartShowLoadingParam(
      widget: widget ?? this.widget,
      alignment: alignment ?? this.alignment,
      clickMaskDismiss: clickMaskDismiss ?? this.clickMaskDismiss,
      animationType: animationType ?? this.animationType,
      nonAnimationTypes: nonAnimationTypes ?? this.nonAnimationTypes,
      animationBuilder: animationBuilder ?? this.animationBuilder,
      usePenetrate: usePenetrate ?? this.usePenetrate,
      useAnimation: useAnimation ?? this.useAnimation,
      animationTime: animationTime ?? this.animationTime,
      maskColor: maskColor ?? this.maskColor,
      maskWidget: maskWidget ?? this.maskWidget,
      onDismiss: onDismiss ?? this.onDismiss,
      onMask: onMask ?? this.onMask,
      displayTime: displayTime ?? this.displayTime,
      backType: backType ?? this.backType,
      onBack: onBack ?? this.onBack,
    );
  }
}

class SmartShowToastParam extends SmartShowParamBase {
  SmartShowToastParam({
    required Widget widget,
    required Alignment alignment,
    required bool clickMaskDismiss,
    required SmartAnimationType animationType,
    required List<SmartNonAnimationType> nonAnimationTypes,
    required AnimationBuilder? animationBuilder,
    required bool usePenetrate,
    required bool useAnimation,
    required Duration animationTime,
    required Color maskColor,
    required Widget? maskWidget,
    required VoidCallback? onDismiss,
    required VoidCallback? onMask,
    required this.displayTime,
    required this.debounce,
    required this.displayType,
    required this.consumeEvent,
  }) : super(
          widget: widget,
          alignment: alignment,
          clickMaskDismiss: clickMaskDismiss,
          animationType: animationType,
          nonAnimationTypes: nonAnimationTypes,
          animationBuilder: animationBuilder,
          usePenetrate: usePenetrate,
          useAnimation: useAnimation,
          animationTime: animationTime,
          maskColor: maskColor,
          maskWidget: maskWidget,
          onDismiss: onDismiss,
          onMask: onMask,
        );

  final Duration displayTime;
  final bool debounce;
  final SmartToastType displayType;
  final bool consumeEvent;

  @override
  SmartShowToastParam copyWith({
    Widget? widget,
    Alignment? alignment,
    bool? clickMaskDismiss,
    SmartAnimationType? animationType,
    List<SmartNonAnimationType>? nonAnimationTypes,
    AnimationBuilder? animationBuilder,
    bool? usePenetrate,
    bool? useAnimation,
    Duration? animationTime,
    Color? maskColor,
    Widget? maskWidget,
    VoidCallback? onDismiss,
    VoidCallback? onMask,
    Duration? displayTime,
    bool? debounce,
    SmartToastType? displayType,
    bool? consumeEvent,
  }) {
    return SmartShowToastParam(
      widget: widget ?? this.widget,
      alignment: alignment ?? this.alignment,
      clickMaskDismiss: clickMaskDismiss ?? this.clickMaskDismiss,
      animationType: animationType ?? this.animationType,
      nonAnimationTypes: nonAnimationTypes ?? this.nonAnimationTypes,
      animationBuilder: animationBuilder ?? this.animationBuilder,
      usePenetrate: usePenetrate ?? this.usePenetrate,
      useAnimation: useAnimation ?? this.useAnimation,
      animationTime: animationTime ?? this.animationTime,
      maskColor: maskColor ?? this.maskColor,
      maskWidget: maskWidget ?? this.maskWidget,
      onDismiss: onDismiss ?? this.onDismiss,
      onMask: onMask ?? this.onMask,
      displayTime: displayTime ?? this.displayTime,
      debounce: debounce ?? this.debounce,
      displayType: displayType ?? this.displayType,
      consumeEvent: consumeEvent ?? this.consumeEvent,
    );
  }
}

class SmartMainDialogParam extends SmartShowParamBase {
  SmartMainDialogParam({
    required Widget widget,
    required Alignment alignment,
    required bool clickMaskDismiss,
    required SmartAnimationType animationType,
    required List<SmartNonAnimationType> nonAnimationTypes,
    required AnimationBuilder? animationBuilder,
    required bool usePenetrate,
    required bool useAnimation,
    required Duration animationTime,
    required Color maskColor,
    required Widget? maskWidget,
    required VoidCallback? onDismiss,
    required VoidCallback? onMask,
    required this.useSystem,
    required this.reuse,
    required this.awaitOverType,
    required this.maskTriggerType,
    required this.ignoreArea,
    required this.keepSingle,
  }) : super(
          widget: widget,
          alignment: alignment,
          clickMaskDismiss: clickMaskDismiss,
          animationType: animationType,
          nonAnimationTypes: nonAnimationTypes,
          animationBuilder: animationBuilder,
          usePenetrate: usePenetrate,
          useAnimation: useAnimation,
          animationTime: animationTime,
          maskColor: maskColor,
          maskWidget: maskWidget,
          onDismiss: onDismiss,
          onMask: onMask,
        );

  final bool useSystem;
  final bool reuse;
  final SmartAwaitOverType awaitOverType;
  final SmartMaskTriggerType maskTriggerType;
  final Rect? ignoreArea;
  final bool keepSingle;
}

class SmartMainAttachParam extends SmartShowParamBase {
  SmartMainAttachParam({
    required Widget widget,
    required Alignment alignment,
    required bool clickMaskDismiss,
    required SmartAnimationType animationType,
    required List<SmartNonAnimationType> nonAnimationTypes,
    required AnimationBuilder? animationBuilder,
    required bool usePenetrate,
    required bool useAnimation,
    required Duration animationTime,
    required Color maskColor,
    required Widget? maskWidget,
    required VoidCallback? onDismiss,
    required VoidCallback? onMask,
    required this.targetContext,
    required this.targetBuilder,
    required this.replaceBuilder,
    required this.adjustBuilder,
    required this.scalePointBuilder,
    required this.maskIgnoreArea,
    required this.highlightBuilder,
    required this.maskTriggerType,
    required this.useSystem,
    required this.awaitOverType,
    required this.keepSingle,
  }) : super(
          widget: widget,
          alignment: alignment,
          clickMaskDismiss: clickMaskDismiss,
          animationType: animationType,
          nonAnimationTypes: nonAnimationTypes,
          animationBuilder: animationBuilder,
          usePenetrate: usePenetrate,
          useAnimation: useAnimation,
          animationTime: animationTime,
          maskColor: maskColor,
          maskWidget: maskWidget,
          onDismiss: onDismiss,
          onMask: onMask,
        );

  final BuildContext? targetContext;
  final Offset Function(Offset targetOffset, Size targetSize)? targetBuilder;
  final Widget Function(
    Offset targetOffset,
    Size targetSize,
    Offset selfOffset,
    Size selfSize,
  )? replaceBuilder;
  final AttachAdjustParam Function(AttachParam attachParam)? adjustBuilder;
  final Offset Function(Size selfSize)? scalePointBuilder;
  final Rect? maskIgnoreArea;
  final Positioned Function(Offset targetOffset, Size targetSize)?
      highlightBuilder;
  final SmartMaskTriggerType maskTriggerType;
  final bool useSystem;
  final SmartAwaitOverType awaitOverType;
  final bool keepSingle;
}
