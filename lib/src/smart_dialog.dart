import 'dart:async';

import 'package:flutter/material.dart';

import 'compatible/compatible_smart_dialog.dart';
import 'config/config.dart';
import 'helper/dialog_proxy.dart';
import 'widget/attach_dialog_widget.dart';

enum SmartStatus {
  /// close single dialog：loading（showToast），custom（show）or attach（showAttach）
  ///
  /// 关闭单个dialog：loading（showLoading），custom（show）或 attach（showAttach）
  smart,

  /// close toast（showToast）
  ///
  /// 关闭toast（showToast）
  toast,

  /// close loading（showLoading）
  ///
  /// 关闭loading（showLoading）
  loading,

  /// close single custom dialog（show）
  ///
  /// 关闭单个custom dialog（show）
  custom,

  /// close single attach dialog（showAttach）
  ///
  /// 关闭单个attach dialog（showAttach）
  attach,

  /// close single dialog（attach or custom）
  ///
  /// 关闭单个dialog（attach或custom）
  dialog,

  /// close all custom dialog, but not close toast,loading and attach dialog
  ///
  /// 关闭打开的所有custom dialog，但是不关闭toast，loading和attach dialog
  allCustom,

  /// close all attach dialog, but not close toast,loading and custom dialog
  ///
  /// 关闭打开的所有attach dialog，但是不关闭toast，loading和custom dialog
  allAttach,

  /// close all dialog（attach and custom）, but not close toast and loading
  ///
  /// 关闭打开的所有dialog（attach和custom），但是不关闭toast和loading
  allDialog,
}

enum SmartToastType {
  /// Each toast will be displayed, after the current toast disappears，
  /// the next toast will be displayed
  ///
  /// 每一条toast都会显示，当前toast消失之后，后一条toast才会显示
  normal,

  /// Call toast continuously, during the period when the first toast exists on the screen,
  /// other toasts called will be invalid
  ///
  /// 连续调用toast，在第一条toast存在界面的期间内，调用的其它toast都将无效
  first,

  /// Call toast continuously, the next toast will top off the previous toast
  ///
  /// 连续调用toast，后一条toast会顶掉前一条toast
  last,

  /// Call toast continuously, the first toast is displayed normally，
  /// and all toasts generated during the first toast display period，only the last toast is valid
  ///
  /// 连续调用toast，第一条toast正常显示，其显示期间产生的所有toast，仅最后一条toast有效
  firstAndLast,
}

/// Different animation types can be set for dialog (appearing and disappearing)
///
/// 可给弹窗(出现和消失)设置不同的动画类型
enum SmartAnimationType {
  /// FadeTransition
  ///
  /// 渐隐动画
  fade,

  /// SizeTransition
  ///
  /// 缩放动画
  scale,

  /// 中间位置的为渐隐动画, 其他位置为位移缩放动画
  centerFadeAndOtherScale
}

class SmartDialog {
  /// Compatible with version 3.x
  ///
  /// 兼容3.x版本
  static CompatibleSmartDialog compatible = CompatibleSmartDialog.instance;

  /// SmartDialog global config
  ///
  /// SmartDialog全局配置
  static Config config = DialogProxy.instance.config;

  /// custom dialog
  ///
  /// [widget]：custom widget
  ///
  /// [alignment]：control the location of the dialog
  ///
  /// [clickBgDismiss]：true（the dialog will be closed after click background），false（not close）
  ///
  /// [animationType]：For details, please refer to the [SmartAnimationType] comment
  ///
  /// [usePenetrate]：true（the click event will penetrate background），false（not penetration）
  ///
  /// [useAnimation]：true（use the animation），false（not use）
  ///
  /// [animationDuration]：animation duration
  ///
  /// [maskColor]：the color of the mask，it is invalid if [maskWidget] set the value and [usePenetrate] is true
  ///
  /// [maskWidget]：highly customizable mask
  ///
  /// [debounce]：debounce feature
  ///
  /// [onDismiss]：the callback will be invoked when the dialog is closed
  ///
  /// [tag]：if you set a tag for the dialog, you can turn it off in a targeted manner
  ///
  /// [backDismiss]：default（true），true（the back event will close the dialog but not close the page），
  /// false（the back event not close the dialog and not close page），you still can use the dismiss method to close the dialog
  ///
  /// [keepSingle]：Default (false), true (calling [show] multiple times will not generate multiple dialogs,
  /// only single dialog will be kept), false (calling [show] multiple times will generate multiple dialogs)
  ///
  /// [useSystem]: default (false), true (using the system dialog, [usePenetrate] is invalid, [tag] and [keepSingle] are prohibited),
  /// false (using SmartDialog), this param can completely solve the page jump scene on the dialog
  ///
  /// -------------------------------------------------------------------------------
  ///
  /// 自定义弹窗
  ///
  /// [widget]：自定义 widget
  ///
  /// [alignment]：控制弹窗的位置
  ///
  /// [clickBgDismiss]：true（点击半透明的暗色背景后，将关闭loading），false（不关闭）
  ///
  /// [animationType]：具体可参照[SmartAnimationType]注释
  ///
  /// [usePenetrate]：true（点击事件将穿透背景），false（不穿透）
  ///
  /// [useAnimation]：true（使用动画），false（不使用）
  ///
  /// [animationDuration]：动画持续时间
  ///
  /// [maskColor]：遮罩颜色，如果给[maskWidget]设置了值，该参数将会失效
  ///
  /// [maskWidget]：可高度定制遮罩
  ///
  /// [debounce]：防抖功能
  ///
  /// [onDismiss]：在dialog被关闭的时候，该回调将会被触发
  ///
  /// [tag]：如果你给dialog设置了tag, 你可以针对性的关闭它
  ///
  /// [backDismiss]：默认（true），true（返回事件将关闭loading，但是不会关闭页面），
  /// false（返回事件不会关闭loading，也不会关闭页面），你仍然可以使用dismiss方法来关闭loading
  ///
  /// [keepSingle]：默认（false），true（多次调用[show]并不会生成多个dialog，仅仅保持一个dialog），
  /// false（多次调用[show]会生成多个dialog）
  ///
  /// [useSystem]：默认（false），true（使用系统dialog，[usePenetrate]功能失效,[tag]和[keepSingle]禁止使用），
  /// false（使用SmartDialog），此参数可彻底解决在弹窗上跳转页面问题
  static Future<void> show({
    required Widget widget,
    AlignmentGeometry? alignment,
    bool? clickBgDismiss,
    bool? usePenetrate,
    bool? useAnimation,
    SmartAnimationType? animationType,
    Duration? animationDuration,
    Color? maskColor,
    Widget? maskWidget,
    bool? debounce,
    VoidCallback? onDismiss,
    String? tag,
    bool? backDismiss,
    bool? keepSingle,
    bool? useSystem,
  }) {
    assert(
      (useSystem == true && keepSingle == null && tag == null) ||
          (useSystem == null || useSystem == false),
      'useSystem is true, keepSingle and tag prohibit setting values',
    );
    assert(
      keepSingle == null || keepSingle == false || tag == null,
      'keepSingle is true, tag prohibit setting values',
    );

    return DialogProxy.instance.show(
      widget: widget,
      alignment: alignment ?? config.custom.alignment,
      clickBgDismiss: clickBgDismiss ?? config.custom.clickBgDismiss,
      animationType: animationType ?? config.custom.animationType,
      usePenetrate: usePenetrate ?? config.custom.usePenetrate,
      useAnimation: useAnimation ?? config.custom.useAnimation,
      animationDuration: animationDuration ?? config.custom.animationDuration,
      maskColor: maskColor ?? config.custom.maskColor,
      maskWidget: maskWidget ?? config.custom.maskWidget,
      debounce: debounce ?? config.custom.debounce,
      onDismiss: onDismiss,
      tag: tag,
      backDismiss: backDismiss ?? true,
      keepSingle: keepSingle ?? false,
      useSystem: useSystem ?? false,
    );
  }

  /// attach dialog
  ///
  /// [targetContext]：BuildContext with target widget
  ///
  /// [widget]：custom widget
  ///
  /// [target]：target offset，when the target is set to value，
  /// the targetContext param will be invalid
  ///
  /// [alignment]：control the location of the dialog
  ///
  /// [clickBgDismiss]：true（the dialog will be closed after click background），false（not close）
  ///
  /// [animationType]：For details, please refer to the [SmartAnimationType] comment
  ///
  /// [usePenetrate]：true（the click event will penetrate background），false（not penetration）
  ///
  /// [useAnimation]：true（use the animation），false（not use）
  ///
  /// [animationDuration]：animation duration
  ///
  /// [maskColor]：the color of the mask，it is invalid if [maskWidget] set the value and [usePenetrate] is true
  ///
  /// [maskWidget]：highly customizable mask
  ///
  /// [debounce]：debounce feature
  ///
  /// [highlight]：highlight feature, dissolve the mask of a specific area
  ///
  /// [highlightBuilder]：the function is the same as [highlight], it may be a little troublesome to use,
  /// but you can quickly get the target widget info（Coordinates and size）；
  /// Note: If [highlightBuilder] is used, [highlight] will be invalid
  ///
  /// [onDismiss]：the callback will be invoked when the dialog is closed
  ///
  /// [tag]：if you set a tag for the dialog, you can turn it off in a targeted manner
  ///
  /// [backDismiss]：default（true），true（the back event will close the dialog but not close the page），
  /// false（the back event not close the dialog and not close page），you still can use the dismiss method to close the dialog
  ///
  /// [keepSingle]：Default (false), true (calling [showAttach] multiple times will not generate multiple dialogs,
  /// only single dialog will be kept), false (calling [showAttach] multiple times will generate multiple dialogs)
  ///
  /// [useSystem]: default (false), true (using the system dialog, [usePenetrate] is invalid, [tag] and [keepSingle] are prohibited),
  /// false (using SmartDialog), this param can completely solve the page jump scene on the dialog
  ///
  /// -------------------------------------------------------------------------------
  ///
  /// 定位弹窗
  ///
  /// [targetContext]：伴随位置widget的BuildContext
  ///
  /// [widget]：自定义 widget
  ///
  /// [target]：target offset，当target被设置数据，targetContext参数将失效
  ///
  /// [alignment]：控制弹窗的位置
  ///
  /// [clickBgDismiss]：true（点击半透明的暗色背景后，将关闭loading），false（不关闭）
  ///
  /// [animationType]：具体可参照[SmartAnimationType]注释
  ///
  /// [usePenetrate]：true（点击事件将穿透背景），false（不穿透）
  ///
  /// [useAnimation]：true（使用动画），false（不使用）
  ///
  /// [animationDuration]：动画持续时间
  ///
  /// [maskColor]：遮罩颜色，如果给[maskWidget]设置了值，该参数将会失效
  ///
  /// [maskWidget]：可高度定制遮罩
  ///
  /// [debounce]：防抖功能
  ///
  /// [highlight]：高亮功能，溶解特定区域的遮罩
  ///
  /// [highlightBuilder]：功能和[highlight]一致，使用上可能麻烦一点，但是可以快速获取目标widget信息（坐标和大小）；
  /// 注：使用了[highlightBuilder]，[highlight]将失效
  ///
  /// [onDismiss]：在dialog被关闭的时候，该回调将会被触发
  ///
  /// [tag]：如果你给dialog设置了tag, 你可以针对性的关闭它
  ///
  /// [backDismiss]：默认（true），true（返回事件将关闭loading，但是不会关闭页面），
  /// false（返回事件不会关闭loading，也不会关闭页面），你仍然可以使用dismiss方法来关闭loading
  ///
  /// [keepSingle]：默认（false），true（多次调用[showAttach]并不会生成多个dialog，仅仅保持一个dialog），
  /// false（多次调用[showAttach]会生成多个dialog）
  ///
  /// [useSystem]：默认（false），true（使用系统dialog，[usePenetrate]功能失效,[tag]和[keepSingle]禁止使用），
  /// false（使用SmartDialog），此参数可彻底解决在弹窗上跳转页面问题
  static Future<void> showAttach({
    required BuildContext? targetContext,
    required Widget widget,
    Offset? target,
    AlignmentGeometry? alignment,
    bool? clickBgDismiss,
    SmartAnimationType? animationType,
    bool? usePenetrate,
    bool? useAnimation,
    Duration? animationDuration,
    Color? maskColor,
    Widget? maskWidget,
    bool? debounce,
    Positioned? highlight,
    HighlightBuilder? highlightBuilder,
    VoidCallback? onDismiss,
    String? tag,
    bool? backDismiss,
    bool? keepSingle,
    bool? useSystem,
  }) {
    assert(
      targetContext != null || target != null,
      'targetContext and target, cannot both be null',
    );
    assert(
      (useSystem == true && keepSingle == null && tag == null) ||
          (useSystem == null || useSystem == false),
      'useSystem is true, keepSingle and tag prohibit setting values',
    );
    assert(
      keepSingle == null || keepSingle == false || tag == null,
      'keepSingle is true, tag prohibit setting values',
    );

    return DialogProxy.instance.showAttach(
      targetContext: targetContext,
      target: target,
      widget: widget,
      alignment: alignment ?? config.attach.alignment,
      clickBgDismiss: clickBgDismiss ?? config.attach.clickBgDismiss,
      animationType: animationType ?? config.attach.animationType,
      usePenetrate: usePenetrate ?? config.attach.usePenetrate,
      useAnimation: useAnimation ?? config.attach.useAnimation,
      animationDuration: animationDuration ?? config.attach.animationDuration,
      maskColor: maskColor ?? config.attach.maskColor,
      maskWidget: maskWidget ?? config.attach.maskWidget,
      debounce: debounce ?? config.attach.debounce,
      highlight: highlight ?? Positioned(child: Container()),
      highlightBuilder: highlightBuilder,
      onDismiss: onDismiss,
      tag: tag,
      backDismiss: backDismiss ?? true,
      keepSingle: keepSingle ?? false,
      useSystem: useSystem ?? false,
    );
  }

  /// loading dialog
  ///
  /// [msg]：loading msg (Use the 'widget' param, this param will be invalid)
  ///
  /// [background]：the rectangle background color of msg (Use the 'widget' param, this param will be invalid)
  ///
  /// [clickBgDismiss]：default（false），true（loading will be closed after click background），
  /// false（not close）
  ///
  /// [animationType]：For details, please refer to the [SmartAnimationType] comment
  ///
  /// [usePenetrate]：default（false），true（the click event will penetrate background），
  /// false（not penetration）
  ///
  /// [useAnimation]：true（use the animation），false（not use）
  ///
  /// [animationDuration]：animation duration
  ///
  /// [maskColor]：the color of the mask，it is invalid if [maskWidget] set the value
  ///
  /// [maskWidget]：highly customizable mask
  ///
  /// [widget]：the custom loading
  ///
  /// [backDismiss]：default（true），true（the back event will close the loading but not close the page），
  /// false（the back event not close the loading and not close page），
  /// you still can use the dismiss method to close the loading
  ///
  /// -------------------------------------------------------------------------------
  ///
  /// loading弹窗
  ///
  /// [msg]：loading 的信息（使用 'widget' 参数，该参数将失效）
  ///
  /// [background]：loading信息后面的矩形背景颜色（使用 'widget' 参数，该参数将失效）
  ///
  /// [clickBgDismiss]：默认（false），true（点击半透明的暗色背景后，将关闭loading），false（不关闭）
  ///
  /// [animationType]：具体可参照[SmartAnimationType]注释
  ///
  /// [usePenetrate]：默认（false），true（点击事件将穿透背景），false（不穿透）
  ///
  /// [useAnimation]：true（使用动画），false（不使用）
  ///
  /// [animationDuration]：动画持续时间
  ///
  /// [maskColor]：遮罩颜色，如果给[maskWidget]设置了值，该参数将会失效
  ///
  /// [maskWidget]：可高度定制遮罩
  ///
  /// [widget]：the custom loading
  ///
  /// [backDismiss]：默认（true），true（返回事件将关闭loading，但是不会关闭页面），
  /// false（返回事件不会关闭loading，也不会关闭页面），你仍然可以使用dismiss方法来关闭loading
  static Future<void> showLoading({
    String msg = 'loading...',
    Color background = Colors.black,
    bool? clickBgDismiss,
    SmartAnimationType? animationType,
    bool? usePenetrate,
    bool? useAnimation,
    Duration? animationDuration,
    Color? maskColor,
    Widget? maskWidget,
    bool? backDismiss,
    Widget? widget,
  }) {
    return DialogProxy.instance.showLoading(
      clickBgDismiss: clickBgDismiss ?? config.loading.clickBgDismiss,
      animationType: animationType ?? config.loading.animationType,
      usePenetrate: usePenetrate ?? config.loading.usePenetrate,
      useAnimation: useAnimation ?? config.loading.useAnimation,
      animationDuration: animationDuration ?? config.loading.animationDuration,
      maskColor: maskColor ?? config.loading.maskColor,
      maskWidget: maskWidget ?? config.loading.maskWidget,
      backDismiss: backDismiss ?? true,
      widget: widget ?? DialogProxy.instance.loadingBuilder(msg, background),
    );
  }

  /// toast message
  ///
  /// [msg]：msg presented to users(Use the 'widget' param, this param will be invalid)
  ///
  /// [alignment]：control the location of the dialog
  ///
  /// [clickBgDismiss]：default（false），true（loading will be closed after click background），
  /// false（not close）
  ///
  /// [animationType]：For details, please refer to the [SmartAnimationType] comment
  ///
  /// [usePenetrate]：default（true），true（the click event will penetrate background），
  /// false（not penetration）
  ///
  /// [useAnimation]：true（use the animation），false（not use）
  ///
  /// [animationDuration]：animation duration
  ///
  /// [maskColor]：the color of the mask，it is invalid if [maskWidget] set the value
  ///
  /// [maskWidget]：highly customizable mask
  ///
  /// [location]：control the location of toast on the screen
  ///
  /// [consumeEvent]： default (false), true (toast will consume touch events),
  /// false (toast no longer consumes events, touch events can penetrate toast)
  ///
  /// [time]：toast display time on the screen(Use the 'widget' param, this param will be invalid)
  ///
  /// [debounce]：debounce feature
  ///
  /// [type]：provider multiple display logic，
  /// please refer to [SmartToastType] comment for detailed description
  ///
  /// [widget]：highly customizable toast
  ///
  /// -------------------------------------------------------------------------------
  ///
  /// toast消息
  ///
  /// [msg]：呈现给用户的信息（使用 'widget' 参数，该参数将失效）
  ///
  /// [alignment]：控制弹窗的位置
  ///
  /// [clickBgDismiss]：默认（false），true（点击半透明的暗色背景后，将关闭loading），false（不关闭）
  ///
  /// [animationType]：具体可参照[SmartAnimationType]注释
  ///
  /// [usePenetrate]：默认（true），true（点击事件将穿透背景），false（不穿透）
  ///
  /// [useAnimation]：true（使用动画），false（不使用）
  ///
  /// [animationDuration]：动画持续时间
  ///
  /// [maskColor]：遮罩颜色，如果给[maskWidget]设置了值，该参数将会失效
  ///
  /// [maskWidget]：可高度定制遮罩
  ///
  /// [location]：控制toast在屏幕上的显示位置（使用 'widget' 参数，该参数将失效）
  ///
  /// [consumeEvent]：默认（false），true（toast会消耗触摸事件），false（toast不再消耗事件，触摸事件能穿透toast）
  ///
  /// [time]：toast在屏幕上的显示时间
  ///
  /// [debounce]：防抖功能
  ///
  /// [type]：提供多种显示逻辑，详细描述请查看 [SmartToastType] 注释
  ///
  /// [widget]：可高度定制化toast
  static Future<void> showToast(
    String msg, {
    AlignmentGeometry? alignment,
    bool? clickBgDismiss,
    SmartAnimationType? animationType,
    bool? usePenetrate,
    bool? useAnimation,
    Duration? animationDuration,
    Color? maskColor,
    Widget? maskWidget,
    AlignmentGeometry location = Alignment.bottomCenter,
    bool? consumeEvent,
    Duration? time,
    bool? debounce,
    SmartToastType? type,
    Widget? widget,
  }) async {
    return DialogProxy.instance.showToast(
      alignment: alignment ?? config.toast.alignment,
      clickBgDismiss: clickBgDismiss ?? config.toast.clickBgDismiss,
      animationType: animationType ?? config.toast.animationType,
      usePenetrate: usePenetrate ?? config.toast.usePenetrate,
      useAnimation: useAnimation ?? config.toast.useAnimation,
      animationDuration: animationDuration ?? config.toast.animationDuration,
      maskColor: maskColor ?? config.toast.maskColor,
      maskWidget: maskWidget ?? config.toast.maskWidget,
      consumeEvent: consumeEvent ?? false,
      time: time ?? Duration(milliseconds: 2000),
      debounce: debounce ?? config.toast.clickBgDismiss,
      type: type ?? SmartToastType.normal,
      widget: widget ?? DialogProxy.instance.toastBuilder(msg, location),
    );
  }

  /// close dialog
  ///
  /// [status]：For the specific meaning, please refer to the [SmartStatus] note
  ///
  /// [tag]：if you want to close the specified dialog, you can set a 'tag' for it
  ///
  /// -------------------------------------------------------------------------------
  /// 关闭dialog
  ///
  /// [status]：具体含义可参照[SmartStatus]注释
  /// 注意：status参数设置值后，closeType参数将失效。
  ///
  /// [tag]：如果你想关闭指定的dialog，你可以给它设置一个tag
  static Future<void> dismiss({
    SmartStatus status = SmartStatus.smart,
    String? tag,
  }) async {
    await DialogProxy.instance.dismiss(status: status, tag: tag);
  }
}
