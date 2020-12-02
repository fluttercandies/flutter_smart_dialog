import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/widget/loading_widget.dart';
import 'package:flutter_smart_dialog/src/widget/toast_widget.dart';

import 'widget/smart_dialog_view.dart';

class SmartDialog {
  ///内容控件方向
  AlignmentGeometry alignment = Alignment.center;

  ///是否穿透遮罩背景,交互遮罩之后控件，true：点击能穿透背景，false：不能穿透；
  ///穿透遮罩设置为true，背景遮罩会自动变成透明（必须）
  bool isPenetrate = false;

  ///点击遮罩，是否关闭dialog---true：点击遮罩关闭dialog，false：不关闭
  bool clickBgDismiss;

  ///遮罩颜色
  Color maskColor = Colors.black.withOpacity(0.3);

  ///动画时间
  Duration animationDuration = Duration(milliseconds: 260);

  ///是否使用动画
  bool isUseAnimation = true;

  ///是否使用Loading情况；true:内容体使用渐隐动画  false：内容体使用缩放动画
  ///仅仅针对中间位置的控件
  bool isLoading = true;

  ///SmartDialog是否存在在界面上
  bool isExit = false;

  ///该控件是全局覆盖在app页面上的控件,该库dialog便是基于此实现;
  ///用户也可以用此控件自定义相关操作
  OverlayEntry overlayEntry;

  ///提供全局单例
  static SmartDialog get instance => _getInstance();

  ///提供新实例，获取的新实例可保存，eg：将loading类弹窗和常用交互弹窗区别开，可是使用此属性，
  ///获取全新的实例，所有类型的弹窗都使用唯一单例，可能会存在问题，例如关闭loading弹窗时，
  ///可能也会将自定义Toast关闭
  static SmartDialog get newInstance => SmartDialog._internal();

  ///-------------------------私有类型，不对面提供修改----------------------
  ///呈现的Widget
  Widget _widget;
  GlobalKey<SmartDialogViewState> _key;
  static SmartDialog _instance;

  ///不允许自行创建实例
  SmartDialog._();

  static SmartDialog _getInstance() {
    if (_instance == null) {
      _instance = SmartDialog._internal();
    }
    return _instance;
  }

  SmartDialog._internal() {
    ///初始化一些参数
    overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return SmartDialog.instance._widget ?? Container();
      },
    );
  }

  ///使用自定义布局
  ///
  /// 使用'Temp'为后缀的属性，在此处设置，并不会影响全局的属性，未设置‘Temp’属性，
  /// 则默认使用全局设置的属性
  void show({
    @required Widget widget,
    AlignmentGeometry alignmentTemp,
    bool isPenetrateTemp,
    bool isUseAnimationTemp,
    Duration animationDurationTemp,
    bool isLoadingTemp,
    Color maskColorTemp,
  }) {
    //展示弹窗
    _key = GlobalKey<SmartDialogViewState>();
    _widget = SmartDialogView(
      key: _key,
      alignment: alignmentTemp ?? alignment,
      isPenetrate: isPenetrateTemp ?? isPenetrate,
      isUseAnimation: isUseAnimationTemp ?? isUseAnimation,
      animationDuration: animationDurationTemp ?? animationDuration,
      isLoading: isLoadingTemp ?? isLoading,
      maskColor: maskColorTemp ?? maskColor,
      child: widget,
      onBgTap: () => dismiss(),
    );

    isExit = true;
    _rebuild();
  }

  ///提供loading弹窗
  void showLoading({String msg = '加载中...'}) {
    show(widget: LoadingWidget());
  }

  ///提供toast示例
  void showToast({
    String msg = '',
    Duration time = const Duration(milliseconds: 1500),
  }) async {
    show(widget: ToastWidget());

    await Future.delayed(time);
    dismiss();
  }

  ///关闭动画
  Future<void> dismiss() async {
    _widget = null;
    isExit = false;

    SmartDialogViewState smartDialogViewState = _key?.currentState;
    await smartDialogViewState?.dismiss();

    _rebuild();
  }

  ///刷新重建，实际上是调用OverlayEntry中builder方法,重建布局
  void _rebuild() {
    overlayEntry.markNeedsBuild();
  }
}
