import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import '../kit/dialog_kit.dart';
import 'smart_config_attributes.dart';

/// Global configuration is unified here
///
/// 全局配置统一在此处处理
class SmartConfig {
  /// show(): custom dialog global config
  ///
  /// show(): custom dialog全局配置项
  SmartConfigCustom custom = SmartConfigCustom();

  /// showAttach(): attach dialog global config
  ///
  /// showAttach(): attach dialog全局配置项
  SmartConfigAttach attach = SmartConfigAttach();

  /// showNotify(): notify dialog global config
  ///
  /// showNotify(): notify dialog全局配置项
  SmartConfigNotify notify = SmartConfigNotify();

  /// showLoading(): loading global config
  ///
  /// showLoading(): loading全局配置项
  SmartConfigLoading loading = SmartConfigLoading();

  /// showToast(): toast global config
  ///
  /// showToast(): toast全局配置项
  SmartConfigToast toast = SmartConfigToast();

  SmartConfig(
      {SmartConfigCustom? custom,
      SmartConfigAttach? attach,
      SmartConfigNotify? notify,
      SmartConfigLoading? loading,
      SmartConfigToast? toast})
      : custom = custom ?? SmartConfigCustom(),
        attach = attach ?? SmartConfigAttach(),
        notify = notify ?? SmartConfigNotify(),
        loading = loading ?? SmartConfigLoading(),
        toast = toast ?? SmartConfigToast();

  void configure(SmartConfig config) {
    toast = config.toast;
    loading = config.loading;
    attach = config.attach;
    notify = config.notify;
    custom = config.custom;
  }

  void configureSpecific(
      {SmartConfigCustom? custom,
      SmartConfigAttach? attach,
      SmartConfigNotify? notify,
      SmartConfigLoading? loading,
      SmartConfigToast? toast}) {
    if (custom != null) this.custom = custom;
    if (attach != null) this.attach = attach;
    if (notify != null) this.notify = notify;
    if (loading != null) this.loading = loading;
    if (toast != null) this.toast = toast;
  }

  ///region configureDefaultAttributes
  void configureDefaultAttributes(SmartConfigAttributes attributes) {
    // List of objects to apply default values to
    final objects = [custom, attach, notify, loading, toast];

    // Helper function to apply default values to all objects
    void applyDefault<T>(T? value, void Function(dynamic obj, T value) setter) {
      if (value != null) {
        for (final obj in objects) {
          setter(obj, value);
        }
      }
    }

    // Apply default values to all objects
    applyDefault(attributes.defaultAlignment, (obj, val) => obj.alignment = val);
    applyDefault(attributes.defaultAnimationType, (obj, val) => obj.animationType = val);
    applyDefault(attributes.defaultAnimationTime, (obj, val) => obj.animationTime = val);
    applyDefault(attributes.defaultUseAnimation, (obj, val) => obj.useAnimation = val);
    applyDefault(attributes.defaultUsePenetrate, (obj, val) => obj.usePenetrate = val);
    applyDefault(attributes.defaultMaskColor, (obj, val) => obj.maskColor = val);
    applyDefault(attributes.defaultMaskWidget, (obj, val) => obj.maskWidget = val);
    applyDefault(attributes.defaultClickMaskDismiss, (obj, val) => obj.clickMaskDismiss = val);
    applyDefault(attributes.defaultAwaitOverType, (obj, val) => obj.awaitOverType = val);
    applyDefault(attributes.defaultMaskTriggerType, (obj, val) => obj.maskTriggerType = val);
    applyDefault(attributes.defaultNonAnimationTypes, (obj, val) => obj.nonAnimationTypes = val);

    // Apply individual values to each object if provided
    if (attributes.customAlignment != null) custom.alignment = attributes.customAlignment!;
    if (attributes.attachAlignment != null) attach.alignment = attributes.attachAlignment!;
    if (attributes.notifyAlignment != null) notify.alignment = attributes.notifyAlignment!;
    if (attributes.loadingAlignment != null) loading.alignment = attributes.loadingAlignment!;
    if (attributes.toastAlignment != null) toast.alignment = attributes.toastAlignment!;

    if (attributes.customAnimationType != null) custom.animationType = attributes.customAnimationType!;
    if (attributes.attachAnimationType != null) attach.animationType = attributes.attachAnimationType!;
    if (attributes.notifyAnimationType != null) notify.animationType = attributes.notifyAnimationType!;
    if (attributes.loadingAnimationType != null) loading.animationType = attributes.loadingAnimationType!;
    if (attributes.toastAnimationType != null) toast.animationType = attributes.toastAnimationType!;

    if (attributes.customAnimationTime != null) custom.animationTime = attributes.customAnimationTime!;
    if (attributes.attachAnimationTime != null) attach.animationTime = attributes.attachAnimationTime!;
    if (attributes.notifyAnimationTime != null) notify.animationTime = attributes.notifyAnimationTime!;
    if (attributes.loadingAnimationTime != null) loading.animationTime = attributes.loadingAnimationTime!;
    if (attributes.toastAnimationTime != null) toast.animationTime = attributes.toastAnimationTime!;

    if (attributes.customUseAnimation != null) custom.useAnimation = attributes.customUseAnimation!;
    if (attributes.attachUseAnimation != null) attach.useAnimation = attributes.attachUseAnimation!;
    if (attributes.notifyUseAnimation != null) notify.useAnimation = attributes.notifyUseAnimation!;
    if (attributes.loadingUseAnimation != null) loading.useAnimation = attributes.loadingUseAnimation!;
    if (attributes.toastUseAnimation != null) toast.useAnimation = attributes.toastUseAnimation!;

    if (attributes.customUsePenetrate != null) custom.usePenetrate = attributes.customUsePenetrate!;
    if (attributes.attachUsePenetrate != null) attach.usePenetrate = attributes.attachUsePenetrate!;
    if (attributes.notifyUsePenetrate != null) notify.usePenetrate = attributes.notifyUsePenetrate!;
    if (attributes.loadingUsePenetrate != null) loading.usePenetrate = attributes.loadingUsePenetrate!;
    if (attributes.toastUsePenetrate != null) toast.usePenetrate = attributes.toastUsePenetrate!;

    if (attributes.customMaskColor != null) custom.maskColor = attributes.customMaskColor!;
    if (attributes.attachMaskColor != null) attach.maskColor = attributes.attachMaskColor!;
    if (attributes.notifyMaskColor != null) notify.maskColor = attributes.notifyMaskColor!;
    if (attributes.loadingMaskColor != null) loading.maskColor = attributes.loadingMaskColor!;
    if (attributes.toastMaskColor != null) toast.maskColor = attributes.toastMaskColor!;

    if (attributes.customMaskWidget != null) custom.maskWidget = attributes.customMaskWidget!;
    if (attributes.attachMaskWidget != null) attach.maskWidget = attributes.attachMaskWidget!;
    if (attributes.notifyMaskWidget != null) notify.maskWidget = attributes.notifyMaskWidget!;
    if (attributes.loadingMaskWidget != null) loading.maskWidget = attributes.loadingMaskWidget!;
    if (attributes.toastMaskWidget != null) toast.maskWidget = attributes.toastMaskWidget!;

    if (attributes.customClickMaskDismiss != null) custom.clickMaskDismiss = attributes.customClickMaskDismiss!;
    if (attributes.attachClickMaskDismiss != null) attach.clickMaskDismiss = attributes.attachClickMaskDismiss!;
    if (attributes.notifyClickMaskDismiss != null) notify.clickMaskDismiss = attributes.notifyClickMaskDismiss!;
    if (attributes.loadingClickMaskDismiss != null) loading.clickMaskDismiss = attributes.loadingClickMaskDismiss!;
    if (attributes.toastClickMaskDismiss != null) toast.clickMaskDismiss = attributes.toastClickMaskDismiss!;

    if (attributes.defaultDebounce != null) {
      custom.debounce = attributes.customDebounce!;
      attach.debounce = attributes.attachDebounce!;
      notify.debounce = attributes.notifyDebounce!;
      toast.debounce = attributes.toastDebounce!;
    }
    if (attributes.customDebounce != null) custom.debounce = attributes.customDebounce!;
    if (attributes.attachDebounce != null) attach.debounce = attributes.attachDebounce!;
    if (attributes.notifyDebounce != null) notify.debounce = attributes.notifyDebounce!;
    if (attributes.toastDebounce != null) toast.debounce = attributes.toastDebounce!;

    if (attributes.defaultDebounceTime != null) {
      custom.debounceTime = attributes.defaultDebounceTime!;
      attach.debounceTime = attributes.defaultDebounceTime!;
      notify.debounceTime = attributes.defaultDebounceTime!;
      toast.debounceTime = attributes.defaultDebounceTime!;
    }

    if (attributes.customDebounceTime != null) custom.debounceTime = attributes.customDebounceTime!;
    if (attributes.attachDebounceTime != null) attach.debounceTime = attributes.attachDebounceTime!;
    if (attributes.notifyDebounceTime != null) notify.debounceTime = attributes.notifyDebounceTime!;
    if (attributes.toastDebounceTime != null) toast.debounceTime = attributes.toastDebounceTime!;

    if (attributes.toastDisplayType != null) toast.displayType = attributes.toastDisplayType!;
    if (attributes.toastConsumeEvent != null) toast.consumeEvent = attributes.toastConsumeEvent!;

    if (attributes.defaultDisplayTime != null) {
      notify.displayTime = attributes.defaultDisplayTime!;
      toast.displayTime = attributes.defaultDisplayTime!;
    }
    if (attributes.notifyDisplayTime != null) notify.displayTime = attributes.notifyDisplayTime!;
    if (attributes.toastDisplayTime != null) toast.displayTime = attributes.toastDisplayTime!;

    if (attributes.toastIntervalTime != null) toast.intervalTime = attributes.toastIntervalTime!;

    if (attributes.customAwaitOverType != null) custom.awaitOverType = attributes.customAwaitOverType!;
    if (attributes.attachAwaitOverType != null) attach.awaitOverType = attributes.attachAwaitOverType!;
    if (attributes.notifyAwaitOverType != null) notify.awaitOverType = attributes.notifyAwaitOverType!;
    if (attributes.loadingAwaitOverType != null) loading.awaitOverType = attributes.loadingAwaitOverType!;
    if (attributes.toastAwaitOverType != null) toast.awaitOverType = attributes.toastAwaitOverType!;

    if (attributes.customMaskTriggerType != null) custom.maskTriggerType = attributes.customMaskTriggerType!;
    if (attributes.attachMaskTriggerType != null) attach.maskTriggerType = attributes.attachMaskTriggerType!;
    if (attributes.notifyMaskTriggerType != null) notify.maskTriggerType = attributes.notifyMaskTriggerType!;
    if (attributes.loadingMaskTriggerType != null) loading.maskTriggerType = attributes.loadingMaskTriggerType!;
    if (attributes.toastMaskTriggerType != null) toast.maskTriggerType = attributes.toastMaskTriggerType!;

    if (attributes.customNonAnimationTypes != null) custom.nonAnimationTypes = attributes.customNonAnimationTypes!;
    if (attributes.attachNonAnimationTypes != null) attach.nonAnimationTypes = attributes.attachNonAnimationTypes!;
    if (attributes.notifyNonAnimationTypes != null) notify.nonAnimationTypes = attributes.notifyNonAnimationTypes!;
    if (attributes.loadingNonAnimationTypes != null) loading.nonAnimationTypes = attributes.loadingNonAnimationTypes!;
    if (attributes.toastNonAnimationTypes != null) toast.nonAnimationTypes = attributes.toastNonAnimationTypes!;
  }

  ///endregion configureDefaultAttributes

  /// Check whether the relevant dialog exists on the interface,
  /// if the tag attribute is used, dialogTypes will be invalid
  ///
  /// 检查相关dialog是否存在于界面上，如果使用tag属性，dialogTypes将失效
  @Deprecated("please use SmartDialog.checkExist()")
  bool checkExist({
    String? tag,
    Set<SmartAllDialogType> dialogTypes = const {
      SmartAllDialogType.custom,
      SmartAllDialogType.attach,
      SmartAllDialogType.loading,
    },
  }) {
    return DialogKit.instance.checkExist(tag: tag, dialogTypes: dialogTypes);
  }

  /// whether custom dialog，attach and loading  exist on the screen
  ///
  /// 自定义dialog，attach或loading，是否存在在界面上
  @Deprecated("Please use checkExist")
  bool get isExist => custom.isExist || attach.isExist || loading.isExist;

  /// whether custom dialog exist on the screen
  ///
  /// 自定义dialog或attach是否存在在界面上
  @Deprecated("Please use checkExist")
  bool get isExistDialog => custom.isExist || attach.isExist;

  /// whether loading exist on the screen
  ///
  /// loading是否存在界面上
  @Deprecated("Please use checkExist")
  bool get isExistLoading => loading.isExist;

  /// whether toast exist on the screen
  ///
  /// toast是否存在在界面上
  @Deprecated("Please use checkExist")
  bool get isExistToast => toast.isExist;
}