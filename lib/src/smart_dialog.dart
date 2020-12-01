import 'package:flutter/material.dart';

import 'widget/smart_dialog_view.dart';

class SmartDialog {
  ///实现单例
  factory SmartDialog() => _getInstance();

  ///提供全局单例
  static SmartDialog get instance => _getInstance();

  ///提供新实例，获取的新实例可保存，eg：将loading类弹窗和常用交互弹窗区别开，可是使用此属性，
  ///获取全新的实例，所有类型的弹窗都使用唯一单例，可能会存在问题，例如关闭loading弹窗时，
  ///可能也会将自定义Toast关闭
  static SmartDialog get newInstance => SmartDialog._internal();
  static SmartDialog _instance;

  static SmartDialog _getInstance() {
    if (_instance == null) {
      _instance = SmartDialog._internal();
    }
    return _instance;
  }

  ///呈现的Widget
  Widget _widget;
  GlobalKey<SmartDialogViewState> _key;

  ///该控件是全局覆盖在app页面上的控件,该库dialog便是基于此实现;
  ///用户也可以用此控件自定义相关操作
  OverlayEntry overlayEntry;

  SmartDialog._internal() {
    ///初始化一些参数
    overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return SmartDialog.instance._widget ?? Container();
      },
    );
  }

  void show() {
    //展示弹窗
    _key = GlobalKey<SmartDialogViewState>();
    _widget = SmartDialogView(
      key: _key,
      alignment: Alignment.centerRight,
      isPenetrate: false,
      isUseAnimation: true,
      child: Container(
        height: 200,
        width: 500,
        color: Colors.deepOrange,
      ),
      onBgTap: () {
        dismiss();
      },
    );

    _rebuild();
  }

  ///关闭动画
  Future<void> dismiss() async {
    _widget = null;

    SmartDialogViewState smartDialogViewState = _key?.currentState;
    await smartDialogViewState?.dismiss();

    _rebuild();
  }

  ///刷新重建，实际上是调用OverlayEntry中builder方法,重建布局
  void _rebuild() {
    overlayEntry.markNeedsBuild();
  }
}
