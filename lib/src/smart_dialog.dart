import 'dart:async';

import 'package:flutter/material.dart';

import 'compatible/compatible_smart_dialog.dart';
import 'config/smart_config.dart';
import 'config/enum_config.dart';
import 'helper/dialog_proxy.dart';
import 'widget/attach_dialog_widget.dart';
import 'widget/dialog_scope.dart';

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
  /// [builder]：the custom dialog
  ///
  /// [controller]：this controller can be used to refresh the layout of the custom dialog
  ///
  /// [alignment]：control the location of the dialog
  ///
  /// [clickMaskDismiss]：true（the dialog will be closed after click mask），false（not close）
  ///
  /// [animationType]：For details, please refer to the [SmartAnimationType] comment
  ///
  /// [usePenetrate]：true（the click event will penetrate mask），false（not penetration）
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
  /// [onMask]：This callback will be triggered when the mask is clicked
  ///
  /// [tag]：If you set a tag for the dialog, you can turn it off in a targeted manner
  ///
  /// [backDismiss]：true（the back event will close the dialog but not close the page），
  /// false（the back event not close the dialog and not close page），you still can use the dismiss method to close the dialog
  ///
  /// [keepSingle]：default (false), true (calling [show] multiple times will not generate multiple dialogs,
  /// only single dialog will be kept), false (calling [show] multiple times will generate multiple dialogs)
  ///
  /// [permanent]： default (false), true (set the dialog as a permanent dialog), false (not set);
  /// Various security operations (return events, routing) inside the framework cannot close the permanent dialog,
  /// you need to close this kind of dialog: dismiss(force: true)
  ///
  /// [useSystem]：default (false), true (using the system dialog, [usePenetrate] is invalid;
  /// [tag], [keepSingle], [permanent] and [bindPage] are prohibited), false (using SmartDialog),
  /// using this param can make SmartDialog reasonably interact with the routing page and the dialog that comes with flutter
  ///
  /// [bindPage]：bind the dialog to the current page, the bound page is not on the top of the stack,
  /// the dialog is automatically hidden, the bound page is placed on the top of the stack, and the dialog is automatically displayed;
  /// the bound page is closed, and the dialog bound to the page will also be removed
  ///
  /// -------------------------------------------------------------------------------
  ///
  /// 自定义弹窗
  ///
  /// [builder]：自定义 dialog
  ///
  /// [controller]：可使用该控制器来刷新自定义的dialog的布局
  ///
  /// [alignment]：控制弹窗的位置
  ///
  /// [clickMaskDismiss]：true（点击遮罩后，将关闭dialog），false（不关闭）
  ///
  /// [animationType]：具体可参照[SmartAnimationType]注释
  ///
  /// [usePenetrate]：true（点击事件将穿透遮罩），false（不穿透）
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
  /// [onMask]：点击遮罩时，该回调将会被触发
  ///
  /// [tag]：如果你给dialog设置了tag, 你可以针对性的关闭它
  ///
  /// [backDismiss]：true（返回事件将关闭loading，但是不会关闭页面），
  /// false（返回事件不会关闭loading，也不会关闭页面），你仍然可以使用dismiss方法来关闭loading
  ///
  /// [keepSingle]：默认（false），true（多次调用[show]并不会生成多个dialog，仅仅保持一个dialog），
  /// false（多次调用[show]会生成多个dialog）
  ///
  /// [permanent]：默认（false），true（将该dialog设置为永久化dialog）,false(不设置);
  /// 框架内部各种兜底操作(返回事件,路由)无法关闭永久化dialog, 需要关闭此类dialog可使用: dismiss(force: true)
  ///
  /// [useSystem]：默认（false），true（使用系统dialog，[usePenetrate]功能失效; [tag], [keepSingle], [permanent]和[bindPage]禁止使用），
  /// false（使用SmartDialog），使用该参数可使SmartDialog, 与路由页面以及flutter自带dialog合理交互
  ///
  /// [bindPage]：将该dialog与当前页面绑定，绑定页面不在路由栈顶，dialog自动隐藏，绑定页面置于路由栈顶，dialog自动显示;
  /// 绑定页面被关闭,被绑定在该页面上的dialog也将被移除
  static Future<T?> show<T>({
    required WidgetBuilder builder,
    SmartDialogController? controller,
    AlignmentGeometry? alignment,
    bool? clickMaskDismiss,
    bool? usePenetrate,
    bool? useAnimation,
    SmartAnimationType? animationType,
    Duration? animationTime,
    Color? maskColor,
    Widget? maskWidget,
    bool? debounce,
    VoidCallback? onDismiss,
    VoidCallback? onMask,
    String? tag,
    bool? backDismiss,
    bool? keepSingle,
    bool? permanent,
    bool? useSystem,
    bool? bindPage,
  }) {
    assert(
      (useSystem == true &&
              tag == null &&
              permanent == null &&
              keepSingle == null) ||
          (useSystem == null || useSystem == false),
      'useSystem is true; tag, keepSingle and permanent prohibit setting values',
    );
    assert(
      keepSingle == null || keepSingle == false || tag == null,
      'keepSingle is true, tag prohibit setting values',
    );

    return DialogProxy.instance.show<T>(
      widget: DialogScope(
        controller: controller,
        builder: (context) => builder(context),
      ),
      alignment: alignment ?? config.custom.alignment,
      clickMaskDismiss: clickMaskDismiss ?? config.custom.clickMaskDismiss,
      animationType: animationType ?? config.custom.animationType,
      usePenetrate: usePenetrate ?? config.custom.usePenetrate,
      useAnimation: useAnimation ?? config.custom.useAnimation,
      animationTime: animationTime ?? config.custom.animationTime,
      maskColor: maskColor ?? config.custom.maskColor,
      maskWidget: maskWidget ?? config.custom.maskWidget,
      debounce: debounce ?? config.custom.debounce,
      onDismiss: onDismiss,
      onMask: onMask,
      tag: tag,
      backDismiss: backDismiss ?? config.custom.backDismiss,
      keepSingle: keepSingle ?? false,
      permanent: permanent ?? false,
      useSystem: useSystem ?? false,
      bindPage: bindPage ?? config.custom.bindPage,
    );
  }

  /// attach dialog
  ///
  /// [targetContext]：BuildContext with target widget
  ///
  /// [builder]：the custom dialog
  ///
  /// [controller]：this controller can be used to refresh the layout of the custom dialog
  ///
  /// [target]：target offset，when the target is set to value，
  /// the targetContext param will be invalid
  ///
  /// [alignment]：control the location of the dialog
  ///
  /// [clickMaskDismiss]：true（the dialog will be closed after click mask），false（not close）
  ///
  /// [animationType]：For details, please refer to the [SmartAnimationType] comment
  ///
  /// [scalePoint]：he zoom point of the zoom animation, the default point is the center point of the attach widget as the zoom point;
  /// Offset(0, 0): Use the upper left point of the control as the zoom point,
  /// Offset(attach widget width, 0): Use the upper right point of the control as the zoom point
  /// Offset(0, attach widget height): use the lower left point of the control as the zoom point,
  /// Offset (attach widget width, attach widget height): use the lower right point of the control as the zoom point
  ///
  /// [usePenetrate]：true（the click event will penetrate mask），false（not penetration）
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
  /// [onMask]：this callback will be triggered when the mask is clicked
  ///
  /// [tag]：if you set a tag for the dialog, you can turn it off in a targeted manner
  ///
  /// [backDismiss]：true（the back event will close the dialog but not close the page），
  /// false（the back event not close the dialog and not close page），you still can use the dismiss method to close the dialog
  ///
  /// [keepSingle]：default (false), true (calling [showAttach] multiple times will not generate multiple dialogs,
  /// only single dialog will be kept), false (calling [showAttach] multiple times will generate multiple dialogs)
  ///
  /// [permanent]：default (false), true (set the dialog as a permanent dialog), false (not set);
  /// Various security operations (return events, routing) inside the framework cannot close the permanent dialog,
  /// you need to close this kind of dialog: dismiss(force: true)
  ///
  /// [useSystem]：default (false), true (using the system dialog, [usePenetrate] is invalid;
  /// [tag], [keepSingle], [permanent] and [bindPage] are prohibited), false (using SmartDialog),
  /// using this param can make SmartDialog reasonably interact with the routing page and the dialog that comes with flutter
  ///
  /// [bindPage]：bind the dialog to the current page, the bound page is not on the top of the stack,
  /// the dialog is automatically hidden, the bound page is placed on the top of the stack, and the dialog is automatically displayed;
  /// the bound page is closed, and the dialog bound to the page will also be removed
  ///
  /// -------------------------------------------------------------------------------
  ///
  /// 定位弹窗
  ///
  /// [targetContext]：伴随位置widget的BuildContext
  ///
  /// [builder]：自定义 dialog
  ///
  /// [controller]：可使用该控制器来刷新自定义的dialog的布局
  ///
  /// [target]：target offset，当target被设置数据，targetContext参数将失效
  ///
  /// [alignment]：控制弹窗的位置
  ///
  /// [clickMaskDismiss]：true（点击遮罩后，将关闭dialog），false（不关闭）
  ///
  /// [animationType]：具体可参照[SmartAnimationType]注释
  ///
  /// [scalePoint]：缩放动画的缩放点, 默认点将自定义dialog控件的中心点作为缩放点;
  /// Offset(0, 0): 将控件左上点作为缩放点, Offset(控件宽度, 0): 将控件右上点作为缩放点
  /// Offset(0, 控件高度): 将控件左下点作为缩放点, Offset(控件宽度, 控件高度): 将控件右下点作为缩放点
  ///
  /// [usePenetrate]：true（点击事件将穿透遮罩），false（不穿透）
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
  /// [onMask]：点击遮罩时，该回调将会被触发
  ///
  /// [tag]：如果你给dialog设置了tag, 你可以针对性的关闭它
  ///
  /// [backDismiss]：true（返回事件将关闭loading，但是不会关闭页面），
  /// false（返回事件不会关闭loading，也不会关闭页面），你仍然可以使用dismiss方法来关闭loading
  ///
  /// [keepSingle]：默认（false），true（多次调用[showAttach]并不会生成多个dialog，仅仅保持一个dialog），
  /// false（多次调用[showAttach]会生成多个dialog）
  ///
  /// [permanent]：默认（false），true（将该dialog设置为永久化dialog）,false(不设置);
  /// 框架内部各种兜底操作(返回事件,路由)无法关闭永久化dialog, 需要关闭此类dialog可使用: dismiss(force: true)
  ///
  /// [useSystem]：默认（false），true（使用系统dialog，[usePenetrate]功能失效; [tag], [keepSingle], [permanent]和[bindPage]禁止使用），
  /// false（使用SmartDialog），使用该参数可使SmartDialog, 与路由页面以及flutter自带dialog合理交互
  ///
  /// [bindPage]：将该dialog与当前页面绑定，绑定页面不在路由栈顶，dialog自动隐藏，绑定页面置于路由栈顶，dialog自动显示;
  /// 绑定页面被关闭,被绑定在该页面上的dialog也将被移除
  static Future<T?> showAttach<T>({
    required BuildContext? targetContext,
    required WidgetBuilder builder,
    SmartDialogController? controller,
    Offset? target,
    AlignmentGeometry? alignment,
    bool? clickMaskDismiss,
    SmartAnimationType? animationType,
    Offset? scalePoint,
    bool? usePenetrate,
    bool? useAnimation,
    Duration? animationTime,
    Color? maskColor,
    Widget? maskWidget,
    bool? debounce,
    HighlightBuilder? highlightBuilder,
    VoidCallback? onDismiss,
    VoidCallback? onMask,
    String? tag,
    bool? backDismiss,
    bool? keepSingle,
    bool? permanent,
    bool? useSystem,
    bool? bindPage,
  }) {
    assert(
      targetContext != null || target != null,
      'targetContext and target, cannot both be null',
    );
    assert(
      (useSystem == true &&
              tag == null &&
              permanent == null &&
              keepSingle == null) ||
          (useSystem == null || useSystem == false),
      'useSystem is true; tag, keepSingle and permanent prohibit setting values',
    );
    assert(
      keepSingle == null || keepSingle == false || tag == null,
      'keepSingle is true, tag prohibit setting values',
    );

    var highlight = highlightBuilder;
    return DialogProxy.instance.showAttach<T>(
      targetContext: targetContext,
      widget: DialogScope(
        controller: controller,
        builder: (context) => builder(context),
      ),
      target: target,
      alignment: alignment ?? config.attach.alignment,
      clickMaskDismiss: clickMaskDismiss ?? config.attach.clickMaskDismiss,
      animationType: animationType ?? config.attach.animationType,
      scalePoint: scalePoint,
      usePenetrate: usePenetrate ?? config.attach.usePenetrate,
      useAnimation: useAnimation ?? config.attach.useAnimation,
      animationTime: animationTime ?? config.attach.animationTime,
      maskColor: maskColor ?? config.attach.maskColor,
      maskWidget: maskWidget ?? config.attach.maskWidget,
      debounce: debounce ?? config.attach.debounce,
      highlightBuilder: highlight ?? (_, __) => Positioned(child: Container()),
      onDismiss: onDismiss,
      onMask: onMask,
      tag: tag,
      backDismiss: backDismiss ?? config.attach.backDismiss,
      keepSingle: keepSingle ?? false,
      permanent: permanent ?? false,
      useSystem: useSystem ?? false,
      bindPage: bindPage ?? config.attach.bindPage,
    );
  }

  /// loading dialog
  ///
  /// [msg]：loading msg (Use the [builder] param, this param will be invalid)
  ///
  /// [controller]：this controller can be used to refresh the layout of the custom loading
  ///
  /// [clickMaskDismiss]：true（loading will be closed after click mask），false（not close）
  ///
  /// [animationType]：For details, please refer to the [SmartAnimationType] comment
  ///
  /// [usePenetrate]：true（the click event will penetrate mask），
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
  /// [builder]：the custom loading
  /// -------------------------------------------------------------------------------
  ///
  /// loading弹窗
  ///
  /// [msg]：loading 的信息（使用[builder]参数，该参数将失效）
  ///
  /// [controller]：可使用该控制器来刷新自定义的loading的布局
  ///
  /// [clickMaskDismiss]：true（点击遮罩后，将关闭loading），false（不关闭）
  ///
  /// [animationType]：具体可参照[SmartAnimationType]注释
  ///
  /// [usePenetrate]：true（点击事件将穿透遮罩），false（不穿透）
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
  /// [builder]：自定义loading
  static Future<T?> showLoading<T>({
    String msg = 'loading...',
    SmartDialogController? controller,
    bool? clickMaskDismiss,
    SmartAnimationType? animationType,
    bool? usePenetrate,
    bool? useAnimation,
    Duration? animationTime,
    Color? maskColor,
    Widget? maskWidget,
    bool? backDismiss,
    WidgetBuilder? builder,
  }) {
    return DialogProxy.instance.showLoading<T>(
      clickMaskDismiss: clickMaskDismiss ?? config.loading.clickMaskDismiss,
      animationType: animationType ?? config.loading.animationType,
      usePenetrate: usePenetrate ?? config.loading.usePenetrate,
      useAnimation: useAnimation ?? config.loading.useAnimation,
      animationTime: animationTime ?? config.loading.animationTime,
      maskColor: maskColor ?? config.loading.maskColor,
      maskWidget: maskWidget ?? config.loading.maskWidget,
      backDismiss: backDismiss ?? config.loading.backDismiss,
      widget: builder != null
          ? DialogScope(
              controller: controller,
              builder: (context) => builder(context),
            )
          : DialogProxy.instance.loadingBuilder(msg),
    );
  }

  /// toast message
  ///
  /// [msg]：msg presented to users (Use the [builder] param to customize the toast, this param will be invalid)
  ///
  ///  [controller]：this controller can be used to refresh the layout of the custom toast
  ///
  /// [displayTime]：toast display time on the screen
  ///
  /// [alignment]：control the location of the dialog
  ///
  /// [clickMaskDismiss]：true（toast will be closed after click mask），false（not close）
  ///
  /// [animationType]：For details, please refer to the [SmartAnimationType] comment
  ///
  /// [usePenetrate]：true（the click event will penetrate mask），
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
  /// [debounce]：debounce feature
  ///
  /// [displayType]：provider multiple display logic，
  /// please refer to [SmartToastType] comment for detailed description
  ///
  /// [consumeEvent]：true (toast will consume touch events), false (toast no longer consumes events, touch events can penetrate toast)
  ///
  /// [builder]：the custom toast
  ///
  /// -------------------------------------------------------------------------------
  ///
  /// toast消息
  ///
  /// [msg]：呈现给用户的信息（使用[builder]参数自定义toast，该参数将失效）
  ///
  /// [controller]：可使用该控制器来刷新自定义的toast的布局
  ///
  /// [displayTime]：toast在屏幕上的显示时间
  ///
  /// [alignment]：控制弹窗的位置
  ///
  /// [clickMaskDismiss]：true（点击遮罩后，将关闭toast），false（不关闭）
  ///
  /// [animationType]：具体可参照[SmartAnimationType]注释
  ///
  /// [usePenetrate]：true（点击事件将穿透遮罩），false（不穿透）
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
  /// [displayType]：提供多种显示逻辑，详细描述请查看 [SmartToastType] 注释
  ///
  /// [consumeEvent]：true（toast会消耗触摸事件），false（toast不再消耗事件，触摸事件能穿透toast）
  ///
  /// [builder]：自定义toast
  static Future<void> showToast(
    String msg, {
    SmartDialogController? controller,
    Duration? displayTime,
    AlignmentGeometry? alignment,
    bool? clickMaskDismiss,
    SmartAnimationType? animationType,
    bool? usePenetrate,
    bool? useAnimation,
    Duration? animationTime,
    Color? maskColor,
    Widget? maskWidget,
    bool? consumeEvent,
    bool? debounce,
    SmartToastType? displayType,
    WidgetBuilder? builder,
  }) async {
    return DialogProxy.instance.showToast(
      displayTime: displayTime ?? config.toast.displayTime,
      alignment: alignment ?? config.toast.alignment,
      clickMaskDismiss: clickMaskDismiss ?? config.toast.clickMaskDismiss,
      animationType: animationType ?? config.toast.animationType,
      usePenetrate: usePenetrate ?? config.toast.usePenetrate,
      useAnimation: useAnimation ?? config.toast.useAnimation,
      animationTime: animationTime ?? config.toast.animationTime,
      maskColor: maskColor ?? config.toast.maskColor,
      maskWidget: maskWidget ?? config.toast.maskWidget,
      debounce: debounce ?? config.toast.debounce,
      displayType: displayType ?? config.toast.displayType,
      consumeEvent: consumeEvent ?? config.toast.consumeEvent,
      widget: builder != null
          ? DialogScope(
              controller: controller,
              builder: (context) => builder(context),
            )
          : DialogProxy.instance.toastBuilder(msg),
    );
  }

  /// close dialog
  ///
  /// [status]：for the specific meaning, please refer to the [SmartStatus] note
  ///
  /// [tag]：if you want to close the specified dialog, you can set a 'tag' for it
  ///
  /// [result]：set a return value and accept it at the place where the dialog is called
  ///
  /// [force]：force close the permanent dialog; with this param, the permanent dialog will be closed first
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
  ///
  /// [force]：强制关闭永久化的dialog; 使用该参数, 将优先关闭永久化dialog
  static Future<void> dismiss<T>({
    SmartStatus status = SmartStatus.smart,
    String? tag,
    T? result,
    bool force = false,
  }) async {
    return DialogProxy.instance.dismiss<T>(
      status: status,
      tag: tag,
      result: result,
      force: force,
    );
  }
}
