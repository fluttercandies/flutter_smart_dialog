import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ToastWidget extends StatelessWidget {
  ToastWidget({
    Key? key,
    required this.msg,
    this.alignment = Alignment.bottomCenter,
  }) : super(key: key);

  ///信息
  final String msg;

  ///toast显示位置
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 30, vertical: 50),
        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          msg,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
