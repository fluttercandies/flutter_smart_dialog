import 'package:flutter/material.dart';

import 'enum_config.dart';

///showLoading() global config
///
///showLoading() 全局配置
class LoadingConfig {
  LoadingConfig({
    this.alignment = Alignment.center,
    this.animationType = SmartAnimationType.fade,
    this.animationTime = const Duration(milliseconds: 260),
    this.useAnimation = true,
    this.usePenetrate = false,
    this.maskColor = const Color.fromRGBO(0, 0, 0, 0.35),
    this.maskWidget,
    this.clickBgDismiss = false,
    this.isExist = false,
  });

  /// control the location of the dialog on the screen
  ///
  /// center: the dialog locate the center on the screen，The animation type can be set using [animationType]
  ///
  /// bottomCenter、bottomLeft、bottomRight：the dialog locate the bottom on the screen，
  /// animation effect is bottom-to-up
  ///
  /// topCenter、topLeft、Alignment.topRight：the dialog locate the top on the screen，
  /// animation effect is up-to-bottom
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
  /// topCenter、topLeft、Alignment.topRight：dialog位于屏幕顶部，
  ///
  /// centerLeft：dialog位于屏幕左边，动画默认为位移动画，自左而右，
  ///
  /// centerRight：dialog位于屏幕左边，动画默认为位移动画，自右而左，
  AlignmentGeometry alignment = Alignment.center;

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

  /// default（false），true（click event will penetrate background），false（not penetration）
  ///
  /// 屏幕上交互事件可以穿透遮罩背景（默认:false）：true（交互事件能穿透背景，遮罩会自动变成透明），false（不能穿透）
  bool usePenetrate;

  /// the color of the mask，it is invalid if [usePenetrate] is true or [maskWidget] set the value
  ///
  /// 遮罩颜色：[usePenetrate]设置为true或[maskWidget]参数设置了数据，该参数会失效
  Color maskColor;

  /// highly customizable mask, it is invalid if [usePenetrate] is true
  ///
  /// 遮罩Widget，可高度自定义你自己的遮罩背景：[usePenetrate]设置为true，该参数失效
  Widget? maskWidget;

  /// default（true），true（loading will be closed after click background），false（not close）
  ///
  /// 点击遮罩，是否关闭dialog（默认：true）：true（点击遮罩关闭dialog），false（不关闭）
  bool clickBgDismiss;

  /// whether loading(showLoading()) exist on the screen
  ///
  /// loading(showLoading())是否存在在界面上
  bool isExist;
}
