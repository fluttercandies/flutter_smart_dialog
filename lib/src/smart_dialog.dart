import 'dart:async';

import 'package:flutter/material.dart';

import 'helper/config.dart';
import 'helper/dialog_proxy.dart';
import 'widget/loading_widget.dart';
import 'widget/toast_widget.dart';

enum SmartStatus {
  /// close toast
  toast,

  /// close loading
  loading,

  /// close single dialog
  dialog,

  /// close all dialog, but not close toast and loading
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

class SmartDialog {
  /// SmartDialog global config
  ///
  /// SmartDialog全局配置
  static Config config = DialogProxy.instance.config;

  /// custom dialog：'temp' suffix param, if there is no default value, the global attribute in config will be used by default
  ///
  /// [widget]：custom widget
  ///
  /// [alignmentTemp]：control the location of the dialog
  ///
  /// [clickBgDismissTemp]：true（the dialog will be closed after click background），false（not close）
  ///
  /// [isLoadingTemp]：true（use the opacity animation），false（use the scale transition animation）
  ///
  /// [isPenetrateTemp]：true（the click event will penetrate background），false（not penetration）
  ///
  /// [isUseAnimationTemp]：true（use the animation），false（not use）
  ///
  /// [animationDurationTemp]：animation duration
  ///
  /// [maskColorTemp]：the color of the mask，it is invalid if [maskWidgetTemp] set the value and [isPenetrateTemp] is true
  ///
  /// [maskWidgetTemp]：highly customizable mask
  ///
  /// [antiShakeTemp]：anti-shake function（debounce）
  ///
  /// [onDismiss]：the callback will be invoked when the dialog is closed
  ///
  /// [tag]：if you set a tag for the dialog, you can turn it off in a targeted manner
  ///
  /// [backDismiss]：default（true），true（the back event will close the dialog but not close the page），
  /// false（the back event not close the dialog and not close page），you still can use the dismiss method to close the dialog
  ///
  /// -------------------------------------------------------------------------------
  ///
  /// 提供loading弹窗：'temp' 后缀的参数，如果没有默认值，则默认使用config中的全局属性
  ///
  /// [widget]：自定义 widget
  ///
  /// [alignmentTemp]：控制弹窗的位置
  ///
  /// [clickBgDismissTemp]：true（点击半透明的暗色背景后，将关闭loading），false（不关闭）
  ///
  /// [isLoadingTemp]：true（使用透明动画），false（使用尺寸缩放动画）
  ///
  /// [isPenetrateTemp]：true（点击事件将穿透背景），false（不穿透）
  ///
  /// [isUseAnimationTemp]：true（使用动画），false（不使用）
  ///
  /// [animationDurationTemp]：动画持续时间
  ///
  /// [maskColorTemp]：遮罩颜色，如果给[maskWidgetTemp]设置了值，该参数将会失效
  ///
  /// [maskWidgetTemp]：可高度定制遮罩
  ///
  /// [antiShakeTemp]：防抖功能（debounce）
  ///
  /// [onDismiss]：在dialog被关闭的时候，该回调将会被触发
  ///
  /// [tag]：如果你给dialog设置了tag, 你可以针对性的关闭它
  ///
  /// [backDismiss]：默认（true），true（返回事件将关闭loading，但是不会关闭页面），false（返回事件不会关闭loading，也不会关闭页面），
  /// 你仍然可以使用dismiss方法来关闭loading
  static Future<void> show({
    required Widget widget,
    AlignmentGeometry? alignmentTemp,
    bool? clickBgDismissTemp,
    bool? isLoadingTemp,
    bool? isPenetrateTemp,
    bool? isUseAnimationTemp,
    Duration? animationDurationTemp,
    Color? maskColorTemp,
    Widget? maskWidgetTemp,
    bool? antiShakeTemp,
    VoidCallback? onDismiss,
    String? tag,
    bool? backDismiss,
  }) {
    return DialogProxy.instance.show(
      widget: widget,
      alignment: alignmentTemp ?? config.alignment,
      clickBgDismiss: clickBgDismissTemp ?? config.clickBgDismiss,
      isLoading: isLoadingTemp ?? config.isLoading,
      isPenetrate: isPenetrateTemp ?? config.isPenetrate,
      isUseAnimation: isUseAnimationTemp ?? config.isUseAnimation,
      animationDuration: animationDurationTemp ?? config.animationDuration,
      maskColor: maskColorTemp ?? config.maskColor,
      maskWidget: maskWidgetTemp ?? config.maskWidget,
      antiShake: antiShakeTemp ?? config.antiShake,
      onDismiss: onDismiss,
      tag: tag,
      backDismiss: backDismiss ?? true,
    );
  }

  /// loading dialog：'temp' suffix param, if there is no default value,
  /// the global attribute in config will be used by default
  ///
  /// [msg]：loading msg (Use the 'widget' param, this param will be invalid)
  ///
  /// [background]：the rectangle background color of msg (Use the 'widget' param, this param will be invalid)
  ///
  /// [clickBgDismissTemp]：default（false），true（loading will be closed after click background），
  /// false（not close）
  ///
  /// [isLoadingTemp]：default（true），true（use the opacity animation），
  /// false（use the scale transition animation）
  ///
  /// [isPenetrateTemp]：default（false），true（the click event will penetrate background），
  /// false（not penetration）
  ///
  /// [isUseAnimationTemp]：true（use the animation），false（not use）
  ///
  /// [animationDurationTemp]：animation duration
  ///
  /// [maskColorTemp]：the color of the mask，it is invalid if [maskWidgetTemp] set the value
  ///
  /// [maskWidgetTemp]：highly customizable mask
  ///
  /// [widget]：the custom loading
  ///
  /// [backDismiss]：default（true），true（the back event will close the loading but not close the page），
  /// false（the back event not close the loading and not close page），
  /// you still can use the dismiss method to close the loading
  ///
  /// -------------------------------------------------------------------------------
  ///
  /// loading弹窗：'temp' 后缀的参数，如果没有默认值，则默认使用config中的全局属性
  ///
  /// [msg]：loading 的信息（使用 'widget' 参数，该参数将失效）
  ///
  /// [background]：loading信息后面的矩形背景颜色（使用 'widget' 参数，该参数将失效）
  ///
  /// [clickBgDismissTemp]：默认（false），true（点击半透明的暗色背景后，将关闭loading），false（不关闭）
  ///
  /// [isLoadingTemp]：默认（true），true（使用透明动画），false（使用尺寸缩放动画）
  ///
  /// [isPenetrateTemp]：默认（false），true（点击事件将穿透背景），false（不穿透）
  ///
  /// [isUseAnimationTemp]：true（使用动画），false（不使用）
  ///
  /// [animationDurationTemp]：动画持续时间
  ///
  /// [maskColorTemp]：遮罩颜色，如果给[maskWidgetTemp]设置了值，该参数将会失效
  ///
  /// [maskWidgetTemp]：可高度定制遮罩
  ///
  /// [widget]：the custom loading
  ///
  /// [backDismiss]：默认（true），true（返回事件将关闭loading，但是不会关闭页面），
  /// false（返回事件不会关闭loading，也不会关闭页面），你仍然可以使用dismiss方法来关闭loading
  static Future<void> showLoading({
    String msg = 'loading...',
    Color background = Colors.black,
    bool? clickBgDismissTemp,
    bool? isLoadingTemp,
    bool? isPenetrateTemp,
    bool? isUseAnimationTemp,
    Duration? animationDurationTemp,
    Color? maskColorTemp,
    Widget? maskWidgetTemp,
    bool? backDismiss,
    Widget? widget,
  }) {
    return DialogProxy.instance.showLoading(
      clickBgDismiss: clickBgDismissTemp ?? false,
      isLoading: isLoadingTemp ?? true,
      isPenetrate: isPenetrateTemp ?? false,
      isUseAnimation: isUseAnimationTemp ?? config.isUseAnimation,
      animationDuration: animationDurationTemp ?? config.animationDuration,
      maskColor: maskColorTemp ?? config.maskColor,
      maskWidget: maskWidgetTemp ?? config.maskWidget,
      backDismiss: backDismiss ?? true,
      widget: widget ?? LoadingWidget(msg: msg, background: background),
    );
  }

  /// [msg]：msg presented to users(Use the 'widget' param, this param will be invalid)
  ///
  /// [time]：toast display time on the screen(Use the 'widget' param, this param will be invalid)
  ///
  /// [alignment]：control the location of toast on the screen
  ///
  /// [antiShakeTemp]：anti-shake function（debounce）
  ///
  /// [type]：provider multiple display logic，
  /// please refer to [SmartToastType] comment for detailed description
  ///
  /// [widget]：highly customizable toast
  ///
  /// -------------------------------------------------------------------------------
  ///
  /// [msg]：呈现给用户的信息（使用 'widget' 参数，该参数将失效）
  ///
  /// [time]：toast在屏幕上的显示时间
  ///
  /// [alignment]：控制toast在屏幕上的显示位置（使用 'widget' 参数，该参数将失效）
  ///
  /// [antiShakeTemp]：防抖功能（debounce）
  ///
  /// [type]：提供多种显示逻辑，详细描述请查看 [SmartToastType] 注释
  ///
  /// [widget]：可高度定制化toast
  static Future<void> showToast(
    String msg, {
    AlignmentGeometry alignment = Alignment.bottomCenter,
    Duration? time,
    bool? antiShakeTemp,
    SmartToastType? type,
    Widget? widget,
  }) async {
    return DialogProxy.instance.showToast(
      time: time ?? Duration(milliseconds: 2000),
      antiShake: antiShakeTemp ?? config.antiShake,
      type: type ?? SmartToastType.normal,
      widget: widget ?? ToastWidget(msg: msg, alignment: alignment),
    );
  }

  /// It is recommended to use the status param,
  /// and keep the closeType param for compatibility with older versions
  ///
  /// [status]：SmartStatus.dialog（only close dialog），SmartStatus.toast（only close toast），
  /// SmartStatus.loading（only close loading）。
  /// note: the closeType param will become invalid after setting the value of the status param。
  ///
  /// [closeType]：0（default：close dialog or loading），1（only close dialog），2（only close toast），
  /// 3（only close loading），other（all close）
  ///
  /// tag：if you want to close the specified dialog, you can set a 'tag' for it
  ///
  /// -------------------------------------------------------------------------------
  ///
  /// 推荐使用status参数，保留closeType参数，是为了兼容旧版本用法
  ///
  /// [status]：SmartStatus.dialog（仅关闭dialog），SmartStatus.toast（仅关闭toast），
  /// SmartStatus.loading（仅关闭loading）。
  /// 注意：status参数设置值后，closeType参数将失效。
  ///
  /// [closeType]：0（默认：关闭dialog或者loading），1（仅关闭dialog），2（仅关闭toast），
  /// 3（仅关闭loading），other（全关闭）
  ///
  /// [tag]：如果你想关闭指定的dialog，你可以给它设置一个tag
  static Future<void> dismiss({
    SmartStatus? status,
    String? tag,
    @deprecated int closeType = 0,
  }) async {
    var instance = DialogProxy.instance;
    if (status == null) {
      if (closeType == 0) {
        await instance.dismiss(tag: tag);
      } else if (closeType == 1) {
        await instance.dismiss(status: SmartStatus.dialog, tag: tag);
      } else if (closeType == 2) {
        await instance.dismiss(status: SmartStatus.toast);
      } else if (closeType == 3) {
        await instance.dismiss(status: SmartStatus.loading);
      } else {
        await instance.dismiss(status: SmartStatus.loading);
        await instance.dismiss(status: SmartStatus.dialog, tag: tag);
        await instance.dismiss(status: SmartStatus.toast);
      }
      return;
    }

    await instance.dismiss(status: status, tag: tag);
  }
}
