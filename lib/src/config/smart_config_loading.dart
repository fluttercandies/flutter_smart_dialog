import 'package:flutter/material.dart';

import 'enum_config.dart';

///showLoading() global config
///
///showLoading() 全局配置
class SmartConfigLoading {
  SmartConfigLoading({
    this.alignment = Alignment.center,
    this.animationType = SmartAnimationType.fade,
    this.animationTime = const Duration(milliseconds: 200),
    this.useAnimation = true,
    this.usePenetrate = false,
    this.maskColor = const Color.fromRGBO(0, 0, 0, 0.46),
    this.maskWidget,
    this.clickMaskDismiss = false,
    this.leastLoadingTime = const Duration(milliseconds: 0),
    this.awaitOverType = SmartAwaitOverType.dialogDismiss,
    this.maskTriggerType = SmartMaskTriggerType.up,
    this.nonAnimationTypes = const [
      SmartNonAnimationType.routeClose_nonAnimation,
      SmartNonAnimationType.continueLoading_nonAnimation,
    ],
    this.backType = SmartBackType.block,
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
  Alignment alignment;

  /// [animationTime]：The animation time can be set
  ///
  /// [animationTime]：可设置动画时间
  Duration animationTime;

  /// Animation type [animationType]：For details, please refer to the [SmartAnimationType] comment
  ///
  /// 动画类型[animationType]： 具体可参照[SmartAnimationType]注释
  SmartAnimationType animationType;

  /// default（true），true（use the animation），false（not use）
  ///
  /// 是否使用动画（默认：true）
  bool useAnimation;

  /// On-screen interaction events can penetrate the masked background:
  /// true（click event will penetrate background），false（not penetration）
  ///
  /// 屏幕上交互事件可以穿透遮罩背景：true（交互事件能穿透背景，遮罩会自动变成透明），false（不能穿透）
  bool usePenetrate;

  /// the color of the mask，it is invalid if [usePenetrate] is true or [maskWidget] set the value
  ///
  /// 遮罩颜色：[usePenetrate]设置为true或[maskWidget]参数设置了数据，该参数会失效
  Color maskColor;

  /// highly customizable mask, it is invalid if [usePenetrate] is true
  ///
  /// 遮罩Widget，可高度自定义你自己的遮罩背景：[usePenetrate]设置为true，该参数失效
  Widget? maskWidget;

  /// true（dialog will be closed after click background），false（not close）
  ///
  /// true（点击遮罩关闭dialog），false（不关闭）
  bool clickMaskDismiss;

  /// leastLoadingTime: If this param is set to 1 second, dismiss() is called immediately after showLoading(),
  /// loading will not be closed immediately, but will be closed when the loading time reaches 1 second
  ///
  /// 最小加载时间: 如果该参数设置为1秒, showLoading()之后立马调用dismiss(), loading不会立马关闭, 会在加载时间达到1秒的时候关闭
  Duration leastLoadingTime;

  /// The type of dialog await ending
  ///
  /// 弹窗await结束的类型
  SmartAwaitOverType awaitOverType;

  /// When the mask is clicked, the trigger timing type (please refer to the [SmartMaskTriggerType] note for details)
  ///
  /// 点击遮罩时, 被触发时机的类型 (具体请查看[SmartMaskTriggerType]注释)
  SmartMaskTriggerType maskTriggerType;

  /// For different scenes, the pop-up animation can be dynamically closed.
  /// For details, please refer to [SmartNonAnimationType]
  ///
  /// 对于不同的场景, 可动态关闭弹窗动画, 具体请参照[SmartNonAnimationType]
  List<SmartNonAnimationType> nonAnimationTypes;

  /// For different processing types of return events,
  /// please refer to the description of [SmartBackType] for details
  ///
  /// 对于返回事件不同的处理类型, 具体可参照[SmartBackType]说明
  SmartBackType backType;

  /// whether loading(showLoading()) exist on the screen
  ///
  /// loading(showLoading())是否存在在界面上
  bool isExist;
}