import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/widget/default/toast_widget.dart';

import '../../flutter_smart_dialog.dart';
import '../widget/default/notify_widget.dart';

class FlutterSmartNotifyStyle {
  const FlutterSmartNotifyStyle({
    this.successBuilder,
    this.failureBuilder,
    this.warningBuilder,
    this.alertBuilder,
    this.errorBuilder,
  });

  final FlutterSmartToastBuilder? successBuilder;
  final FlutterSmartToastBuilder? failureBuilder;
  final FlutterSmartToastBuilder? warningBuilder;
  final FlutterSmartToastBuilder? alertBuilder;
  final FlutterSmartToastBuilder? errorBuilder;
}

FlutterSmartToastBuilder defaultToastBuilder = ({
  required String msg,
  String? title,
  Widget? titleWidget,
  Widget? leadingWidget,
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
}) =>
    ToastWidget(
      msg: msg,
      title: title,
      titleWidget: titleWidget,
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

FlutterSmartToastBuilder defaultSuccessBuilder = ({
  required String msg,
  String? title,
  Widget? titleWidget,
  Widget? leadingWidget,
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
}) =>
    NotifySuccess(
      msg: msg,
      title: title,
      titleWidget: titleWidget,
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

FlutterSmartToastBuilder defaultFailureBuilder = ({
  required String msg,
  String? title,
  Widget? titleWidget,
  Widget? leadingWidget,
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
}) =>
    NotifyFailure(
      msg: msg,
      title: title,
      titleWidget: titleWidget,
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

FlutterSmartToastBuilder defaultWarningBuilder = ({
  required String msg,
  String? title,
  Widget? titleWidget,
  Widget? leadingWidget,
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
}) =>
    NotifyWarning(
      msg: msg,
      title: title,
      titleWidget: titleWidget,
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

FlutterSmartToastBuilder defaultAlertBuilder = ({
  required String msg,
  String? title,
  Widget? titleWidget,
  Widget? leadingWidget,
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
}) =>
    NotifyAlert(
      msg: msg,
      title: title,
      titleWidget: titleWidget,
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

FlutterSmartToastBuilder defaultErrorBuilder = ({
  required String msg,
  String? title,
  Widget? titleWidget,
  Widget? leadingWidget,
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
}) =>
    NotifyError(
      msg: msg,
      title: title,
      titleWidget: titleWidget,
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