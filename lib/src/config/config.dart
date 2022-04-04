import 'package:flutter_smart_dialog/src/compatible/compatible_config.dart';
import 'package:flutter_smart_dialog/src/config/custom_config.dart';
import 'package:flutter_smart_dialog/src/config/loading_config.dart';
import 'package:flutter_smart_dialog/src/config/toast_config.dart';

import 'attach_config.dart';

/// Global configuration is unified here
///
/// 全局配置统一在此处处理
class Config {
  /// show(): custom dialog global config
  ///
  /// show(): custom dialog全局配置项
  CustomConfig custom = CustomConfig();

  /// showAttach(): attach dialog global config
  ///
  /// showAttach(): attach dialog全局配置项
  AttachConfig attach = AttachConfig();

  /// showLoading(): loading global config
  ///
  /// showLoading(): loading全局配置项
  LoadingConfig loading = LoadingConfig();

  /// showToast(): toast global config
  ///
  /// showToast(): toast全局配置项
  ToastConfig toast = ToastConfig();

  /// compatible with 3.x versions
  ///
  /// 兼容3.x版本配置
  CompatibleConfig compatible = CompatibleConfig();

  /// whether custom dialog，attach and loading  exist on the screen
  ///
  /// 自定义dialog，attach或loading，是否存在在界面上
  bool get isExist => custom.isExist || attach.isExist || loading.isExist;

  /// whether custom dialog exist on the screen
  ///
  /// 自定义dialog或attach是否存在在界面上
  bool get isExistDialog => custom.isExist || attach.isExist;

  /// whether loading exist on the screen
  ///
  /// loading是否存在界面上
  bool get isExistLoading => loading.isExist;

  /// whether toast exist on the screen
  ///
  /// toast是否存在在界面上
  bool get isExistToast => toast.isExist;
}
