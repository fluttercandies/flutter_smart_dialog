import 'package:flutter/material.dart';

///控件配置统一在此处处理
class Config {
  ///内容控件方向
  AlignmentGeometry alignment = Alignment.center;

  ///是否穿透遮罩背景,交互遮罩之后控件，true：点击能穿透背景，false：不能穿透；
  ///穿透遮罩设置为true，背景遮罩会自动变成透明（必须）
  bool isPenetrate = false;

  ///点击遮罩，是否关闭dialog---true：点击遮罩关闭dialog，false：不关闭
  bool clickBgDismiss = false;

  ///遮罩颜色
  Color maskColor = Colors.black.withOpacity(0.3);

  ///动画时间
  Duration animationDuration = Duration(milliseconds: 260);

  ///是否使用动画
  bool isUseAnimation = true;

  ///是否使用Loading情况；true:内容体使用渐隐动画  false：内容体使用缩放动画
  ///仅仅针对中间位置的控件
  bool isLoading = true;

  ///主体SmartDialog是否存在在界面上
  bool isExist = false;

  ///额外SmartDialog是否存在界面
  bool isExistExtra = false;
}
