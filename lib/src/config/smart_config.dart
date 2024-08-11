import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_smart_dialog/src/compatible/smart_config_compatible.dart';

import '../kit/dialog_kit.dart';

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

  /// showNotify(): notify dialog global config
  ///
  /// showNotify(): notify dialog全局配置项
  SmartConfigNotify notify = SmartConfigNotify();

  /// showLoading(): loading global config
  ///
  /// showLoading(): loading全局配置项
  SmartConfigLoading loading = SmartConfigLoading();

  /// showToast(): toast global config
  ///
  /// showToast(): toast全局配置项
  SmartConfigToast toast = SmartConfigToast();

  /// Check whether the relevant dialog exists on the interface,
  /// if the tag attribute is used, dialogTypes will be invalid
  ///
  /// 检查相关dialog是否存在于界面上，如果使用tag属性，dialogTypes将失效
  @Deprecated("please use SmartDialog.checkExist()")
  bool checkExist({
    String? tag,
    Set<SmartAllDialogType> dialogTypes = const {
      SmartAllDialogType.custom,
      SmartAllDialogType.attach,
      SmartAllDialogType.loading,
    },
  }) {
    return DialogKit.instance.checkExist(tag: tag, dialogTypes: dialogTypes);
  }

  /// Compatible with older versions
  ///
  /// 兼容老版本配置
  @Deprecated("5.0 will be deleted and is not recommended for continued use")
  SmartConfigCompatible compatible = SmartConfigCompatible();

  /// whether custom dialog，attach and loading  exist on the screen
  ///
  /// 自定义dialog，attach或loading，是否存在在界面上
  @Deprecated("Please use checkExist")
  bool get isExist => custom.isExist || attach.isExist || loading.isExist;

  /// whether custom dialog exist on the screen
  ///
  /// 自定义dialog或attach是否存在在界面上
  @Deprecated("Please use checkExist")
  bool get isExistDialog => custom.isExist || attach.isExist;

  /// whether loading exist on the screen
  ///
  /// loading是否存在界面上
  @Deprecated("Please use checkExist")
  bool get isExistLoading => loading.isExist;

  /// whether toast exist on the screen
  ///
  /// toast是否存在在界面上
  @Deprecated("Please use checkExist")
  bool get isExistToast => toast.isExist;
}
