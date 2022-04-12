import 'dart:async';

import 'package:flutter/material.dart';

import 'compatible/compatible_smart_dialog.dart';
import 'config/smart_config.dart';
import 'config/enum_config.dart';
import 'helper/dialog_proxy.dart';
import 'widget/attach_dialog_widget.dart';

class SmartDialog {
  /// Compatible with older versions
  ///
  /// 兼容老版本
  static CompatibleSmartDialog compatible = CompatibleSmartDialog.instance;

  /// SmartDialog global config
  ///
  /// SmartDialog全局配置
  static SmartConfig config = DialogProxy.instance.config;

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
  /// [animationTime]：animation duration
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
  /// [clickBgDismiss]：true（点击半透明的暗色背景后，将关闭dialog），false（不关闭）
  ///
  /// [animationType]：具体可参照[SmartAnimationType]注释
  ///
  /// [usePenetrate]：true（点击事件将穿透背景），false（不穿透）
  ///
  /// [useAnimation]：true（使用动画），false（不使用）
  ///
  /// [animationTime]：动画持续时间
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
  static Future<T?>? show<T>({
    required WidgetBuilder builder,
    AlignmentGeometry? alignment,
    bool? clickBgDismiss,
    bool? usePenetrate,
    bool? useAnimation,
    SmartAnimationType? animationType,
    Duration? animationTime,
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

    return DialogProxy.instance.show<T>(
      widget: Builder(builder: (context) => builder(context)),
      alignment: alignment ?? config.custom.alignment,
      clickBgDismiss: clickBgDismiss ?? config.custom.clickBgDismiss,
      animationType: animationType ?? config.custom.animationType,
      usePenetrate: usePenetrate ?? config.custom.usePenetrate,
      useAnimation: useAnimation ?? config.custom.useAnimation,
      animationTime: animationTime ?? config.custom.animationTime,
      maskColor: maskColor ?? config.custom.maskColor,
      maskWidget: maskWidget ?? config.custom.maskWidget,
      debounce: debounce ?? config.custom.debounce,
      onDismiss: onDismiss,
      tag: tag,
      backDismiss: backDismiss ?? config.custom.backDismiss,
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
  /// [animationTime]：animation duration
  ///
  /// [maskColor]：the color of the mask，it is invalid if [maskWidget] set the value and [usePenetrate] is true
  ///
  /// [maskWidget]：highly customizable mask
  ///
  /// [debounce]：debounce feature
  ///
  /// [highlightBuilder]：highlight function, dissolve the mask of a specific area,
  /// you can quickly get the target widget information (coordinates and size)
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
  /// [clickBgDismiss]：true（点击半透明的暗色背景后，将关闭dialog），false（不关闭）
  ///
  /// [animationType]：具体可参照[SmartAnimationType]注释
  ///
  /// [usePenetrate]：true（点击事件将穿透背景），false（不穿透）
  ///
  /// [useAnimation]：true（使用动画），false（不使用）
  ///
  /// [animationTime]：动画持续时间
  ///
  /// [maskColor]：遮罩颜色，如果给[maskWidget]设置了值，该参数将会失效
  ///
  /// [maskWidget]：可高度定制遮罩
  ///
  /// [debounce]：防抖功能
  ///
  /// [highlightBuilder]：高亮功能，溶解特定区域的遮罩，可以快速获取目标widget信息（坐标和大小）
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
  static Future<T?>? showAttach<T>({
    required BuildContext? targetContext,
    required WidgetBuilder builder,
    Offset? target,
    AlignmentGeometry? alignment,
    bool? clickBgDismiss,
    SmartAnimationType? animationType,
    bool? usePenetrate,
    bool? useAnimation,
    Duration? animationTime,
    Color? maskColor,
    Widget? maskWidget,
    bool? debounce,
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

    var highlight = highlightBuilder;
    return DialogProxy.instance.showAttach<T>(
      targetContext: targetContext,
      widget: Builder(builder: (context) => builder(context)),
      target: target,
      alignment: alignment ?? config.attach.alignment,
      clickBgDismiss: clickBgDismiss ?? config.attach.clickBgDismiss,
      animationType: animationType ?? config.attach.animationType,
      usePenetrate: usePenetrate ?? config.attach.usePenetrate,
      useAnimation: useAnimation ?? config.attach.useAnimation,
      animationTime: animationTime ?? config.attach.animationTime,
      maskColor: maskColor ?? config.attach.maskColor,
      maskWidget: maskWidget ?? config.attach.maskWidget,
      debounce: debounce ?? config.attach.debounce,
      highlightBuilder: highlight ?? (_, __) => Positioned(child: Container()),
      onDismiss: onDismiss,
      tag: tag,
      backDismiss: backDismiss ?? config.attach.backDismiss,
      keepSingle: keepSingle ?? false,
      useSystem: useSystem ?? false,
    );
  }

  /// loading dialog
  ///
  /// [msg]：loading msg (Use the [builder] param, this param will be invalid)
  ///
  /// [background]：the rectangle background color of msg  (Use the [builder] param, this param will be invalid)
  ///
  /// [clickBgDismiss]：true（loading will be closed after click background），
  /// false（not close）
  ///
  /// [animationType]：For details, please refer to the [SmartAnimationType] comment
  ///
  /// [usePenetrate]：true（the click event will penetrate background），
  /// false（not penetration）
  ///
  /// [useAnimation]：true（use the animation），false（not use）
  ///
  /// [animationTime]：animation duration
  ///
  /// [maskColor]：the color of the mask，it is invalid if [maskWidget] set the value
  ///
  /// [maskWidget]：highly customizable mask
  ///
  /// [backDismiss]：true（the back event will close the loading but not close the page），
  /// false（the back event not close the loading and not close page），
  /// you still can use the dismiss method to close the loading
  ///
  /// [widget]：the custom loading
  /// -------------------------------------------------------------------------------
  ///
  /// loading弹窗
  ///
  /// [msg]：loading 的信息（使用[builder]参数，该参数将失效）
  ///
  /// [background]：loading信息后面的矩形背景颜色（使用[builder]参数，该参数将失效）
  ///
  /// [clickBgDismiss]：true（点击半透明的暗色背景后，将关闭loading），false（不关闭）
  ///
  /// [animationType]：具体可参照[SmartAnimationType]注释
  ///
  /// [usePenetrate]：true（点击事件将穿透背景），false（不穿透）
  ///
  /// [useAnimation]：true（使用动画），false（不使用）
  ///
  /// [animationTime]：动画持续时间
  ///
  /// [maskColor]：遮罩颜色，如果给[maskWidget]设置了值，该参数将会失效
  ///
  /// [maskWidget]：可高度定制遮罩
  ///
  /// [backDismiss]：true（返回事件将关闭loading，但是不会关闭页面），false（返回事件不会关闭loading，也不会关闭页面），
  /// 你仍然可以使用dismiss方法来关闭loading
  ///
  /// [builder]：the custom loading
  static Future<void> showLoading({
    String msg = 'loading...',
    bool? clickBgDismiss,
    SmartAnimationType? animationType,
    bool? usePenetrate,
    bool? useAnimation,
    Duration? animationTime,
    Color? maskColor,
    Widget? maskWidget,
    bool? backDismiss,
    WidgetBuilder? builder,
  }) {
    return DialogProxy.instance.showLoading(
      clickBgDismiss: clickBgDismiss ?? config.loading.clickBgDismiss,
      animationType: animationType ?? config.loading.animationType,
      usePenetrate: usePenetrate ?? config.loading.usePenetrate,
      useAnimation: useAnimation ?? config.loading.useAnimation,
      animationTime: animationTime ?? config.loading.animationTime,
      maskColor: maskColor ?? config.loading.maskColor,
      maskWidget: maskWidget ?? config.loading.maskWidget,
      backDismiss: backDismiss ?? config.loading.backDismiss,
      widget: builder != null
          ? Builder(builder: (context) => builder(context))
          : DialogProxy.instance.loadingBuilder(msg),
    );
  }

  /// toast message
  ///
  /// [msg]：msg presented to users (Use the [builder] param to customize the toast, this param will be invalid)
  ///
  /// [displayTime]：toast display time on the screen
  ///
  /// [alignment]：control the location of the dialog
  ///
  /// [clickBgDismiss]：true（toast will be closed after click background），
  /// false（not close）
  ///
  /// [animationType]：For details, please refer to the [SmartAnimationType] comment
  ///
  /// [usePenetrate]：true（the click event will penetrate background），
  /// false（not penetration）
  ///
  /// [useAnimation]：true（use the animation），false（not use）
  ///
  /// [animationTime]：animation duration
  ///
  /// [maskColor]：the color of the mask，it is invalid if [maskWidget] set the value
  ///
  /// [maskWidget]：highly customizable mask
  ///
  /// [location]：control the location of toast on the screen (Use the [builder] param to customize the toast, this param will be invalid)
  ///
  /// [debounce]：debounce feature
  ///
  /// [type]：provider multiple display logic，
  /// please refer to [SmartToastType] comment for detailed description
  ///
  /// [consumeEvent]：true (toast will consume touch events), false (toast no longer consumes events, touch events can penetrate toast)
  ///
  /// [widget]：highly customizable toast
  ///
  /// -------------------------------------------------------------------------------
  ///
  /// toast消息
  ///
  /// [msg]：呈现给用户的信息（使用[builder]参数自定义toast，该参数将失效）
  ///
  /// [displayTime]：toast在屏幕上的显示时间
  ///
  /// [alignment]：控制弹窗的位置
  ///
  /// [clickBgDismiss]：true（点击半透明的暗色背景后，将关闭toast），false（不关闭）
  ///
  /// [animationType]：具体可参照[SmartAnimationType]注释
  ///
  /// [usePenetrate]：true（点击事件将穿透背景），false（不穿透）
  ///
  /// [useAnimation]：true（使用动画），false（不使用）
  ///
  /// [animationTime]：动画持续时间
  ///
  /// [maskColor]：遮罩颜色，如果给[maskWidget]设置了值，该参数将会失效
  ///
  /// [maskWidget]：可高度定制遮罩
  ///
  /// [location]：控制toast在屏幕上的显示位置（使用[builder]参数自定义toast，该参数将失效）
  ///
  /// [debounce]：防抖功能
  ///
  /// [type]：提供多种显示逻辑，详细描述请查看 [SmartToastType] 注释
  ///
  /// [consumeEvent]：true（toast会消耗触摸事件），false（toast不再消耗事件，触摸事件能穿透toast）
  ///
  /// [builder]：可高度定制化toast
  static Future<void> showToast(
    String msg, {
    Duration? displayTime,
    AlignmentGeometry? alignment,
    bool? clickBgDismiss,
    SmartAnimationType? animationType,
    bool? usePenetrate,
    bool? useAnimation,
    Duration? animationTime,
    Color? maskColor,
    Widget? maskWidget,
    bool? consumeEvent,
    bool? debounce,
    SmartToastType? type,
    WidgetBuilder? builder,
  }) async {
    return DialogProxy.instance.showToast(
      displayTime: displayTime ?? config.toast.displayTime,
      alignment: alignment ?? config.toast.alignment,
      clickBgDismiss: clickBgDismiss ?? config.toast.clickBgDismiss,
      animationType: animationType ?? config.toast.animationType,
      usePenetrate: usePenetrate ?? config.toast.usePenetrate,
      useAnimation: useAnimation ?? config.toast.useAnimation,
      animationTime: animationTime ?? config.toast.animationTime,
      maskColor: maskColor ?? config.toast.maskColor,
      maskWidget: maskWidget ?? config.toast.maskWidget,
      debounce: debounce ?? config.toast.debounce,
      type: type ?? config.toast.type,
      consumeEvent: consumeEvent ?? config.toast.consumeEvent,
      widget: builder != null
          ? Builder(builder: (context) => builder(context))
          : DialogProxy.instance.toastBuilder(msg),
    );
  }

  /// close dialog
  ///
  /// [status]：For the specific meaning, please refer to the [SmartStatus] note
  ///
  /// [tag]：If you want to close the specified dialog, you can set a 'tag' for it
  ///
  /// [result]：Set a return value and accept it at the place where the dialog is called
  ///
  /// -------------------------------------------------------------------------------
  /// 关闭dialog
  ///
  /// [status]：具体含义可参照[SmartStatus]注释
  /// 注意：status参数设置值后，closeType参数将失效。
  ///
  /// [tag]：如果你想关闭指定的dialog，你可以给它设置一个tag
  ///
  /// [result]：设置一个返回值,可在调用弹窗的地方接受
  static Future<void> dismiss<T>({
    SmartStatus status = SmartStatus.smart,
    String? tag,
    T? result,
  }) async {
    return DialogProxy.instance.dismiss<T>(
      status: status,
      tag: tag,
      result: result,
    );
  }
}
