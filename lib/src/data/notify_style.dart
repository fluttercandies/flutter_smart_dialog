import 'package:flutter/material.dart';

class FlutterSmartNotifyStyle {
  const FlutterSmartNotifyStyle({
    this.successBuilder,
    this.failureBuilder,
    this.warnBuilder,
    this.alertBuilder,
    this.errorBuilder,
  });

  final Widget Function(String msg)? successBuilder;
  final Widget Function(String msg)? failureBuilder;
  final Widget Function(String msg)? warnBuilder;
  final Widget Function(String msg)? alertBuilder;
  final Widget Function(String msg)? errorBuilder;
}
