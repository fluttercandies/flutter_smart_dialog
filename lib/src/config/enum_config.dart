enum SmartStatus {
  /// close single dialog：loading（showToast），custom（show）or attach（showAttach）
  ///
  /// 关闭单个dialog：loading（showLoading），custom（show）或 attach（showAttach）
  smart,

  /// close toast（showToast）
  ///
  /// 关闭toast（showToast）
  toast,

  /// close all toasts（showToast）
  ///
  /// 关闭所有toast（showToast）
  allToast,

  /// close loading（showLoading）
  ///
  /// 关闭loading（showLoading）
  loading,

  /// close single custom dialog（show）
  ///
  /// 关闭单个custom dialog（show）
  custom,

  /// close single attach dialog（showAttach）
  ///
  /// 关闭单个attach dialog（showAttach）
  attach,

  /// close single dialog（attach or custom）
  ///
  /// 关闭单个dialog（attach或custom）
  dialog,

  /// close all custom dialog, but not close toast,loading and attach dialog
  ///
  /// 关闭打开的所有custom dialog，但是不关闭toast，loading和attach dialog
  allCustom,

  /// close all attach dialog, but not close toast,loading and custom dialog
  ///
  /// 关闭打开的所有attach dialog，但是不关闭toast，loading和custom dialog
  allAttach,

  /// close all dialog（attach and custom）, but not close toast and loading
  ///
  /// 关闭打开的所有dialog（attach和custom），但是不关闭toast和loading
  allDialog,
}

enum SmartToastType {
  /// Each toast will be displayed, after the current toast disappears，
  /// the next toast will be displayed
  ///
  /// 每一条toast都会显示，当前toast消失之后，后一条toast才会显示
  normal,

  /// Call toast continuously, during the period when the first toast exists on the screen,
  /// other toasts called will be invalid
  ///
  /// 连续调用toast，在第一条toast存在界面的期间内，调用的其它toast都将无效
  first,

  /// Call toast continuously, the next toast will top off the previous toast
  ///
  /// 连续调用toast，后一条toast会顶掉前一条toast
  last,

  /// Call toast continuously, the first toast is displayed normally，
  /// and all toasts generated during the first toast display period，only the last toast is valid
  ///
  /// 连续调用toast，第一条toast正常显示，其显示期间产生的所有toast，仅最后一条toast有效
  firstAndLast,
}

/// Different animation types can be set for dialog (appearing and disappearing)
///
/// 可给弹窗(出现和消失)设置不同的动画类型
enum SmartAnimationType {
  /// FadeTransition
  ///
  /// 渐隐动画
  fade,

  /// SizeTransition
  ///
  /// 缩放动画
  scale,

  /// 中间位置的为渐隐动画, 其他位置为位移缩放动画
  centerFadeAndOtherScale
}

/// The type of dialog await ending
///
/// 弹窗await结束的类型
enum SmartAwaitOverType {
  /// The moment when the dialog is completely closed
  ///
  /// dialog完全关闭的时刻
  dialogDismiss,

  /// The moment when the pop-up window fully appears (when the start animation of the dialog appears)
  ///
  /// 弹窗完全出现时刻(弹窗出现的开始动画结束时)
  dialogAppear,

  /// await ends after 10 milliseconds
  ///
  /// await 10毫秒后结束
  none
}
