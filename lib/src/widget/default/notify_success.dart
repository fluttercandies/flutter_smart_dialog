import 'package:flutter/material.dart';

class NotifySuccess extends StatelessWidget {
  const NotifySuccess({
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
        Icon(Icons.check, size: 22, color: Colors.white),
        Container(
          margin: EdgeInsets.only(top: 5),
          child: Text(msg, style: TextStyle(color: Colors.white)),
        ),
      ]),
    );
  }
}
