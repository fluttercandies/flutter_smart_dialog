import 'package:flutter/material.dart';

import 'enum_config.dart';

///showLoading() global config
///
///showLoading() 全局配置
class SmartConfigLoading {
  SmartConfigLoading({
    this.alignment = Alignment.center,
    this.animationType = SmartAnimationType.fade,
    this.animationTime = const Duration(milliseconds: 260),
    this.useAnimation = true,
    this.usePenetrate = false,
    this.maskColor = const Color.fromRGBO(0, 0, 0, 0.46),
    this.maskWidget,
    this.backDismiss = true,
    this.clickMaskDismiss = false,
    this.leastLoadingTime = const Duration(milliseconds: 0),
    this.awaitOverType = SmartAwaitOverType.dialogDismiss,
    this.maskTriggerType = SmartMaskTriggerType.up,
    this.nonAnimationTypes = const [
      SmartNonAnimationType.routeClose_nonAnimation,
    ],
    this.isExist = false,
  });

  /// control the location of the dialog on the screen
  ///
  /// center: the dialog locate the center on the screen，The animation type can be set using [animationType]
  ///
  /// bottomCenter、bottomLeft、bottomRight：the dialog locate the bottom on the screen，animation effect is bottom-to-up
  ///
  /// topCenter、topLeft、Alignment.topRight：the dialog locate the top on the screen，animation effect is up-to-bottom
  ///
  /// centerLeft：the dialog locate the left on the screen，animation effect is left-to-right
  ///
  /// centerRight：the dialog locate the right on the screen，animation effect is right-to-left
  ///
  /// -------------------------------------------------------------------------------
  ///
  /// 控制dialog位于屏幕的位置
  ///
  /// center: dialog位于屏幕中间，可使用[animationType]设置动画类型
  ///
  /// bottomCenter、bottomLeft、bottomRight：dialog位于屏幕底部，动画默认为位移动画，自下而上
  ///
  /// topCenter、topLeft、Alignment.topRight：dialog位于屏幕顶部，动画默认为位移动画，自上而下
  ///
  /// centerLeft：dialog位于屏幕左边，动画默认为位移动画，自左而右
  ///
  /// centerRight：dialog位于屏幕左边，动画默认为位移动画，自右而左
  final AlignmentGeometry alignment;

  /// [animationTime]：The animation time can be set
  ///
  /// [animationTime]：可设置动画时间
  final Duration animationTime;

  /// Animation type [animationType]：For details, please refer to the [SmartAnimationType] comment
  ///
  /// 动画类型[animationType]： 具体可参照[SmartAnimationType]注释
  final SmartAnimationType animationType;

  /// default（true），true（use the animation），false（not use）
  ///
  /// 是否使用动画（默认：true）
  final bool useAnimation;

  /// On-screen interaction events can penetrate the masked background:
  /// true（click event will penetrate background），false（not penetration）
  ///
  /// 屏幕上交互事件可以穿透遮罩背景：true（交互事件能穿透背景，遮罩会自动变成透明），false（不能穿透）
  final bool usePenetrate;

  /// the color of the mask，it is invalid if [usePenetrate] is true or [maskWidget] set the value
  ///
  /// 遮罩颜色：[usePenetrate]设置为true或[maskWidget]参数设置了数据，该参数会失效
  final Color maskColor;

  /// highly customizable mask, it is invalid if [usePenetrate] is true
  ///
  /// 遮罩Widget，可高度自定义你自己的遮罩背景：[usePenetrate]设置为true，该参数失效
  final Widget? maskWidget;

  /// true（the back event will close the loading but not close the page），
  /// false（the back event not close the loading and not close page），
  /// you still can use the dismiss method to close the loading
  ///
  /// true（返回事件将关闭loading，但是不会关闭页面），false（返回事件不会关闭loading，也不会关闭页面），
  /// 你仍然可以使用dismiss方法来关闭loading
  final bool backDismiss;

  /// true（dialog will be closed after click background），false（not close）
  ///
  /// true（点击遮罩关闭dialog），false（不关闭）
  final bool clickMaskDismiss;

  /// leastLoadingTime: If this param is set to 1 second, dismiss() is called immediately after showLoading(),
  /// loading will not be closed immediately, but will be closed when the loading time reaches 1 second
  ///
  /// 最小加载时间: 如果该参数设置为1秒, showLoading()之后立马调用dismiss(), loading不会立马关闭, 会在加载时间达到1秒的时候关闭
  final Duration leastLoadingTime;

  /// The type of dialog await ending
  ///
  /// 弹窗await结束的类型
  final SmartAwaitOverType awaitOverType;

  /// When the mask is clicked, the trigger timing type (please refer to the [SmartMaskTriggerType] note for details)
  ///
  /// 点击遮罩时, 被触发时机的类型 (具体请查看[SmartMaskTriggerType]注释)
  final SmartMaskTriggerType maskTriggerType;

  /// For different scenes, the pop-up animation can be dynamically closed.
  /// For details, please refer to [SmartNonAnimationType]
  ///
  /// 对于不同的场景, 可动态关闭弹窗动画, 具体请参照[SmartNonAnimationType]
  final List<SmartNonAnimationType> nonAnimationTypes;

  /// whether loading(showLoading()) exist on the screen
  ///
  /// loading(showLoading())是否存在在界面上
  bool isExist;
}
