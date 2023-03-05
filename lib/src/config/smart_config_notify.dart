import 'package:flutter/material.dart';

import 'enum_config.dart';

///show() global config
///
///show() 全局配置
class SmartConfigNotify {
  SmartConfigNotify({
    this.alignment = Alignment.center,
    this.animationType = SmartAnimationType.fade,
    this.animationTime = const Duration(milliseconds: 200),
    this.useAnimation = true,
    this.usePenetrate = true,
    this.maskColor = const Color.fromRGBO(0, 0, 0, 0.46),
    this.maskWidget,
    this.clickMaskDismiss = false,
    this.debounce = false,
    this.debounceTime = const Duration(milliseconds: 300),
    this.displayTime = const Duration(milliseconds: 2500),
    this.awaitOverType = SmartAwaitOverType.dialogDismiss,
    this.maskTriggerType = SmartMaskTriggerType.up,
    this.nonAnimationTypes = const [],
    this.backType = SmartBackType.ignore,
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

  /// true（use the animation），false（not use）
  ///
  /// true（使用动画），false（不使用）
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

  /// true（dialog will be closed after click background），false（not close）
  ///
  /// true（点击遮罩关闭dialog），false（不关闭）
  final bool clickMaskDismiss;

  /// debounce feature，it works on toast and dialog：default（false）;
  ///
  /// 防抖功能，它作用于toast和dialog上：默认（false）;
  final bool debounce;

  /// [debounceTime]：Within the debounce time, multiple clicks will only respond to the first time,
  /// and the second invalid click will trigger the debounce time to re-time.
  /// note: The definition of anti-shake is that the response will not be triggered again at the specified time,
  /// which will cause a delay in the click response, so the actual implementation needs to be adjusted a little.
  ///
  /// [debounceTime]：防抖时间内，多次点击只会响应第一次，第二次无效点击会触发防抖时间重新计时
  /// note: 防抖定义是在规定时间无二次触发才会响应,这样会导致点击响应有延时,所以实际实现做一点调整
  final Duration debounceTime;

  /// [displayTime]：Controls the display time of the dialog on the screen;
  /// the default is null, if it is null, it means that the param will not control the dialog to close;
  ///
  /// [displayTime]：控制弹窗在屏幕上显示时间; 默认为null, 为null则代表该参数不会控制弹窗关闭;
  final Duration? displayTime;

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

  /// For different processing types of return events,
  /// please refer to the description of [SmartBackType] for details
  ///
  /// 对于返回事件不同的处理类型, 具体可参照[SmartBackType]说明
  final SmartBackType backType;

  /// whether custom dialog(show()) exist on the screen
  ///
  /// 自定义dialog(show())，是否存在在界面上
  bool isExist;
}
