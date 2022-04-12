import 'package:flutter_smart_dialog/src/compatible/smart_config_compatible.dart';
import 'package:flutter_smart_dialog/src/config/smart_config_custom.dart';
import 'package:flutter_smart_dialog/src/config/smart_config_loading.dart';
import 'package:flutter_smart_dialog/src/config/smart_config_toast.dart';

import 'smart_config_attach.dart';

/// Global configuration is unified here
///
/// 全局配置统一在此处处理
class SmartConfig {
  /// show(): custom dialog global config
  ///
  /// show(): custom dialog全局配置项
  SmartConfigCustom custom = SmartConfigCustom();

  /// showAttach(): attach dialog global config
  ///
  /// showAttach(): attach dialog全局配置项
  SmartConfigAttach attach = SmartConfigAttach();

  /// showLoading(): loading global config
  ///
  /// showLoading(): loading全局配置项
  SmartConfigLoading loading = SmartConfigLoading();

  /// showToast(): toast global config
  ///
  /// showToast(): toast全局配置项
  SmartConfigToast toast = SmartConfigToast();

  /// Compatible with older versions
  ///
  /// 兼容老版本配置
  SmartConfigCompatible compatible = SmartConfigCompatible();

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
