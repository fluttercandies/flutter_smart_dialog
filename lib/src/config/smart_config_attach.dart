import 'package:flutter/material.dart';

import 'enum_config.dart';

///showAttach() global config
///
///showAttach() 全局配置
class SmartConfigAttach {
  SmartConfigAttach({
    this.alignment = Alignment.bottomCenter,
    this.animationType = SmartAnimationType.centerScale_otherSlide,
    this.animationTime = const Duration(milliseconds: 260),
    this.useAnimation = true,
    this.usePenetrate = false,
    this.maskColor = const Color.fromRGBO(0, 0, 0, 0.35),
    this.maskWidget,
    this.clickMaskDismiss = true,
    this.debounce = false,
    this.debounceTime = const Duration(milliseconds: 300),
    this.backDismiss = true,
    this.bindPage = true,
    this.awaitOverType = SmartAwaitOverType.dialogDismiss,
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
  Widget? maskWidget;

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

  /// true（the back event will close the loading but not close the page），
  /// false（the back event not close the loading and not close page），
  /// you still can use the dismiss method to close the loading
  ///
  /// true（返回事件将关闭loading，但是不会关闭页面），false（返回事件不会关闭loading，也不会关闭页面），
  /// 你仍然可以使用dismiss方法来关闭dialog
  final bool backDismiss;

  /// Bind the dialog to the current page, the bound page is not on the top of the stack,
  /// the dialog is automatically hidden, the bound page is placed on the top of the stack, and the dialog is automatically displayed;
  /// the bound page is closed, and the dialog bound to the page will also be removed
  ///
  /// 将该dialog与当前页面绑定，绑定页面不在路由栈顶，dialog自动隐藏，绑定页面置于路由栈顶，dialog自动显示;
  /// 绑定页面被关闭,被绑定在该页面上的dialog也将被移除
  final bool bindPage;

  /// The type of dialog await ending
  ///
  /// 弹窗await结束的类型
  final SmartAwaitOverType awaitOverType;

  /// whether attach dialog(showAttach()) exist on the screen
  ///
  /// attach dialog(showAttach())，是否存在在界面上
  bool isExist;
}
