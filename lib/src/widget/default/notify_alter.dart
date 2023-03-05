import 'package:flutter/material.dart';

class NotifyAlter extends StatelessWidget {
  const NotifyAlter({
    Key? key,
    required this.msg,
  }) : super(key: key);

  final String msg;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black,
      ),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.priority_high_outlined, size: 22, color: Colors.white),
        Container(
          margin: EdgeInsets.only(top: 5),
          child: Text(msg, style: TextStyle(color: Colors.white)),
        ),
      ]),
    );
  }
}
