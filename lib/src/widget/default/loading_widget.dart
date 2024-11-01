import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/kit/view_utils.dart';

/// A customizable loading widget with a loading indicator, optional message,
/// and flexible color options for background, text, and loading animation.
class LoadingWidget extends StatelessWidget {
  /// Constructs a [LoadingWidget].
  ///
  /// This widget displays a loading indicator with an optional message. It allows
  /// customization of colors, spacing, loading indicator type, and layout direction.
  ///
  /// The [msg] parameter provides a loading message displayed beside or below the indicator,
  /// depending on the value of [isHorizontal]. The [spacer] defines the space
  /// between the loading indicator and message.
  /// [color] - Background color of the widget. Defaults to theme's background color.
  ///
  /// [txtColor] - Text color for the loading message. Defaults to theme's text color.
  ///
  /// [loadingColor] - Color of the loading indicator. Defaults to [txtColor] or theme's text color.
  ///
  /// [spacer] - Space between the loading indicator and message text. Default is 20.
  ///
  /// [loadingIndicator] - Custom loading indicator widget. Defaults to a [CircularProgressIndicator].
  ///
  /// [borderRadius] - Border radius for the container. Defaults to 15 if not specified.
  ///
  /// [msgStyle] - Text style for the message, allowing customization of font size, color, etc.
  ///
  /// [isHorizontal] - If `true`, the layout is horizontal; otherwise, it is vertical.
  ///
  /// [padding] - Dialog padding.

  const LoadingWidget({
    Key? key,
    this.msg,
    this.spacer = 20,
    this.loadingIndicator,
    this.color,
    this.txtColor,
    this.loadingColor,
    this.borderRadius,
    this.msgStyle,
    this.padding = const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
    this.isHorizontal = false,
  }) : super(key: key);

  /// The loading message displayed next to or below the loading indicator, if provided.
  final String? msg;

  /// Background color of the widget. Defaults to theme's background color.
  final Color? color;

  /// Text color for the loading message. Defaults to theme's text color.
  final Color? txtColor;

  /// Color of the loading indicator. Defaults to [txtColor] or theme's text color.
  final Color? loadingColor;

  /// Space between the loading indicator and message text. Default is 20.
  final double spacer;

  /// Custom loading indicator widget. Defaults to a [CircularProgressIndicator].
  final Widget? loadingIndicator;

  /// Border radius for the container. Defaults to 15 if not specified.
  final BorderRadius? borderRadius;

  /// Text style for the message, allowing customization of font size, color, etc.
  final TextStyle? msgStyle;

  /// If `true`, the layout is horizontal; otherwise, it is vertical.
  final bool isHorizontal;

  /// Dialog padding
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? ThemeStyle.backgroundColor,
        borderRadius: borderRadius ?? BorderRadius.circular(15),
      ),
      child: Flex(
        direction: isHorizontal ? Axis.horizontal : Axis.vertical,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Loading animation
          loadingIndicator ??
              CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation(loadingColor ?? txtColor ?? ThemeStyle.textColor),
              ),

          // Spacer between the loading indicator and message text
          if (msg != null) SizedBox(width: isHorizontal ? spacer : 0, height: isHorizontal ? 0 : spacer),

          // Message text
          if (msg != null)
            Text(
              msg!,
              style: msgStyle ?? TextStyle(color: txtColor ?? ThemeStyle.textColor),
            ),
        ],
      ),
    );
  }
}