import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/widget/loading_widget.dart';
import 'package:flutter_smart_dialog/src/widget/toast_widget.dart';

import 'config/config.dart';
import 'widget/smart_dialog_view.dart';

class SmartDialog {
  ///SmartDialog相关配置,使用Config管理
  Config config;

  ///该控件是全局覆盖在app页面上的控件,该库dialog便是基于此实现;
  ///用户也可以用此控件自定义相关操作
  OverlayEntry overlayEntry;

  ///Toast之类应该是和Dialog之类区分开,且能独立存在,提供备用覆盖浮层
  OverlayEntry overlayEntryExtra;

  ///提供全局单例
  static SmartDialog get instance => _getInstance();

  ///提供新实例，获取的新实例可保存，eg：将loading类弹窗和常用交互弹窗区别开，可是使用此属性，
  ///获取全新的实例，所有类型的弹窗都使用唯一单例，可能会存在问题，例如关闭loading弹窗时，
  ///可能也会将自定义Toast关闭
  static SmartDialog get newInstance => SmartDialog._internal();

  ///-------------------------私有类型，不对面提供修改----------------------
  ///呈现的Widget
  Widget _widget;
  Widget _widgetExtra;
  GlobalKey<SmartDialogViewState> _key;
  GlobalKey<SmartDialogViewState> _keyExtra;
  static SmartDialog _instance;

  static SmartDialog _getInstance() {
    if (_instance == null) {
      _instance = SmartDialog._internal();
    }
    return _instance;
  }

  SmartDialog._internal() {
    ///初始化一些参数

    ///主体覆盖浮层
    overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return SmartDialog.instance._widget ?? Container();
      },
    );

    ///备用覆盖浮层
    overlayEntryExtra = OverlayEntry(
      builder: (BuildContext context) {
        return SmartDialog.instance._widgetExtra ?? Container();
      },
    );

    config = Config();
  }

  ///使用自定义布局
  ///
  /// 使用'Temp'为后缀的属性，在此处设置，并不会影响全局的属性，未设置‘Temp’为后缀的属性，
  /// 则默认使用Config设置的全局属性
  void show({
    @required Widget widget,
    AlignmentGeometry alignmentTemp,
    bool isPenetrateTemp,
    bool isUseAnimationTemp,
    Duration animationDurationTemp,
    bool isLoadingTemp,
    Color maskColorTemp,
    bool clickBgDismissTemp,
    //是否使用额外覆盖浮层,可与主浮层独立开
    bool isUseExtraWidget = false,
  }) {
    //展示弹窗
    var globalKey = GlobalKey<SmartDialogViewState>();
    Widget smartDialogView = SmartDialogView(
      key: globalKey,
      alignment: alignmentTemp ?? config.alignment,
      isPenetrate: isPenetrateTemp ?? config.isPenetrate,
      isUseAnimation: isUseAnimationTemp ?? config.isUseAnimation,
      animationDuration: animationDurationTemp ?? config.animationDuration,
      isLoading: isLoadingTemp ?? config.isLoading,
      maskColor: maskColorTemp ?? config.maskColor,
      clickBgDismiss: clickBgDismissTemp ?? config.clickBgDismiss,
      child: widget,
      onBgTap: () => dismiss(),
    );

    if (!isUseExtraWidget) {
      _widget = smartDialogView;
      config.isExist = true;
      _key = globalKey;
      _rebuild(buildType: 0);
    } else {
      _widgetExtra = smartDialogView;
      config.isExistExtra = true;
      _keyExtra = globalKey;
      _rebuild(buildType: 1);
    }
  }

  ///提供loading弹窗
  void showLoading({String msg = '加载中...'}) {
    show(
      widget: LoadingWidget(msg: msg),
      alignmentTemp: Alignment.center,
      isLoadingTemp: true,
    );
  }

  ///提供toast示例
  void showToast(
    String msg, {
    Duration time = const Duration(milliseconds: 1500),
    alignment: Alignment.bottomCenter,
  }) async {
    show(
      widget: ToastWidget(
        msg: msg,
        alignment: alignment,
      ),
      isPenetrateTemp: true,
      isUseExtraWidget: true,
    );

    await Future.delayed(time);
    dismiss(closeType: 1);
  }

  ///关闭Dialog
  ///
  /// closeType：关闭类型；0：仅关闭主体Overlay、1：仅关闭额外Overlay、2：俩者都关闭
  ///
  /// 如果不清楚使用,请查看showToast和showLoading
  Future<void> dismiss({int closeType = 0}) async {
    if (closeType == 0) {
      await _dismissBody();
    } else if (closeType == 1) {
      await _dismissExtra();
    } else if (closeType == 2) {
      await _dismissBody();
      await _dismissExtra();
    }

    _rebuild(buildType: closeType);
  }

  Future<void> _dismissBody() async {
    _widget = null;
    config.isExist = false;
    var state = _key?.currentState;
    await state?.dismiss();
  }

  Future<void> _dismissExtra() async {
    _widgetExtra = null;
    config.isExistExtra = false;
    var stateExtra = _keyExtra?.currentState;
    await stateExtra?.dismiss();
  }

  ///刷新重建，实际上是调用OverlayEntry中builder方法,重建布局
  ///
  /// buildType：刷新类型；0：仅刷新主体Overlay、1：仅刷新额外Overlay、2：俩者都刷新
  void _rebuild({int buildType}) {
    if (buildType == 0) {
      overlayEntry.markNeedsBuild();
    } else if (buildType == 1) {
      overlayEntryExtra.markNeedsBuild();
    } else if (buildType == 2) {
      overlayEntry.markNeedsBuild();
      overlayEntryExtra.markNeedsBuild();
    }
  }
}
