import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_smart_dialog/src/data/notify_info.dart';
import 'package:flutter_smart_dialog/src/kit/typedef.dart';

import 'config/smart_config.dart';
import 'data/animation_param.dart';
import 'data/dialog_info.dart';
import 'helper/dialog_proxy.dart';
import 'kit/dialog_kit.dart';
import 'widget/attach_dialog_widget.dart';
import 'widget/helper/dialog_scope.dart';

class SmartDialog {
  SmartDialog._();

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
  /// [alignment]：control the location of the dialog, For details, please refer to the description of alignment parameters in [SmartConfigCustom]
  ///
  /// [clickMaskDismiss]：true（the dialog will be closed after click mask），false（not close）
  ///
  /// [animationType]：Set the animation type, For details, please refer to the [SmartAnimationType] comment
  ///
  /// [nonAnimationTypes]：For different scenes, the pop-up animation can be dynamically closed.
  /// For details, please refer to [SmartNonAnimationType]
  ///
  /// [animationBuilder]：Support highly custom animation, please refer to [AnimationBuilder] description for details
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
  /// [onMask]：This callback will be triggered when the mask is clicked
  ///
  /// [debounce]：debounce feature
  ///
  /// [onDismiss]：the callback will be invoked when the dialog is closed
  ///
  /// [displayTime]：Controls the display time of the dialog on the screen;
  /// the default is null, if it is null, it means that the param will not control the dialog to close;
  /// note: Using the [displayTime] param will disable the use of the [tag] param
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
  /// [tag], [keepSingle] and [permanent] are prohibited), false (using SmartDialog),
  /// using this param can make SmartDialog reasonably interact with the routing page and the dialog that comes with flutter
  ///
  /// [bindPage]：bind the dialog to the current page, the bound page is not on the top of the stack,
  /// the dialog is automatically hidden, the bound page is placed on the top of the stack, and the dialog is automatically displayed;
  /// the bound page is closed, and the dialog bound to the page will also be removed
  ///
  /// [bindWidget]：bind the dialog to a Widget, when the widget is not visible, the dialog is automatically hidden,
  /// and when the widget is visible, the dialog is automatically displayed; Applicable to PageView, TabView, etc., bind its sub-pages,
  /// and when switching pages, the dialog can also interact reasonably
  /// Note: The processing logic of [bindWidget] takes precedence over [bindPage]. When [bindWidget] is not null, [bindPage] will be automatically set to false.
  ///
  /// [ignoreArea]： dialog placeholder ignores area, supports up, down, left and right areas, set area, dialog will not occupy space in this area;
  /// Example: ignoreArea: Rect.fromLTRB (0,0,0,30), there will be 30 gaps at the bottom, and neither dialog nor mask will occupy this area;
  /// Applies to: do not want the dialog to overwrite the navigation bar area such as BottomNavigationBar, NavigationRail
  ///
  /// [backType]：For different processing types of return events,
  /// please refer to the description of [SmartBackType] for details
  ///
  /// [onBack]： Return event monitoring, return true, which means to intercept the back event;
  /// return false, which means not to intercept, and perform operations such as closing the dialog normally
  /// -------------------------------------------------------------------------------
  ///
  /// 自定义弹窗
  ///
  /// [builder]：自定义 dialog
  ///
  /// [controller]：可使用该控制器来刷新自定义的dialog的布局
  ///
  /// [alignment]：控制弹窗的位置, 详细请参照[SmartConfigCustom]中alignment参数说明
  ///
  /// [clickMaskDismiss]：true（点击遮罩后，将关闭dialog），false（不关闭）
  ///
  /// [animationType]：设置动画类型, 具体可参照[SmartAnimationType]注释
  ///
  /// [nonAnimationTypes]：对于不同的场景, 可动态关闭弹窗动画, 具体请参照[SmartNonAnimationType]
  ///
  /// [animationBuilder]：支持高度自定义动画, 具体可参照[AnimationBuilder]说明
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
  /// [onMask]：点击遮罩时，该回调将会被触发
  ///
  /// [debounce]：防抖功能
  ///
  /// [onDismiss]：在dialog被关闭的时候，该回调将会被触发
  ///
  /// [displayTime]：控制弹窗在屏幕上显示时间; 默认为null, 为null则代表该参数不会控制弹窗关闭;
  /// 注: 使用[displayTime]参数, 将禁止使用[tag]参数
  ///
  /// [tag]：如果你给dialog设置了tag, 你可以针对性的关闭它
  ///
  /// [backDismiss]：true（返回事件将关闭dialog，但是不会关闭页面），
  /// false（返回事件不会关闭loading，也不会关闭页面），你仍然可以使用dismiss方法来关闭dialog
  ///
  /// [keepSingle]：默认（false），true（多次调用[show]并不会生成多个dialog，仅仅保持一个dialog），
  /// false（多次调用[show]会生成多个dialog）
  ///
  /// [permanent]：默认（false），true（将该dialog设置为永久化dialog）,false(不设置);
  /// 框架内部各种兜底操作(返回事件,路由)无法关闭永久化dialog, 需要关闭此类dialog可使用: dismiss(force: true)
  ///
  /// [useSystem]：默认（false），true（使用系统dialog，[usePenetrate]功能失效; [tag], [keepSingle]和[permanent]禁止使用），
  /// false（使用SmartDialog），使用该参数可使SmartDialog, 与路由页面以及flutter自带dialog合理交互
  ///
  /// [bindPage]：将该dialog与当前页面绑定，绑定页面不在路由栈顶，dialog自动隐藏，绑定页面置于路由栈顶，dialog自动显示;
  /// 绑定页面被关闭,被绑定在该页面上的dialog也将被移除
  ///
  /// [bindWidget]：将dialog与某个Widget绑定, 当该widget不可见时, dialog自动隐藏, 该widget可见时, dialog自动显示;
  /// 适用于PageView, TabView之类, 绑定其子页面, 切换页面时, dialog也能合理交互
  /// 注意: [bindWidget]处理逻辑高于[bindPage], 当[bindWidget]不为null, [bindPage]将自动被设置为false
  ///
  /// [ignoreArea]：dialog占位忽略区域, 支持上下左右区域, 设置的区域, dialog将不会在此区域占位;
  /// 例: ignoreArea: Rect.fromLTRB(0, 0, 0, 30), 底部会有30空隙, dialog和mask都不会占位该区域;
  /// 适用于: 不想dialog覆盖BottomNavigationBar, NavigationRail之类的导航栏区域
  ///
  /// [backType]：对于返回事件不同的处理类型, 具体可参照[SmartBackType]说明
  ///
  /// [onBack]：返回事件监听，返回true，代表拦截此次返回事件；返回false，代表不拦截，正常执行关闭弹窗等操作
  static Future<T?> show<T>({
    required WidgetBuilder builder,
    SmartDialogController? controller,
    Alignment? alignment,
    bool? clickMaskDismiss,
    bool? usePenetrate,
    bool? useAnimation,
    SmartAnimationType? animationType,
    List<SmartNonAnimationType>? nonAnimationTypes,
    AnimationBuilder? animationBuilder,
    Duration? animationTime,
    Color? maskColor,
    Widget? maskWidget,
    bool? debounce,
    VoidCallback? onDismiss,
    VoidCallback? onMask,
    Duration? displayTime,
    String? tag,
    @Deprecated("please use backType") bool? backDismiss,
    bool? keepSingle,
    bool? permanent,
    bool? useSystem,
    bool? bindPage,
    BuildContext? bindWidget,
    Rect? ignoreArea,
    SmartBackType? backType,
    SmartOnBack? onBack,
  }) {
    assert(
      (useSystem == true && tag == null && permanent == null && keepSingle == null) || (useSystem == null || useSystem == false),
      'useSystem is true; tag, keepSingle and permanent prohibit setting values',
    );

    return DialogProxy.instance.show<T>(
      widget: DialogScope(
        controller: controller,
        builder: (context) => builder(context),
      ),
      alignment: alignment ?? config.custom.alignment,
      clickMaskDismiss: clickMaskDismiss ?? config.custom.clickMaskDismiss,
      animationType: animationType ?? config.custom.animationType,
      nonAnimationTypes: nonAnimationTypes ?? config.custom.nonAnimationTypes,
      animationBuilder: animationBuilder,
      usePenetrate: usePenetrate ?? config.custom.usePenetrate,
      useAnimation: useAnimation ?? config.custom.useAnimation,
      animationTime: animationTime ?? config.custom.animationTime,
      maskColor: maskColor ?? config.custom.maskColor,
      maskWidget: maskWidget ?? config.custom.maskWidget,
      debounce: debounce ?? config.custom.debounce,
      onDismiss: onDismiss,
      onMask: onMask,
      displayTime: displayTime,
      tag: tag,
      keepSingle: keepSingle ?? false,
      permanent: permanent ?? false,
      useSystem: useSystem ?? false,
      bindPage: (bindPage ?? config.custom.bindPage) && bindWidget == null,
      bindWidget: bindWidget,
      ignoreArea: ignoreArea,
      backType: backType ?? (backDismiss == null ? config.custom.backType : (backDismiss ? SmartBackType.normal : SmartBackType.block)),
      onBack: onBack,
    );
  }

  /// attach dialog
  ///
  /// [targetContext]：BuildContext with target widget
  ///
  /// [builder]：the custom dialog
  ///
  /// [replaceBuilder]：deprecated, please use adjustBuilder
  ///
  /// [adjustBuilder]：The widget returned in [adjustBuilder] will replace the widget returned in [builder];
  /// [adjustBuilder] will callback the offset and size of the target widget and the offset and size of the dialog itself.
  /// You can customize a suitable replacement widget according to these parameters.
  /// It is strongly recommended that the width and height of the custom widget returned by [adjustBuilder] should be consistent with that in [builder],
  /// and the positioning information in showAttach is calculated based on the widget in [builder].
  ///
  /// [controller]：this controller can be used to refresh the layout of the custom dialog
  ///
  /// [targetBuilder]：Manually specify the appropriate coordinate point.
  /// When targetBuilder is used, the targetContext param will not be able to automatically set the position.
  /// The param of the targetBuilder callback are calculated according to the targetContext
  ///
  /// [alignment]：control the location of the dialog, For details, please refer to the description of alignment parameters in [SmartConfigAttach]
  ///
  /// [clickMaskDismiss]：true（the dialog will be closed after click mask），false（not close）
  ///
  /// [animationType]：Set the animation type, For details, please refer to the [SmartAnimationType] comment
  ///
  /// [nonAnimationTypes]：For different scenes, the pop-up animation can be dynamically closed.
  /// For details, please refer to [SmartNonAnimationType]
  ///
  /// [animationBuilder]：Support highly custom animation, please refer to [AnimationBuilder] description for details
  ///
  /// [scalePointBuilder]：he zoom point of the zoom animation, the default point is the center point of the attach widget as the zoom point;
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
  /// [maskIgnoreArea]：mask occupancy ignore area, support up, down, left and right areas, set area, mask will not occupy space in this area;
  /// Example: maskIgnoreArea: Rect.fromLTRB (0,0,0,30), there will be 30 gaps at the bottom, the mask will not occupy this area;
  /// Applies to: do not want mask to cover navigation bar areas such as BottomNavigationBar, NavigationRail
  ///
  /// [onMask]：this callback will be triggered when the mask is clicked
  ///
  /// [debounce]：debounce feature
  ///
  /// [highlightBuilder]：highlight function, dissolve the mask of a specific area,
  /// you can quickly get the target widget information (coordinates and size)
  ///
  /// [onDismiss]：the callback will be invoked when the dialog is closed
  ///
  /// [displayTime]：Controls the display time of the dialog on the screen;
  /// the default is null, if it is null, it means that the param will not control the dialog to close;
  /// note: Using the [displayTime] param will disable the use of the [tag] param
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
  /// [tag], [keepSingle] and [permanent] are prohibited), false (using SmartDialog),
  /// using this param can make SmartDialog reasonably interact with the routing page and the dialog that comes with flutter
  ///
  /// [bindPage]：bind the dialog to the current page, the bound page is not on the top of the stack,
  /// the dialog is automatically hidden, the bound page is placed on the top of the stack, and the dialog is automatically displayed;
  /// the bound page is closed, and the dialog bound to the page will also be removed
  ///
  /// [bindWidget]：bind the dialog to a Widget, when the widget is not visible, the dialog is automatically hidden,
  /// and when the widget is visible, the dialog is automatically displayed; Applicable to PageView, TabView, etc., bind its sub-pages,
  /// and when switching pages, the dialog can also interact reasonably
  /// Note: The processing logic of [bindWidget] takes precedence over [bindPage]. When [bindWidget] is not null, [bindPage] will be automatically set to false.
  ///
  /// [backType]：For different processing types of return events,
  /// please refer to the description of [SmartBackType] for details
  ///
  /// [onBack]：Return event monitoring, return true, which means to intercept the back event;
  /// return false, which means not to intercept, and perform operations such as closing the dialog normally
  /// -------------------------------------------------------------------------------
  ///
  /// 定位弹窗
  ///
  /// [targetContext]：伴随位置widget的BuildContext
  ///
  /// [builder]：自定义 dialog
  ///
  /// [replaceBuilder]：已废弃, 请使用adjustBuilder
  ///
  /// [adjustBuilder]：[adjustBuilder]中返回widget会替换掉[builder]中返回的widget;
  /// [adjustBuilder]将回调目标widget的坐标,大小和dialog自身的坐标,大小,你可以根据这些参数,重新自定义一个合适的替换widget,
  /// 强烈建议[adjustBuilder]返回的自定义的widget宽高和[builder]中的保持一致, showAttach中定位信息都是根据[builder]中widget计算得来的
  ///
  /// [controller]：可使用该控制器来刷新自定义的dialog的布局
  ///
  /// [targetBuilder]：手动指定合适坐标点，当targetBuilder被使用时，targetContext参数将无法自动设置位置,
  /// targetBuilder回调的参数是根据targetContext计算得来的
  ///
  /// [alignment]：控制弹窗的位置, 详细请参照[SmartConfigAttach]中alignment参数说明
  ///
  /// [clickMaskDismiss]：true（点击遮罩后，将关闭dialog），false（不关闭）
  ///
  /// [animationType]：具体可参照[SmartAnimationType]注释
  ///
  /// [nonAnimationTypes]：对于不同的场景, 可动态关闭弹窗动画, 具体请参照[SmartNonAnimationType]
  ///
  /// [animationBuilder]：支持高度自定义动画, 具体可参照[AnimationBuilder]说明
  ///
  /// [scalePointBuilder]：缩放动画的缩放点, 默认点将自定义dialog控件的中心点作为缩放点;
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
  /// [maskIgnoreArea]：mask占位忽略区域, 支持上下左右区域, 设置的区域, mask将不会在此区域占位;
  /// 例: maskIgnoreArea: Rect.fromLTRB(0, 0, 0, 30), 底部会有30空隙, mask不会占位该区域;
  /// 适用于: 不想mask覆盖BottomNavigationBar, NavigationRail之类的导航栏区域
  ///
  /// [onMask]：点击遮罩时，该回调将会被触发
  ///
  /// [debounce]：防抖功能
  ///
  /// [highlightBuilder]：高亮功能，溶解特定区域的遮罩，可以快速获取目标widget信息（坐标和大小）
  ///
  /// [onDismiss]：在dialog被关闭的时候，该回调将会被触发
  ///
  /// [displayTime]：控制弹窗在屏幕上显示时间; 默认为null, 为null则代表该参数不会控制弹窗关闭;
  /// 注: 使用[displayTime]参数, 将禁止使用[tag]参数
  ///
  /// [tag]：如果你给dialog设置了tag, 你可以针对性的关闭它
  ///
  /// [backDismiss]：true（返回事件将关闭dialog，但是不会关闭页面），
  /// false（返回事件不会关闭loading，也不会关闭页面），你仍然可以使用dismiss方法来关闭dialog
  ///
  /// [keepSingle]：默认（false），true（多次调用[showAttach]并不会生成多个dialog，仅仅保持一个dialog），
  /// false（多次调用[showAttach]会生成多个dialog）
  ///
  /// [permanent]：默认（false），true（将该dialog设置为永久化dialog）,false(不设置);
  /// 框架内部各种兜底操作(返回事件,路由)无法关闭永久化dialog, 需要关闭此类dialog可使用: dismiss(force: true)
  ///
  /// [useSystem]：默认（false），true（使用系统dialog，[usePenetrate]功能失效; [tag], [keepSingle]和[permanent]禁止使用），
  /// false（使用SmartDialog），使用该参数可使SmartDialog, 与路由页面以及flutter自带dialog合理交互
  ///
  /// [bindPage]：将该dialog与当前页面绑定，绑定页面不在路由栈顶，dialog自动隐藏，绑定页面置于路由栈顶，dialog自动显示;
  /// 绑定页面被关闭,被绑定在该页面上的dialog也将被移除
  ///
  /// [bindWidget]：将dialog与某个Widget绑定, 当该widget不可见时, dialog自动隐藏, 该widget可见时, dialog自动显示;
  /// 适用于PageView, TabView之类, 绑定其子页面, 切换页面时, dialog也能合理交互
  /// 注意: [bindWidget]处理路由逻辑高于[bindPage], 当[bindWidget]不为null, [bindPage]将自动被设置为false
  ///
  /// [backType]：对于返回事件不同的处理类型, 具体可参照[SmartBackType]说明
  ///
  /// [onBack]：返回事件监听，返回true，代表拦截此次返回事件；返回false，代表不拦截，正常执行关闭弹窗等操作
  static Future<T?> showAttach<T>({
    required BuildContext? targetContext,
    required WidgetBuilder builder,
    @Deprecated("Please use adjustBuilder") ReplaceBuilder? replaceBuilder,
    AdjustBuilder? adjustBuilder,
    SmartDialogController? controller,
    TargetBuilder? targetBuilder,
    Alignment? alignment,
    bool? clickMaskDismiss,
    SmartAnimationType? animationType,
    List<SmartNonAnimationType>? nonAnimationTypes,
    AnimationBuilder? animationBuilder,
    ScalePointBuilder? scalePointBuilder,
    bool? usePenetrate,
    bool? useAnimation,
    Duration? animationTime,
    Color? maskColor,
    Widget? maskWidget,
    Rect? maskIgnoreArea,
    VoidCallback? onMask,
    bool? debounce,
    HighlightBuilder? highlightBuilder,
    VoidCallback? onDismiss,
    Duration? displayTime,
    String? tag,
    @Deprecated("please use backType") bool? backDismiss,
    bool? keepSingle,
    bool? permanent,
    bool? useSystem,
    bool? bindPage,
    BuildContext? bindWidget,
    SmartBackType? backType,
    SmartOnBack? onBack,
  }) {
    assert(
      targetContext != null || targetBuilder != null,
      'targetContext and target, cannot both be null',
    );
    assert(
      (useSystem == true && tag == null && permanent == null && keepSingle == null) || (useSystem == null || useSystem == false),
      'useSystem is true; tag, keepSingle and permanent prohibit setting values',
    );

    return DialogProxy.instance.showAttach<T>(
      targetContext: targetContext,
      widget: DialogScope(
        controller: controller,
        builder: (context) => builder(context),
      ),
      targetBuilder: targetBuilder,
      replaceBuilder: replaceBuilder,
      adjustBuilder: adjustBuilder,
      alignment: alignment ?? config.attach.alignment,
      clickMaskDismiss: clickMaskDismiss ?? config.attach.clickMaskDismiss,
      animationType: animationType ?? config.attach.animationType,
      nonAnimationTypes: nonAnimationTypes ?? config.attach.nonAnimationTypes,
      animationBuilder: animationBuilder,
      scalePointBuilder: scalePointBuilder,
      usePenetrate: usePenetrate ?? config.attach.usePenetrate,
      useAnimation: useAnimation ?? config.attach.useAnimation,
      animationTime: animationTime ?? config.attach.animationTime,
      maskColor: maskColor ?? config.attach.maskColor,
      maskWidget: maskWidget ?? config.attach.maskWidget,
      maskIgnoreArea: maskIgnoreArea,
      onMask: onMask,
      debounce: debounce ?? config.attach.debounce,
      highlightBuilder: highlightBuilder,
      onDismiss: onDismiss,
      displayTime: displayTime,
      tag: tag,
      keepSingle: keepSingle ?? false,
      permanent: permanent ?? false,
      useSystem: useSystem ?? false,
      bindPage: (bindPage ?? config.attach.bindPage) && bindWidget == null,
      bindWidget: bindWidget,
      backType: backType ?? (backDismiss == null ? config.attach.backType : (backDismiss ? SmartBackType.normal : SmartBackType.block)),
      onBack: onBack,
    );
  }

  /// By setting NotifyType, many different types of Notify dialog can be used
  ///
  /// [msg]：notify msg (Use the [builder] param, this param will be invalid)
  ///
  /// [notifyType]：specify the notify dialog type
  ///
  /// [builder]：the notify dialog
  ///
  /// [controller]：this controller can be used to refresh the layout of the custom dialog
  ///
  /// [alignment]：control the location of the dialog, For details, please refer to the description of alignment parameters in [SmartConfigCustom]
  ///
  /// [clickMaskDismiss]：true（the dialog will be closed after click mask），false（not close）
  ///
  /// [animationType]：Set the animation type, For details, please refer to the [SmartAnimationType] comment
  ///
  /// [nonAnimationTypes]：For different scenes, the pop-up animation can be dynamically closed.
  /// For details, please refer to [SmartNonAnimationType]
  ///
  /// [animationBuilder]：Support highly custom animation, please refer to [AnimationBuilder] description for details
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
  /// [onMask]：This callback will be triggered when the mask is clicked
  ///
  /// [debounce]：debounce feature
  ///
  /// [onDismiss]：the callback will be invoked when the dialog is closed
  ///
  /// [displayTime]：Controls the display time of the dialog on the screen;
  /// the default is null, if it is null, it means that the param will not control the dialog to close;
  ///
  /// [tag]：If you set a tag for the dialog, you can turn it off in a targeted manner
  ///
  /// [keepSingle]：default (false), true (calling [show] multiple times will not generate multiple dialogs,
  /// only single dialog will be kept), false (calling [show] multiple times will generate multiple dialogs)
  ///
  /// [backType]：For different processing types of return events,
  /// please refer to the description of [SmartBackType] for details
  ///
  /// [onBack]： Return event monitoring, return true, which means to intercept the back event;
  /// return false, which means not to intercept, and perform operations such as closing the dialog normally
  /// [title] - The title of the toast, displayed above the message if [titleWidget] is not provided.
  ///
  /// [titleWidget] - Custom widget for the title, used instead of [title] if provided.
  ///
  /// [leadingWidget] - Widget displayed before the title and message, typically an icon.
  ///
  /// [trailingWidget] - Widget displayed after the title and message, typically an icon or button.
  ///
  /// [color] - Background color of the toast container. Defaults to theme's background color.
  ///
  /// [txtColor] - Text color for both title and message if [txtStyle] or [titleStyle] is not provided.
  ///
  /// [txtStyle] - Text style for the message text.
  ///
  /// [margin] - Space between the title/message and the container edges.
  ///
  /// [padding] - Padding inside the container around the title and message.
  ///
  /// [spaceAroundTxt] - Space between the title, message, and any leading or trailing widget.
  ///
  /// [isHorizontal] - If `true`, the layout is horizontal; otherwise, it is vertical.
  ///
  /// [msg] - The main message displayed in the toast. This is a required parameter.
  ///
  /// [titleStyle] - Text style for the title, allowing customization of font size, weight, etc.
  ///
  /// [borderRadius] - Border radius for the toast container.
  /// -------------------------------------------------------------------------------
  ///
  /// 通过设置NotifyType, 可使用多种不同类型的提示弹窗
  ///
  /// [msg]：notify 的信息（使用[builder]参数，该参数将失效）
  ///
  /// [notifyType]：指定通知弹窗类型
  ///
  /// [builder]：自定义 notify dialog
  ///
  /// [controller]：可使用该控制器来刷新自定义的dialog的布局
  ///
  /// [alignment]：控制弹窗的位置, 详细请参照[SmartConfigCustom]中alignment参数说明
  ///
  /// [clickMaskDismiss]：true（点击遮罩后，将关闭dialog），false（不关闭）
  ///
  /// [animationType]：设置动画类型, 具体可参照[SmartAnimationType]注释
  ///
  /// [nonAnimationTypes]：对于不同的场景, 可动态关闭弹窗动画, 具体请参照[SmartNonAnimationType]
  ///
  /// [animationBuilder]：支持高度自定义动画, 具体可参照[AnimationBuilder]说明
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
  /// [onMask]：点击遮罩时，该回调将会被触发
  ///
  /// [debounce]：防抖功能
  ///
  /// [onDismiss]：在dialog被关闭的时候，该回调将会被触发
  ///
  /// [displayTime]：控制弹窗在屏幕上显示时间; 默认为null, 为null则代表该参数不会控制弹窗关闭;
  ///
  /// [tag]：如果你给dialog设置了tag, 你可以针对性的关闭它
  ///
  /// [keepSingle]：默认（false），true（多次调用[show]并不会生成多个dialog，仅仅保持一个dialog），
  /// false（多次调用[show]会生成多个dialog）
  ///
  /// [backType]：对于返回事件不同的处理类型, 具体可参照[SmartBackType]说明
  ///
  /// [onBack]：返回事件监听，返回true，代表拦截此次返回事件；返回false，代表不拦截，正常执行关闭弹窗等操作
  ///
  static Future<T?> showNotify<T>({
    required String msg,
    required NotifyType notifyType,
    WidgetBuilder? builder,
    SmartDialogController? controller,
    Alignment? alignment,
    bool? clickMaskDismiss,
    bool? usePenetrate,
    bool? useAnimation,
    SmartAnimationType? animationType,
    List<SmartNonAnimationType>? nonAnimationTypes,
    AnimationBuilder? animationBuilder,
    Duration? animationTime,
    Color? maskColor,
    Widget? maskWidget,
    bool? debounce,
    VoidCallback? onDismiss,
    VoidCallback? onMask,
    Duration? displayTime,
    String? tag,
    bool? keepSingle,
    bool isHorizontal = false,
    SmartBackType? backType,
    SmartOnBack? onBack,
    String? title,
    Widget? titleWidget,
    Widget? leadingWidget,
    Widget? trailingWidget,
    Color? color,
    Color? txtColor,
    TextStyle? txtStyle,
    EdgeInsets? margin,
    double? spaceAroundTxt,
    EdgeInsets? padding,
    TextStyle? titleStyle,
    BorderRadius? borderRadius,
  }) {
    return DialogProxy.instance.showNotify<T>(
      widget: DialogScope(
        controller: controller,
        builder: (context) {
          if (builder != null) {
            return builder(context);
          }

          Widget? widget;
          var notifyStyle = DialogProxy.instance.notifyStyle;
          FlutterSmartToastBuilder? flutterSmartToastBuilder = {
            NotifyType.success: notifyStyle.successBuilder,
            NotifyType.failure: notifyStyle.failureBuilder,
            NotifyType.warning: notifyStyle.warningBuilder,
            NotifyType.alert: notifyStyle.alertBuilder,
            NotifyType.error: notifyStyle.errorBuilder,
          }[notifyType];

          widget = flutterSmartToastBuilder?.call(
            msg: msg,
            title: title,
            titleWidget: titleWidget,
            trailingWidget: trailingWidget,
            color: color,
            txtColor: txtColor,
            txtStyle: txtStyle,
            margin: margin,
            spaceAroundTxt: spaceAroundTxt,
            padding: padding,
            isHorizontal: isHorizontal,
            titleStyle: titleStyle,
            borderRadius: borderRadius,
          );
          return widget ?? Container();
        },
      ),
      alignment: alignment ?? config.notify.alignment,
      clickMaskDismiss: clickMaskDismiss ?? config.notify.clickMaskDismiss,
      animationType: animationType ?? config.notify.animationType,
      nonAnimationTypes: nonAnimationTypes ?? config.notify.nonAnimationTypes,
      animationBuilder: animationBuilder,
      usePenetrate: usePenetrate ?? config.notify.usePenetrate,
      useAnimation: useAnimation ?? config.notify.useAnimation,
      animationTime: animationTime ?? config.notify.animationTime,
      maskColor: maskColor ?? config.notify.maskColor,
      maskWidget: maskWidget ?? config.notify.maskWidget,
      debounce: debounce ?? config.notify.debounce,
      onDismiss: onDismiss,
      onMask: onMask,
      displayTime: displayTime ?? config.notify.displayTime,
      tag: tag,
      keepSingle: keepSingle ?? false,
      backType: backType ?? config.notify.backType,
      onBack: onBack,
    );
  }

  /// loading dialog
  ///
  /// [msg]：loading msg (Use the [builder] param, this param will be invalid)
  ///
  /// [controller]：this controller can be used to refresh the layout of the custom loading
  ///
  /// [alignment]：control the location of the dialog, For details, please refer to the description of alignment parameters in [SmartConfigLoading]
  ///
  /// [clickMaskDismiss]：true（loading will be closed after click mask），false（not close）
  ///
  /// [animationType]：For details, please refer to the [SmartAnimationType] comment
  ///
  /// [nonAnimationTypes]：For different scenes, the pop-up animation can be dynamically closed.
  /// For details, please refer to [SmartNonAnimationType]
  ///
  /// [animationBuilder]：Support highly custom animation, please refer to [AnimationBuilder] description for details
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
  /// [onDismiss]：This callback will be triggered when the dialog is closed
  ///
  /// [onMask]：This callback will be triggered when the mask is clicked
  ///
  /// [displayTime]：Controls the display time of the dialog on the screen;
  /// the default is null, if it is null, it means that the param will not control the dialog to close
  ///
  /// [backDismiss]：true（the back event will close the loading but not close the page），
  /// false（the back event not close the loading and not close page），
  /// you still can use the dismiss method to close the loading
  ///
  /// [backType]：For different processing types of return events,
  /// please refer to the description of [SmartBackType] for details
  ///
  /// [onBack]： Return event monitoring, return true, which means to intercept the back event;
  /// return false, which means not to intercept, and perform operations such as closing the dialog normally
  ///
  /// [builder]：the custom loading
  ///
  /// [color] - Background color of the widget. Defaults to theme's background color.
  ///
  /// [txtColor] - Text color for the loading message. Defaults to theme's text color.
  ///
  /// [loadingColor] - Color of the loading indicator. Defaults to [txtColor] or theme's text color.
  ///
  /// [spacer] - Space between the loading indicator and message text. Default is 20.
  ///
  /// [loadingIndicator] - Custom loading indicator widget. Defaults to a [CircularProgressIndicator].
  ///
  /// [borderRadius] - Border radius for the container. Defaults to 15 if not specified.
  ///
  /// [msgStyle] - Text style for the message, allowing customization of font size, color, etc.
  ///
  /// [isHorizontal] - If `true`, the layout is horizontal; otherwise, it is vertical.
  ///
  /// [padding] - Dialog padding.

  /// -------------------------------------------------------------------------------
  ///
  /// loading弹窗
  ///
  /// [msg]：loading 的信息（使用[builder]参数，该参数将失效）
  ///
  /// [controller]：可使用该控制器来刷新自定义的loading的布局
  ///
  /// [alignment]：控制弹窗的位置, 详细请参照[SmartConfigLoading]中alignment参数说明
  ///
  /// [clickMaskDismiss]：true（点击遮罩后，将关闭loading），false（不关闭）
  ///
  /// [animationType]：具体可参照[SmartAnimationType]注释
  ///
  /// [nonAnimationTypes]：对于不同的场景, 可动态关闭弹窗动画, 具体请参照[SmartNonAnimationType]
  ///
  /// [animationBuilder]：支持高度自定义动画, 具体可参照[AnimationBuilder]说明
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
  /// [onDismiss]：在dialog被关闭的时候，该回调将会被触发
  ///
  /// [onMask]：点击遮罩时，该回调将会被触发
  ///
  /// [displayTime]：控制弹窗在屏幕上显示时间; 默认为null, 为null则代表该参数不会控制弹窗关闭
  ///
  /// [backDismiss]：true（返回事件将关闭loading，但是不会关闭页面），false（返回事件不会关闭loading，也不会关闭页面），
  /// 你仍然可以使用dismiss方法来关闭loading
  ///
  /// [backType]：对于返回事件不同的处理类型, 具体可参照[SmartBackType]说明
  ///
  /// [onBack]：返回事件监听，返回true，代表拦截此次返回事件；返回false，代表不拦截，正常执行关闭弹窗等操作
  ///
  /// [builder]：自定义loading
  static Future<T?> showLoading<T>(
      {String msg = 'loading...',
      SmartDialogController? controller,
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
      @Deprecated("please use backType") bool? backDismiss,
      SmartBackType? backType,
      SmartOnBack? onBack,
      WidgetBuilder? builder,
      Color? color,
      Color? txtColor,
      Color? loadingColor,
      double spacer = 20,
      Widget? loadingIndicator,
      BorderRadius? borderRadius,
      TextStyle? msgStyle,
      bool isHorizontal = false,
      SmartAwaitOverType? awaitOverType}) {
    print('showLoading backType = $backType');
    return DialogProxy.instance.showLoading<T>(
      widget: DialogScope(
        controller: controller,
        builder: (context) {
          return builder != null
              ? builder(context)
              : DialogProxy.instance.loadingBuilder(
                  msg: msg,
                  color: color,
                  txtColor: txtColor,
                  loadingColor: loadingColor,
                  spacer: spacer,
                  loadingIndicator: loadingIndicator,
                  borderRadius: borderRadius,
                  msgStyle: msgStyle,
                  isHorizontal: isHorizontal,
                );
        },
      ),
      alignment: alignment ?? config.loading.alignment,
      clickMaskDismiss: clickMaskDismiss ?? config.loading.clickMaskDismiss,
      animationType: animationType ?? config.loading.animationType,
      nonAnimationTypes: nonAnimationTypes ?? config.loading.nonAnimationTypes,
      animationBuilder: animationBuilder,
      usePenetrate: usePenetrate ?? config.loading.usePenetrate,
      useAnimation: useAnimation ?? config.loading.useAnimation,
      animationTime: animationTime ?? config.loading.animationTime,
      maskColor: maskColor ?? config.loading.maskColor,
      maskWidget: maskWidget ?? config.loading.maskWidget,
      onDismiss: onDismiss,
      awaitOverType: awaitOverType,
      onMask: onMask,
      displayTime: displayTime,
      backType: backType ?? (backDismiss == null ? config.loading.backType : (backDismiss ? SmartBackType.normal : SmartBackType.block)),
      onBack: onBack,
    );
  }

  /// toast message
  ///
  /// [msg]：msg presented to users (Use the [builder] param to customize the toast, this param will be invalid)
  ///
  /// [controller]：this controller can be used to refresh the layout of the custom toast
  ///
  /// [displayTime]：toast display time on the screen
  ///
  /// [alignment]：control the location of the dialog, For details, please refer to the description of alignment parameters in [SmartConfigToast]
  ///
  /// [clickMaskDismiss]：true（toast will be closed after click mask），false（not close）
  ///
  /// [animationType]：For details, please refer to the [SmartAnimationType] comment
  ///
  /// [nonAnimationTypes]：For different scenes, the pop-up animation can be dynamically closed.
  /// For details, please refer to [SmartNonAnimationType]
  ///
  /// [animationBuilder]：Support highly custom animation, please refer to [AnimationBuilder] description for details
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
  /// [onDismiss]：This callback will be triggered when the dialog is closed
  ///
  /// [onMask]：This callback will be triggered when the mask is clicked
  ///
  /// [consumeEvent]：true (toast will consume touch events),
  /// false (toast no longer consumes events, touch events can penetrate toast)
  ///
  /// [debounce]：debounce feature
  ///
  /// [displayType]：provider multiple display logic，
  /// please refer to [SmartToastType] comment for detailed description
  ///
  /// [builder]：the custom toast
  ///
  /// [title] - The title of the toast, displayed above the message if [titleWidget] is not provided.
  ///
  /// [titleWidget] - Custom widget for the title, used instead of [title] if provided.
  ///
  /// [leadingWidget] - Widget displayed before the title and message, typically an icon.
  ///
  /// [trailingWidget] - Widget displayed after the title and message, typically an icon or button.
  ///
  /// [color] - Background color of the toast container. Defaults to theme's background color.
  ///
  /// [txtColor] - Text color for both title and message if [txtStyle] or [titleStyle] is not provided.
  ///
  /// [txtStyle] - Text style for the message text.
  ///
  /// [margin] - Space between the title/message and the container edges.
  ///
  /// [padding] - Padding inside the container around the title and message.
  ///
  /// [spaceAroundTxt] - Space between the title, message, and any leading or trailing widget.
  ///
  /// [isHorizontal] - If `true`, the layout is horizontal; otherwise, it is vertical.
  ///
  /// [msg] - The main message displayed in the toast. This is a required parameter.
  ///
  /// [titleStyle] - Text style for the title, allowing customization of font size, weight, etc.
  ///
  /// [borderRadius] - Border radius for the toast container.

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
  /// [alignment]：控制弹窗的位置, 详细请参照[SmartConfigToast]中alignment参数说明
  ///
  /// [clickMaskDismiss]：true（点击遮罩后，将关闭toast），false（不关闭）
  ///
  /// [animationType]：具体可参照[SmartAnimationType]注释
  ///
  /// [nonAnimationTypes]：对于不同的场景, 可动态关闭弹窗动画, 具体请参照[SmartNonAnimationType]
  ///
  /// [animationBuilder]：支持高度自定义动画, 具体可参照[AnimationBuilder]说明
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
  /// [onDismiss]：在dialog被关闭的时候，该回调将会被触发
  ///
  /// [onMask]：点击遮罩时，该回调将会被触发
  ///
  /// [consumeEvent]：true（toast会消耗触摸事件），false（toast不再消耗事件，触摸事件能穿透toast）
  ///
  /// [debounce]：防抖功能
  ///
  /// [displayType]：提供多种显示逻辑，详细描述请查看 [SmartToastType] 注释
  ///
  /// [builder]：自定义toast
  static Future<void> showToast(
    String msg, {
    SmartDialogController? controller,
    Duration? displayTime,
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
    bool? consumeEvent,
    bool? debounce,
    SmartToastType? displayType,
    WidgetBuilder? builder,
    // ToastWidget specific parameters
    String? title,
    Widget? titleWidget,
    Widget? leadingWidget,
    Widget? trailingWidget,
    Color? color,
    Color? txtColor,
    TextStyle? txtStyle,
    EdgeInsets? margin,
    double spaceAroundTxt = 8,
    EdgeInsets? padding,
    bool isHorizontal = true,
    TextStyle? titleStyle,
    BorderRadius? borderRadius,
  }) async {
    return DialogProxy.instance.showToast(
      widget: DialogScope(
        controller: controller,
        builder: (context) {
          return builder != null
              ? builder(context)
              : DialogProxy.instance.toastBuilder(
                  msg: msg,
                  title: title,
                  titleWidget: titleWidget,
                  leadingWidget: leadingWidget,
                  trailingWidget: trailingWidget,
                  color: color,
                  txtColor: txtColor,
                  txtStyle: txtStyle,
                  margin: margin,
                  spaceAroundTxt: spaceAroundTxt,
                  padding: padding,
                  isHorizontal: isHorizontal,
                  titleStyle: titleStyle,
                  borderRadius: borderRadius,
                );
        },
      ),
      displayTime: displayTime ?? config.toast.displayTime,
      alignment: alignment ?? config.toast.alignment,
      clickMaskDismiss: clickMaskDismiss ?? config.toast.clickMaskDismiss,
      animationType: animationType ?? config.toast.animationType,
      nonAnimationTypes: nonAnimationTypes ?? config.toast.nonAnimationTypes,
      animationBuilder: animationBuilder,
      usePenetrate: usePenetrate ?? config.toast.usePenetrate,
      useAnimation: useAnimation ?? config.toast.useAnimation,
      animationTime: animationTime ?? config.toast.animationTime,
      maskColor: maskColor ?? config.toast.maskColor,
      maskWidget: maskWidget ?? config.toast.maskWidget,
      onDismiss: onDismiss,
      onMask: onMask,
      debounce: debounce ?? config.toast.debounce,
      displayType: displayType ?? config.toast.displayType,
      consumeEvent: consumeEvent ?? config.toast.consumeEvent,
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

  /// Check whether the relevant dialog exists on the interface,
  /// if the tag attribute is used, dialogTypes will be invalid
  ///
  /// 检查相关dialog是否存在于界面上，如果使用tag属性，dialogTypes将失效
  static bool checkExist({
    String? tag,
    Set<SmartAllDialogType> dialogTypes = const {
      SmartAllDialogType.custom,
      SmartAllDialogType.attach,
      SmartAllDialogType.loading,
    },
  }) {
    return DialogKit.instance.checkExist(tag: tag, dialogTypes: dialogTypes);
  }

  /// check isAnyShown
  static bool get isAnyShown => checkExist(dialogTypes: {
        SmartAllDialogType.custom,
        SmartAllDialogType.attach,
        SmartAllDialogType.loading,
        SmartAllDialogType.notify,
        SmartAllDialogType.toast,
      });

  /// check isDialogShown
  static bool get isDialogShown => isCustomShown || isAttachShown;

  /// check isToastShown
  static bool get isToastShown => checkExist(dialogTypes: {SmartAllDialogType.toast});

  /// check isNotifyShown
  static bool get isNotifyShown => checkExist(dialogTypes: {SmartAllDialogType.notify});

  /// check isAttachShown
  static bool get isAttachShown => checkExist(dialogTypes: {SmartAllDialogType.attach});

  /// check isLoadingShown
  static bool get isLoadingShown => checkExist(dialogTypes: {SmartAllDialogType.loading});

  /// check isCustomShown
  static bool get isCustomShown => checkExist(dialogTypes: {SmartAllDialogType.custom});

  /// get firstDialogInfo
  static DialogInfo? get firstDialogInfo => DialogProxy.instance.dialogQueue.firstOrNull;

  /// get lastDialogInfo
  static DialogInfo? get lastDialogInfo => DialogProxy.instance.dialogQueue.lastOrNull;

  /// get dialogQueueInfo
  static Queue<DialogInfo> get dialogQueueInfo => DialogProxy.instance.dialogQueue;

  /// get firstNotifyInfo
  static NotifyInfo? get firstNotifyInfo => DialogProxy.instance.notifyQueue.firstOrNull;

  /// get lastNotifyInfo
  static NotifyInfo? get lastNotifyInfo => DialogProxy.instance.notifyQueue.lastOrNull;

  /// get notifyQueueInfo
  static Queue<NotifyInfo> get notifyQueueInfo => DialogProxy.instance.notifyQueue;

  /// check isCurrentDialogBackDismissible
  /// bool includeLoading to check loading or not
  static bool isCurrentDialogBackDismissible({bool includeLoading = true}) {
    if (!isAnyShown) return false;

    // Check custom dialog conditions
    if (config.custom.isExist && lastDialogInfo?.backType != SmartBackType.normal) return false;

    // Additional check for loading dialogs if includeLoading is true
    if (includeLoading && config.loading.isExist && (DialogProxy.instance.loadingInfo.backType != SmartBackType.normal)) return false;

    return true;
  }
}

extension SmartDialogIterableExtensions<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
  T? get lastOrNull => isEmpty ? null : last;
}