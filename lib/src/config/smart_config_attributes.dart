import 'package:flutter/material.dart';

import 'enum_config.dart';

typedef SmartConfigAttributesSetter = void Function(SmartConfigAttributes attributes);

class SmartConfigAttributes {
  Alignment? defaultAlignment;
  Alignment? customAlignment;
  Alignment? attachAlignment;
  Alignment? notifyAlignment;
  Alignment? loadingAlignment;
  Alignment? toastAlignment;
  SmartAnimationType? defaultAnimationType;
  SmartAnimationType? customAnimationType;
  SmartAnimationType? attachAnimationType;
  SmartAnimationType? notifyAnimationType;
  SmartAnimationType? loadingAnimationType;
  SmartAnimationType? toastAnimationType;
  Duration? defaultAnimationTime;
  Duration? customAnimationTime;
  Duration? attachAnimationTime;
  Duration? notifyAnimationTime;
  Duration? loadingAnimationTime;
  Duration? toastAnimationTime;
  bool? defaultUseAnimation;
  bool? customUseAnimation;
  bool? attachUseAnimation;
  bool? notifyUseAnimation;
  bool? loadingUseAnimation;
  bool? toastUseAnimation;
  bool? defaultUsePenetrate;
  bool? customUsePenetrate;
  bool? attachUsePenetrate;
  bool? notifyUsePenetrate;
  bool? loadingUsePenetrate;
  bool? toastUsePenetrate;
  Color? defaultMaskColor;
  Color? customMaskColor;
  Color? attachMaskColor;
  Color? notifyMaskColor;
  Color? loadingMaskColor;
  Color? toastMaskColor;
  Widget? defaultMaskWidget;
  Widget? customMaskWidget;
  Widget? attachMaskWidget;
  Widget? notifyMaskWidget;
  Widget? loadingMaskWidget;
  Widget? toastMaskWidget;
  bool? defaultClickMaskDismiss;
  bool? customClickMaskDismiss;
  bool? attachClickMaskDismiss;
  bool? notifyClickMaskDismiss;
  bool? loadingClickMaskDismiss;
  bool? toastClickMaskDismiss;
  bool? defaultDebounce;
  bool? customDebounce;
  bool? attachDebounce;
  bool? notifyDebounce;
  bool? toastDebounce;
  Duration? defaultDebounceTime;
  Duration? customDebounceTime;
  Duration? attachDebounceTime;
  Duration? notifyDebounceTime;
  Duration? toastDebounceTime;
  SmartToastType? toastDisplayType;
  bool? toastConsumeEvent;
  Duration? defaultDisplayTime;
  Duration? notifyDisplayTime;
  Duration? toastDisplayTime;
  Duration? toastIntervalTime;
  SmartAwaitOverType? defaultAwaitOverType;
  SmartAwaitOverType? customAwaitOverType;
  SmartAwaitOverType? attachAwaitOverType;
  SmartAwaitOverType? notifyAwaitOverType;
  SmartAwaitOverType? loadingAwaitOverType;
  SmartAwaitOverType? toastAwaitOverType;
  SmartMaskTriggerType? defaultMaskTriggerType;
  SmartMaskTriggerType? customMaskTriggerType;
  SmartMaskTriggerType? attachMaskTriggerType;
  SmartMaskTriggerType? notifyMaskTriggerType;
  SmartMaskTriggerType? loadingMaskTriggerType;
  SmartMaskTriggerType? toastMaskTriggerType;
  List<SmartNonAnimationType>? defaultNonAnimationTypes;
  List<SmartNonAnimationType>? customNonAnimationTypes;
  List<SmartNonAnimationType>? attachNonAnimationTypes;
  List<SmartNonAnimationType>? notifyNonAnimationTypes;
  List<SmartNonAnimationType>? loadingNonAnimationTypes;
  List<SmartNonAnimationType>? toastNonAnimationTypes;

  SmartConfigAttributes({
    this.defaultAlignment,
    this.customAlignment,
    this.attachAlignment,
    this.notifyAlignment,
    this.loadingAlignment,
    this.toastAlignment,
    this.defaultAnimationType,
    this.customAnimationType,
    this.attachAnimationType,
    this.notifyAnimationType,
    this.loadingAnimationType,
    this.toastAnimationType,
    this.defaultAnimationTime,
    this.customAnimationTime,
    this.attachAnimationTime,
    this.notifyAnimationTime,
    this.loadingAnimationTime,
    this.toastAnimationTime,
    this.defaultUseAnimation,
    this.customUseAnimation,
    this.attachUseAnimation,
    this.notifyUseAnimation,
    this.loadingUseAnimation,
    this.toastUseAnimation,
    this.defaultUsePenetrate,
    this.customUsePenetrate,
    this.attachUsePenetrate,
    this.notifyUsePenetrate,
    this.loadingUsePenetrate,
    this.toastUsePenetrate,
    this.defaultMaskColor,
    this.customMaskColor,
    this.attachMaskColor,
    this.notifyMaskColor,
    this.loadingMaskColor,
    this.toastMaskColor,
    this.defaultMaskWidget,
    this.customMaskWidget,
    this.attachMaskWidget,
    this.notifyMaskWidget,
    this.loadingMaskWidget,
    this.toastMaskWidget,
    this.defaultClickMaskDismiss,
    this.customClickMaskDismiss,
    this.attachClickMaskDismiss,
    this.notifyClickMaskDismiss,
    this.loadingClickMaskDismiss,
    this.toastClickMaskDismiss,
    this.defaultDebounce,
    this.customDebounce,
    this.attachDebounce,
    this.notifyDebounce,
    this.toastDebounce,
    this.defaultDebounceTime,
    this.customDebounceTime,
    this.attachDebounceTime,
    this.notifyDebounceTime,
    this.toastDebounceTime,
    this.toastDisplayType,
    this.toastConsumeEvent,
    this.defaultDisplayTime,
    this.notifyDisplayTime,
    this.toastDisplayTime,
    this.toastIntervalTime,
    this.defaultAwaitOverType,
    this.customAwaitOverType,
    this.attachAwaitOverType,
    this.notifyAwaitOverType,
    this.loadingAwaitOverType,
    this.toastAwaitOverType,
    this.defaultMaskTriggerType,
    this.customMaskTriggerType,
    this.attachMaskTriggerType,
    this.notifyMaskTriggerType,
    this.loadingMaskTriggerType,
    this.toastMaskTriggerType,
    this.defaultNonAnimationTypes,
    this.customNonAnimationTypes,
    this.attachNonAnimationTypes,
    this.notifyNonAnimationTypes,
    this.loadingNonAnimationTypes,
    this.toastNonAnimationTypes,
  });
}