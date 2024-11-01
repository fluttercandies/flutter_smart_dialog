import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/widget/default/toast_widget.dart';

import '../../kit/view_utils.dart';

/// A customizable notification alert that displays a message with an optional title,
/// icons, and configurable styling options, inheriting from [ToastWidget].
class NotifyAlert extends ToastWidget {
  /// Constructs a [NotifyAlert] with a priority icon, customizable message, and styling options.
  ///
  /// This widget allows full customization of the [ToastWidget] parameters, including
  /// layout direction, colors, padding, and border styling.
  NotifyAlert({
    Key? key,
    required String msg,
    String? title,
    Widget? titleWidget,
    Widget? trailingWidget,
    Color? color,
    Color? txtColor,
    TextStyle? txtStyle,
    EdgeInsets? margin,
    double? spaceAroundTxt,
    EdgeInsets? padding,
    bool isHorizontal = false,
    TextStyle? titleStyle,
    BorderRadius? borderRadius,
  }) : super(
          key: key,
          msg: msg,
          title: title,
          titleWidget: titleWidget,
          leadingWidget: Icon(
            Icons.priority_high_outlined,
            size: 22,
            color: txtColor ?? ThemeStyle.textColor,
          ),
          trailingWidget: trailingWidget,
          color: color,
          txtColor: txtColor,
          txtStyle: txtStyle,
          margin: margin,
          spaceAroundTxt: spaceAroundTxt,
          padding: padding,
          isHorizontal: isHorizontal,
          titleStyle: titleStyle,
          borderRadius: borderRadius,
        );
}

/// A customizable notification error that displays a message with an optional title,
/// icons, and configurable styling options, inheriting from [ToastWidget].
class NotifyError extends ToastWidget {
  /// Constructs a [NotifyError] with a priority icon, customizable message, and styling options.
  ///
  /// This widget allows full customization of the [ToastWidget] parameters, including
  /// layout direction, colors, padding, and border styling.
  NotifyError({
    Key? key,
    required String msg,
    String? title,
    Widget? titleWidget,
    Widget? trailingWidget,
    Color? color,
    Color? txtColor,
    TextStyle? txtStyle,
    EdgeInsets? margin,
    double? spaceAroundTxt,
    EdgeInsets? padding,
    bool isHorizontal = false,
    TextStyle? titleStyle,
    BorderRadius? borderRadius,
  }) : super(
          key: key,
          msg: msg,
          title: title,
          titleWidget: titleWidget,
          leadingWidget: Icon(
            Icons.error_outline,
            size: 22,
            color: txtColor ?? ThemeStyle.textColor,
          ),
          trailingWidget: trailingWidget,
          color: color,
          txtColor: txtColor,
          txtStyle: txtStyle,
          margin: margin,
          spaceAroundTxt: spaceAroundTxt,
          padding: padding,
          isHorizontal: isHorizontal,
          titleStyle: titleStyle,
          borderRadius: borderRadius,
        );
}

/// A customizable notification failure that displays a message with an optional title,
/// icons, and configurable styling options, inheriting from [ToastWidget].
class NotifyFailure extends ToastWidget {
  /// Constructs a [NotifyFailure] with a priority icon, customizable message, and styling options.
  ///
  /// This widget allows full customization of the [ToastWidget] parameters, including
  /// layout direction, colors, padding, and border styling.
  NotifyFailure({
    Key? key,
    required String msg,
    String? title,
    Widget? titleWidget,
    Widget? trailingWidget,
    Color? color,
    Color? txtColor,
    TextStyle? txtStyle,
    EdgeInsets? margin,
    double? spaceAroundTxt,
    EdgeInsets? padding,
    bool isHorizontal = false,
    TextStyle? titleStyle,
    BorderRadius? borderRadius,
  }) : super(
          key: key,
          msg: msg,
          title: title,
          titleWidget: titleWidget,
          leadingWidget: Icon(
            Icons.close,
            size: 22,
            color: txtColor ?? ThemeStyle.textColor,
          ),
          trailingWidget: trailingWidget,
          color: color,
          txtColor: txtColor,
          txtStyle: txtStyle,
          margin: margin,
          spaceAroundTxt: spaceAroundTxt,
          padding: padding,
          isHorizontal: isHorizontal,
          titleStyle: titleStyle,
          borderRadius: borderRadius,
        );
}

/// A customizable notification success that displays a message with an optional title,
/// icons, and configurable styling options, inheriting from [ToastWidget].
class NotifySuccess extends ToastWidget {
  /// Constructs a [NotifySuccess] with a priority icon, customizable message, and styling options.
  ///
  /// This widget allows full customization of the [ToastWidget] parameters, including
  /// layout direction, colors, padding, and border styling.
  NotifySuccess({
    Key? key,
    required String msg,
    String? title,
    Widget? titleWidget,
    Widget? trailingWidget,
    Color? color,
    Color? txtColor,
    TextStyle? txtStyle,
    EdgeInsets? margin,
    double? spaceAroundTxt,
    EdgeInsets? padding,
    bool isHorizontal = false,
    TextStyle? titleStyle,
    BorderRadius? borderRadius,
  }) : super(
          key: key,
          msg: msg,
          title: title,
          titleWidget: titleWidget,
          leadingWidget: Icon(
            Icons.check,
            size: 22,
            color: txtColor ?? ThemeStyle.textColor,
          ),
          trailingWidget: trailingWidget,
          color: color,
          txtColor: txtColor,
          txtStyle: txtStyle,
          margin: margin,
          spaceAroundTxt: spaceAroundTxt,
          padding: padding,
          isHorizontal: isHorizontal,
          titleStyle: titleStyle,
          borderRadius: borderRadius,
        );
}

/// A customizable notification warning that displays a message with an optional title,
/// icons, and configurable styling options, inheriting from [ToastWidget].
class NotifyWarning extends ToastWidget {
  /// Constructs a [NotifyWarning] with a priority icon, customizable message, and styling options.
  ///
  /// This widget allows full customization of the [ToastWidget] parameters, including
  /// layout direction, colors, padding, and border styling.
  NotifyWarning({
    Key? key,
    required String msg,
    String? title,
    Widget? titleWidget,
    Widget? trailingWidget,
    Color? color,
    Color? txtColor,
    TextStyle? txtStyle,
    EdgeInsets? margin,
    double? spaceAroundTxt,
    EdgeInsets? padding,
    bool isHorizontal = false,
    TextStyle? titleStyle,
    BorderRadius? borderRadius,
  }) : super(
          key: key,
          msg: msg,
          title: title,
          titleWidget: titleWidget,
          leadingWidget: Icon(
            Icons.warning_amber_outlined,
            size: 22,
            color: txtColor ?? ThemeStyle.textColor,
          ),
          trailingWidget: trailingWidget,
          color: color,
          txtColor: txtColor,
          txtStyle: txtStyle,
          margin: margin,
          spaceAroundTxt: spaceAroundTxt,
          padding: padding,
          isHorizontal: isHorizontal,
          titleStyle: titleStyle,
          borderRadius: borderRadius,
        );
}