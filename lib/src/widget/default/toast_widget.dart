import 'package:flutter/material.dart';

import '../../kit/view_utils.dart';

/// A customizable toast-style notification widget that can be displayed either
/// horizontally or vertically, with support for leading and trailing widgets,
/// background color customization, text color, title styling, and flexible spacing.
class ToastWidget extends StatelessWidget {
  /// Constructs a [ToastWidget].
  ///
  /// This widget displays a notification message with optional title, icons,
  /// and customizable color and padding options.
  ///
  /// The [msg] parameter is required and provides the main message text.
  ///
  /// Additional parameters allow you to add a title, leading or trailing widget,
  /// customize colors, and control padding and spacing. Use [isHorizontal]
  /// to switch between horizontal and vertical layouts.
  const ToastWidget({
    Key? key,
    required this.msg,
    this.title,
    this.titleWidget,
    this.leadingWidget,
    this.trailingWidget,
    this.color,
    this.txtColor,
    this.txtStyle,
    this.margin,
    this.spaceAroundTxt = 8,
    this.padding,
    this.isHorizontal = true,
    this.titleStyle,
    this.borderRadius,
  }) : super(key: key);

  /// The title of the toast, displayed above the message if [titleWidget] is not provided.
  final String? title;

  /// Custom widget for the title, used instead of [title] if provided.
  final Widget? titleWidget;

  /// Widget displayed before the title and message, typically an icon.
  final Widget? leadingWidget;

  /// Widget displayed after the title and message, typically an icon or button.
  final Widget? trailingWidget;

  /// Background color of the toast container. Defaults to theme's background color.
  final Color? color;

  /// Text color for both title and message if [txtStyle] or [titleStyle] is not provided.
  final Color? txtColor;

  /// Text style for the message text.
  final TextStyle? txtStyle;

  /// Space between the title/message and the container edges.
  final EdgeInsets? margin;

  /// Padding inside the container around the title and message.
  final EdgeInsets? padding;

  /// Space between the title, message, and any leading or trailing widget.
  final double? spaceAroundTxt;

  /// If `true`, the layout is horizontal; otherwise, it is vertical.
  final bool isHorizontal;

  /// The main message displayed in the toast. This is a required parameter.
  final String msg;

  /// Text style for the title, allowing customization of font size, weight, etc.
  final TextStyle? titleStyle;

  /// Border radius for the toast container.
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      decoration: BoxDecoration(
        color: color ?? ThemeStyle.backgroundColor,
        borderRadius: borderRadius ?? BorderRadius.circular(20),
      ),
      child: isHorizontal
          ? _ToastContent(
              msg: msg,
              title: title,
              titleWidget: titleWidget,
              leadingWidget: leadingWidget,
              trailingWidget: trailingWidget,
              txtColor: txtColor,
              txtStyle: txtStyle,
              spaceAroundTxt: spaceAroundTxt,
              titleStyle: titleStyle,
              isHorizontal: true,
            )
          : _ToastContent(
              msg: msg,
              title: title,
              titleWidget: titleWidget,
              leadingWidget: leadingWidget,
              trailingWidget: trailingWidget,
              txtColor: txtColor,
              txtStyle: txtStyle,
              spaceAroundTxt: spaceAroundTxt,
              titleStyle: titleStyle,
              isHorizontal: false,
            ),
    );
  }
}

/// A flexible layout widget used internally by [ToastWidget] to layout content
/// either horizontally or vertically based on the [isHorizontal] flag.
class _ToastContent extends StatelessWidget {
  const _ToastContent({
    Key? key,
    required this.msg,
    this.title,
    this.titleWidget,
    this.leadingWidget,
    this.trailingWidget,
    this.txtColor,
    this.txtStyle,
    this.spaceAroundTxt,
    this.titleStyle,
    this.isHorizontal = true,
  }) : super(key: key);

  final String? title;
  final Widget? titleWidget, leadingWidget, trailingWidget;
  final Color? txtColor;
  final TextStyle? txtStyle;
  final double? spaceAroundTxt;
  final TextStyle? titleStyle;
  final String msg;
  final bool isHorizontal;

  @override
  Widget build(BuildContext context) {
    final spacing = SizedBox(width: isHorizontal ? spaceAroundTxt : 0, height: isHorizontal ? 0 : spaceAroundTxt);

    return Flex(
      direction: isHorizontal ? Axis.horizontal : Axis.vertical,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leadingWidget != null) leadingWidget!,
        if (leadingWidget != null) spacing,
        titleWidget ??
            (title != null
                ? Text(title!, style: titleStyle ?? TextStyle(color: txtColor ?? ThemeStyle.textColor, fontWeight: FontWeight.bold))
                : SizedBox.shrink()),
        if (title != null || titleWidget != null) spacing,
        Flexible(child: Text(msg, style: txtStyle ?? TextStyle(color: txtColor ?? ThemeStyle.textColor))),
        if (trailingWidget != null) spacing,
        if (trailingWidget != null) trailingWidget!,
      ],
    );
  }
}