import 'package:flutter/material.dart';

///控件配置统一在此处处理
class Config {
  /// 控制自定义控件位于屏幕的位置
  ///
  /// Alignment.center: 自定义控件位于屏幕中间，且是动画默认为：渐隐和缩放，可使用isLoading选择
  ///
  /// Alignment.bottomCenter、Alignment.bottomLeft、Alignment.bottomRight：自定义控件
  /// 位于屏幕底部，动画默认为位移动画，自下而上，可使用animationDuration设置动画时间
  ///
  /// Alignment.topCenter、Alignment.topLeft、Alignment.topRight：自定义控件位于屏幕顶部，
  /// 动画默认为位移动画，自上而下，可使用animationDuration设置动画时间
  ///
  /// Alignment.centerLeft：自定义控件位于屏幕左边，动画默认为位移动画，自左而右，
  /// 可使用animationDuration设置动画时间
  ///
  /// Alignment.centerRight：自定义控件位于屏幕左边，动画默认为位移动画，自右而左，
  /// 可使用animationDuration设置动画时间
  AlignmentGeometry alignment = Alignment.center;

  ///默认:false；是否穿透遮罩背景,交互遮罩之后控件，true：点击能穿透背景，false：不能穿透；
  ///穿透遮罩设置为true，背景遮罩会自动变成透明（必须）
  bool isPenetrate = false;

  ///默认：true；点击遮罩，是否关闭dialog---true：点击遮罩关闭dialog，false：不关闭
  bool clickBgDismiss = true;

  ///遮罩颜色
  Color maskColor = Colors.black.withOpacity(0.3);

  ///动画时间
  Duration animationDuration = Duration(milliseconds: 260);

  ///默认：true；是否使用动画
  bool isUseAnimation = true;

  ///默认：true；是否使用Loading动画；true:内容体使用渐隐动画  false：内容体使用缩放动画，
  ///仅仅针对中间位置的控件
  bool isLoading = true;

  ///默认：false；主体SmartDialog（OverlayEntry）是否存在在界面上
  bool isExist = false;

  ///默认：false；额外SmartDialog（OverlayEntry）是否存在在界面上
  bool isExistExtra = false;
}
