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

  /// Call toast continuously, the next toast will top off the previous toast
  ///
  /// 连续调用toast，后一条toast会顶掉前一条toast
  last,

  /// When the toast is called continuously, if the previous toast does not disappear,
  /// only the toast content is refreshed, and the toast will not be closed and reopened
  ///
  /// 连续调用toast时, 如果上一条toast未消失, 仅刷新toast内容, 并不会关闭toast重新打开
  onlyRefresh,

  /// Can display multi toasts at the same time
  ///
  /// 可同时显示多个toast
  multi,
}

/// Different animation types can be set for dialog (appearing and disappearing)
///
/// 可给弹窗(出现和消失)设置不同的动画类型
enum SmartAnimationType {
  /// FadeTransition for all positions
  ///
  /// 全部位置都为渐隐动画
  fade,

  /// All positions are ScaleTransition
  ///
  /// 全部位置都为缩放动画
  scale,

  /// The center position is the FadeTransition, and the other positions are the SlideTransition
  ///
  /// 中间位置的为渐隐动画, 其他位置为位移动画
  centerFade_otherSlide,

  /// The center position is the ScaleTransition, and the other positions are the SlideTransition
  ///
  /// 中间位置的为缩放, 其他位置为位移动画
  centerScale_otherSlide,
}

/// The type of dialog await ending
///
/// 弹窗await结束的类型
enum SmartAwaitOverType {
  /// The moment when the dialog is completely closed
  ///
  /// dialog完全关闭的时刻
  dialogDismiss,

  /// The moment when the dialog fully appears (when the start animation of the dialog appears)
  ///
  /// 弹窗完全出现时刻(弹窗出现的开始动画结束时)
  dialogAppear,

  /// await ends after 10 milliseconds
  ///
  /// await 10毫秒后结束
  none
}

/// The type of timing that is triggered when the mask is clicked
///
/// 点击遮罩时, 被触发时机的类型
enum SmartMaskTriggerType {
  /// Triggered when the mask is clicked (down gesture)
  ///
  /// 点击到遮罩时(down手势)触发
  down,

  /// Click to the mask, trigger when the move gesture (move gesture),
  /// if the move event is not triggered, it will be downgraded to the up event trigger
  ///
  /// 点击到遮罩, 移动手势时(move手势)触发, 如果move事件未触发, 将会降级到up事件触发
  move,

  /// Triggered when the mask is tapped and then raised (up gesture)
  ///
  /// 点击到遮罩, 然后抬起手势时(up手势)触发
  up
}

/// For different scenes, the pop-up animation can be dynamically closed.
///
/// 对于不同的场景, 可动态关闭弹窗动画
enum SmartNonAnimationType {
  /// Open dialog, no dialog start animation
  ///
  /// 打开dialog, 无弹窗开始动画
  openDialog_nonAnimation,

  /// All scenes close dialog, no dialog end animation
  ///
  /// 所有场景关闭弹窗, 无弹窗结束动画
  closeDialog_nonAnimation,

  /// Route the pop event to close the dialog, no dialog end animation
  ///
  /// 路由pop事件关闭弹窗, 无弹窗结束动画
  routeClose_nonAnimation,

  /// Click the mask event to close the dialog, no dialog end animation
  ///
  /// 点击遮罩事件关闭弹窗, 无弹窗结束动画
  maskClose_nonAnimation,

  /// Back event close the dialog, no dialog end animation
  ///
  /// 返回事件关闭弹窗, 无弹窗结束动画
  backClose_nonAnimation,

  /// When the attach dialog uses the highlight function, there is no start and end mask animation,
  /// use this property to solve the stroboscopic problem described below
  /// Note: ColorFiltered and FadeTransition animation components conflict, which will cause stroboscopic bugs,
  /// flutter2.10.5 and flutter3.3.5 can reproduce stably, flutter3.0.5 version does not have this problem
  ///
  /// attach dialog使用highlight功能时, 无开始和结束遮罩动画, 使用该属性可解决下述描述的频闪问题
  /// 注: ColorFiltered和FadeTransition动画组件冲突, 会造成频闪bug,
  /// flutter2.10.5和flutter3.3.5能稳定复现，flutter3.0.5版本则不存在这个问题
  highlightMask_nonAnimation,
}

/// The alignment effect when the attach dialog selects different alignment properties
///
/// attach dialog选择不同alignment属性时的对齐效果
enum SmartAttachAlignmentType {
  /// attach dialog align the inner edge of the goals control, note: Alignment.centerXxx is not affected, the center point is still aligned;
  /// Alignment.bottom Left/topLeft (the left edge of the dialog align goals control left edge),
  /// Alignment.bottom Right/topRight ((the right edge of the dialog align goals control right edge))
  ///
  /// attach dialog对齐目标控件内边缘, 注意: Alignment.centerXxx不受影响, 依旧是中心点对齐;
  /// Alignment.bottomLeft/topLeft(dialog左边边缘对齐目标控件左侧边缘), Alignment.bottomRight/topRight((dialog右边边缘对齐目标控件右侧边缘))
  inside,

  /// attach the center point of the dialog align goals control edge
  /// Alignment.bottom Left/topLeft (dialog center point align goals control left edge),
  /// Alignment.bottom Right/topRight (dialog center point align goals control right edge)
  ///
  /// attach dialog的中心点对齐目标控件边缘
  /// Alignment.bottomLeft/topLeft(dialog中心点对齐目标控件左侧边缘), Alignment.bottomRight/topRight(dialog中心点对齐目标控件右侧边缘)
  center,

  /// attach dialog align the outer edge of the goals control, note: Alignment.centerXxx is not affected, the center point is still aligned;
  /// Alignment.bottom Left/topLeft (the right edge of the dialog align goals control left edge),
  /// Alignment.bottom Right/topRight ((the left edge of the dialog align goals control right edge))
  ///
  /// attach dialog对齐目标控件外边缘, 注意: Alignment.centerXxx不受影响, 依旧是中心点对齐;
  /// Alignment.bottomLeft/topLeft(dialog右边边缘对齐目标控件左侧边缘), Alignment.bottomRight/topRight((dialog左边边缘对齐目标控件右侧边缘))
  outside,
}

/// The initialization type can be dynamically set, which is suitable for some special scenarios;
/// for example: for a desktop application, initializing the global only needs to initialize the Attach Dialog,
/// and initializing a block area does not need to initialize the Attach Dialog
///
/// 可动态设置初始化类型, 适用于一些特殊场景;
/// 例如: 某桌面端应用, 初始化全局只需要初始化Attach Dialog, 初始化某块区域不需要初始化Attach Dialog
enum SmartInitType {
  /// init CustomDialog (show)
  custom,

  /// init AttachDialog (showAttach)
  attach,

  /// init NotifyDialog (showNotify)
  notify,

  /// init Loading (showLoading)
  loading,

  /// init Toast (showToast)
  toast,
}
